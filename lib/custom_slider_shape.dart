part of 'flutter_scale_ruler.dart';

/// A custom track shape for the slider that extends [RoundedRectSliderTrackShape].
class _CustomTrackShape extends RoundedRectSliderTrackShape {
  /// Returns the preferred rectangle for the track shape.
  ///
  /// The preferred rectangle is calculated based on the provided parameters,
  /// including the dimensions of the parent box and the current slider theme.
  ///
  /// Parameters:
  /// - [parentBox]: The parent box that contains the slider. Used to calculate the dimensions of the track.
  /// - [offset]: The offset position for the track. Defaults to [Offset.zero].
  /// - [sliderTheme]: The theme data for the slider, which includes properties like track height.
  /// - [isEnabled]: A boolean indicating whether the slider is enabled. Defaults to false.
  /// - [isDiscrete]: A boolean indicating whether the slider is discrete. Defaults to false.
  ///
  /// Returns a [Rect] representing the dimensions and position of the track.
  @override
  Rect getPreferredRect({
    required RenderBox? parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData? sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    // Get the height of the track from the slider theme.
    final double? trackHeight = sliderTheme!.trackHeight;

    // Calculate the left position of the track.
    final double trackLeft = offset.dx;

    // Calculate the top position of the track, centering it vertically within the parent box.
    final double trackTop =
        offset.dy + (parentBox!.size.height - trackHeight!) / 2;

    // Get the width of the track, which matches the width of the parent box.
    final double trackWidth = parentBox.size.width;

    // Return a rectangle representing the track's position and dimensions.
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}
