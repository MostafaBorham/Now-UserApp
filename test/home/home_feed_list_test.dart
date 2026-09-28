import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/features/home/presentation/screens/home_view.dart';

/// A section appearing or disappearing above another must not rebuild it: the
/// live-orders strip collapses on every Home load for a user with nothing in
/// flight, and each section below it used to be torn down and built again,
/// losing whatever it kept (carousel pages, list positions).
void main() {
  Future<void> pumpFeed(WidgetTester tester, List<String> keys) =>
      tester.pumpWidget(
        MaterialApp(
          home: CustomScrollView(
            slivers: <Widget>[
              HomeFeedList(
                sections: <HomeFeedSection>[
                  for (final String key in keys)
                    HomeFeedSection(
                      key: ValueKey<String>(key),
                      child: _Probe(label: key),
                    ),
                ],
              ),
            ],
          ),
        ),
      );

  State<_Probe> probe(WidgetTester tester, String label) =>
      tester.state<State<_Probe>>(find.byKey(ValueKey<String>('probe-$label')));

  testWidgets('a section inserted above keeps the ones below', (
    WidgetTester tester,
  ) async {
    await pumpFeed(tester, <String>['header', 'offers']);
    final State<_Probe> offers = probe(tester, 'offers');

    await pumpFeed(tester, <String>['header', 'live_orders', 'offers']);

    expect(probe(tester, 'offers'), same(offers));
  });

  testWidgets('a section removed above keeps the ones below', (
    WidgetTester tester,
  ) async {
    await pumpFeed(tester, <String>['header', 'live_orders', 'offers']);
    final State<_Probe> offers = probe(tester, 'offers');

    await pumpFeed(tester, <String>['header', 'offers']);

    expect(probe(tester, 'offers'), same(offers));
  });
}

class _Probe extends StatefulWidget {
  _Probe({required this.label}) : super(key: ValueKey<String>('probe-$label'));

  final String label;

  @override
  State<_Probe> createState() => _ProbeState();
}

class _ProbeState extends State<_Probe> {
  @override
  Widget build(BuildContext context) =>
      SizedBox(height: 100, child: Text(widget.label));
}
