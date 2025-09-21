import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../DeliveryDetail.dart';
import '../DeliveryVerificationSummary.dart';
import '../DropoffVerification.dart';
import '../Dashboard.dart';
import '../login.dart';
import '../PickupVerification.dart';
import '../profile.dart';


final FirebaseAuth _auth = FirebaseAuth.instance;

// Auth redirect function
String? authGuard(BuildContext context, GoRouterState state) {
  final user = _auth.currentUser;
  // If not logged in, redirect to login
  if (user == null) return '/login';
  // Otherwise, continue
  return null;
}


final GoRouter router = GoRouter(
  initialLocation: '/home',
  redirect: authGuard,
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => Dashboard(),
      routes: [
        GoRoute(
          path: 'profile', // /home/profile
          builder: (context, state) => StaffDetailsPage(),
        ),
        GoRoute(
          path: 'deliveryDetail/:deliveryId', // /deliveryDetail
          builder: (context, state) {
            final deliveryId = state.pathParameters['deliveryId']!;
            return OrderDetail(deliveryId: deliveryId,);
          },
          routes: [
            GoRoute(
              path: 'pickupVerification', // /home/deliveryDetail/verification
              builder: (context, state) {
                final deliveryId = state.pathParameters['deliveryId']!;
                return PickupConfirmationPage(deliveryId: deliveryId,);
              },
              routes: [
                GoRoute(
                    path: 'verified',
                    builder: (context, state){
                      final deliveryId = state.pathParameters['deliveryId']!;
                      return VerificationSummary(deliveryId: deliveryId, showingPickup: true);
                    }
                )
              ]
            ),
            GoRoute(
              path: 'dropoffVerification', // /home/deliveryDetail/verification
              builder: (context, state) {
                final deliveryId = state.pathParameters['deliveryId']!;
                return DropoffVerification(deliveryId: deliveryId, );
              },
              routes: [
                GoRoute(
                  path: 'verified',
                  builder: (context, state){
                    final deliveryId = state.pathParameters['deliveryId']!;
                    return VerificationSummary(deliveryId: deliveryId, showingPickup: false,);
                  }
                )
              ]
            ),
          ],
        ),
      ],
    ),
  ],
);
