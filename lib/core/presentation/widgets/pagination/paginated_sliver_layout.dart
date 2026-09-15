import 'package:flutter/material.dart';

abstract class PaginatedSliverLayout {
  const PaginatedSliverLayout({this.padding = EdgeInsets.zero});

  final EdgeInsetsGeometry padding;

  @protected
  Widget buildItemsSliver({
    required int itemCount,
    required IndexedWidgetBuilder itemBuilder,
  });

  Widget buildSliver({
    required int itemCount,
    required IndexedWidgetBuilder itemBuilder,
  }) {
    return SliverPadding(
      padding: padding,
      sliver: buildItemsSliver(itemCount: itemCount, itemBuilder: itemBuilder),
    );
  }
}

class PaginatedGridLayout extends PaginatedSliverLayout {
  const PaginatedGridLayout({
    required this.gridDelegate,
    super.padding,
  });

  final SliverGridDelegate gridDelegate;

  @override
  Widget buildItemsSliver({
    required int itemCount,
    required IndexedWidgetBuilder itemBuilder,
  }) {
    return SliverGrid.builder(
      gridDelegate: gridDelegate,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );
  }
}

class PaginatedListLayout extends PaginatedSliverLayout {
  const PaginatedListLayout({
    this.separatorBuilder,
    super.padding,
  });

  final IndexedWidgetBuilder? separatorBuilder;

  @override
  Widget buildItemsSliver({
    required int itemCount,
    required IndexedWidgetBuilder itemBuilder,
  }) {
    final IndexedWidgetBuilder? separatorBuilder = this.separatorBuilder;
    if (separatorBuilder == null) {
      return SliverList.builder(
        itemCount: itemCount,
        itemBuilder: itemBuilder,
      );
    }

    return SliverList.separated(
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      separatorBuilder: separatorBuilder,
    );
  }
}
