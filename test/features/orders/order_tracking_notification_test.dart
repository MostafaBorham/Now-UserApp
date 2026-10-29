import 'package:dartz/dartz.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/localization/constants.dart';
import 'package:nowdelivery_user_app/features/orders/data/models/order_model.dart';
import 'package:nowdelivery_user_app/features/orders/presentation/notifications/order_tracking_notification.dart';

import '../../helpers/categories_test_harness.dart';

class _KeyLoader extends AssetLoader {
  const _KeyLoader();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async =>
      <String, dynamic>{};
}

OrderModel _order(String uuid, String status) => OrderModel.fromJson(
  <String, dynamic>{
    'uuid': uuid,
    'status': status,
    'order_status': <String, dynamic>{'en': 'Preparing', 'ar': 'جاري التجهيز'},
    'vendor': <String, dynamic>{
      'name': <String, dynamic>{'en': 'KFC', 'ar': 'كنتاكي'},
    },
  },
);

/// An Arabic [BuildContext], the card's main language.
Future<BuildContext> _arabicContext(WidgetTester tester) async {
  late BuildContext captured;
  await tester.pumpWidget(
    EasyLocalization(
      supportedLocales: LocalizationConstants.supportedLocales,
      path: LocalizationConstants.languagesPath,
      startLocale: LocalizationConstants.arabicLocale,
      assetLoader: const _KeyLoader(),
      child: Builder(
        builder: (BuildContext context) => MaterialApp(
          locale: context.locale,
          supportedLocales: context.supportedLocales,
          localizationsDelegates: context.localizationDelegates,
          home: Builder(
            builder: (BuildContext context) {
              captured = context;
              return const SizedBox();
            },
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump();
  return captured;
}

void main() {
  setUpAll(initCategoriesTestLocalization);

  const MethodChannel channel = MethodChannel('nowdelivery/order_tracking');
  final List<MethodCall> calls = <MethodCall>[];
  List<String> onTray = <String>[];

  List<MethodCall> callsTo(String method) =>
      calls.where((MethodCall c) => c.method == method).toList();

  setUp(() async {
    OrderTrackingNotification.enabled = true;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
          calls.add(call);
          return call.method == 'active' ? onTray : null;
        });
    await OrderTrackingNotification.cancelAll();
    calls.clear();
    onTray = <String>[];
  });

  tearDown(() {
    OrderTrackingNotification.enabled = false;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  testWidgets('draws a live order once, with its stage, and again only when '
      'it moves', (WidgetTester tester) async {
    final BuildContext context = await _arabicContext(tester);

    await OrderTrackingNotification.sync(context, <OrderModel>[
      _order('a', 'preparing'),
    ]);

    final List<MethodCall> shows = callsTo('show');
    expect(shows, hasLength(1));
    final Map<Object?, Object?> card =
        shows.single.arguments as Map<Object?, Object?>;
    expect(card['uuid'], 'a');
    expect(card['rtl'], isTrue);
    // No estimate on the order: the store and its stage instead.
    expect(card['title'], 'كنتاكي');
    expect(card['subtitle'], 'جاري التجهيز');
    expect(card['steps'], <String>['done', 'current', 'pending', 'pending']);
    expect(card['ongoing'], isTrue);

    // The next poll, unchanged, with the card on the tray: nothing redrawn.
    onTray = <String>['a'];
    await OrderTrackingNotification.sync(context, <OrderModel>[
      _order('a', 'preparing'),
    ]);
    expect(callsTo('show'), hasLength(1));

    // On the way: redrawn.
    await OrderTrackingNotification.sync(context, <OrderModel>[
      _order('a', 'on_the_way'),
    ]);
    expect(callsTo('show'), hasLength(2));
    expect(
      (callsTo('show').last.arguments as Map<Object?, Object?>)['steps'],
      <String>['done', 'done', 'done', 'current'],
    );
  });

  testWidgets('a card whose order left the list completes when delivered and '
      'goes when cancelled', (WidgetTester tester) async {
    final BuildContext context = await _arabicContext(tester);
    onTray = <String>['delivered-one', 'cancelled-one', 'offline-one'];

    await OrderTrackingNotification.sync(
      context,
      const <OrderModel>[],
      fetchOrder: (String uuid) async => switch (uuid) {
        'delivered-one' => Right<Failure, OrderModel>(
          _order(uuid, 'delivered'),
        ),
        'cancelled-one' => Right<Failure, OrderModel>(
          _order(uuid, 'cancelled'),
        ),
        _ => const Left<Failure, OrderModel>(Failure('offline')),
      },
    );

    final Map<Object?, Object?> delivered =
        callsTo('show').single.arguments as Map<Object?, Object?>;
    expect(delivered['uuid'], 'delivered-one');
    expect(delivered['steps'], <String>['done', 'done', 'done', 'done']);
    expect(delivered['ongoing'], isFalse);
    expect(
      callsTo('cancel').map((MethodCall c) => c.arguments),
      <Object?>['cancelled-one'],
    );
  });
}
