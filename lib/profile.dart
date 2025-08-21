import 'package:flutter/material.dart';

void main() {
  runApp(const StaffDetailsApp());
}

class StaffDetailsApp extends StatelessWidget {
  const StaffDetailsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StaffDetailsPage(),
    );
  }
}

class StaffDetailsPage extends StatelessWidget {
  const StaffDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
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
                      const Text(
                        "Welcome, ALI BABA\nStaff ID: 007",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Full Name
                      buildReadOnlyField("Full Name", "ALI BABA"),

                      // Contact Number
                      buildReadOnlyField("Contact Number", "+60123456789"),

                      // Email
                      buildReadOnlyField("Email", "alibaba@gmail.com"),

                      const SizedBox(height: 30),

                      // Logout Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // Handle logout logic
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
