import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_assignment/service/DeliveryService.dart';
import 'package:intl/intl.dart';

import 'AppColors.dart';
import 'Defines.dart';
import 'GeneralWidgets.dart';
import 'DeliveryCard.dart';
import 'models/Delivery.dart';

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

// final List<OrderStage> orderStages = [
//   OrderStage(stage: "Order Confirmed", status: "Completed", time: "5 Jun, 6.00 p.m."),
//   OrderStage(stage: "Packing Finished", status: "Completed", time: "6 Jun, 9.45 p.m."),
//   OrderStage(stage: "Package Pickup", status: "Current", time: "6 Jun, 11.40 p.m."),
//   OrderStage(stage: "Package Dropoff", status: "Pending", time: "-"),
//   OrderStage(stage: "Order Complete", status: "Pending", time: "-"),
// ];


class OrderDetail extends StatefulWidget{
  final String deliveryId;

  OrderDetail({super.key, required this.deliveryId});

  @override
  State<OrderDetail> createState() => _OrderDetailState();

  static StatusBarOrderType _getStatusFromDelivery(Delivery delivery){
    var txt = delivery.toOrderSummary().status;

    if(txt == "Packing") {
      return StatusBarOrderType.packing;
    }
    else if(txt == "Ready To Ship"){
      return StatusBarOrderType.ready;
    }
    else if (txt == "In Transit") {
      return StatusBarOrderType.transit;
    }
    else{
      return StatusBarOrderType.arrived;
    }
  }
}

class _OrderDetailState extends State<OrderDetail> {
  late Future<Delivery?> _deliveryFuture;

  Future<Delivery?> fetchDelivery(deliveryId) async {
    return await DeliveryService().fetchDeliveryDetail(deliveryId);
  }

  @override initState(){
    super.initState();
    _deliveryFuture = fetchDelivery(widget.deliveryId);
  }

  @override
  Widget build(BuildContext context) {
    print("Current route: ${GoRouter.of(context).routeInformationProvider.value.uri}");

    return FutureBuilder(
        future: _deliveryFuture,
        builder: (context, asyncSnapshot) {
          if (asyncSnapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              appBar: DetailedAppBar(
                  appBarIcon: Icons.account_box,
                  heading: "Order Details",
                  subheading: "Loading Details..."
              ),
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (asyncSnapshot.hasError) {
            // final rawData = asyncSnapshot.data;
            // print("DEBUG rawData runtimeType: ${rawData.runtimeType}");
            // print("DEBUG rawData value: $rawData");
            // throw asyncSnapshot.error!;
            return Center(
                child: Text('Error: ${asyncSnapshot.error}'),
            );
          }

          final delivery = asyncSnapshot.data;
          if (delivery == null) {
            return Center(
              child: Text('Delivery not found'),
            );
          }

          return Scaffold(
            appBar: DetailedAppBar(
                appBarIcon: Icons.account_box,
                heading: "Order Details",
                subheading: "Deliver By ${delivery.deliverBy}"
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
                    DeliveryCardContents(delivery: delivery.toOrderSummary()),
                    SizedBox(height: 16),
                    //OrderProgression(status: _getStatusFromDelivery(delivery)),
                    TrackingHistory(delivery: delivery),
                    SizedBox(height: 16),
                    PackageDetails(delivery: delivery),
                    SizedBox(height: 16),
                    AttachmentsFrame(delivery: delivery),
                    SizedBox(height: 16),
                    VerificationDetails(delivery: delivery),
                    // SizedBox(height: 16),
                    // ContactsFrame(),
                    SizedBox(height: 26),
                    StepConfirmedButton(delivery: delivery),
                    SizedBox(height: 26),
                  ],
                ),
              ),
            ),
          );
        }
      );
  }
}

_formatDate(DateTime deliverBy) {
  // Custom formatter
  final formatter = DateFormat("h:mm a"); // Example: 9:50 AM
  var formatted = formatter.format(deliverBy);

  // Add periods into AM/PM manually
  formatted = formatted.replaceAll("AM", "A.M.").replaceAll("PM", "P.M.");

  return formatted;
}

class VerificationDetails extends StatelessWidget{
  final Delivery delivery;

  const VerificationDetails(
      {
        super.key,
        required this.delivery
      });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Verification",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          Container(
            child: Column(
              children: [
                Column(
                  children: [
                    VerificationStatusRow(label: "Pickup Verified",
                      verified: delivery.isPickupVerified(),
                      onDetails: () {
                        context.push(
                          '/home/deliveryDetail/${delivery.deliveryId}/pickupVerification/verified',
                        );
                      }
                    ),
                    VerificationStatusRow(label: "Dropoff Verified",
                        verified: delivery.isDropoffVerified(),
                        onDetails: () {
                          context.push(
                            '/home/deliveryDetail/${delivery.deliveryId}/dropoffVerification/verified',
                          );
                        }
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class StepConfirmedButton extends StatelessWidget{
  final Delivery delivery;

  StepConfirmedButton({super.key, required Delivery this.delivery});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      height: 48,
      child: ElevatedButton(
          onPressed: delivery.getCurrentStageName() == "ready" ||  delivery.getCurrentStageName() == "transit" ? (){
            navigateToVerification(delivery, context);
          } : null,
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

navigateToVerification(Delivery delivery, BuildContext context){
  var dS = delivery.toOrderSummary();
  if(dS.status == "Ready To Ship"){
    //print("Current route: ${GoRouter.of(context).routeInformationProvider.value.uri}");

    context.push('/home/deliveryDetail/${dS.orderId}/pickupVerification');

  } else {
    //print("Current route: ${GoRouter.of(context).routeInformationProvider.value.uri}");

    context.push('/home/deliveryDetail/${dS.orderId}/dropoffVerification');
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
  List<DeliveryAttachment> attachments;

  AttachmentsFrame({super.key, required Delivery delivery}): attachments = delivery.attachments;

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
        SizedBox(
          height: 150,
          child:
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  attachments.length,
                  (index) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ImageWithPreviewUrl(
                      imageUrl: attachments[index].downloadUrl,
                    ),
                  ),
                ),
              ),
            ),

          // ListView.builder(
          //   scrollDirection: Axis.horizontal,
          //   itemCount: attachments.length,
          //   itemBuilder: (context, index) {
          //     return Padding(
          //       padding: const EdgeInsets.all(8.0),
          //       child: WebImage(url: attachments[index].downloadUrl),
          //     );
          //   },
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            // image icon
            // children: [
            //   Image.asset(
            //     'assets/image_icon.png',
            //     width: 84,
            //     height: 84,
            //     fit: BoxFit.contain, // or cover, fill, etc.
            //   ),
            //   Image.asset(
            //     'assets/image_icon.png',
            //     width: 84,
            //     height: 84,
            //     fit: BoxFit.contain, // or cover, fill, etc.
            //   ),
            //   Image.asset(
            //     'assets/more_icon.png',
            //     width: 84,
            //     height: 84,
            //     fit: BoxFit.contain, // or cover, fill, etc.
            //   )
            // ]
        ),
      ],
    );
  }
}

class WebImage extends StatelessWidget{
  final String url;

  const WebImage({
    super.key,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child; // finished loading
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return const Center(
          child: Icon(
            Icons.broken_image,
            size: 48,
            color: Colors.grey,
          ),
        );
      },
    );
  }
}

class PackageDetails extends StatelessWidget{
  // final List<DeliveryPart> partsList;
  final Delivery delivery;

  PackageDetails({super.key, required Delivery delivery}): this.delivery = delivery;

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
        PartsDataTable(delivery: delivery,),
      ],
    );
  }
}

class TrackingHistory extends StatelessWidget{
  final Delivery delivery;
  TrackingHistory({super.key, required this.delivery});

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
        ScheduleTable(stages: delivery.toStages()),
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
        OrderProgression(status: StatusBarOrderType.ready),

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
          Expanded(
            child: Column(
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
            ),
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
  List<Map<String, dynamic>> parts;

  PartsDataTable({super.key, required Delivery delivery }): parts = delivery.partsListToMap();  //parts = PartsDataTable._partsListToMap(partsList);

  // static List<Map<String, dynamic>> _partsListToMap(List<DeliveryPart> partsList) {
  //   return partsList.map((part) {
  //     return {
  //       "code": part.code,
  //       "name": part.name,
  //       "qty": part.quantity
  //     };
  //   }).toList();
  // }

  @override
  Widget build(BuildContext context) {
    // final parts = [
    //   {"code": "MY-PRO-0001", "name": "Brake Pads for Proton Saga", "qty": 12},
    //   {"code": "MY-PER-0002", "name": "Oil Filters for Perodua Myvi", "qty": 25},
    //   {"code": "MY-PRO-0003", "name": "Air Filters for Proton Persona", "qty": 18},
    //   {"code": "MY-PER-0004", "name": "Timing Belts for Perodua Axia", "qty": 10},
    //   {"code": "MY-PRO-0005", "name": "Spark Plugs for Proton Iriz", "qty": 40},
    //   {"code": "MY-PER-0006", "name": "Shock Absorbers for Perodua Bezza", "qty": 7},
    // ];
    return ItemsTable(items: parts);
  }
}

class ScheduleTable extends StatelessWidget {
  final List<Map<String, dynamic>> stages;

  const ScheduleTable({
    Key? key,
    required this.stages,
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
          2: FixedColumnWidth(200),
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
                child: Text('Stage',
                    style:
                    TextStyle(fontWeight: FontWeight.w700)),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Status',
                    style:
                    TextStyle(fontWeight: FontWeight.w700)),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Time',
                    style:
                    TextStyle(fontWeight: FontWeight.w700),
                    textAlign: TextAlign.left),
              ),
            ],
          ),
          // item rows
          ...stages.map((it) {
            return TableRow(children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 10, horizontal: 8),
                child: Text(
                  it['stage']?.toString() ?? 'N/A',
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    vertical: 10, horizontal: 8),
                child: Text(
                  it['status']?.toString() ?? 'N/As',
                  style: TextStyle(fontSize: 13),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 10, horizontal: 8),
                child: Text(
                  it['timestamp']?.toString() ?? 'N/A',
                  textAlign: TextAlign.left,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ]);
          }).toList(),
        ],
      ),
    );
  }
}

class VerificationStatusRow extends StatelessWidget {
  final String label;
  final bool verified;
  final VoidCallback? onDetails; // optional callback

  const VerificationStatusRow({
    super.key,
    required this.label,
    required this.verified,
    this.onDetails,
  });

  @override
  Widget build(BuildContext context) {
    final statusText = verified ? "YES" : "PENDING";
    final statusColor = verified ? Colors.green : Colors.orange;
    final statusIcon = verified ? Icons.check_circle : Icons.hourglass_empty;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side label
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),

          // Right side: status + optional details
          Row(
            children: [
              // Status pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(statusIcon, size: 18, color: statusColor),
                    const SizedBox(width: 6),
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),

              // Show "Details" button only if verified
              if (verified) ...[
                const SizedBox(width: 10),
                TextButton(
                  onPressed: onDetails,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  child: const Text(
                    "Details",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ]
            ],
          ),
        ],
      ),
    );
  }
}

