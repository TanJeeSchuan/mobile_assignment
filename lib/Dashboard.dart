import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_assignment/AppColors.dart';
import 'package:mobile_assignment/service/DeliveryService.dart';
import 'package:shimmer/shimmer.dart';

import 'Defines.dart';
import 'DeliveryCard.dart';
import 'models/DeliverySummary.dart';

class Dashboard extends StatelessWidget {
  final GlobalKey<_DeliveryListState> deliveryListKey = GlobalKey<_DeliveryListState>();

  Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Greenstem Delivery"),
        backgroundColor: AppColors.accentColor,
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
          SliverToBoxAdapter(child: DeliveryList(key: deliveryListKey)),
          //SliverToBoxAdapter(child: DeliveryList()), // <-- no nested scroll
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Find the DeliveryList state and trigger refresh
          //DeliveryList.refreshDeliveries(context);
          deliveryListKey.currentState?.refresh();
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

class DeliveryList extends StatefulWidget {
  const DeliveryList({super.key});

  // static helper so Dashboard can trigger refresh
  static void refreshDeliveries(BuildContext context) {
    final state = context.findAncestorStateOfType<_DeliveryListState>();
    state?._refreshFuture();
  }

  @override
  State<DeliveryList> createState() => _DeliveryListState();
}
class _DeliveryListState extends State<DeliveryList> with AutomaticKeepAliveClientMixin{

  late Future<List<DeliverySummary>> ordersFuture;
  late DeliveryService service;

  String selectedFilter = "All";

  // previously private; make public and return Future so callers can await
  Future<void> refresh() async {
    if (!mounted) return;
    // debug print so you can see it was triggered
    debugPrint('[DeliveryList] refresh() called');
    setState(() {
      // assign a *new* future so FutureBuilder notices change
      ordersFuture = service.fetchDeliveries();
    });
    try {
      await ordersFuture; // await so caller can wait until complete
      debugPrint('[DeliveryList] refresh finished');
    } catch (e) {
      debugPrint('[DeliveryList] refresh error: $e');
      // FutureBuilder will display the error; we swallow here to avoid unhandled exceptions
    }
  }

  void _refreshFuture() {
    setState(() {
      ordersFuture = service.fetchDeliveries();
    });
  }

  // Define your options with icon + label
  final List<Map<String, dynamic>> filterOptions = [
    {"label": "All", "icon": Icons.playlist_add_check_outlined},
    {"label": "Packing", "icon": Icons.inventory_2_outlined},
    {"label": "Ready To Ship", "icon": Icons.check_circle_outline},
    {"label": "In Transit", "icon": Icons.local_shipping_outlined},
    {"label": "Package Arrived", "icon": Icons.home_outlined},
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    service = DeliveryService();
    ordersFuture = service.fetchDeliveries(); // only once
  }


  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder<List<DeliverySummary>>(
      future: ordersFuture,
      builder: (context, snapshot){
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3, // show 3 placeholders
            itemBuilder: (context, index) {
              return const DeliveryCardShimmer();
            },
          );
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No deliveries found"));
        }

        final deliveries = _applyFilter(snapshot.data!);

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedFilter,
                  isExpanded: true,
                  icon: const Icon(Icons.filter_list, color: Colors.blue),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                  items: filterOptions.map((option) {
                    return DropdownMenuItem<String>(
                      value: option["label"],
                      child: Row(
                        children: [
                          Icon(option["icon"], size: 20, color: Colors.grey.shade600),
                          const SizedBox(width: 10),
                          Text(option["label"]),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedFilter = value;
                      });
                    }
                  },
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(), // disable ListView scrolling
              itemCount: deliveries.length,
              itemBuilder: (context, index) {
                return DeliveryCard(delivery: deliveries[index]);
              },
            ),
          ],
        );
      },
    );
  }

  _applyFilter(List<DeliverySummary> list) {
    if (selectedFilter == "All") return list;

    return list.where((d) {
      //print("ID: ${d.orderId}, status: ${d.status}\n");
      switch (selectedFilter) {
        case "Packing":
          return d.status == "Packing";
        case "Ready To Ship":
          return d.status == "Ready To Ship";
        case "In Transit":
          return d.status == "In Transit";
        case "Package Arrived":
          return d.status == "Completed" || d.status == "Package Arrived";
        default:
          return false; // fallback
      }
    }).toList();
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
  Timer? timer;

  @override initState(){
    super.initState();
    service = DeliveryService();
    _refreshFuture(); // initial load
    // future = () async {
    //   return service.fetchDeliveryTypeCount();
    // }();

    // refresh every 10 seconds (adjust as needed)
    timer = Timer.periodic(Duration(seconds: 150), (_) {
      _refreshFuture();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void _refreshFuture() {
    setState(() {
      future = service.fetchDeliveryTypeCount();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (context, asyncSnapshot) {

        if(asyncSnapshot.connectionState == ConnectionState.waiting){
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderColour, width: 1),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowColor,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 24, width: 120, color: Colors.grey), // Title
                  const SizedBox(height: 20),
                  for (int i = 0; i < 4; i++) ...[
                    Container(height: 40, margin: const EdgeInsets.symmetric(vertical: 6), color: Colors.grey),
                  ]
                ],
              ),
            ),
          );
        } else if(asyncSnapshot.hasError){
          return Center(child: Text("Error: ${asyncSnapshot.error}"));
        } else if(!asyncSnapshot.hasData || asyncSnapshot.data!.isEmpty){
          return const Center(child: Text("No data found"));
        }

        Map<String, dynamic> deliveryReport = asyncSnapshot.data!;
        Map<String, dynamic> statusSummary = deliveryReport['statusSummary'] ?? {};
        // Access counts directly
        int packingCount = statusSummary['packing'] ?? 0;
        int readyCount   = statusSummary['ready'] ?? 0;
        int transitCount = statusSummary['transit'] ?? 0;
        int arrivedCount = statusSummary['arrived'] ?? 0;

//         Map<String, dynamic> deliveryReport = asyncSnapshot.data!;
// // Convert list of maps into a lookup by status
//         List<dynamic> summaryList = deliveryReport['statusSummary'];
//         Map<String, int> statusMap = {
//           for (var item in summaryList) item['status']: item['count']
//         };
// // Now you can safely access by status name
//         int packingCount  = statusMap['package_pickup'] ?? 0;
//         int readyCount    = statusMap['packing_finished'] ?? 0;
//         int transitCount  = statusMap['order_complete'] ?? 0;
//         int arrivedCount  = statusMap['order_confirmed'] ?? 0;


        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 22,vertical: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.backgroundColor,
            borderRadius: BorderRadius.circular(8), // rounded corners
            border: Border.all(
              color: AppColors.borderColour, // thin border
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColor,
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
  final int value;

  const DashboardStatusBar({
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