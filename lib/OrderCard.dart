import 'package:flutter/material.dart';

import 'AppColors.dart';
import 'Defines.dart';
import 'GeneralWidgets.dart';
import 'OrderDetail.dart';

class DeliveryCard extends StatelessWidget{
  const DeliveryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 22,vertical: 16),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8), // rounded corners
          border: Border.all(
            color: Colors.grey.shade300, // thin border
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 12), // shadow direction
            ),
          ],
        ),
        child: Column(
          children: [
            DeliveryCardContents(),
            SizedBox(height: 28,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                    child: ElevatedButton (
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (context) => const OrderDetail(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.transit, // button background color
                        foregroundColor: Colors.white, // text/icon color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12), // <-- rounded corners
                        ),
                      ),
                      child: Text("Detail"),
                    )
                ),
                SizedBox(width: 52,),
                Expanded(
                    child: ElevatedButton (
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.stepActive, // button background color
                        foregroundColor: Colors.white, // text/icon color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12), // <-- rounded corners
                        ),
                      ),
                      child: Text("Step Confirmed"),
                    )
                )
              ],
            )
          ],
        ),
      );
  }
}

class DeliveryCardContents extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center, // centers horizontally
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

// TODO modify to stateful
class OrderProgression extends StatelessWidget{
  const OrderProgression({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final arrowSize = screenWidth * 0.03; // 3% of screen width

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: OrderProgressIcon(
            orderType: StatusBarOrderType.packing,
            status: OrderStageStatus.completed,
          ),
        ),
        Align(
          alignment: Alignment.center, // vertical center
          child: Icon(
            Icons.arrow_forward_ios,
            size: arrowSize,
          ),
        ),
        Expanded(
          child: OrderProgressIcon(
            orderType: StatusBarOrderType.ready,
            status: OrderStageStatus.active,
          ),
        ),
        Icon(
          Icons.arrow_forward_ios,
          size: arrowSize,
        ),
        Expanded(
          child: OrderProgressIcon(
            orderType: StatusBarOrderType.transit,
            status: OrderStageStatus.pending,
          ),
        ),
        Icon(
          Icons.arrow_forward_ios,
          size: arrowSize,
        ),
        Expanded(
          child: OrderProgressIcon(
            orderType: StatusBarOrderType.arrived,
            status: OrderStageStatus.pending,
          ),
        ),
      ],
    );
  }
}

class OrderProgressIcon extends StatefulWidget{
  final StatusBarOrderType orderType;
  final OrderStageStatus status; // 👈 status variable added

  const OrderProgressIcon({
    super.key,
    required this.status,
    required this.orderType,
  });

  @override
  State<StatefulWidget> createState() {
    return _OrderProgressIconState();
  }
}

class _OrderProgressIconState extends State<OrderProgressIcon>{
  Color boxColor = AppColors.stepPending;
  IconData icon = Icons.error;
  String desc = "";

  void _setText(){
    switch(widget.orderType){
      case StatusBarOrderType.packing:
        desc = "Packing";
        break;
      case StatusBarOrderType.ready:
        desc = "Ready to Ship";
        break;
      case StatusBarOrderType.transit:
        desc = "In Transit";
        break;
      case StatusBarOrderType.arrived:
        desc = "Arrived";
        break;
    }
  }

  void _setIconData(){
    switch(widget.orderType){
      case StatusBarOrderType.packing:
        icon = Icons.checklist;
        break;
      case StatusBarOrderType.ready:
        icon = Icons.trolley;
        break;
      case StatusBarOrderType.transit:
        icon = Icons.local_shipping;
        break;
      case StatusBarOrderType.arrived:
        icon = Icons.warehouse;
        break;
    }
  }

  void _setBoxColor(){
    switch(widget.status) {
      case OrderStageStatus.pending:
        boxColor = AppColors.stepPending;
        break;
      case OrderStageStatus.active:
        boxColor = AppColors.stepActive;
        break;
      case OrderStageStatus.completed:
        boxColor = AppColors.stepCompleted;
        break;
    }
  }

  @override
  void initState() {
    super.initState();

    _setIconData();
    _setBoxColor();
    _setText();
  }


  @override
  void didUpdateWidget(covariant OrderProgressIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 👈 Update colors/icons when parent changes props
    _setIconData();
    _setBoxColor();
    _setText();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(  // icon display
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: boxColor, // background color
            borderRadius: BorderRadius.circular(12), // rounded corners
          ),
          child: Icon(
            icon,
            size: 32,
            color: Colors.black, // optional
          ),
        ),
        Text(       // bottom text
          desc,
          textAlign: TextAlign.center,
        )
      ],
    );
  }
}