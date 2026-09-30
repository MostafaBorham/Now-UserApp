import 'dart:io';
import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/unprimary_gradient_app_button.dart';
import 'package:nowdelivery_user_app/features/address/data/datasources/local/current_location_cache_service.dart';
import 'package:nowdelivery_user_app/features/address/data/models/address_model.dart';
import 'package:nowdelivery_user_app/features/home/data/models/home_section_model.dart';
import 'package:nowdelivery_user_app/features/home/presentation/screens/home_view.dart';
import 'package:nowdelivery_user_app/features/home/presentation/widgets/new_home/home_featured_stores_view.dart';
import 'package:nowdelivery_user_app/features/home/viewmodel/get_home_sections_vm.dart';
import 'package:nowdelivery_user_app/main.dart' as app;

/// Home's frame-time benchmark: the same scripted scenarios on every build, so
/// a change is judged on numbers rather than on how a hand scroll felt.
///
/// Run it on a real device, in profile mode, once per build being compared:
///
///     PERF_LABEL=<label> flutter drive --profile --no-dds --keep-app-running \
///       --driver=test_driver/perf_driver.dart \
///       --target=integration_test/home_perf_test.dart -d <device>
///
/// `--no-dds`, because `watchPerformance` opens its own VM service connection,
/// which fails behind DDS. `--keep-app-running`, because otherwise `flutter
/// drive` uninstalls the app afterwards — and with it the session and the
/// location grant the next run needs.
///
/// Each scenario's summary (average / p90 / p99 / worst build and raster
/// times, missed-budget counts, frame count) lands in
/// `build/perf/<label>/<scenario>.json`, next to `app_animation_frame_count`
/// (see [_AnimationFrames]). The app launches as it does for a
/// user: an existing session goes straight to Home, otherwise the test
/// continues as a guest. Grant the location prompt by hand before the first
/// run — a native dialog cannot be tapped from here.
///
/// Only types that predate the Tier 1 performance work are used, so the same
/// file measures older commits too.
void main() {
  final IntegrationTestWidgetsFlutterBinding binding =
      IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  // Draw every frame the app asks for, as it runs for real. The default only
  // draws the frames a test pumps, so the app's own animations — every
  // carousel, every scroll below — would never advance.
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;
  final _AnimationFrames animationFrames = _AnimationFrames(binding);

  Future<void> watch(String reportKey, Future<void> Function() action) async {
    await binding.watchPerformance(() async {
      animationFrames.start();
      await action();
      animationFrames.stop();
    }, reportKey: reportKey);
    (binding.reportData![reportKey]
            as Map<String, dynamic>)['app_animation_frame_count'] =
        animationFrames.count;
  }

  testWidgets('home performance', (WidgetTester tester) async {
    final FlutterExceptionHandler? reportToTest = FlutterError.onError;
    app.main();
    // The app installs a handler that only logs, which would let a failing
    // run report success.
    FlutterError.onError = reportToTest;

    final Finder home = find.byType(HomeView);
    final Finder guest = find.byType(UnPrimaryGradientAppButton);
    await _pumpUntil(tester, () => _found(home) || _found(guest));
    if (!_found(home)) {
      await tester.tap(guest);
      await _pumpUntil(tester, () => _found(home));
    }

    final ProviderContainer container = ProviderScope.containerOf(
      tester.element(home),
    );
    await _pumpUntil(
      tester,
      () => container.read(getHomeSectionsProvider).hasValue,
    );
    // Let the header's 12 s intro finish, so idle means idle.
    await _wait(const Duration(seconds: 15));

    final ScrollPosition feed = tester
        .state<ScrollableState>(
          find.descendant(of: home, matching: find.byType(Scrollable)).first,
        )
        .position;

    _step('idle_top');
    await watch('idle_top', () async {
      await _wait(const Duration(seconds: 10));
      await tester.pump();
    });

    _step('scroll');
    await watch('scroll', () async {
      await _scrollToBottom(feed);
      await _scrollToTop(feed);
      await tester.pump();
    });

    _step('categories_swipe');
    await watch('categories_swipe', () async {
      final Finder carousel = find
          .descendant(of: home, matching: find.byType(PageView))
          .first;
      for (int i = 0; i < 3; i++) {
        await tester.fling(carousel, const Offset(-300, 0), 1500);
        await _wait(const Duration(seconds: 1));
      }
      await tester.pump();
    });

    // After the full scroll, so every section that stays alive is alive: the
    // worst case for a rebuild of the whole feed.
    final List<HomeSectionModel> sections = container
        .read(getHomeSectionsProvider)
        .requireValue;
    final ProductModel? product = sections
        .expand((HomeSectionModel section) => section.products)
        .firstOrNull;
    final GetHomeSectionsViewModel viewModel = container.read(
      getHomeSectionsProvider.notifier,
    );
    if (product != null) {
      final bool isFavourite = product.isFavorite ?? false;
      _step('favourite_rebuild');
      await watch('favourite_rebuild', () async {
        // The view model's own write-back, so no favourite reaches the server.
        viewModel.updateProductFavourite(product.id, !isFavourite);
        await _wait(const Duration(milliseconds: 500));
        viewModel.updateProductFavourite(product.id, isFavourite);
        await _wait(const Duration(milliseconds: 500));
        await tester.pump();
      });
    }

    _step('feed_reload');
    await watch('feed_reload', () async {
      // What pull-to-refresh runs, called directly so no gesture can miss.
      final AddressModel? location = CurrentLocationCacheService()
          .getCurrentLocation();
      await viewModel.getHomeSections(
        platform: Platform.isIOS ? 'ios' : 'android',
        lang: tester.element(home).locale.languageCode,
        lat: double.tryParse(location?.latitude ?? ''),
        lng: double.tryParse(location?.longitude ?? ''),
      );
      await _wait(const Duration(seconds: 1));
      await tester.pump();
    });

    final Finder featuredStores = find.byType(HomeFeaturedStoresView);
    for (int i = 0; i < 20 && !_found(featuredStores); i++) {
      await feed.animateTo(
        math.min(feed.pixels + 400, feed.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.linear,
      );
    }
    if (_found(featuredStores)) {
      await Scrollable.ensureVisible(
        tester.element(featuredStores),
        duration: const Duration(milliseconds: 300),
      );
      _step('idle_mid');
      await watch('idle_mid', () async {
        await _wait(const Duration(seconds: 10));
        await tester.pump();
      });
    }
  });
}

/// Counts the frames in which an app ticker ran: an animation, a carousel
/// slide, a scroll animation.
///
/// `frame_count` can't say that. Under
/// [LiveTestWidgetsFlutterBindingFramePolicy.fullyLive] the binding asks for a
/// new frame after every frame it draws, so it renders every vsync on its own:
/// a static screen reads ~600 frames in 10 s at 60 Hz. A one-off rebuild with
/// no ticker (the favourite flip's own frame) is not counted.
class _AnimationFrames {
  _AnimationFrames(SchedulerBinding binding) : _binding = binding {
    binding.addPersistentFrameCallback(_onFrame);
  }

  final SchedulerBinding _binding;
  bool _counting = false;
  bool _bookedByLastFrame = false;
  int count = 0;

  void start() {
    count = 0;
    _counting = true;
  }

  void stop() => _counting = false;

  // Runs inside frames that happen anyway, so it asks for none. A ticker ran
  // in this frame if one was booked going into it, or one started since the
  // last frame and is still booked coming out of it.
  void _onFrame(Duration _) {
    final bool booked = _binding.transientCallbackCount > 0;
    if (_counting && (_bookedByLastFrame || booked)) count++;
    _bookedByLastFrame = booked;
  }
}

void _step(String scenario) => debugPrint('home_perf: $scenario');

bool _found(Finder finder) => finder.evaluate().isNotEmpty;

Future<void> _wait(Duration duration) => Future<void>.delayed(duration);

/// Home never settles (carousels, the flash strip), so `pumpAndSettle` would
/// time out; poll instead.
Future<void> _pumpUntil(
  WidgetTester tester,
  bool Function() done, {
  Duration timeout = const Duration(seconds: 90),
}) async {
  final Stopwatch clock = Stopwatch()..start();
  while (!done()) {
    if (clock.elapsed > timeout) {
      throw TestFailure('Home did not load within $timeout');
    }
    await _wait(const Duration(milliseconds: 200));
    await tester.pump();
  }
}

/// 2000 px a second — a brisk fling — until the lazily built feed stops
/// growing. Capped, in case a section pages in more content without end.
Future<void> _scrollToBottom(ScrollPosition position) async {
  for (int i = 0; i < 30 && position.pixels < position.maxScrollExtent; i++) {
    await position.animateTo(
      math.min(position.pixels + 2000, position.maxScrollExtent),
      duration: const Duration(seconds: 1),
      curve: Curves.linear,
    );
  }
}

Future<void> _scrollToTop(ScrollPosition position) async {
  while (position.pixels > 0) {
    await position.animateTo(
      math.max(position.pixels - 2000, 0),
      duration: const Duration(seconds: 1),
      curve: Curves.linear,
    );
  }
}
