import 'package:flutter/material.dart';

class RangeInputWidget extends StatelessWidget {
  final String label;
  final String unit;
  final double? minValue;
  final double? maxValue;
  final ValueChanged<String> onChangedMin;
  final ValueChanged<String> onChangedMax;

  const RangeInputWidget({
    super.key,
    required this.label,
    required this.unit,
    this.minValue,
    this.maxValue,
    required this.onChangedMin,
    required this.onChangedMax,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: TextField(
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: 'Min',
                    suffixText: unit,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  ),
                  onChanged: onChangedMin,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text('〜'),
              ),
              Expanded(
                child: TextField(
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: 'Max',
                    suffixText: unit,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  ),
                  onChanged: onChangedMax,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
