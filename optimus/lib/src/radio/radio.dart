import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:optimus/optimus.dart';
import 'package:optimus/src/common/gesture_wrapper.dart';
import 'package:optimus/src/common/group_wrapper.dart';

/// The radio component is available in two size variants to accommodate
/// different environments with different requirements.
enum OptimusRadioSize {
  ///  A radio with a small label is intended for content-heavy environments
  ///  and/or small mobile viewports.
  small,

  /// A radio with a large label is the most used across all products and
  /// platforms and is considered the default option.
  large,
}

/// The radio is a binary form of input used in a list of mutually exclusive
/// options. Users can make only one selection in a list at any given time.
class OptimusRadio<T> extends StatefulWidget {
  const OptimusRadio({
    super.key,
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.size = OptimusRadioSize.large,
    this.error,
    this.isEnabled = true,
  });

  /// Controls label.
  final Widget label;

  /// Controls the value represented by this radio button.
  final T value;

  /// Controls the currently selected value for a group of radio buttons.
  ///
  /// This radio button is considered selected if its [value] matches the
  /// [groupValue].
  final T groupValue;

  /// Called when the user selects this radio button.
  ///
  /// The radio button passes [value] as a parameter to this callback. The radio
  /// button does not actually change state until the parent widget rebuilds the
  /// radio button with the new [groupValue].
  ///
  /// [onChanged] will not be invoked if this radio button is already selected.
  ///
  /// The callback provided to [onChanged] should update the state of the parent
  /// [StatefulWidget] using the [State.setState] method;
  /// for example:
  ///
  /// ```dart
  /// Radio<String>(
  ///   value: 'Option A',
  ///   groupValue: _groupValue,
  ///   onChanged: (String newValue) {
  ///     setState(() {
  ///       _groupValue = newValue;
  ///     });
  ///   },
  /// )
  /// ```
  final ValueChanged<T> onChanged;

  /// Controls size.
  final OptimusRadioSize size;

  /// Controls error.
  final String? error;

  /// Controls if the widget is enabled.
  final bool isEnabled;

  @override
  State<OptimusRadio<T>> createState() => _OptimusRadioState<T>();
}

class _OptimusRadioState<T> extends State<OptimusRadio<T>> with ThemeGetter {
  bool _isHovering = false;
  bool _isPressed = false;

  bool get _isSelected => widget.value == widget.groupValue;

  Color get _textColor => widget.isEnabled
      ? theme.tokens.textStaticPrimary
      : theme.tokens.textDisabled;

  TextStyle get _labelStyle => switch (widget.size) {
        OptimusRadioSize.small =>
          tokens.bodyMediumStrong.copyWith(color: _textColor),
        OptimusRadioSize.large =>
          tokens.bodyLargeStrong.copyWith(color: _textColor),
      };

  void _handleHoverChanged(bool isHovering) =>
      setState(() => _isHovering = isHovering);

  void _handlePressedChanged(bool isPressed) =>
      setState(() => _isPressed = isPressed);

  void _handleChanged() {
    if (!_isSelected) {
      widget.onChanged(widget.value);
    }
  }

  _RadioState get _state {
    if (!widget.isEnabled) return _RadioState.disabled;
    if (_isPressed) return _RadioState.active;
    if (_isHovering) return _RadioState.hover;

    return _RadioState.basic;
  }

  @override
  Widget build(BuildContext context) {
    final leadingSize = tokens.spacing400;

    return GroupWrapper(
      error: widget.error,
      isEnabled: widget.isEnabled,
      child: IgnorePointer(
        ignoring: !widget.isEnabled,
        child: GestureWrapper(
          onHoverChanged: _handleHoverChanged,
          onPressedChanged: _handlePressedChanged,
          onTap: _handleChanged,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: leadingSize,
                child: Align(
                  alignment: Alignment.topLeft,
                  child: _RadioCircle(
                    state: _state,
                    isSelected: _isSelected,
                  ),
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(minHeight: leadingSize),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(width: leadingSize),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: tokens.spacing25,
                        ),
                        child: DefaultTextStyle.merge(
                          style: _labelStyle,
                          child: widget.label,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RadioCircle extends StatelessWidget {
  const _RadioCircle({
    required this.state,
    required this.isSelected,
  });

  final _RadioState state;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final size = tokens.sizing200;

    return Padding(
      padding: EdgeInsets.only(
        top: tokens.spacing100,
        bottom: tokens.spacing100,
        right: tokens.spacing200,
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            width: isSelected ? _selectedBorder : tokens.borderWidth150,
            color: state.borderColor(tokens, isSelected: isSelected),
          ),
          color: state.circleFillColor(tokens),
        ),
      ),
    );
  }
}

enum _RadioState { basic, hover, active, disabled }

extension on _RadioState {
  Color borderColor(OptimusTokens tokens, {required bool isSelected}) =>
      switch (this) {
        _RadioState.basic => isSelected
            ? tokens.backgroundInteractivePrimaryDefault
            : tokens.borderInteractiveSecondaryDefault,
        _RadioState.hover => isSelected
            ? tokens.backgroundInteractivePrimaryHover
            : tokens.borderInteractiveSecondaryHover,
        _RadioState.active => isSelected
            ? tokens.backgroundInteractivePrimaryActive
            : tokens.borderInteractiveSecondaryActive,
        _RadioState.disabled =>
          isSelected ? tokens.backgroundDisabled : tokens.borderDisabled,
      };

  Color circleFillColor(OptimusTokens tokens) => switch (this) {
        _RadioState.basic ||
        _RadioState.disabled =>
          tokens.backgroundInteractiveNeutralSubtleDefault,
        _RadioState.hover => tokens.backgroundInteractiveNeutralSubtleHover,
        _RadioState.active => tokens.backgroundInteractiveNeutralSubtleActive,
      };
}

const double _selectedBorder = 6.0;
