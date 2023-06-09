/// Imports
/// ------------------------------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'primary_button.dart';
import '../painters/animated_indicator_painter.dart';
import '../../utils/duration.dart';


/// Indicator Button
/// ------------------------------------------------------------------------------------------------

class SPDIndicatorButton extends StatefulWidget {

  /// Creates a button that transition between an [SPDPrimaryButton] and progress indicator. Set 
  /// [showIndicator] equal to `true` for a progress indicator and `false` for a primary button.
  SPDIndicatorButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.focusNode,
    this.showIndicator = false,
    this.autofocus = false,
    this.enabled = true,
    this.expand = false,
    final ButtonStyle? style,
    this.targetPadding,
  }): style = style ?? SPDPrimaryButton.styleFrom();

  /// The button's main content.
  final Widget? child;

  /// The callback function that's triggered when the button is pressed while `enabled`. If `null`, 
  /// the button's state will be set to [MaterialState.disabled].
  final VoidCallback? onPressed;

  /// Controls whether or not the widget has keyboard focus to handle keyboard events.
  final FocusNode? focusNode;

  /// If `true`, render the progress indicator. Else, render the [SPDPrimaryButton].
  final bool showIndicator;

  /// If `true`, the widget will try to obtain focus when it's first loaded (default: `false`).
  final bool autofocus;

  /// If `false`, the button's state will be set to [MaterialState.disabled] (default: `true`).
  final bool enabled;

  /// If `true`, fill the available width.
  final bool expand;

  /// Button style.
  final ButtonStyle? style;

  /// The button's outer padding, used to increase its target area.
  final EdgeInsets? targetPadding;

  @override
  SPDIndicatorButtonState createState() => SPDIndicatorButtonState();
}


/// Indicator Button State
/// ------------------------------------------------------------------------------------------------

class SPDIndicatorButtonState extends State<SPDIndicatorButton> with TickerProviderStateMixin {

  /// The controller that animates the indicator's movement.
  late AnimationController _translateController;

  /// The controller that animates the between the button and indicator state.
  late AnimationController _transformController;

  /// The animation that fades the button in/out of view.
  late Animation<double> _fadeAnimation;

  /// The animation that resizes the widget.
  late Animation<double> _sizeAnimation;

  /// The animation that transforms the indicator's appearance.
  late Animation<double> _transformAnimation;

  // /// Return the button's minimum height.
  // Size get _minSize {
  //   return widget.style?.m ?? const Size.square(SPDGrid.x1 * 6.0);
  // }

  /// Initialise the widget's state.
  @override
  void initState() {
    super.initState();

    final double value = widget.showIndicator ? 0.0 : 1.0;

    _translateController = AnimationController(
      vsync: this, 
      value: value,
      duration: SPDDuration.slow,
    );
    
    _transformController = AnimationController(
      vsync: this, 
      value: value,
      duration: SPDDuration.slow,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _transformController, 
      curve: const Interval(0.70, 1.0, curve: Curves.easeInOut),
    );

    _sizeAnimation = CurvedAnimation(
      parent: _transformController, 
      curve: const Interval(0.25, 0.7, curve: Curves.easeOut),
    );

    _transformAnimation = CurvedAnimation(
      parent: _transformController, 
      curve: const Interval(0.0, 0.25, curve: Curves.easeIn),
    );

    if (widget.showIndicator) {
      _translateController.repeat();
    }
  }

  /// Dispose of all acquired resources.
  @override
  void dispose() {
    _translateController.dispose();
    _transformController.dispose();
    super.dispose();
  }

  /// Update the widget's state.
  /// @param [oldWidget]: The widget's previous state.
  @override
  void didUpdateWidget(covariant final SPDIndicatorButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showIndicator != oldWidget.showIndicator) {
      _animate(showIndicator: widget.showIndicator);
    }
  }

  /// Animate the widget from its current state to a progress indicator or primary button.
  /// @param [showIndicator]: If `true`, render a progress indicator, else render a primary button.
  void _animate({ required final bool showIndicator }) {
    _translateController.stop();
    _transformController.stop();
    if (showIndicator) {
      _transformController.reverse().whenComplete(() {
        _translateController.repeat();
      });
    } else {
      _translateController.forward().whenComplete(() {
        _transformController.forward();
      });
    }
  }

  /// Build the button widget.
  /// @param [minHeight]: The button's height.
  Widget _buildButton() {
    return SPDPrimaryButton(
      onPressed: widget.onPressed,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      enabled: widget.enabled,
      expand: widget.expand,
      style: widget.style,
      targetPadding: widget.targetPadding,
      child: widget.child,
    );
  }

  /// Build the progress indicator for the current animation ([_transformAnimation]) frame.
  /// @param [context]: The current build context.
  /// @param [child]?: The static child widget.
  Widget _animatedBuilder(BuildContext context, Widget? child) {
    return CustomPaint(
      painter: SPDAnimatedIndicatorPainter(
        animation: _translateController,
        transformValue: _transformAnimation.value,
        color: widget.style?.backgroundColor?.resolve({}),
        borderRadius: (widget.style?.minimumSize?.resolve({})?.shortestSide ?? 0.0) * 0.5,
      ),
    );
  }

  /// Build the final widget.
  /// @param [context]: The current build context.
  @override
  Widget build(final BuildContext context) {
    final Size? minimumSize = widget.style?.minimumSize?.resolve({});
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.hardEdge,
      children: [
        SizedBox.fromSize(
          size: minimumSize,
        ),
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _transformAnimation,
            builder: _animatedBuilder,
          ),
        ),
        FadeTransition(
          opacity: _fadeAnimation,
          child: SizeTransition(
            axis: Axis.horizontal,
            sizeFactor: _sizeAnimation,
            child: _buildButton(),
          ),
        ),
      ],
    );
  }
}