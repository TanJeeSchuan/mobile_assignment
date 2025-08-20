import 'package:flutter/material.dart';
import 'package:mobile_assignment/AppColors.dart';

import 'OrderDetail.dart';

enum StatusBarOrderType{
  packing,
  ready,
  transit,
  arrived,
}

enum OrderStageStatus {
  pending,
  active,
  completed,
}

class OrderStrings {
  static const String awaiting = "Awaiting";
  static const String packing = "Packing";
  static const String ready   = "Ready";
  static const String transit = "Transit";
  static const String arrived = "Arrived";
}

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Greenstem Delivery"),
          backgroundColor: Color(0xFF03A9F4),
          actions: <Widget>[
            IconButton(
              onPressed: (){},
              icon: const Icon(Icons.account_circle_sharp),
            )
          ],
        ),
        body: SingleChildScrollView(
            child: Column(
          children: [
            // order status
            OrderStatus(),
            // delivery cards
            Column(
              children: [
                DeliveryCard(),
                DeliveryCard(),
              ],
            )
          ],
        )
      )
    );
  }
}

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  OrderProgressIcon(
                    orderType: StatusBarOrderType.packing,
                    status: OrderStageStatus.completed,
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                  ),
                  OrderProgressIcon(
                    orderType: StatusBarOrderType.ready,
                    status: OrderStageStatus.active,
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                  ),
                  OrderProgressIcon(
                    orderType: StatusBarOrderType.transit,
                    status: OrderStageStatus.pending,
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                  ),
                  OrderProgressIcon(
                    orderType: StatusBarOrderType.arrived,
                    status: OrderStageStatus.pending,
                  ),
                ],
              ),
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
        Container(
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
        Text(
          desc,

        )
      ],
    );
  }
}

class OrderStatus extends StatelessWidget{

  const OrderStatus({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 22,vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
          Align(
            alignment: Alignment.centerLeft,
            child: Text (
              "Order Status",
              textAlign: TextAlign.left,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
          ),
          Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column (
                children: [
                  DashboardStatusBar(type: StatusBarOrderType.packing),
                  DashboardStatusBar(type: StatusBarOrderType.ready),
                  DashboardStatusBar(type: StatusBarOrderType.transit),
                  DashboardStatusBar(type: StatusBarOrderType.arrived),
                ],
              )
          )
        ],
      )
    );
  }
}

class DashboardStatusBar extends StatefulWidget{
  final StatusBarOrderType type;

  const DashboardStatusBar({
    super.key,
    required this.type,
  });

  @override
  State<DashboardStatusBar> createState() => _DashboardStatusBarState();
}

class _DashboardStatusBarState extends State<DashboardStatusBar> {
  String orderString = OrderStrings.awaiting;
  Color squareColor = AppColors.defaultColor;
  int orderTypeNum = 0;

  void _setOrderData(){
    switch(widget.type){
      case StatusBarOrderType.packing:
        orderString = OrderStrings.packing;
        squareColor = AppColors.packing;
        break;
      case StatusBarOrderType.ready:
        orderString = OrderStrings.ready;
        squareColor = AppColors.ready;
        break;
      case StatusBarOrderType.transit:
        orderString = OrderStrings.transit;
        squareColor = AppColors.transit;
        break;
      case StatusBarOrderType.arrived:
        orderString = OrderStrings.arrived;
        squareColor = AppColors.arrived;
        break;
    }
  }

  @override
  void initState(){
    super.initState();
    _setOrderData();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
        child:Row(
        children: [
          ColoredBox(
            color: squareColor, // Set the background color
            child: SizedBox(
              height: 25.0, // Specify the height of the square
              width:  25.0,  // Specify the width of the square
            ),
          ),
          // SizedBox(width: 20, height: 1,),
          const SizedBox(width: 8),
          SizedBox(
            width: 60,
            child: Text(orderString),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: const Divider(
                color: Colors.black,
                thickness: 1,
              ),
            ),
          ),
          // Count (right-aligned in fixed width)
          SizedBox(
            width: 40, // adjust to fit your largest number
            child: Text(
              "25",
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      )
    );
  }
}

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

