import 'package:flutter/material.dart';

/// How a [PaginatedView] arranges its items — a grid, a separated list, or
/// anything added later.
///
/// The view owns the pagination behaviour and knows nothing about the
/// arrangement: it hands over an item count and an item builder and gets a
/// sliver back. New arrangements are new subclasses, no change to the view.
abstract class PaginatedSliverLayout {
  const PaginatedSliverLayout({this.padding = EdgeInsets.zero});

  /// Padding around the items, inside the scroll view.
  final EdgeInsetsGeometry padding;

  /// Builds the sliver holding the items, [padding] excluded — that part is the
  /// same for every layout and is applied by [buildSliver].
  @protected
  Widget buildItemsSliver({
    required int itemCount,
    required IndexedWidgetBuilder itemBuilder,
  });

  /// The padded sliver to put in the scroll view.
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

/// Lays the items out in a grid, e.g. product cards two per row.
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

/// Lays the items out in a single column, optionally separated.
class PaginatedListLayout extends PaginatedSliverLayout {
  const PaginatedListLayout({
    this.separatorBuilder,
    super.padding,
  });

  /// Built between two items. When null the items sit flush against each other.
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
