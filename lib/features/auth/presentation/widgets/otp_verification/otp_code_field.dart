import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nowdelivery_user_app/core/presentation/styles/text_styles.dart';
import 'package:nowdelivery_user_app/core/presentation/theme/app_color_scheme.dart';




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
          spacing: 8,
          children: List.generate(widget.length, (index) {
            final bool isActive = hasFocus && index == code.length;
            final String char = index < code.length ? code[index] : '';
            return Expanded(
              child: _OtpBox(char: char, isActive: isActive),
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
              ? context.colors.primary500Main
              : context.colors.neutral300,
          width: isActive ? 2 : 1,
        ),
      ),
      child: char.isNotEmpty
          ? Text(
              char,
              style: AppTextStyles.style24SemiBold.copyWith(
                color: context.colors.tertiaryContainer,
              ),
            )
          : isActive
          ? Container(width: 2, height: 26, color: context.colors.primary500Main)
          : null,
    );
  }
}
