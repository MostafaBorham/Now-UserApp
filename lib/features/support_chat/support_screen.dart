import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nowdelivery_user_app/core/localization/lang_keys.dart';
import 'package:nowdelivery_user_app/core/presentation/widgets/app_waved_scaffold.dart';

import '../settings/app_colors.dart';
import '../settings/components/profile_header.dart';
import 'components/chat_bubble.dart';
import 'components/message_input_bar.dart';

/// Support chat screen.
///
/// Sections (see `components/`):
///   1. [CommonHeader]     – yellow header + wave + back button + title.
///   2. [ChatBubble] × N   – the scrolling conversation (customer on the left,
///                           "now" agent on the right).
///   3. [MessageInputBar]  – pinned composer with the green send button.
class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  static const double _hPadding = 20;

  final List<ChatMessage> _messages = [
    const ChatMessage(
      text: 'How long will my order take?',
      time: '2 minutes ago',
    ),
    const ChatMessage(
      text: 'Hello! Your order has been received and is on its way to you.',
      time: '2 minutes ago',
      fromAgent: true,
    ),
    const ChatMessage(
      text: 'How long will my order take?',
      time: '2 minutes ago',
    ),
    const ChatMessage(
      text: 'Hello! Your order has been received and is on its way to you.',
      time: '2 minutes ago',
      fromAgent: true,
    ),
    const ChatMessage(
      text: 'How long will my order take?',
      time: '2 minutes ago',
    ),
    const ChatMessage(
      text: 'Hello! Your order has been received and is on its way to you.',
      time: '2 minutes ago',
      fromAgent: true,
    ),
  ];

  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send() {
    final String text = _input.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(ChatMessage(text: text, time: 'Just now'));
    });
    _input.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppWavedScaffold(
        appBarTitle: LangKeys.support.tr(),
        body: Column(
          children: [
            Expanded(
              child: ListView.separated(
                controller: _scroll,
                itemCount: _messages.length,
                separatorBuilder: (_, _) => const SizedBox(height: 18),
                itemBuilder: (context, index) =>
                    ChatBubble(message: _messages[index]),
              ),
            ),
            MessageInputBar(controller: _input, onSend: _send),
          ],
        ),
      ),
    );
  }
}
