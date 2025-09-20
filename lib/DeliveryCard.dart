import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_assignment/models/DeliverySummary.dart';
import 'package:shimmer/shimmer.dart';

import 'AppColors.dart';
import 'Defines.dart';
import 'GeneralWidgets.dart';
import 'DeliveryDetail.dart';
import 'DropoffVerification.dart';
import 'PickupVerification.dart';
import 'navigation/DeliveryNavigation.dart';

class DeliveryCard extends StatelessWidget{
  final DeliverySummary delivery;

  const DeliveryCard({super.key, required this.delivery});

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
            DeliveryCardContents(delivery: delivery),
            SizedBox(height: 28,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                    child: ElevatedButton (
                      onPressed: () {
                        context.push('/home/deliveryDetail/${delivery.orderId}');
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
                      onPressed: confirmButtonEnabled(delivery) ?
                        () => handleDeliveryNavigation(context, delivery)
                        : null,
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

  // bool _confirmButtonEnabled(OrderSummary delivery) {
  //   return delivery.status == "Ready To Ship" || delivery.status == "In Transit";
  // }
}

class DeliveryCardShimmer extends StatelessWidget {
  const DeliveryCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Column(
          children: [
            // Fake DeliveryCardContents section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 18, width: 140, color: Colors.grey), // title
                const SizedBox(height: 10),
                Container(height: 14, width: 200, color: Colors.grey), // subtitle
                const SizedBox(height: 10),
                Container(height: 14, width: double.infinity, color: Colors.grey), // extra line
              ],
            ),
            const SizedBox(height: 28),

            // Fake buttons row
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(width: 52),
                Expanded(
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


navigateToVerification(DeliverySummary delivery, BuildContext context){
  if(delivery.status == "Ready To Ship"){
    context.push('/home/deliveryDetail/${delivery.orderId}/pickupVerification');
  } else {
    context.push('/home/deliveryDetail/${delivery.orderId}/dropoffVerification');
  }
}


class DeliveryCardContents extends StatelessWidget{
  final DeliverySummary delivery;
  final StatusBarOrderType status;

  DeliveryCardContents({
    super.key,
    required this.delivery
  }): status = _getStatusFromDelivery(delivery);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center, // centers horizontally
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Delivery ${delivery.orderId.toUpperCase()}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Container(  // status box with rounded corners and shadow
                width: 155,
                height: 45,
                decoration: BoxDecoration(
                  color: _getStatusBoxColor(status), // Set color based on delivery status
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
                    child: Text(delivery.status)
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
              value: delivery.source,
              symbolColor: Colors.black,
              icon: Icons.dataset,
            ),
            const SizedBox(height: 12), // spacingng
            LabelWithSymbolAndValue(
              label: "Drop Off:",
              value: delivery.destination,
              symbolColor: Colors.black,
              icon: Icons.folder,
            ),
            const SizedBox(height: 12), // spacing
            LabelWithSymbolAndValue(
              label: "Weight:",
              value: "${delivery.weight}kg",
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
              value: delivery.deliverBy,
              symbolColor: Colors.black,
              icon: Icons.timer,
            ),
          ],
        ),
        SizedBox(height: 28,),
        OrderProgression(status: status),
      ],
    );
  }


  static StatusBarOrderType _getStatusFromDelivery(DeliverySummary delivery) {
    var txt = delivery.status;

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

  Color _getStatusBoxColor(StatusBarOrderType status) {
    switch (status) {
      case StatusBarOrderType.packing:
        return AppColors.packing;
      case StatusBarOrderType.ready:
        return AppColors.ready;
      case StatusBarOrderType.transit:
        return AppColors.transit;
      case StatusBarOrderType.arrived:
        return AppColors.arrived;
    }
  }
}

// TODO modify to stateful
class OrderProgression extends StatelessWidget{
  final StatusBarOrderType status;
  List<OrderStageStatus> statusList = [
    OrderStageStatus.completed,
    OrderStageStatus.active,
    OrderStageStatus.pending,
    OrderStageStatus.pending,
  ];

  OrderProgression({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final arrowSize = screenWidth * 0.03; // 3% of screen width

    if(status == StatusBarOrderType.packing) {
      statusList = [
        OrderStageStatus.active,
        OrderStageStatus.pending,
        OrderStageStatus.pending,
        OrderStageStatus.pending,
      ];
    } else if(status == StatusBarOrderType.ready) {
      statusList = [
        OrderStageStatus.completed,
        OrderStageStatus.active,
        OrderStageStatus.pending,
        OrderStageStatus.pending,
      ];
    } else if(status == StatusBarOrderType.transit) {
      statusList = [
        OrderStageStatus.completed,
        OrderStageStatus.completed,
        OrderStageStatus.active,
        OrderStageStatus.pending,
      ];
    } else if(status == StatusBarOrderType.arrived) {
      statusList = [
        OrderStageStatus.completed,
        OrderStageStatus.completed,
        OrderStageStatus.completed,
        OrderStageStatus.active,
      ];
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center, // 👈 align to top,
      children: [
        Expanded(
          child: OrderProgressIcon(
            orderType: StatusBarOrderType.packing,
            status: statusList[0],
          ),
        ),
        Column(
          children: [
            Icon(
              Icons.arrow_forward_ios,
              size: arrowSize,
            ),
            SizedBox(
              height: 40,
            )
          ],
        ),
        Expanded(
          child: OrderProgressIcon(
            orderType: StatusBarOrderType.ready,
            status: statusList[1],
          ),
        ),
        Icon(
          Icons.arrow_forward_ios,
          size: arrowSize,
        ),
        Expanded(
          child: OrderProgressIcon(
            orderType: StatusBarOrderType.transit,
            status: statusList[2],
          ),
        ),
        Icon(
          Icons.arrow_forward_ios,
          size: arrowSize,
        ),
        Expanded(
          child: OrderProgressIcon(
            orderType: StatusBarOrderType.arrived,
            status: statusList[3],
          ),
        ),
      ],
    );
  }
}

Color GetStatusBoxColor(status) {
  switch (status) {
    case OrderStageStatus:
      return AppColors.stepPending;
    case OrderStageStatus.active:
      return AppColors.stepActive;
    case OrderStageStatus.completed:
      return AppColors.stepCompleted;
  }

  return AppColors.ready;
}

class OrderProgressIcon extends StatelessWidget {
  final StatusBarOrderType orderType;
  final OrderStageStatus status;

  const OrderProgressIcon({
    super.key,
    required this.orderType,
    required this.status,
  });

  Color _getBoxColor() {
    switch (status) {
      case OrderStageStatus.pending:
        return AppColors.stepPending;
      case OrderStageStatus.active:
        return AppColors.stepActive;
      case OrderStageStatus.completed:
        return AppColors.stepCompleted;
    }
  }

  IconData _getIconData() {
    switch (orderType) {
      case StatusBarOrderType.packing:
        return Icons.checklist;
      case StatusBarOrderType.ready:
        return Icons.trolley; // make sure this exists, might need CupertinoIcons.cart
      case StatusBarOrderType.transit:
        return Icons.local_shipping;
      case StatusBarOrderType.arrived:
        return Icons.warehouse;
    }
  }

  String _getText() {
    switch (orderType) {
      case StatusBarOrderType.packing:
        return "Packing";
      case StatusBarOrderType.ready:
        return "Ready to Ship";
      case StatusBarOrderType.transit:
        return "In Transit";
      case StatusBarOrderType.arrived:
        return "Arrived";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: _getBoxColor(),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(_getIconData(), size: 32, color: Colors.black),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 36,
          child: Text(
            _getText(),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }
}
