import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Signature for the builder callback used by [SidAnimatedList].
typedef SidAnimatedListItemBuilder = Widget Function(BuildContext context, int index, Animation<double> animation);

/// Signature for the builder callback used by [SidAnimatedListState.removeItem].
typedef SidAnimatedListRemovedItemBuilder = Widget Function(BuildContext context, Animation<double> animation);

// The default insert/remove animation duration.
const Duration _kDuration = Duration(milliseconds: 300);

// Incoming and outgoing AnimatedList items.
class _SidActiveItem implements Comparable<_SidActiveItem> {
  _SidActiveItem.incoming(this.controller, this.itemIndex) : removedItemBuilder = null;
  _SidActiveItem.outgoing(this.controller, this.itemIndex, this.removedItemBuilder);
  _SidActiveItem.index(this.itemIndex)
    : controller = null,
      removedItemBuilder = null;

  final AnimationController? controller;
  final SidAnimatedListRemovedItemBuilder? removedItemBuilder;
  int itemIndex;

  @override
  int compareTo(_SidActiveItem other) => itemIndex - other.itemIndex;
}

typedef SidAnimatedListRemover = void Function(
  int index, 
  SidAnimatedListRemovedItemBuilder builder,
  { Duration duration }
);
typedef SidAnimatedListInserter = void Function(int index, {Duration? duration});

class SidAnimatedListController{
  SidAnimatedListController();
  SidAnimatedListRemover? _remove;
  SidAnimatedListInserter? _insert;
  void Function(int)? _refresh;
  VoidCallback? _rebuild;

  void remove(
    int index, 
    SidAnimatedListRemovedItemBuilder builder,
    { Duration duration = _kDuration }
  ){
    if(_remove != null)
      _remove!(index, builder, duration: duration);
    else
      print("this sid animated list controller is not used");
  }

  void insert(
    int index, 
    { Duration duration = _kDuration }
  ){
    if(_insert != null)
      _insert!(index, duration: duration);
    else
      print("this sid animated list controller is not used");
  }

  void refresh(int count){
    debugPrint("refreshing list from controller: count: $count");
    if(_refresh != null)
      _refresh!(count);
    else
      print("this sid animated list controller is not used");
  }

  void rebuild(){
    debugPrint("rebuilding list from controller");
    if(_rebuild != null)
      _rebuild!();
  }

  void addListeners(
    SidAnimatedListRemover remover,
    SidAnimatedListInserter inserter,
    void Function(int) refresher,
    VoidCallback rebuilder,
  ){
    _remove = remover;
    _insert = inserter;
    _refresh = refresher;
    _rebuild = rebuilder;
  }
}

class SidAnimatedList extends StatefulWidget {

  const SidAnimatedList({
    Key? key,
    required this.itemBuilder,
    this.initialItemCount = 0,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    this.listController,
  }): assert(initialItemCount >= 0),
      super(key: key);

  final SidAnimatedListItemBuilder itemBuilder;

  final int initialItemCount;

  final Axis scrollDirection;

  final bool reverse;

  final ScrollController? controller;

  final bool? primary;

  final ScrollPhysics? physics;

  final bool shrinkWrap;

  final EdgeInsetsGeometry? padding;

  final SidAnimatedListController? listController;

  /// The state from the closest instance of this class that encloses the given context.
  ///
  /// This method is typically used by [SidAnimatedList] item widgets that insert or
  /// remove items in response to user input.
  ///
  /// ```dart
  /// AnimatedListState animatedList = AnimatedList.of(context);
  /// ```
  static SidAnimatedListState? of(BuildContext context, { bool nullOk = false }) {
    final SidAnimatedListState? result = context.findAncestorStateOfType<SidAnimatedListState>();
    if (nullOk || result != null)
      return result;
    throw FlutterError(
      'AnimatedList.of() called with a context that does not contain an AnimatedList.\n'
      'No AnimatedList ancestor could be found starting from the context that was passed to AnimatedList.of(). '
      'This can happen when the context provided is from the same StatefulWidget that '
      'built the AnimatedList. Please see the AnimatedList documentation for examples '
      'of how to refer to an AnimatedListState object: '
      '  https://api.flutter.dev/flutter/widgets/AnimatedListState-class.html \n'
      'The context used was:\n'
      '  $context'
    );
  }

  @override
  SidAnimatedListState createState() => SidAnimatedListState();
}

/// The state for a scrolling container that animates items when they are
/// inserted or removed.
///
/// When an item is inserted with [insertItem] an animation begins running. The
/// animation is passed to [SidAnimatedList.itemBuilder] whenever the item's widget
/// is needed.
///
/// When an item is removed with [removeItem] its animation is reversed.
/// The removed item's animation is passed to the [removeItem] builder
/// parameter.
///
/// An app that needs to insert or remove items in response to an event
/// can refer to the [SidAnimatedList]'s state with a global key:
///
/// ```dart
/// GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();
/// ...
/// AnimatedList(key: listKey, ...);
/// ...
/// listKey.currentState.insert(123);
/// ```
///
/// [SidAnimatedList] item input handlers can also refer to their [SidAnimatedListState]
/// with the static [SidAnimatedList.of] method.
class SidAnimatedListState extends State<SidAnimatedList> with TickerProviderStateMixin<SidAnimatedList> {
  final List<_SidActiveItem> _incomingItems = <_SidActiveItem>[];
  final List<_SidActiveItem> _outgoingItems = <_SidActiveItem>[];
  int _itemsCount = 0;

  @override
  void initState() {
    super.initState();
    _itemsCount = widget.initialItemCount;
    
    widget.listController?.addListeners(removeItem, insertItem, refresh, rebuild);
  }

  void rebuild(){
    if(!mounted) return;
    this.setState((){});
  }

  @override
  void dispose() {
    for (_SidActiveItem item in _incomingItems)
      item.controller!.dispose();
    for (_SidActiveItem item in _outgoingItems)
      item.controller!.dispose();
    super.dispose();
  }

  _SidActiveItem? _removeActiveItemAt(List<_SidActiveItem> items, int itemIndex) {
    final int i = binarySearch(items, _SidActiveItem.index(itemIndex));
    return i == -1 ? null : items.removeAt(i);
  }

  _SidActiveItem? _activeItemAt(List<_SidActiveItem> items, int itemIndex) {
    final int i = binarySearch(items, _SidActiveItem.index(itemIndex));
    return i == -1 ? null : items[i];
  }

  // The insertItem() and removeItem() index parameters are defined as if the
  // removeItem() operation removed the corresponding list entry immediately.
  // The entry is only actually removed from the ListView when the remove animation
  // finishes. The entry is added to _outgoingItems when removeItem is called
  // and removed from _outgoingItems when the remove animation finishes.

  int _indexToItemIndex(int index) {
    int itemIndex = index;
    for (_SidActiveItem item in _outgoingItems) {
      if (item.itemIndex <= itemIndex)
        itemIndex += 1;
      else
        break;
    }
    return itemIndex;
  }

  int _itemIndexToIndex(int itemIndex) {
    int index = itemIndex;
    for (_SidActiveItem item in _outgoingItems) {
      assert(item.itemIndex != itemIndex);
      if (item.itemIndex < itemIndex)
        index -= 1;
      else
        break;
    }
    return index;
  }

  /// Insert an item at [index] and start an animation that will be passed
  /// to [SidAnimatedList.itemBuilder] when the item is visible.
  ///
  /// This method's semantics are the same as Dart's [List.insert] method:
  /// it increases the length of the list by one and shifts all items at or
  /// after [index] towards the end of the list.
  void insertItem(int index, { Duration? duration = _kDuration }) {
    assert(index >= 0);
    assert(duration != null);
    if(!mounted) return;

    final int itemIndex = _indexToItemIndex(index);
    assert(itemIndex >= 0 && itemIndex <= _itemsCount);

    // Increment the incoming and outgoing item indices to account
    // for the insertion.
    for (_SidActiveItem item in _incomingItems) {
      if (item.itemIndex >= itemIndex)
        item.itemIndex += 1;
    }
    for (_SidActiveItem item in _outgoingItems) {
      if (item.itemIndex >= itemIndex)
        item.itemIndex += 1;
    }

    final AnimationController controller = AnimationController(duration: duration, vsync: this);
    final _SidActiveItem incomingItem = _SidActiveItem.incoming(controller, itemIndex);
    setState(() {
      _incomingItems
        ..add(incomingItem)
        ..sort();
      _itemsCount += 1;
    });

    controller.forward().then<void>((_) {
      _removeActiveItemAt(_incomingItems, incomingItem.itemIndex)!.controller!.dispose();
    });
  }

  /// Remove the item at [index] and start an animation that will be passed
  /// to [builder] when the item is visible.
  ///
  /// Items are removed immediately. After an item has been removed, its index
  /// will no longer be passed to the [SidAnimatedList.itemBuilder]. However the
  /// item will still appear in the list for [duration] and during that time
  /// [builder] must construct its widget as needed.
  ///
  /// This method's semantics are the same as Dart's [List.remove] method:
  /// it decreases the length of the list by one and shifts all items at or
  /// before [index] towards the beginning of the list.
  void removeItem(
    int index, 
    SidAnimatedListRemovedItemBuilder builder, 
    { Duration duration = _kDuration }
  ) {

    if(!mounted) return;
    assert(index >= 0);

    final int itemIndex = _indexToItemIndex(index);
    assert(itemIndex >= 0 && itemIndex < _itemsCount);
    assert(_activeItemAt(_outgoingItems, itemIndex) == null);

    final _SidActiveItem? incomingItem = _removeActiveItemAt(_incomingItems, itemIndex);
    final AnimationController controller = incomingItem?.controller
      ?? AnimationController(duration: duration, value: 1.0, vsync: this);

    final _SidActiveItem outgoingItem = _SidActiveItem.outgoing(controller, itemIndex, builder);

    setState(() {
      _outgoingItems
        ..add(outgoingItem)
        ..sort();
    });

    controller.reverse().then<void>((void value) {
      _removeActiveItemAt(_outgoingItems, outgoingItem.itemIndex)!.controller!.dispose();

      // Decrement the incoming and outgoing item indices to account
      // for the removal.
      for (_SidActiveItem item in _incomingItems) {
        if (item.itemIndex > outgoingItem.itemIndex)
          item.itemIndex -= 1;
      }
      for (_SidActiveItem item in _outgoingItems) {
        if (item.itemIndex > outgoingItem.itemIndex)
          item.itemIndex -= 1;
      }

      setState(() {
        _itemsCount -= 1;
      });
    });
  }

  void refresh(int itemsCount){
    if(!mounted) return;
    for (_SidActiveItem item in _incomingItems)
      item.controller!.dispose();
    for (_SidActiveItem item in _outgoingItems)
      item.controller!.dispose();

    _incomingItems.clear();
    _outgoingItems.clear();
    this.setState((){
      _itemsCount = itemsCount;
    });
  }

  Widget _itemBuilder(BuildContext context, int itemIndex) {
    final _SidActiveItem? outgoingItem = _activeItemAt(_outgoingItems, itemIndex);
    if (outgoingItem != null)
      return outgoingItem.removedItemBuilder!(context, outgoingItem.controller!.view);

    final _SidActiveItem? incomingItem = _activeItemAt(_incomingItems, itemIndex);
    final Animation<double> animation = incomingItem?.controller?.view ?? kAlwaysCompleteAnimation;
    return widget.itemBuilder(context, _itemIndexToIndex(itemIndex), animation);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: _itemBuilder,
      itemCount: _itemsCount,
      scrollDirection: widget.scrollDirection,
      reverse: widget.reverse,
      controller: widget.controller,
      primary: widget.primary,
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
      padding: widget.padding,
    );
  }
}
