import 'package:flutter/material.dart';

import 'AppColors.dart';
import 'Defines.dart';
import 'GeneralWidgets.dart';
import 'OrderCard.dart';

class OrderStage {
  final String stage;
  final String status;
  final String time;

  OrderStage({
    required this.stage,
    required this.status,
    required this.time,
  });
}

final List<OrderStage> orderStages = [
  OrderStage(stage: "Order Confirmed", status: "Completed", time: "5 Jun, 6.00 p.m."),
  OrderStage(stage: "Packing Finished", status: "Completed", time: "6 Jun, 9.45 p.m."),
  OrderStage(stage: "Package Pickup", status: "Current", time: "6 Jun, 11.40 p.m."),
  OrderStage(stage: "Package Dropoff", status: "Pending", time: "-"),
  OrderStage(stage: "Order Complete", status: "Pending", time: "-"),
];


class OrderDetail extends StatelessWidget{
  const OrderDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DetailedAppBar(
        appBarIcon: Icons.account_box,
        heading: "Order Details",
        subheading: "Posted At 9:50 A.M."
      ),
      body: SingleChildScrollView(
        child:Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8), // rounded corners
            border: Border.all(
              color: Colors.grey.shade300, // thin border
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.28),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(3, 4), // shadow direction
              ),
            ],
          ),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 45), // outside space
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6), // inside space
          child: Column(
            children: [
              DeliveryCardContents(),
              SizedBox(height: 16),
              TrackingHistory(),
              SizedBox(height: 16),
              PackageDetails(),
              SizedBox(height: 16),
              AttachmentsFrame(),
              SizedBox(height: 16),
              ContactsFrame(),
              SizedBox(height: 26),
              StepConfirmedButton(),
              SizedBox(height: 26),
            ],
          ),
        ),
      )
    );
  }
}

class StepConfirmedButton extends StatelessWidget{
  const StepConfirmedButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      height: 48,
      child: ElevatedButton(
          onPressed: (){
            //TODO go to verification
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.stepActive, // button background color
            foregroundColor: Colors.white, // text/icon color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // <-- rounded corners
            ),
          ),
          child: Text("Step Confirmed"),
      ),
    );
  }
}

class ContactsFrame extends StatelessWidget {
  const ContactsFrame({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Contacts",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(2), // rounded corners
            border: Border.all(
              color: Colors.black, // thin border
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.28),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(3, 4), // shadow direction
              ),
            ],
          ),
          child: SizedBox(
            width: MediaQuery.of(context).size.width, // force full parent width
            child: Column(
              children: [
                Row(
                  children: const [
                    Icon(Icons.account_box),
                    SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: Text("Purchasing Officer"),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text("Ahmad Zulkifli"),
                    ),
                    Icon(Icons.phone),
                    SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child: Text("0123456789"),
                    ),
                  ],
                ),
                Divider(),
                Row(
                  children: const [
                    Icon(Icons.account_box),
                    SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: Text("Warehouse Manager"),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text("Roslan Tan"),
                    ),
                    Icon(Icons.phone),
                    SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child: Text("0132223344"),
                    ),
                  ],
                ),
                Divider(),
                Row(
                  children: const [
                    Icon(Icons.account_box),
                    SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: Text("Delivery Coordinator"),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text("Faizal Wong"),
                    ),
                    Icon(Icons.phone),
                    SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child: Text("0118889990"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class AttachmentsFrame extends StatelessWidget{
  const AttachmentsFrame({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Attachments",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          // image icon
          children: [
            Image.asset(
              'assets/image_icon.png',
              width: 84,
              height: 84,
              fit: BoxFit.contain, // or cover, fill, etc.
            ),
            Image.asset(
              'assets/image_icon.png',
              width: 84,
              height: 84,
              fit: BoxFit.contain, // or cover, fill, etc.
            ),
            Image.asset(
              'assets/more_icon.png',
              width: 84,
              height: 84,
              fit: BoxFit.contain, // or cover, fill, etc.
            )
          ]
        ),
      ],
    );
  }
}

class PackageDetails extends StatelessWidget{
  const PackageDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Package Details",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        PartsDataTable(),
      ],
    );
  }
}

class TrackingHistory extends StatelessWidget{
  const TrackingHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Tracking History",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        const OrderStageTable(),
      ],
    );
  }
}

class OrderHeader extends StatelessWidget {
  const OrderHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Delivery #12345",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Container(
                width: 155,
                height: 45,
                decoration: BoxDecoration(
                  color: AppColors.ready,
                  borderRadius: BorderRadius.circular(6), // rounded corners
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(2, 2), // shadow position
                    ),
                  ],
                ),
                child: Center(
                    child: Text("Ready for pickup")
                )
            )
          ],
        ),
        const Divider(
          color: Colors.black54,
          thickness: 1,   // line thickness
          height: 30,     // space above + below
        ),
        Column(
          children: [
            LabelWithSymbolAndValue(
              label: "Warehouse:",
              value: "Batu Caves Hub",
              symbolColor: Colors.black,
              icon: Icons.dataset,
            ),
            const SizedBox(height: 12), // spacing
            LabelWithSymbolAndValue(
              label: "Volume:",
              value: "2 Boxes",
              symbolColor: Colors.black,
              icon: Icons.add_box,
            ),
            const SizedBox(height: 12), // spacing
            LabelWithSymbolAndValue(
              label: "Drop Off:",
              value: "Sentul Workshop",
              symbolColor: Colors.black,
              icon: Icons.folder,
            ),
            const SizedBox(height: 12), // spacing
            LabelWithSymbolAndValue(
              label: "Weight:",
              value: "15kg",
              symbolColor: Colors.black,
              icon: Icons.monitor_weight,
            ),
          ],
        ),
        const Divider(
          color: Colors.black54,
          thickness: 1,   // line thickness
          height: 30,     // space above + below
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LabelWithSymbolAndValue(
              label: "Deliver By:",
              value: "7 June, 12pm",
              symbolColor: Colors.black,
              icon: Icons.timer,
            ),
          ],
        ),
        SizedBox(height: 28,),
        OrderProgression(),

      ],
    );
  }

}

class DetailedAppBar extends StatelessWidget implements PreferredSizeWidget{
  final IconData? appBarIcon;
  final String heading;
  final String subheading;

  const DetailedAppBar({
    super.key,
    this.appBarIcon,
    this.heading = "",
    this.subheading = "",
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          Icon(
            appBarIcon,
            size: 48,
          ),
          SizedBox(
            width: 18,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start, // left-align text
            children: [
              Text(
                heading,
                textAlign: TextAlign.left,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                subheading,
                textAlign: TextAlign.left,
                style: const TextStyle(fontWeight: FontWeight.normal),
              )
            ],
          )
        ],
      ),
      leading: Padding(
        padding: const EdgeInsets.only(left: 12), // space behind back button
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(6), // <-- rounded square
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class OrderStageTable extends StatelessWidget {
  const OrderStageTable({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // fit to parent width
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal, // allows full width scrolling if needed
        child: DataTable(
          columnSpacing: 2, // space between columns
          headingRowHeight: 48, // fixed header row height
          dataRowMinHeight: 48, // min row height
          dataRowMaxHeight: double.infinity, // expands based on text
          columns: const [
            DataColumn(label: Text('Stage')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Time')),
          ],
          rows: const [
            DataRow(cells: [
              DataCell(Padding(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Text("Order Confirmed"),
              )),
              DataCell(Padding(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Text("Completed"),
              )),
              DataCell(Padding(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Text("5 Jun, 6.00 p.m."),
              )),
            ]),
            DataRow(cells: [
              DataCell(Padding(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Text("Packing Finished"),
              )),
              DataCell(Padding(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Text("Completed"),
              )),
              DataCell(Padding(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Text("6 Jun, 9.45 p.m."),
              )),
            ]),
            DataRow(cells: [
              DataCell(Padding(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Text("In Transit"),
              )),
              DataCell(Padding(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Text("Pending"),
              )),
              DataCell(Padding(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Text("—"),
              )),
            ]),
          ],
        ),
      ),
    );
  }
}

class PartsDataTable extends StatelessWidget {
  const PartsDataTable({super.key});

  @override
  Widget build(BuildContext context) {
    final parts = [
      {"code": "MY-PRO-0001", "name": "Brake Pads for Proton Saga", "qty": 12},
      {"code": "MY-PER-0002", "name": "Oil Filters for Perodua Myvi", "qty": 25},
      {"code": "MY-PRO-0003", "name": "Air Filters for Proton Persona", "qty": 18},
      {"code": "MY-PER-0004", "name": "Timing Belts for Perodua Axia", "qty": 10},
      {"code": "MY-PRO-0005", "name": "Spark Plugs for Proton Iriz", "qty": 40},
      {"code": "MY-PER-0006", "name": "Shock Absorbers for Perodua Bezza", "qty": 7},
    ];

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 0,
          headingRowHeight: 16,
          dataRowMinHeight: 0,
          dataRowMaxHeight: double.infinity,
          columns: const [
            DataColumn(label: Text('Code', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Item Name', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Qty', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: parts.map((part) {
            return DataRow(cells: [
              DataCell(Padding(
                padding: const EdgeInsets.all(0.0),
                child: Text(part["code"].toString()),
              )),
              DataCell(Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(part["name"].toString()),
              )),
              DataCell(Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(part["qty"].toString()),
              )),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}
