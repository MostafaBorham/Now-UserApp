import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_details/product_details_transition.dart';
import 'package:nowdelivery_user_app/features/products/presentation/widgets/product_details/product_details_viewport.dart';

void main() {
  testWidgets(
    'resizing fits the page without repeatedly laying out its content',
    (tester) async {
      int layouts = 0;
      final contentKey = GlobalKey();
      final pageKey = GlobalKey();
      final content = Column(
        key: pageKey,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: _LayoutProbe(
                onLayout: () => layouts++,
                child: SizedBox(
                  key: contentKey,
                  width: double.infinity,
                  height: 1500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 54),
        ],
      );

      Future<void> resize(double width, double height) => tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: SizedBox(
              width: width,
              height: height,
              child: ProductDetailsViewport(contentWidth: 390, child: content),
            ),
          ),
        ),
      );
      await resize(340, 500);
      final initialLayouts = layouts;
      for (int frame = 1; frame <= 30; frame++) {
        final width = 340 + 50 * frame / 30;
        final height = 500 + 90 * frame / 30;
        await resize(width, height);
        expect(tester.getRect(find.byKey(pageKey)).width, closeTo(width, 0.01));
        expect(
          tester.getRect(find.byKey(pageKey)).height,
          closeTo(height, 0.01),
        );
        expect(tester.getSize(find.byKey(contentKey)).width, 390);
      }
      expect(layouts, initialLayouts);
    },
  );

  testWidgets(
    'route rebuilds keep one curve listener and release it on close',
    (tester) async {
      final animation = _CountingAnimationController(vsync: tester);
      addTearDown(animation.dispose);
      for (int frame = 0; frame <= 30; frame++) {
        animation.value = frame / 30;
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: ProductDetailsTransition(
              animation: animation,
              child: const SizedBox.expand(),
            ),
          ),
        );
        expect(animation.statusListeners, 1);
      }
      await tester.pumpWidget(const SizedBox.shrink());
      expect(animation.statusListeners, 0);
    },
  );
}

class _CountingAnimationController extends AnimationController {
  _CountingAnimationController({required super.vsync});
  int statusListeners = 0;

  @override
  void addStatusListener(AnimationStatusListener listener) {
    statusListeners++;
    super.addStatusListener(listener);
  }

  @override
  void removeStatusListener(AnimationStatusListener listener) {
    statusListeners--;
    super.removeStatusListener(listener);
  }
}

class _LayoutProbe extends SingleChildRenderObjectWidget {
  const _LayoutProbe({required this.onLayout, required super.child});
  final VoidCallback onLayout;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderLayoutProbe(onLayout);
}

class _RenderLayoutProbe extends RenderProxyBox {
  _RenderLayoutProbe(this.onLayout);
  final VoidCallback onLayout;

  @override
  void performLayout() {
    onLayout();
    super.performLayout();
  }
}
