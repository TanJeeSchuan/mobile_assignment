import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_assignment/service/AuthService.dart';

import 'package:shimmer/shimmer.dart';

import 'models/UserData.dart';

class StaffDetailsPage extends StatefulWidget {

  StaffDetailsPage({super.key});
  @override
  State<StaffDetailsPage> createState() => _StaffDetailsPageState();

  static Widget buildReadOnlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          TextFormField(
            initialValue: value,
            enabled: false, // read-only
            style: const TextStyle(
              color: Colors.black, // keep text black
              fontSize: 16,
            ),
            cursorColor: Colors.transparent, // hide cursor
            decoration: const InputDecoration(
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              disabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey), // grey border
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey), // no blue glow
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey), // consistent grey
              ),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _StaffDetailsPageState extends State<StaffDetailsPage> {
  late Future<UserData?> userDataFuture;

  Future<UserData?> retrieveUserData() async {
    return await AuthService.getCurrentUser();
  }

  @override
  void initState() {
    super.initState();
    userDataFuture = retrieveUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: userDataFuture,
        builder: (context, asyncSnapshot) {
          if (asyncSnapshot.connectionState == ConnectionState.waiting) {
            return SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Expanded(
                    child: Center(
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade300,
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            )
                          ],
                        ),
                        child: Shimmer.fromColors(
                          baseColor: Colors.grey.shade300,
                          highlightColor: Colors.grey.shade100,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircleAvatar(radius: 40, backgroundColor: Colors.grey),
                              const SizedBox(height: 16),
                              Container(height: 16, width: 120, color: Colors.grey),
                              const SizedBox(height: 20),
                              Container(height: 40, width: double.infinity, color: Colors.grey),
                              const SizedBox(height: 16),
                              Container(height: 40, width: double.infinity, color: Colors.grey),
                              const SizedBox(height: 16),
                              Container(height: 40, width: double.infinity, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          if (!asyncSnapshot.hasData || asyncSnapshot.data == null) {
            return const Text("No user data found.");
          }

          final user = asyncSnapshot.data!;

          return SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Bar
                Container(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.lightBlue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.person_outline, color: Colors.black),
                      const SizedBox(width: 6),
                      const Text(
                        "Staff Details",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Card
                Expanded(
                  child: Center(
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade300,
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          )
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Avatar
                          const CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.lightBlueAccent,
                            child: Icon(
                              Icons.person_outline,
                              size: 50,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Welcome Text
                          Text(
                            "Welcome, ${user.staffName}\nStaff ID: ${user.staffId}",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Full Name
                          StaffDetailsPage.buildReadOnlyField("Full Name", user.staffName),

                          // Contact Number
                          StaffDetailsPage.buildReadOnlyField("Contact Number", user.contactNumber),

                          // Email
                          StaffDetailsPage.buildReadOnlyField("Email", user.staffEmail),

                          const SizedBox(height: 30),

                          // Logout Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                try {
                                  var _auth = FirebaseAuth.instance;
                                  await _auth.signOut();
                                  // Navigate to login screen after successful logout
                                  // Check if the widget is still mounted
                                  // Show success dialog
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false, // force user to press button
                                    builder: (context) => AlertDialog(
                                      title: const Text("Logout Successful"),
                                      content: const Text("You have been logged out."),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop(); // close dialog
                                            context.go('/login');        // navigate after dismiss
                                          },
                                          child: const Text("OK"),
                                        ),
                                      ],
                                    ),
                                  );
                                  // if (!mounted) return;
                                  // context.go('/login');

                                  // Navigator.of(context).pushAndRemoveUntil(
                                  //   MaterialPageRoute(builder: (context) => MainApp()),
                                  //       (Route<dynamic> route) => false, // This predicate always returns false, removing all routes
                                  // );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Logout failed: $e")),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                "Logout",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }
}
