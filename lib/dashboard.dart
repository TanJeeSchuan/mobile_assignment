import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_assignment/AppColors.dart';
import 'package:mobile_assignment/profile.dart';
import 'package:mobile_assignment/service/DeliveryService.dart';

import 'Defines.dart';
import 'GeneralWidgets.dart';
import 'DeliveryCard.dart';
import 'DeliveryDetail.dart';
import 'models/DeliverySummary.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Greenstem Delivery"),
        backgroundColor: Color(0xFF03A9F4),
        actions: <Widget>[
          Builder(
            builder: (context) {
              return IconButton(
                onPressed: (){
                  // print('Current route: ${GoRouter.of(context).routerDelegate.currentConfiguration.uri}');
                  context.push('/home/profile');
                },
                icon: const Icon(Icons.account_circle_sharp),
              );
            }
          )
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: OrderStatus()),
          SliverToBoxAdapter(child: DeliveryList()), // <-- no nested scroll
        ],
      )
    );
  }
}

class DeliveryList extends StatefulWidget {
  const DeliveryList({super.key});

  @override
  State<DeliveryList> createState() => _DeliveryListState();
}

class _DeliveryListState extends State<DeliveryList> with AutomaticKeepAliveClientMixin{
  late Future<List<DeliverySummary>> ordersFuture;
  late DeliveryService service;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    service = DeliveryService();
    ordersFuture = service.fetchDeliveries(); // simpler, no async lambda needed
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DeliverySummary>>(
      future: ordersFuture,
      builder: (context, snapshot){
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No deliveries found"));
        }

        final deliveries = snapshot.data!;

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(), // disable ListView scrolling
          itemCount: deliveries.length,
          itemBuilder: (context, index) {
            return DeliveryCard(delivery: deliveries[index]);
          },
        );
      },
    );
  }
}

class OrderStatus extends StatefulWidget{
  const OrderStatus({
    super.key,
  });

  @override
  State<OrderStatus> createState() => _OrderStatusState();
}

class _OrderStatusState extends State<OrderStatus> {
  late DeliveryService service;
  late Future<Map<String, dynamic>> future;

  @override initState(){
    super.initState();
    service = DeliveryService();
    future = () async {
      return service.fetchDeliveryTypeCount();
    }();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (context, asyncSnapshot) {

        if(asyncSnapshot.connectionState == ConnectionState.waiting){
          return const Center(child: CircularProgressIndicator());
        } else if(asyncSnapshot.hasError){
          return Center(child: Text("Error: ${asyncSnapshot.error}"));
        } else if(!asyncSnapshot.hasData || asyncSnapshot.data!.isEmpty){
          return const Center(child: Text("No data found"));
        }

        Map<String, dynamic> deliveryReport = asyncSnapshot.data!;
// Convert list of maps into a lookup by status
        List<dynamic> summaryList = deliveryReport['statusSummary'];
        Map<String, int> statusMap = {
          for (var item in summaryList) item['status']: item['count']
        };
// Now you can safely access by status name
        int packingCount    = statusMap['package_pickup'] ?? 0;
        int readyCount   = statusMap['packing_finished'] ?? 0;
        int transitCount  = statusMap['order_complete'] ?? 0;
        int arrivedCount = statusMap['order_confirmed'] ?? 0;


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
                      DashboardStatusBar(type: StatusBarOrderType.packing,  value: packingCount),
                      DashboardStatusBar(type: StatusBarOrderType.ready,    value: readyCount),
                      DashboardStatusBar(type: StatusBarOrderType.transit,  value: transitCount),
                      DashboardStatusBar(type: StatusBarOrderType.arrived,  value: arrivedCount),
                    ],
                  )
              )
            ],
          )
        );
      }
    );
  }
}

class DashboardStatusBar extends StatefulWidget{
  final StatusBarOrderType type;

  int value;

  DashboardStatusBar({
    super.key,
    required this.type, required this.value,
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
                widget.value.toString(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        )
    );
  }
}