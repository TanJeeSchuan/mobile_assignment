import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LabelWithSymbolAndValue extends StatelessWidget {
  final String label;
  final String value;
  final Color symbolColor;
  final IconData? icon; // optional icon inside the symbol box

  const LabelWithSymbolAndValue({
    super.key,
    required this.label,
    required this.value,
    required this.symbolColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Symbol box
        Container(
          height: 20,
          width: 20,
          decoration: BoxDecoration(
            color: symbolColor,
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(2, 2),
              ),
            ],
          ),
          child: icon != null
              ? Center(
            child: Icon(
              icon,
              size: 12,
              color: Colors.white,
            ),
          )
              : null,
        ),
        const SizedBox(width: 8),

        // Label text
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),

        const SizedBox(width: 8),
        // Value text (right-aligned with fixed width)
        SizedBox(
          child: Text(
            value.toString(),
            textAlign: TextAlign.left,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

