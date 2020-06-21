part of radio_slider;

class RadioSliderOf<T> extends StatelessWidget {

  final T selectedItem;
  final List<T> orderedItems;
  final Map<T,RadioSliderItem> items;
  final void Function(T) onSelect;

  final Duration duration;

  final Widget title;

  final Color selectedColor;
  final Color backgroundColor;
  final bool hideOpenIcons;
  final bool elevateSlider;

  final EdgeInsets margin;
  final double height;

  const RadioSliderOf({
    @required this.selectedItem,
    @required this.items,
    @required this.onSelect,
    this.orderedItems,
    this.backgroundColor,
    this.duration = const Duration(milliseconds: 250),
    this.elevateSlider,
    this.height,
    this.hideOpenIcons,
    this.margin,
    this.selectedColor,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final List<T> ordered = orderedItems ?? items.keys.toList();

    return RadioSlider(
      items: [
        for(final key in ordered)
          items[key],
      ],
      onTap: (int i) => onSelect(ordered[i]),
      selectedIndex: ordered.indexOf(selectedItem),
      backgroundColor: backgroundColor,
      duration: duration ?? const Duration(milliseconds: 250),
      elevateSlider: elevateSlider,
      height: height,
      hideOpenIcons: hideOpenIcons,
      margin: margin,
      selectedColor: selectedColor,
      title: title,
    );
  }
}