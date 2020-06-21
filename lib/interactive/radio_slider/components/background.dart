part of radio_slider;

class _Background extends StatelessWidget {

  _Background(this.backgroundColor);

  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final RadioSliderThemeData radioTheme = RadioSliderTheme.of(context);

    return Material(
      color: this.backgroundColor
        ?? radioTheme?.backgroundColor
          ?? theme.scaffoldBackgroundColor.withOpacity(0.7), //like stage's subsections
          // ?? theme?.colorScheme?.onSurface?.withOpacity(0.08),
      borderRadius: BorderRadius.circular(_RadioSliderState._radius),
    );
  }
}

