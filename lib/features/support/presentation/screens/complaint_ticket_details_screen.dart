import 'dart:io';

import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/assets/assets.gen.dart';
import 'package:nowdelivery_user_app/core/presentation/components/app_toast/app_toast.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_wave/app_waved_view.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/buttons/arrow_back_button.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/clippers/top_wave_clipper.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/images/app_cached_network_image.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/reverse_widget.dart';
import 'package:nowdelivery_user_app/features/support_chat/components/message_input_bar.dart';

const _ticketSurface = Color(0xFFF8F8F8);
const _ticketText = Color(0xFF303030);

class ComplaintTicketDetailsScreen extends StatefulWidget {
  const ComplaintTicketDetailsScreen({super.key});

  @override
  State<ComplaintTicketDetailsScreen> createState() =>
      _ComplaintTicketDetailsScreenState();
}

class _ComplaintTicketDetailsScreenState
    extends State<ComplaintTicketDetailsScreen> {
  final _picker = ImagePicker();
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  final _photos = <String>[];
  final _sentMessages =
      <({String text, List<String> photos, TimeOfDay time})>[];
  bool _isPickingPhotos = false;

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _pickPhotos() async {
    if (_isPickingPhotos) return;
    _isPickingPhotos = true;
    try {
      final picked = await _picker.pickMultiImage(
        imageQuality: 85,
        maxWidth: 1600,
        maxHeight: 1600,
      );
      if (!mounted || picked.isEmpty) return;
      setState(() => _photos.addAll(picked.map((photo) => photo.path)));
    } on PlatformException {
      if (mounted) AppToast.showError(context, LangKeys.imagePickingErrorKey);
    } finally {
      _isPickingPhotos = false;
    }
  }

  void _sendMessage() {
    final text = _inputController.text.trim();
    if (_isPickingPhotos || (text.isEmpty && _photos.isEmpty)) return;

    setState(() {
      _sentMessages.add((
        text: text,
        photos: List.of(_photos),
        time: TimeOfDay.now(),
      ));
      _photos.clear();
    });
    _inputController.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: context.colors.white,
        body: AppWavedView(
          appBarTitle: LangKeys.supportAndComplaintsKey.tr(),
          waveGap: 8,
          bodyPadding: EdgeInsets.only(
            top: TopWaveClipper.depthFor(MediaQuery.sizeOf(context).width),
          ),
          leading: Tooltip(
            message: MaterialLocalizations.of(context).backButtonTooltip,
            child: CircleAvatar(
              radius: 24,
              backgroundColor: context.colors.white,
              child: ReverseWidget(
                child: ArrowBackButton(onTap: () => context.pop()),
              ),
            ),
          ),
          body: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    controller: _scrollController,
                    padding: EdgeInsets.zero,
                    children: [
                      const _TicketInformation(),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Column(
                          spacing: 8,
                          children: [
                            Row(
                              spacing: 12,
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: context.colors.neutral200,
                                  ),
                                ),
                                Text(
                                  'أمس · ٧ نوفمبر',
                                  style: AppTextStyles.style12Regular.copyWith(
                                    height: 22 / 12,
                                    color: const Color(0xFF8B8B8B),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: context.colors.neutral200,
                                  ),
                                ),
                              ],
                            ),
                            const _TicketMessage(
                              message:
                                  'مرحبًا، متى يصل طلبي؟ تأخر عن الموعد المحدد.',
                              isOutgoing: true,
                            ),
                            const _TicketMessage(
                              message:
                                  'أهلًا سارة، نراجع حالة طلبك مع شركة التوصيل.',
                            ),
                            for (final sent in _sentMessages)
                              _TicketMessage(
                                message: sent.text,
                                photos: sent.photos,
                                timeLabel: sent.time.format(context),
                                isOutgoing: true,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                MediaQuery.removePadding(
                  context: context,
                  removeBottom: true,
                  child: MessageInputBar(
                    inlinePhotos: true,
                    controller: _inputController,
                    photos: _photos,
                    onAttach: _pickPhotos,
                    onRemovePhoto: (index) {
                      setState(() => _photos.removeAt(index));
                    },
                    onSend: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TicketInformation extends StatefulWidget {
  const _TicketInformation();

  @override
  State<_TicketInformation> createState() => _TicketInformationState();
}

class _TicketInformationState extends State<_TicketInformation> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final icons = Assets.media.images.svg;
    const processingColor = Color(0xFFAF52DE);
    return Material(
      color: Colors.transparent,
      shape: Border(bottom: BorderSide(color: colors.neutral200)),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 1),
        child: Column(
          children: [
            Semantics(
              expanded: _expanded,
              button: true,
              child: InkWell(
                overlayColor: const WidgetStatePropertyAll(Colors.transparent),
                onTap: () => setState(() => _expanded = !_expanded),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    spacing: 6,
                    children: [
                      icons.complaintTicketInfo.svg(excludeFromSemantics: true),
                      Expanded(
                        child: Text(
                          'معلومات التذكرة',
                          style: AppTextStyles.style14Bold.copyWith(
                            height: 26 / 14,
                            color: _ticketText,
                          ),
                        ),
                      ),
                      Icon(
                        _expanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color: const Color(0xFF5E5E5E),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_expanded)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '#ORD-78452',
                          textDirection: TextDirection.ltr,
                          style: AppTextStyles.style16SemiBold.copyWith(
                            height: 30 / 16,
                            color: colors.primary500Main,
                          ),
                        ),
                        DecoratedBox(
                          decoration: ShapeDecoration(
                            color: processingColor.withValues(alpha: 0.1),
                            shape: const StadiumBorder(),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            child: Text(
                              'قيد المعالجة',
                              style: AppTextStyles.style12SemiBold.copyWith(
                                height: 22 / 12,
                                color: processingColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      spacing: 4,
                      children: [
                        icons.timeIcon.svg(
                          colorFilter: ColorFilter.mode(
                            colors.outline,
                            BlendMode.srcIn,
                          ),
                          excludeFromSemantics: true,
                        ),
                        Flexible(
                          child: Text(
                            'تاريخ الإنشاء: ٧ نوفمبر ٢٠٢٦، ١٠:١٥ ص',
                            style: AppTextStyles.style12Regular.copyWith(
                              height: 22 / 12,
                              color: colors.outline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'كان من المفترض أن يصل طلبي أمس، لكن حالة التوصيل لم تتغير. أرجو تأكيد موعد وصوله.',
                      style: AppTextStyles.style14Regular.copyWith(
                        height: 26 / 14,
                        color: _ticketText,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                    const SizedBox.square(
                      dimension: 64,
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        child: AppCachedNetworkImage(
                          imageUrl:
                              'https://images.pexels.com/photos/4440891/pexels-photo-4440891.jpeg?auto=compress&cs=tinysrgb&w=256',
                          width: 64,
                          height: 64,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TicketMessage extends StatelessWidget {
  const _TicketMessage({
    required this.message,
    this.isOutgoing = false,
    this.photos = const [],
    this.timeLabel = 'منذ دقيقتين',
  });

  final String message;
  final bool isOutgoing;
  final List<String> photos;
  final String timeLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: isOutgoing
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.end,
      spacing: 4,
      children: [
        Row(
          mainAxisAlignment: isOutgoing
              ? MainAxisAlignment.start
              : MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          spacing: 4,
          children: [
            Flexible(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 280),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isOutgoing ? colors.primary500Main : _ticketSurface,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(4),
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  boxShadow: [
                    if (!isOutgoing)
                      const BoxShadow(
                        color: Color(0x40000000),
                        blurRadius: 0.5,
                      ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8,
                  children: [
                    if (photos.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final path in photos)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.file(
                                File(path),
                                width: 64,
                                height: 64,
                                cacheWidth: 192,
                                fit: BoxFit.cover,
                              ),
                            ),
                        ],
                      ),
                    if (message.isNotEmpty)
                      Text(
                        message,
                        style: AppTextStyles.style16Regular.copyWith(
                          height: 30 / 16,
                          color: isOutgoing
                              ? const Color(0xFFFCFCFC)
                              : _ticketText,
                          overflow: TextOverflow.visible,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (!isOutgoing)
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0xFFF4F4F4),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Color(0x0F000000), blurRadius: 10),
                  ],
                ),
                child: Assets.media.images.svg.logoHorizontal.svg(
                  width: 21.6,
                  excludeFromSemantics: true,
                ),
              ),
          ],
        ),
        Padding(
          padding: EdgeInsetsDirectional.only(end: isOutgoing ? 0 : 28),
          child: Text(
            timeLabel,
            style: AppTextStyles.style12Regular.copyWith(
              height: 22 / 12,
              color: colors.neutral500,
            ),
          ),
        ),
      ],
    );
  }
}
