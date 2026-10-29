package com.nowdelivery.user.nowdelivery_user_app

import android.Manifest
import android.app.Activity
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.BitmapShader
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.Shader
import android.os.Build
import android.view.View
import android.widget.RemoteViews
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Draws the live-order card in the notification tray (Figma "Order Track Card - Horizontal"),
 * one per order, tagged with the order's uuid. Dart (`order_tracking_notification.dart`)
 * decides what each card says and when it changes; this only renders it.
 */
class OrderTrackingNotifications(private val activity: Activity) : MethodChannel.MethodCallHandler {

    private val manager = activity.getSystemService(NotificationManager::class.java)

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        // Notification channels arrived in Android 8; Android 7 goes without the card.
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return result.success(null)
        when (call.method) {
            "show" -> show(call.arguments()!!)
            "cancel" -> manager.cancel(call.arguments<String>(), ID)
            "cancelAll" -> manager.cancelAll()
            // The cards still in progress; a finished (delivered) one is left to the user.
            "active" -> return result.success(
                manager.activeNotifications.filter { it.id == ID && it.isOngoing }.map { it.tag },
            )
            "requestPermission" -> requestPermission()
            "takeTapped" -> return result.success(takeTapped())
            else -> return result.notImplemented()
        }
        result.success(null)
    }

    private fun show(card: Map<String, Any?>) {
        val uuid = card["uuid"] as String
        val ongoing = card["ongoing"] as Boolean
        // Creating an existing channel again only renames it, so a language switch carries over.
        manager.createNotificationChannel(
            NotificationChannel(CHANNEL, card["channelName"] as String, NotificationManager.IMPORTANCE_LOW),
        )
        val logo = (card["logo"] as ByteArray?)?.let(::circleCrop)
        val builder = Notification.Builder(activity, CHANNEL)
            .setSmallIcon(R.drawable.ic_stat_order)
            .setColor(PRIMARY)
            // Plain text for whatever cannot show the card (watches, screen readers).
            .setContentTitle(card["subtitle"] as String)
            .setContentText(card["title"] as String)
            .setStyle(Notification.DecoratedCustomViewStyle())
            .setCustomContentView(views(R.layout.order_card_collapsed, card, logo))
            .setCustomBigContentView(views(R.layout.order_card_expanded, card, logo))
            .setOngoing(ongoing)
            .setAutoCancel(!ongoing)
            .setOnlyAlertOnce(true)
            .setShowWhen(false)
            .setContentIntent(tapIntent(uuid))
        // ponytail: the app redraws the card only while it is open (no push yet), so one left
        // behind by a closed app clears itself after an hour instead of sitting there for good.
        // Push updates would make this unnecessary.
        if (ongoing) builder.setTimeoutAfter(STALE_AFTER_MS)
        manager.notify(uuid, ID, builder.build())
    }

    @Suppress("UNCHECKED_CAST")
    private fun views(layout: Int, card: Map<String, Any?>, logo: Bitmap?) =
        RemoteViews(activity.packageName, layout).apply {
            // The app's language, not the phone's: an Arabic app on an English phone still
            // reads right to left.
            setInt(
                R.id.card,
                "setLayoutDirection",
                if (card["rtl"] == true) View.LAYOUT_DIRECTION_RTL else View.LAYOUT_DIRECTION_LTR,
            )
            setTextViewText(R.id.title, card["title"] as String)
            setTextViewText(R.id.subtitle, card["subtitle"] as String)
            if (logo == null) setViewVisibility(R.id.store_logo, View.GONE)
            else setImageViewBitmap(R.id.store_logo, logo)
            if (layout != R.layout.order_card_expanded) return@apply

            val steps = card["steps"] as List<String>
            val labels = card["labels"] as List<String>
            setProgressBar(R.id.progress, steps.size, steps.count { it == "done" }, false)
            steps.forEachIndexed { i, step ->
                setTextViewText(STEP_LABELS[i], labels[i])
                setImageViewResource(
                    STEP_ICONS[i],
                    when (step) {
                        "done" -> R.drawable.order_step_done
                        "current" -> R.drawable.order_step_current
                        else -> R.drawable.order_step_pending
                    },
                )
                // The line after a milestone fills once that milestone is done.
                if (i < STEP_LINES.size) {
                    setInt(STEP_LINES[i], "setBackgroundColor", if (step == "done") GREEN else PRIMARY_LIGHT)
                }
            }
        }

    /** The store's logo as the card draws it: a 40dp circle, cropped from the middle. */
    private fun circleCrop(bytes: ByteArray): Bitmap? {
        val source = BitmapFactory.decodeByteArray(bytes, 0, bytes.size) ?: return null
        val side = minOf(source.width, source.height)
        val size = (40 * activity.resources.displayMetrics.density).toInt()
        val square = Bitmap.createScaledBitmap(
            Bitmap.createBitmap(source, (source.width - side) / 2, (source.height - side) / 2, side, side),
            size,
            size,
            true,
        )
        return Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888).also {
            val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                shader = BitmapShader(square, Shader.TileMode.CLAMP, Shader.TileMode.CLAMP)
            }
            Canvas(it).drawCircle(size / 2f, size / 2f, size / 2f, paint)
        }
    }

    /** Opens the app with the order's uuid, which Dart takes through [takeTapped]. */
    private fun tapIntent(uuid: String): PendingIntent = PendingIntent.getActivity(
        activity,
        uuid.hashCode(),
        Intent(activity, MainActivity::class.java)
            .putExtra(EXTRA_ORDER, uuid)
            .addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP),
        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
    )

    /** The order whose card opened the app, handed over once. */
    private fun takeTapped(): String? = activity.intent?.run {
        getStringExtra(EXTRA_ORDER).also { removeExtra(EXTRA_ORDER) }
    }

    // Android 13+ hides every notification until the user allows them.
    private fun requestPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
            activity.checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED
        ) {
            activity.requestPermissions(arrayOf(Manifest.permission.POST_NOTIFICATIONS), PERMISSION_REQUEST)
        }
    }

    companion object {
        const val METHOD_CHANNEL = "nowdelivery/order_tracking"

        private const val CHANNEL = "order_tracking"
        private const val ID = 7311
        private const val PERMISSION_REQUEST = 7311
        private const val EXTRA_ORDER = "order_uuid"
        private const val STALE_AFTER_MS = 60 * 60 * 1000L

        // primary/500, green/500 and primary/100 from the design system.
        private val PRIMARY = 0xFF4BB749.toInt()
        private val GREEN = 0xFF117456.toInt()
        private val PRIMARY_LIGHT = 0xFFDBF1DB.toInt()

        private val STEP_ICONS = intArrayOf(R.id.step_icon_0, R.id.step_icon_1, R.id.step_icon_2, R.id.step_icon_3)
        private val STEP_LABELS = intArrayOf(R.id.step_label_0, R.id.step_label_1, R.id.step_label_2, R.id.step_label_3)
        private val STEP_LINES = intArrayOf(R.id.step_line_0, R.id.step_line_1, R.id.step_line_2)
    }
}
