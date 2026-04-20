import 'package:flutter/material.dart';
import '../../core/constants/frequencies.dart';

class FrequencySlider extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final ValueChanged<double> onChanged;

  const FrequencySlider({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${value.toStringAsFixed(0)} Hz',
                  style: TextStyle(
                    color: color,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Slider(
            value: value,
            min: FrequencyConstants.minHz,
            max: FrequencyConstants.maxHz,
            divisions: ((FrequencyConstants.maxHz - FrequencyConstants.minHz) /
                    5)
                .round(),
            activeColor: color,
            inactiveColor: color.withOpacity(0.25),
            onChanged: onChanged,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${FrequencyConstants.minHz.toStringAsFixed(0)} Hz',
                style: TextStyle(fontSize: 10, color: color.withOpacity(0.5)),
              ),
              Text(
                '${FrequencyConstants.maxHz.toStringAsFixed(0)} Hz',
                style: TextStyle(fontSize: 10, color: color.withOpacity(0.5)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
