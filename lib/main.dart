import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'navigation/routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize Firebase before runApp
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget{
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
    );
  }
}

// for debug
// class MainApp extends StatelessWidget {
//   const MainApp({super.key});
//
//   Future<bool> _checkLogin() async {
//     // return false;
//     return getCurrentUser() != null;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: StreamBuilder<User?>(
//         stream: FirebaseAuth.instance.authStateChanges(),
//         builder: (BuildContext context, AsyncSnapshot<User?> snapshot){
//           if (!snapshot.hasData) {
//             return LoginScreen();
//             return SignInScreen(
//               providers: [
//                 EmailAuthProvider(),
//               ],
//               headerBuilder: (context, constraints, shrinkOffset) {
//                 return Padding(
//                   padding: const EdgeInsets.all(20),
//                   child: AspectRatio(
//                     aspectRatio: 1,
//                     child: const FlutterLogo(size: 100),
//                   ),
//                 );
//               },
//               subtitleBuilder: (context, action) {
//                 return Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 8.0),
//                   child: action == AuthAction.signIn
//                       ? const Text('Welcome to FlutterFire, please sign in!')
//                       : const Text('Welcome to Flutterfire, please sign up!'),
//                 );
//               },
//               footerBuilder: (context, action) {
//                 return const Padding(
//                   padding: EdgeInsets.only(top: 16),
//                   child: Text(
//                     'By signing in, you agree to our terms and conditions.',
//                     style: TextStyle(color: Colors.grey),
//                   ),
//                 );
//               },
//               sideBuilder: (context, shrinkOffset) {
//                 return Padding(
//                   padding: const EdgeInsets.all(20),
//                   child: AspectRatio(
//                     aspectRatio: 1,
//                     child: const FlutterLogo(size: 100),
//                   ),
//                 );
//               },
//             );
//           }
//           return const Dashboard();
//         },
//       )
//       // home: FutureBuilder<bool>(
//       //   future: _checkLogin(),
//       //   builder: (context, snapshot) {
//       //     if (snapshot.connectionState == ConnectionState.waiting) {
//       //       return const Center(child: CircularProgressIndicator());
//       //     }
//       //     if (snapshot.hasError) {
//       //       return Center(child: Text("Error: ${snapshot.error}"));
//       //     }
//       //     if (snapshot.hasData && snapshot.data == true) {
//       //       return Dashboard();
//       //     }
//       //     return LoginScreen();
//       //   }
//       // )
//     );
//   }
// }