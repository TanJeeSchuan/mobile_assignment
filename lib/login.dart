import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

import 'dashboard.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF8D22FF), // Deep vibrant purple
              Color(0xFF6A5BFF), // Smooth transition (avoids muddy brown/gray)
              Color(0xFF03A9F4), // Bright cyan-blue
            ],
            stops: [
              0.0,
              0.6,
              1.0,
            ], // Emphasize vibrant zones, reduce dull midpoints
            tileMode: TileMode.clamp,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            const Text(
              'Greenstem Delivery',
              style: TextStyle(
                fontSize: 36.0,
                fontWeight: FontWeight.bold,
                color: Color(0xFF003399), // Deep Blue Title
              ),
            ),
            const SizedBox(height: 20),
            LoginCard(),
          ],
        ),
      ),
    );
  }
}

User? getCurrentUser(){
  var user = FirebaseAuth.instance.currentUser;
  return user;
}


class LoginCard extends StatelessWidget {
  LoginCard({super.key});

  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AuthFlowBuilder<EmailAuthController>(
        builder: (context, state, controller, _) {
          if (state is AwaitingEmailAndPassword || state is AuthFailed) {
            return Card(
              elevation: 15,
              margin: EdgeInsets.all(20.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  // Make the column take minimum space
                  children: <Widget>[
                    Text(
                      'Staff Login',
                      style: TextStyle(
                          fontSize: 36.0, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 30.0),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 120, // fixed width for label
                              child: Text(
                                'Staff ID',
                                style: TextStyle(fontSize: 24.0),
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                controller: emailCtrl,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 120, // fixed width for label
                              child: Text(
                                'Password',
                                style: TextStyle(fontSize: 24.0),
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                controller: passwordCtrl,
                                obscureText: true,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 30.0),
                        Text('Forget Password? Contact HQ'),
                        if (state is AuthFailed) ...[
                          const SizedBox(height: 20),
                          Text(
                            "Login failed: ${state.exception.toString()}",
                            style: const TextStyle(color: Colors.red),
                          ),
                        ]
                      ],
                    ),
                    SizedBox(height: 30.0),
                    ClickableButton(
                      onPressed: () {
                        controller.setEmailAndPassword(
                          emailCtrl.text,
                          passwordCtrl.text,
                        );
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(builder: (
                        //       context) => const Dashboard()),
                        // );
                      },
                    ),
                  ],
                ),
              ),
            );
          }
          else if (state is SigningIn) {
            return Center(child: CircularProgressIndicator());
          }
          // else if (state is AuthFailed) {
          //   return Card(
          //     elevation: 15,
          //     margin: EdgeInsets.all(20.0),
          //     child: Padding(
          //       padding: const EdgeInsets.all(16.0),
          //       child: Column(
          //         mainAxisSize: MainAxisSize.min,
          //         // Make the column take minimum space
          //         children: <Widget>[
          //           Text(
          //             'Staff Login',
          //             style: TextStyle(
          //                 fontSize: 36.0, fontWeight: FontWeight.bold),
          //           ),
          //           SizedBox(height: 30.0),
          //           Column(
          //             children: [
          //               Row(
          //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //                 children: [
          //                   SizedBox(
          //                     width: 120, // fixed width for label
          //                     child: Text(
          //                       'Staff ID',
          //                       style: TextStyle(fontSize: 24.0),
          //                     ),
          //                   ),
          //                   Expanded(
          //                     child: TextField(
          //                       controller: emailCtrl,
          //                       decoration: InputDecoration(
          //                         border: OutlineInputBorder(),
          //                       ),
          //                     ),
          //                   ),
          //                 ],
          //               ),
          //               SizedBox(height: 10.0),
          //               Row(
          //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //                 children: [
          //                   SizedBox(
          //                     width: 120, // fixed width for label
          //                     child: Text(
          //                       'Password',
          //                       style: TextStyle(fontSize: 24.0),
          //                     ),
          //                   ),
          //                   Expanded(
          //                     child: TextField(
          //                       controller: passwordCtrl,
          //                       obscureText: true,
          //                       decoration: InputDecoration(
          //                         border: OutlineInputBorder(),
          //                       ),
          //                     ),
          //                   ),
          //                 ],
          //               ),
          //               SizedBox(height: 30.0),
          //               Text('Forget Password? Contact HQ'),
          //               Text(
          //                 'Wrong Login Information',
          //                 style: TextStyle(
          //                   color: Colors.red
          //                 ),
          //               ),
          //             ],
          //           ),
          //           SizedBox(height: 30.0),
          //           ClickableButton(
          //             onPressed: () {
          //               controller.setEmailAndPassword(
          //                 emailCtrl.text,
          //                 passwordCtrl.text,
          //               );
          //               // Navigator.push(
          //               //   context,
          //               //   MaterialPageRoute(builder: (
          //               //       context) => const Dashboard()),
          //               // );
          //             },
          //           ),
          //         ],
          //       ),
          //     ),
          //   );
          // }
          else if (state is SignedIn){
            return Dashboard();
          }
          return Container();
        },
    );
  }
}

class ClickableButton extends StatelessWidget {
  final VoidCallback onPressed; // Function to be passed in

  const ClickableButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Your onTap action here
        onPressed();
        // Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
        // print('Login button tapped');
      },
      child: Container(
        width: 200,
        height: 50,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment(0.8, 1),
            colors: <Color>[Color(0xFF8D22FF), Color(0xFF03A9F4)],
            tileMode: TileMode.mirror,
          ),
        ),
        child: const Center(
          child: Text(
            'Login',
            style: TextStyle(fontSize: 24.0, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
