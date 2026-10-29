import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:nowdelivery_user_app/core/enums/order_status.dart';
import 'package:nowdelivery_user_app/core/errors/failures/failure.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/localization/local_controller.dart';
import 'package:nowdelivery_user_app/features/orders/data/models/order_model.dart';
import 'package:nowdelivery_user_app/features/orders/data/repo/orders_repo.dart';
import 'package:nowdelivery_user_app/features/orders/presentation/extensions/live_order_progress.dart';

/// The live-order card in the Android notification tray (Figma "Order Track
/// Card - Horizontal"), one per in-flight order; tapping it opens Track Order.
///
/// The app is the card's only source: [sync] runs on every home live-orders
/// poll, so the card moves only while the app is open and stands still in the
/// tray once it is closed (there is no push yet). `OrderTrackingNotifications.kt`
/// only draws what it is sent. Android only: on iOS a card like this would be
/// a Live Activity.
abstract final class OrderTrackingNotification {
  static const MethodChannel _channel = MethodChannel(
    'nowdelivery/order_tracking',
  );

  /// Off where there is nothing to draw on: iOS, and tests unless they say so.
  @visibleForTesting
  static bool enabled = Platform.isAndroid;

  /// What each card was last drawn with, so a poll that changed nothing does
  /// not redraw it.
  static final Map<String, String> _drawn = <String, String>{};
  static final Map<String, Uint8List> _logos = <String, Uint8List>{};
  static bool _syncing = false;
  static bool _askedPermission = false;

  /// Brings the tray in line with [live], the signed-in user's in-flight
  /// orders: a card per order, redrawn when its stage or estimate moves. A card
  /// whose order has left the list is finished: completed and swipeable when
  /// delivered, removed otherwise (cancelled, rejected). [fetchOrder] is for
  /// tests.
  static Future<void> sync(
    BuildContext context,
    List<OrderModel> live, {
    Future<Either<Failure, OrderModel>> Function(String uuid)? fetchOrder,
  }) async {
    if (!enabled || _syncing) return;
    _syncing = true;
    try {
      if (live.isNotEmpty && !_askedPermission) {
        _askedPermission = true;
        // Android 13+ hides the card until notifications are allowed. Asked
        // once a run, when there is first something to show.
        await _channel.invokeMethod<void>('requestPermission');
      }
      final Set<String> onTray = <String>{
        ...?await _channel.invokeListMethod<String>('active'),
      };

      for (final OrderModel order in live) {
        if (!context.mounted) return;
        if (order.uuid?.isEmpty ?? true) continue;
        await _draw(
          context,
          order,
          onTray: onTray.contains(order.uuid),
        );
      }

      final Set<String> liveIds = <String>{
        for (final OrderModel order in live) order.uuid ?? '',
      };
      for (final String uuid in onTray.difference(liveIds)) {
        final Either<Failure, OrderModel> result =
            await (fetchOrder ?? _fetchOrder)(uuid);
        if (!context.mounted) return;
        await result.fold(
          // Offline or failed: the card waits for the next poll.
          (Failure _) async {},
          (OrderModel order) => order.lifecycleStatus is DeliveredStatus
              ? _draw(context, order, onTray: true)
              : _cancel(uuid),
        );
      }
    } finally {
      _syncing = false;
    }
  }

  static Future<Either<Failure, OrderModel>> _fetchOrder(String uuid) =>
      OrdersRepo().getOrderDetails(orderUuid: uuid);

  static Future<void> _draw(
    BuildContext context,
    OrderModel order, {
    required bool onTray,
  }) async {
    final String uuid = order.uuid!;
    final OrderStatus status = order.lifecycleStatus;
    final int? minutes = minutesUntil(order.estimatedDeliveryTime);
    final Map<String, Object?> card = <String, Object?>{
      'uuid': uuid,
      'rtl': context.isRTL,
      'channelName': LangKeys.trackOrderKey.tr(),
      // Figma's estimate when the order has one. Customer checkout never sets
      // it, so usually the store and where the order is instead.
      'title': minutes == null
          ? context.getLocalizedApiText(order.vendor.name)
          : LangKeys.estimatedDeliveryTimeKey.tr(),
      'subtitle': minutes == null
          ? context.getLocalizedApiText(order.orderStatus)
          : '$minutes ${LangKeys.minutesKey.tr()}',
      'labels': <String>[for (final String key in liveOrderStepKeys) key.tr()],
      'steps': <String>[
        for (int i = 0; i < liveOrderStepKeys.length; i++)
          status.stepStatusAt(i).name,
      ],
      'ongoing': status is! DeliveredStatus,
    };
    final String? logoUrl = order.vendor.logoUrl;
    final String drawn = '$card $logoUrl';
    if (onTray && _drawn[uuid] == drawn) return;

    final Uint8List? logo = await _logo(logoUrl);
    await _channel.invokeMethod<void>('show', <String, Object?>{
      ...card,
      'logo': logo,
    });
    // A logo that failed to load is tried again on the next poll.
    if (logo != null || (logoUrl?.isEmpty ?? true)) _drawn[uuid] = drawn;
  }

  /// The store's logo, fetched once a run; `null` (the card goes without) when
  /// there is none or it cannot be loaded.
  static Future<Uint8List?> _logo(String? url) async {
    if (url == null || url.isEmpty) return null;
    final Uint8List? cached = _logos[url];
    if (cached != null) return cached;
    try {
      final ByteData data = await NetworkAssetBundle(Uri.parse(url)).load(url);
      return _logos[url] = data.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }

  static Future<void> _cancel(String uuid) {
    _drawn.remove(uuid);
    return _channel.invokeMethod<void>('cancel', uuid);
  }

  /// Clears every card: the outgoing user's orders must not outlive a logout.
  static Future<void> cancelAll() async {
    _drawn.clear();
    if (enabled) await _channel.invokeMethod<void>('cancelAll');
  }

  /// The order whose card was tapped to bring the app up, handed over once;
  /// `null` when the app came up any other way.
  static Future<String?> takeTappedOrder() async =>
      enabled ? _channel.invokeMethod<String>('takeTapped') : null;
}
