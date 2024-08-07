import 'package:flutter/material.dart';

part 'custom_slider_shape.dart';

/// A customizable scale ruler widget that allows measuring in feet and inches or centimeters.
class ScaleRuler extends StatefulWidget {
  /// Determines if the scale ruler will measure in feet and inches.
  final bool isFeet;

  /// The maximum value the slider can reach.
  final int maxValue;

  /// The minimum value the slider can reach.
  final int minValue;

  /// A callback function that returns the current scale value.
  final void Function(ScaleValue scaleValue)? onChanged;

  /// The background color of the scale ruler.
  final Color backgroundColor;

  /// The color of the active part of the slider.
  final Color sliderActiveColor;

  /// The color of the inactive part of the slider.
  final Color sliderInactiveColor;

  /// The color of the slider thumb.
  final Color sliderThumbColor;

  /// The color of the step indicators on the scale.
  final Color stepIndicatorColor;

  /// The color of the step indicator dividers on the scale.
  final Color stepIndicatorDividerColor;

  /// The font size of the scale text.
  final double? fontSize;

  /// The initial value of the slider, must be between [minValue] and [maxValue].
  final int? initialValue;

  /// The color of the scale text.
  final Color? textColor;

  /// The type of the ruler.
  final RulerType rulerType;

  /// The direction of the ruler, either horizontal or vertical.
  final Axis axis;

  /// Constructor for [ScaleRuler].
  const ScaleRuler.lengthMeasurement({
    Key? key,
    required this.maxValue,
    required this.minValue,
    this.initialValue,
    this.onChanged,
    this.isFeet = false,
    this.backgroundColor = const Color(0xFF66BB6A),
    this.sliderActiveColor = const Color(0xFFEF5350),
    this.sliderInactiveColor = const Color(0xFF9C27B0),
    this.sliderThumbColor = Colors.green,
    this.stepIndicatorColor = Colors.black,
    this.stepIndicatorDividerColor = Colors.black45,
    this.fontSize = 11,
    this.textColor = Colors.black,
    this.axis = Axis.horizontal,
  })  : assert(minValue >= 0, 'minValue must be greater than or equal to 0'),
        assert(maxValue > minValue, 'maxValue must be greater than minValue'),
        assert(
            initialValue == null ||
                (initialValue >= minValue && initialValue <= maxValue),
            'initialValue must be between minValue and maxValue'),
        rulerType = RulerType.lengthMeasurement,
        super(key: key);

  @override
  State<ScaleRuler> createState() => _ScaleRulerState();
}

class _ScaleRulerState extends State<ScaleRuler> {
  /// Limits the number of steps on the scale.
  late final int _scaleStepLimit;

  /// Holds the current measurement.
  final _scaleValue = ScaleValue(feet: 0, inch: 0, cms: 0);

  /// Controller for scrolling the scale.
  final _scrollController = ScrollController();

  /// Maximum width of the scale.
  double _screenMaxWidth = 0.0;

  /// Width of a single step on the slider.
  double _sliderSingleStepWidth = 0.0;

  /// Width of a single scale item.
  double _scaleItemWidth = 20.0;

  /// A boolean indicating whether the scale is scrollable.
  bool _isScrolling = false;

  /// Padding for the scale.
  double _scalePadding = 20;

  @override
  void initState() {
    super.initState();
    if (widget.isFeet) {
      _scaleValue.feet = widget.minValue;
      _scaleStepLimit = 12;
    } else {
      _scaleStepLimit = 1;
      _scaleValue.cms = widget.minValue;
    }
    _getScalePadding();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialValue != null) {
        if (widget.isFeet) {
          _scaleValue.feet = widget.initialValue!;
        } else {
          _scaleValue.cms = widget.initialValue!;
        }
        _onDragging(_getSliderValue());
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        _screenMaxWidth = constraints.maxWidth - 40;
        _sliderSingleStepWidth = (_screenMaxWidth) / (_getLength() - 1);
        if (_sliderSingleStepWidth > _screenMaxWidth) {
          _sliderSingleStepWidth = _screenMaxWidth;
        }

        if (widget.maxValue > 99) {
          _scaleItemWidth = 7.0 * (widget.maxValue.toString().length);
        }

        double scaleItemSize = _scaleItemWidth * _getLength();
        if (scaleItemSize < (_screenMaxWidth)) {
          _scaleItemWidth = (_screenMaxWidth) / (_getLength() - 1);
        }

        _isScrolling =
            (_scaleItemWidth) * (_getLength() - 1) > (_screenMaxWidth);

        return RotatedBox(
          quarterTurns: widget.axis == Axis.horizontal ? 0 : 3,
          child: Container(
            alignment: Alignment.bottomCenter,
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            height: 120,
            width: _screenMaxWidth + 40.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: widget.backgroundColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildSlider(),
                _buildScaleSteps(),
                _buildScaleText(),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Builds the slider widget.
  Widget _buildSlider() {
    return Container(
      width: _screenMaxWidth + 40,
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          thumbColor: widget.sliderThumbColor,
          trackShape: _CustomTrackShape(),
        ),
        child: MediaQuery.removePadding(
          context: context,
          removeRight: true,
          removeLeft: true,
          child: Slider(
            value: _getSliderValue(),
            min: widget.isFeet
                ? (widget.minValue * 12).toDouble()
                : widget.minValue.toDouble(),
            max: widget.isFeet
                ? (widget.maxValue * 12).toDouble()
                : widget.maxValue.toDouble(),
            activeColor: widget.sliderActiveColor,
            inactiveColor: widget.sliderInactiveColor,
            label: '${_scaleValue.cms!}',
            onChanged: (value) {
              _onDragging(value);
            },
          ),
        ),
      ),
    );
  }

  /// Builds the scale steps widget.
  Widget _buildScaleSteps() {
    return Container(
      width: _screenMaxWidth + 40,
      padding: const EdgeInsets.only(left: 20.0, right: 2.0),
      height: 15,
      child: Center(
        child: MediaQuery.removePadding(
          context: context,
          removeBottom: true,
          removeLeft: true,
          removeRight: true,
          child: ListView.builder(
            itemCount: _getLength() + 1,
            controller: _scrollController,
            physics: const NeverScrollableScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemBuilder: (context1, index) {
              if (index == _getLength()) return const SizedBox();
              return Container(
                width: _scaleItemWidth,
                alignment: Alignment.bottomLeft,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    height: (index % _scaleStepLimit) == 0 ? 15.0 : 10.0,
                    width: 2,
                    color: (index % _scaleStepLimit) == 0
                        ? widget.stepIndicatorColor
                        : widget.stepIndicatorDividerColor,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Builds the scale text widget.
  Widget _buildScaleText() {
    return Container(
      width: _screenMaxWidth + 40,
      padding: EdgeInsets.only(left: _scalePadding, right: 2.0),
      height: 15,
      child: Center(
        child: MediaQuery.removePadding(
          context: context,
          removeBottom: true,
          removeLeft: true,
          removeRight: true,
          child: ListView.builder(
            itemCount: _getLength() + 1,
            controller: _scrollController,
            physics: const NeverScrollableScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemBuilder: (context1, index) {
              String scaleText;
              if (widget.isFeet) {
                scaleText =
                    ((index + widget.minValue * 12) / 12).truncate().toString();
              } else {
                scaleText = (index + widget.minValue).toString();
              }

              double? textPadding = 0.0;
              if (_scalePadding < 20) {
                double padding = 2 * (scaleText.length.toDouble());
                if (_scalePadding + padding != 20) {
                  textPadding = 20 - (_scalePadding + padding);
                }
              }

              if (index == _getLength()) {
                return SizedBox(width: _scaleItemWidth);
              }

              return Container(
                width: _scaleItemWidth,
                padding: EdgeInsets.only(left: textPadding),
                alignment: Alignment.bottomLeft,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            (index % _scaleStepLimit) == 0 ? scaleText : "",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: widget.fontSize,
                              letterSpacing: 1.0,
                              color: widget.textColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Handles the dragging of the slider, updating the state accordingly.
  void _onDragging(double value) {
    if (mounted) {
      setState(() {
        int minValue = widget.minValue;
        if (widget.isFeet) minValue = widget.minValue * 12;

        double sliderScrollPosition =
            (_sliderSingleStepWidth * (value.toInt() - minValue));
        double listCurrentScaleScrollPosition =
            (_scaleItemWidth * (value.toInt() - minValue));

        if (_isScrolling) {
          _scrollController
              .jumpTo(listCurrentScaleScrollPosition - sliderScrollPosition);
        }

        if (widget.isFeet) {
          _scaleValue.feet = value ~/ 12;
          _scaleValue.inch = (value % 12).truncate();
          _scaleValue.cms = 0;
        } else {
          _scaleValue.cms = value.toInt();
          _scaleValue.feet = 0;
          _scaleValue.inch = 0;
        }

        widget.onChanged?.call(_scaleValue);
      });
    }
  }

  /// Returns the length of the scale based on whether it's measuring in feet or cm.
  int _getLength() {
    return widget.isFeet
        ? (widget.maxValue * 12) - (widget.minValue * 12).toInt() + 1
        : (widget.maxValue - widget.minValue) + 1;
  }

  /// Sets the padding for the scale text based on the length of the [widget.maxValue].
  void _getScalePadding() {
    int textLength = widget.maxValue.toString().length;
    _scalePadding = _scalePadding - (2 * textLength);
    if (_scalePadding < 0) {
      _scalePadding = 0.0;
    }
  }

  /// Returns the current value of the slider.
  double _getSliderValue() {
    return widget.isFeet
        ? ((_scaleValue.feet!.toDouble() * 12) + _scaleValue.inch!)
        : _scaleValue.cms!.toDouble();
  }
}

/// Holds the feet, inch, and cm values.
class ScaleValue {
  int? feet;
  int? inch;
  int? cms;

  ScaleValue({
    this.feet,
    this.inch,
    this.cms,
  });
}

/// Defines the type of ruler.
enum RulerType { lengthMeasurement }
