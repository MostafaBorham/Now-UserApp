import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../settings/app_colors.dart';
import '../settings/components/profile_header.dart';
import 'components/faq_tile.dart';

/// FAQ screen: a list of expandable question cards.
///
/// Sections (see `components/`):
///   1. [CommonHeader] – yellow header + wave + back button + title.
///   2. [FaqTile] × N  – tappable accordion cards; any number can be open and
///                       the first one is open by default.
class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  static const double _hPadding = 20;

  static const List<FaqItem> _items = [
    FaqItem(
      question: 'How Can I Place An Order?',
      answer:
          'Simply browse products, add items to your cart, then proceed to '
          'checkout to place your order.',
    ),
    FaqItem(
      question: 'What Payment Methods Are Available?',
      answer:
          'We accept credit and debit cards, digital wallets, and cash on '
          'delivery.',
    ),
    FaqItem(
      question: 'How Long Does Delivery Take?',
      answer:
          'Delivery usually takes between 30 and 60 minutes, depending on your '
          'location and the store.',
    ),
    FaqItem(
      question: 'Can I Track My Order?',
      answer:
          'Yes. You can follow your order in real time from the orders section '
          'once it is on its way.',
    ),
    FaqItem(
      question: 'What Should I Do If An Item Is Missing Or Incorrect?',
      answer:
          'Reach out through Live Chat with your order number and we will make '
          'it right straight away.',
    ),
    FaqItem(
      question: 'How To Return An Order',
      answer:
          'Open the order, tap Return, choose the items, and follow the steps '
          'to schedule a pickup.',
    ),
  ];

  final Set<int> _expanded = {0};

  void _toggle(int index) {
    setState(() {
      if (!_expanded.remove(index)) _expanded.add(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          CommonHeader(
            title: 'FAQ',
            onBack: () => context.pop(),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(_hPadding, 20, _hPadding, 24),
              itemCount: _items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 14),
              itemBuilder: (context, index) => FaqTile(
                item: _items[index],
                expanded: _expanded.contains(index),
                onTap: () => _toggle(index),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
