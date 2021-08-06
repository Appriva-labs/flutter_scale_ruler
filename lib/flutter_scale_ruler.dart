import 'package:flutter/material.dart';

import 'custom_slider_shape.dart';

class ScaleRuler extends StatefulWidget {
  final bool? isCMS;
  final int? maxValue;
  final int? minValue;
  final Function? onChanged;
  final Color? backgroundColor;
  final Color? sliderActiveColor;
  final Color? sliderInactiveColor;
  final Color? sliderThumbColor;
  final Color? stepIndicatorColor;
  final Color? stepIndicatorDividerColor;
  final double? fontSize;
  final Color? textColor;

  ScaleRuler(
      {@required this.maxValue,
        @required this.minValue,
        this.onChanged,
        this.isCMS = false,
        this.backgroundColor = const Color(0xFF66BB6A),
        this.sliderActiveColor = const Color(0xFFEF5350),
        this.sliderInactiveColor = const Color(0xFF9C27B0),
        this.sliderThumbColor = Colors.green,
        this.stepIndicatorColor = Colors.black,
        this.stepIndicatorDividerColor = Colors.black45,
        this.fontSize = 11,
        this.textColor = Colors.black});

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (!widget.isCMS!) {
      scaleValue!.feet = widget.minValue;
      scaleStepLimit = 12;
    } else {
      scaleStepLimit = 1;
      scaleValue!.cms = widget.minValue!.toInt();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.minValue! > widget.maxValue!)
      return Text(
        "value >= min && value <= max': is not true",
        style: TextStyle(color: Colors.red),
      );
    else
      return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            screenMaxWidth = constraints.maxWidth;
            sliderSingleStepWidth = (screenMaxWidth - 40) / (getLength()-1);
            if (sliderSingleStepWidth > screenMaxWidth) {
              sliderSingleStepWidth = screenMaxWidth;
            }

            if (widget.maxValue! > 99)
              scaleItemWidth = 10.0 * (widget.maxValue!.toString().length);

            double scaleItemSize = scaleItemWidth * getLength();

            if (scaleItemSize < (screenMaxWidth - 40))
              scaleItemWidth = (screenMaxWidth - 40) / (getLength()-1 );

            if ((scaleItemWidth) * (getLength() - 1) > (screenMaxWidth - 40)) {
              isScrolling = true;
            } else {
              isScrolling = false;
            }

            return Container(
              alignment: Alignment.bottomCenter,
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),

              height: 120,
              width: screenMaxWidth,
              // padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: widget.backgroundColor!),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: screenMaxWidth,
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
                            value: (!widget.isCMS!)
                                ? ((scaleValue!.feet!.toDouble() * 12) +
                                scaleValue!.inch!)
                                : scaleValue!.cms!.toDouble(),
                            min: (!widget.isCMS!)
                                ? (widget.minValue! * 12)
                                : widget.minValue!.toDouble(),
                            max: (!widget.isCMS!)
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
                  Expanded(
                    child: Container(
                      width: screenMaxWidth,
                      padding: EdgeInsets.symmetric(horizontal: 0.0),
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
                                String text;
                                if (!widget.isCMS!) {
                                  text = ((index + widget.minValue! * 12) / 12)
                                      .truncate()
                                      .toString();
                                } else
                                  text = (index + widget.minValue!).toString();

                                return index==getLength()?SizedBox():Container(
                                  width: index == (getLength() - 2)
                                      ? scaleItemWidth - 8
                                      : scaleItemWidth,
                                  alignment: Alignment.bottomLeft,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      SizedBox(
                                        width: index == (getLength() - 2)
                                            ? scaleItemWidth - 8
                                            : scaleItemWidth,
                                        child: Wrap(
                                          children: [
                                            Container(
                                              height:
                                              (index % scaleStepLimit!) == 0
                                                  ? 15.0
                                                  : 10.0,
                                              width: 2,
                                              color: (index % scaleStepLimit!) ==
                                                  0
                                                  ? widget.stepIndicatorColor
                                                  : widget
                                                  .stepIndicatorDividerColor,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                          width: index == (getLength() - 2)
                                              ? scaleItemWidth - 10
                                              : scaleItemWidth,
                                          child: Text(
                                            (index % scaleStepLimit!) == 0
                                                ? text
                                                : "",
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontSize: widget.fontSize,
                                                color: widget.textColor),
                                          ))
                                    ],
                                  ),
                                );
                              }),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          });
  }

  void onDragging(double lowerValue) {
    setState(() {
      try {
        int minValue = widget.minValue!;
        if (!widget.isCMS!) minValue = widget.minValue! * 12;
        double sliderScrollPosition =
        (sliderSingleStepWidth * (lowerValue.toInt() - minValue));
        double listCurrentScaleScrollPosition =
        (scaleItemWidth * (lowerValue.toInt() - minValue));

        if (isScrolling) {
          scrollController
              .jumpTo(listCurrentScaleScrollPosition - sliderScrollPosition);
        }

        if (!widget.isCMS!) {
          scaleValue!.feet = lowerValue ~/ 12;

          scaleValue!.inch = (lowerValue % 12).truncate();
          scaleValue!.cms = 0;

          widget.onChanged!(scaleValue!);
        } else {
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
    if (!widget.isCMS!)
      return (widget.maxValue! * 12) - (widget.minValue! * 12).toInt() + 1;
    else
      return (widget.maxValue! - widget.minValue!) + 1;
  }
}

class ScaleValue {
  int? feet;
  int? inch;
  int? cms;

  ScaleValue({this.feet, this.inch, this.cms});
}
