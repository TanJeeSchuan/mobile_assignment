import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobile_assignment/main.dart';
import 'package:http/http.dart' as http;

import 'login.dart';

// void main() {
//   runApp(const StaffDetailsApp());
// }

// class StaffDetailsApp extends StatelessWidget {
//   const StaffDetailsApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: StaffDetailsPage(),
//     );
//   }
// }
class _userData {
  late String id;
  late String staffId;
  late String staffName;
  late String contactNumber;
  late String staffEmail;

  _userData(this.id, this.staffId, this.staffName, this.contactNumber, this.staffEmail);

  factory _userData.fromFirestore(String id, Map<String, dynamic> data) {
    return _userData(
      id,
      data["StaffID"]?.toString() ?? "",   // 🔥 convert to String
      data["StaffName"] ?? "",
      data["StaffContact"] ?? "",
      data["StaffEmail"] ?? "",
    );
  }

  // Factory constructor for JSON map (from HTTP or Firestore-like map with 'id' inside)
  factory _userData.fromJson(Map<String, dynamic> json) {
    return _userData(
      json['id']?.toString() ?? "",              // Use id field if included in JSON
      json['StaffID']?.toString() ?? "",        // convert to String safely
      json['StaffName'] ?? "",
      json['StaffContact'] ?? "",
      json['StaffEmail'] ?? "",
    );
  }
}

class StaffDetailsPage extends StatelessWidget {

  StaffDetailsPage({super.key});
  _userData? userData;

  Future<_userData?> retrieveUserData() async {
    try {
      // final querySnapshot = await FirebaseFirestore.instance
      //     .collection("users")
      //     .where("StaffEmail",
      //     isEqualTo: FirebaseAuth.instance.currentUser?.email)
      //     .limit(1)
      //     .get();

      var user = FirebaseAuth.instance.currentUser;
      var email = user?.email;

      final idToken = await user?.getIdToken();
      final uri = Uri.parse('https://us-central1-mobile-assignment-f9fab.cloudfunctions.net/get_user_by_email?email=$email');
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $idToken',
        },
      );

      if (response.statusCode == 200) {
        return _userData.fromJson(jsonDecode(response.body));
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
      }

      // if (querySnapshot.docs.isNotEmpty) {
      //   var doc = querySnapshot.docs.single;
      //   return _userData.fromFirestore(doc.id, doc.data());
      // }
    } catch (e) {
      print("Error fetching users: $e");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: retrieveUserData(),
        builder: (context, asyncSnapshot) {
          if (asyncSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!asyncSnapshot.hasData || asyncSnapshot.data == null) {
            return const Text("No user data found.");
          }

          final user = asyncSnapshot.data!;
          userData = user;

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
                            "Welcome, ${userData!.staffName}\nStaff ID: ${userData!.staffId}",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 20),
          
                          // Full Name
                          buildReadOnlyField("Full Name", userData!.staffName),

                          // Contact Number
                          buildReadOnlyField("Contact Number", userData!.contactNumber),

                          // Email
                          buildReadOnlyField("Email", userData!.staffEmail),

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
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(builder: (context) => MainApp()),
                                        (Route<dynamic> route) => false, // This predicate always returns false, removing all routes
                                  );
                                } catch (e) {
                                  print('Error during logout: $e');
                                  // Handle logout errors, e.g., show a SnackBar
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

  // ✅ Read-only text field with grey border
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
