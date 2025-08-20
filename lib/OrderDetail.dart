import 'package:flutter/material.dart';

class OrderDetail extends StatelessWidget{
  const OrderDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DetailedAppBar(
        appBarIcon: Icons.account_box,
        heading: "Order Details",
        subheading: "Posted At 9:50 A.M."
      )
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
  // TODO: implement preferredSize
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
