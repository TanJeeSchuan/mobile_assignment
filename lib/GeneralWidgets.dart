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

class ItemsTable extends StatelessWidget {
  final List<Map<String, dynamic>> items;

  const ItemsTable({
    Key? key,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Table(
        columnWidths: const {
          0: FixedColumnWidth(120),
          1: FlexColumnWidth(),
          2: FixedColumnWidth(50),
        },
        border: TableBorder(
          horizontalInside: BorderSide(color: Colors.grey.shade300),
        ),
        children: [
          // header row
          TableRow(
            decoration: BoxDecoration(
                color: Colors.grey.shade50),
            children: const [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Code',
                    style:
                    TextStyle(fontWeight: FontWeight.w700)),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Item Name',
                    style:
                    TextStyle(fontWeight: FontWeight.w700)),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Qty',
                    style:
                    TextStyle(fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center),
              ),
            ],
          ),
          // item rows
          ...items.map((it) {
            return TableRow(children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 10, horizontal: 8),
                child: Text(it['code'],
                    style: const TextStyle(fontSize: 13)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 10, horizontal: 8),
                child: Text(it['name'],
                    style: const TextStyle(fontSize: 13)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 10, horizontal: 8),
                child: Text(it['qty'].toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13)),
              ),
            ]);
          }).toList(),
        ],
      ),
    );
  }
}
