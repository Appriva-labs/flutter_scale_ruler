import 'package:flutter/material.dart';

import 'custom_slider_shape.dart';

class ScaleRuler extends StatefulWidget {
  bool? isFeet; //if cms is true ScaleRuler will return only cms
  final int? maxValue; //maxValue is required
  final int? minValue; //minValue should be less than maxValue
  final Function? onChanged; //function will return ScaleValue
  final Color? backgroundColor; //ScaleRuler background color
  final Color? sliderActiveColor; //slider active color
  final Color? sliderInactiveColor; //slider inactive color
  final Color? sliderThumbColor; //slider thumb color
  final Color? stepIndicatorColor; // scale steps  color
  final Color? stepIndicatorDividerColor; // scale divider color
  final double? fontSize; // scale font size
  final Color? textColor; // scale text color
  RulerType? rulerType; // ruler type

  ScaleRuler.lengthMeasurement(
      {@required this.maxValue,
        @required this.minValue,
        this.onChanged,
        this.isFeet = false,
        this.backgroundColor = const Color(0xFF66BB6A),
        this.sliderActiveColor = const Color(0xFFEF5350),
        this.sliderInactiveColor = const Color(0xFF9C27B0),
        this.sliderThumbColor = Colors.green,
        this.stepIndicatorColor = Colors.black,
        this.stepIndicatorDividerColor = Colors.black45,
        this.fontSize = 11,
        this.textColor = Colors.black}) {
    rulerType = RulerType.lengthMeasurement;
  }

  @override
  _ScaleRulerState createState() => _ScaleRulerState();
}

class _ScaleRulerState extends State<ScaleRuler> {
  ScaleValue? scaleValue = ScaleValue(feet: 0, inch: 0, cms: 0);
  ScrollController scrollController = ScrollController();

  double screenMaxWidth = 0.0;
  double sliderSingleStepWidth = 0.0;
  double scaleItemWidth = 20.0;
  int? scaleStepLimit;
  bool isScrolling = false;
  double scalePadding = 20;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.isFeet!) {
      scaleValue!.feet = widget.minValue;
      scaleStepLimit = 12;
    } else {
      scaleStepLimit = 1;
      scaleValue!.cms = widget.minValue!.toInt();
    }
    getScalePadding();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.minValue! > widget.maxValue!) {
      // return error text if minValue value is greater than maxValue
      return Text(
        "value >= min && value <= max': is not true",
        style: TextStyle(color: Colors.red),
      );
    } else
      return getRulerBuild(context);
  }

  void onDragging(double lowerValue) {
    setState(() {
      try {
        int minValue = widget.minValue!;
        if (widget.isFeet!) minValue = widget.minValue! * 12;
        //find slider current position
        double sliderScrollPosition =
        (sliderSingleStepWidth * (lowerValue.toInt() - minValue));
        //find scale current position
        double listCurrentScaleScrollPosition =
        (scaleItemWidth * (lowerValue.toInt() - minValue));

        if (isScrolling) {
          //scroll scale according to slider position
          scrollController
              .jumpTo(listCurrentScaleScrollPosition - sliderScrollPosition);
        }

        if (widget.isFeet!) {
          //set feet from slider
          scaleValue!.feet = lowerValue ~/ 12;

          //set inch from slider
          scaleValue!.inch = (lowerValue % 12).truncate();
          scaleValue!.cms = 0;

          widget.onChanged!(scaleValue!);
        } else {
          //set cms from slider
          scaleValue!.cms = lowerValue.toInt();

          scaleValue!.feet = 0;
          scaleValue!.inch = 0;
          widget.onChanged!(scaleValue!);
        }
      } catch (e) {
        print(e.toString());
      }
    });
  }

  int getLength() {
    if (widget.isFeet!) {
      //return scale length for feet
      return (widget.maxValue! * 12) - (widget.minValue! * 12).toInt() + 1;
    } else {
      //return scale length for cms
      return (widget.maxValue! - widget.minValue!) + 1;
    }
  }

  void getScalePadding() {

    //set scale text row padding
    int textLength = widget.maxValue.toString().length;
    if (textLength > 1) {
      scalePadding = scalePadding - (2 * textLength);

      if (scalePadding < 0) scalePadding = 0.0;
    }
  }

  Widget getRulerBuild(BuildContext context) {
    switch (widget.rulerType) {
      case RulerType.lengthMeasurement:
        return heigthMeasureRuler(context);
      default:
        return SizedBox();
    }
  }

  Widget heigthMeasureRuler(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          //max width of scale container
          screenMaxWidth = constraints.maxWidth - 40;
          //slider single step width
          sliderSingleStepWidth = (screenMaxWidth) / (getLength() - 1);
          if (sliderSingleStepWidth > screenMaxWidth) {
            sliderSingleStepWidth = screenMaxWidth;
          }

          //set scale item width if maxvalue is more than two digit
          if (widget.maxValue! > 99)
            scaleItemWidth = 7.0 * (widget.maxValue!.toString().length);
          double scaleItemSize = scaleItemWidth * getLength();

          //set scale item width according to screen width
          if (scaleItemSize < (screenMaxWidth))
            scaleItemWidth = (screenMaxWidth) / (getLength() - 1);

          // check to make scale scrollable or not
          if ((scaleItemWidth) * (getLength() - 1) > (screenMaxWidth)) {
            isScrolling = true;
          } else {
            isScrolling = false;
          }

          return Container(
            alignment: Alignment.bottomCenter,
            padding: EdgeInsets.symmetric(vertical: 20.0),

            height: 120,
            width: screenMaxWidth + 40.0,
            // padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: widget.backgroundColor!),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: screenMaxWidth + 40,
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: SizedBox(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        thumbColor: widget.sliderThumbColor,
                        trackShape: CustomTrackShape(),
                      ),
                      child: MediaQuery.removePadding(
                        context: context,
                        removeRight: true,
                        removeLeft: true,
                        child: Slider(
                          value: (widget.isFeet!)
                              ? ((scaleValue!.feet!.toDouble() * 12) +
                              scaleValue!.inch!)
                              : scaleValue!.cms!.toDouble(),
                          min: (widget.isFeet!)
                              ? (widget.minValue! * 12)
                              : widget.minValue!.toDouble(),
                          max: (widget.isFeet!)
                              ? (widget.maxValue! * 12)
                              : widget.maxValue!.toDouble(),
                          activeColor: widget.sliderActiveColor,
                          inactiveColor: widget.sliderInactiveColor,
                          label: '${scaleValue!.cms!}',
                          onChanged: (value) {
                            onDragging(value);
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: screenMaxWidth + 40,
                  padding: EdgeInsets.only(left: 20.0, right: 2.0),
                  height: 15,
                  child: Center(
                    child: MediaQuery.removePadding(
                      context: context,
                      removeBottom: true,
                      removeLeft: true,
                      removeRight: true,
                      child: ListView.builder(
                          itemCount: (getLength() + 1),
                          controller: scrollController,
                          physics: NeverScrollableScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context1, index) {
                            // return scale steps
                            return index == getLength()
                                ? SizedBox()
                                : Container(
                              width: scaleItemWidth,
                              alignment: Alignment.bottomLeft,
                              child: SizedBox(
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    height: (index % scaleStepLimit!) == 0
                                        ? 15.0
                                        : 10.0,
                                    width: 2,
                                    color: (index % scaleStepLimit!) == 0
                                        ? widget.stepIndicatorColor
                                        : widget.stepIndicatorDividerColor,
                                  ),
                                ),
                              ),
                            );
                          }),
                    ),
                  ),
                ),
                Container(
                  width: screenMaxWidth + 40,
                  padding: EdgeInsets.only(left: scalePadding, right: 2.0),
                  height: 15,
                  child: Center(
                    child: MediaQuery.removePadding(
                      context: context,
                      removeBottom: true,
                      removeLeft: true,
                      removeRight: true,
                      child: ListView.builder(
                          itemCount: (getLength() + 1),
                          controller: scrollController,
                          physics: NeverScrollableScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context1, index) {
                            String scaleText;
                            //return scale text for cms or feet
                            if (widget.isFeet!) {
                              scaleText = ((index + widget.minValue! * 12) / 12)
                                  .truncate()
                                  .toString();
                            } else
                              scaleText = (index + widget.minValue!).toString();

                            // find text padding to align text in center
                            double? textPadding = 0.0;
                            if (scalePadding < 20) {
                              double padding = 2 * (scaleText.length.toDouble());
                              if (scalePadding + padding != 20)
                                textPadding = 20 - (scalePadding + padding);
                            }

                            return index == getLength()
                                ? SizedBox(
                              width: scaleItemWidth,
                            )
                                : Container(
                              width: scaleItemWidth,
                              padding: EdgeInsets.only(left: textPadding),
                              alignment: Alignment.bottomLeft,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.center,
                                  //mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        (index % scaleStepLimit!) == 0
                                            ? scaleText
                                            : "",
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontSize: widget.fontSize,
                                            letterSpacing: 1.0,
                                            color: widget.textColor),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          }),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }
}

class ScaleValue {
  int? feet; //provider feet only
  int? inch; //provide inch
  int? cms; //provide centimeters

  ScaleValue({this.feet, this.inch, this.cms});
}

enum RulerType { lengthMeasurement }
