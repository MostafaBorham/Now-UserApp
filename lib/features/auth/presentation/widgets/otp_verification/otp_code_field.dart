import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_colors.dart';

/// A row of boxes that displays an OTP. A single transparent field overlaid on
/// top captures all input (typing, backspace and paste); the boxes are
/// display-only and reflect [controller]'s current value.
class OtpCodeField extends StatefulWidget {
  const OtpCodeField({
    super.key,
    required this.controller,
    this.length = 6,
    this.onCompleted,
    this.onCompletionChanged,
  });

  final TextEditingController controller;
  final int length;
  final ValueChanged<String>? onCompleted;

  /// Fires with `true` once all [length] digits are entered and `false` when
  /// the code becomes incomplete again (e.g. on backspace). Only fires on a
  /// change of state, so the parent can drive its button toggle off it.
  final ValueChanged<bool>? onCompletionChanged;

  @override
  State<OtpCodeField> createState() => _OtpCodeFieldState();
}

class _OtpCodeFieldState extends State<OtpCodeField> {
  final FocusNode _focusNode = FocusNode();
  bool _isComplete = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
    _focusNode.addListener(_onFocusChange);
  }

  void _onChanged() {
    // A programmatic assignment (e.g. paste) bypasses the field's input
    // formatters, so clamp the length here to keep the field the single owner
    // of the [length] constraint. The reassignment re-triggers this listener
    // with the clamped value, which then falls through to the logic below.
    if (widget.controller.text.length > widget.length) {
      final String clamped = widget.controller.text.substring(0, widget.length);
      widget.controller.value = TextEditingValue(
        text: clamped,
        selection: TextSelection.collapsed(offset: clamped.length),
      );
      return;
    }
    setState(() {});
    final bool complete = widget.controller.text.length == widget.length;
    if (complete) {
      widget.onCompleted?.call(widget.controller.text);
    }
    if (complete != _isComplete) {
      _isComplete = complete;
      widget.onCompletionChanged?.call(complete);
    }
  }

  void _onFocusChange() => setState(() {});

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    _focusNode
      ..removeListener(_onFocusChange)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String code = widget.controller.text;
    final bool hasFocus = _focusNode.hasFocus;
    return Stack(
      alignment: Alignment.center,
      children: [
        Row(
          children: List.generate(widget.length, (index) {
            final bool isActive = hasFocus && index == code.length;
            final String char = index < code.length ? code[index] : '';
            return Expanded(
              child: Padding(
                padding: EdgeInsetsDirectional.only(
                  end: index == widget.length - 1 ? 0 : 8,
                ),
                child: _OtpBox(char: char, isActive: isActive),
              ),
            );
          }),
        ),
        Positioned.fill(
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            autofocus: true,
            keyboardType: TextInputType.number,
            showCursor: false,
            enableInteractiveSelection: false,
            cursorColor: Colors.transparent,
            style: const TextStyle(color: Colors.transparent),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(widget.length),
            ],
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}

class _OtpBox extends StatelessWidget {
  const _OtpBox({required this.char, required this.isActive});

  final String char;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive
              ? AppColors.selectedIndicator
              : AppColors.unselectedIndicator,
          width: isActive ? 2 : 1,
        ),
      ),
      child: char.isNotEmpty
          ? Text(
              char,
              style: AppTextStyles.style24SemiBold.copyWith(
                color: AppColors.optionTitle,
              ),
            )
          : isActive
          ? Container(width: 2, height: 26, color: AppColors.selectedIndicator)
          : null,
    );
  }
}
