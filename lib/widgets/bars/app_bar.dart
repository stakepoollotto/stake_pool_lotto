/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:flutter/material.dart';
import '../../extensions/text_style.dart';
import '../../icons/dream_drops_icons.dart';
import '../../layouts/grid.dart';
import '../../layouts/padding.dart';
import '../../navigator/navigator.dart';
import '../../themes/colors/color.dart';
import '../../themes/fonts/font.dart';
import '../buttons/icon_secondary_button.dart';


/// Application Bar
/// ------------------------------------------------------------------------------------------------

class SPDAppBar extends StatefulWidget implements PreferredSizeWidget {

  /// Creates a bar with a leading `back` button, [title] and [trailing] widget.
  const SPDAppBar({
    super.key,
    this.height = kHeight,
    this.canPop = true,
    this.onPop,
    this.title,
    this.trailing,
  });

  /// The application bar's default height (80.0).
  static const double kHeight = SPDGrid.x1 * 10.0;

  /// The application bar's height (default: [SPDAppBar.kHeight]).
  final double height;

  /// If true and the current [Route] can be popped (i.e. it's not the initial route), display a 
  /// `back` button to pop the current [Route] from the stack (default: `true`).
  final bool canPop;

  /// The function called when the `back` button is pressed.
  /// @param [context]: The current build context.
  final void Function(BuildContext context)? onPop;

  /// The application bar's title widget.
  final Widget? title;

  /// The application bar's text style.
  static TextStyle get textStyle => SPDFont.shared.bodyLarge.bold();

  /// The application bar's trailing widget.
  final Widget? trailing;

  /// Return the application bar's size.
  @override
  Size get preferredSize => Size.fromHeight(height);

  /// Create an instance of the class' state widget.
  @override
  _SPDAppBarState createState() => _SPDAppBarState();
}


/// App Bar State
/// ------------------------------------------------------------------------------------------------

class _SPDAppBarState extends State<SPDAppBar> {

  /// The horizontal spacing placed between each of the app bar's items.
  double get _spacing => SPDGrid.x3;

  /// True it the `back` button should be displayed.
  bool get _showBack {
    return (widget.canPop || widget.onPop != null)
      && SPDNavigator.shared.canPop(context);
  }

  /// Pops the [Route] at the top of the stack for the current [context].
  void _onTapBack() {
    return (widget.onPop ?? SPDNavigator.shared.pop).call(context);
  }

  /// Builds the application bar's `back` button.
  Widget _buildBack() {
    return SPDIconSecondaryButton(
      icon: SPDIcons.arrowleft,
      onPressed: _onTapBack,
    );
  }

  /// Builds the application bar's `title` widget.
  Widget _buildTitle() {
    return Expanded(
      child: Center(
        child: widget.title,
      ),
    );
  }

  /// Builds the application bar's `trailing` widget.
  Widget _buildTrailing() {
    return Flexible(
      child: Padding(
        padding: EdgeInsets.only(
          right: _spacing,
        ),
        child: Align(
          alignment: Alignment.centerRight,
          child: widget.trailing,
        ),
      ),
    );
  }

  /// Builds the final widget.
  @override
  Widget build(final BuildContext context) {
    return ColoredBox(
      color: SPDColor.shared.primary1,
      child: SafeArea(
        child: Padding(
          padding: SPDEdgeInsets.shared.inset(),
          child: DefaultTextStyle(
            style: SPDAppBar.textStyle,
            overflow: TextOverflow.ellipsis,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _showBack
                  ? _buildBack()
                  : SizedBox(width: 0),
                if (widget.title != null)
                  _buildTitle(),
                widget.trailing != null
                  ? _buildTrailing()
                  : SizedBox(width: _showBack ? 24 + 16 + 24 : 0), // back button width
              ],
            ),
          ),
        ),
      ),
    );
  }
}