import 'package:flutter/material.dart';

class CustomSlider extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final int? divisions; // Divisions are now optional
  final String? label; // Label is now optional
  final Function(double) onChanged;
  final Function(double) onChangeEnd;

  const CustomSlider({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    this.divisions,
    this.label,
    required this.onChanged,
    required this.onChangeEnd,
  });

  @override
  Widget build(BuildContext context) {
    // This theme data is fine-tuned to match your prototype
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 6.0,
        trackShape: const RoundedRectSliderTrackShape(),
        activeTrackColor: Theme.of(context).primaryColor,
        inactiveTrackColor: Colors.grey.shade800,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10.0),
        thumbColor: Colors.white,
        overlayColor: Theme.of(context).primaryColor.withAlpha(0x29),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 24.0),
        tickMarkShape: const RoundSliderTickMarkShape(),
        activeTickMarkColor: Colors.transparent,
        inactiveTickMarkColor: Colors.transparent,
        valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
        valueIndicatorColor: Theme.of(context).primaryColor,
        valueIndicatorTextStyle: const TextStyle(color: Colors.white),
      ),
      child: Slider(
        value: value,
        min: min,
        max: max,
        divisions: divisions,
        label: label,
        onChanged: onChanged,
        onChangeEnd: onChangeEnd,
      ),
    );
  }
}
