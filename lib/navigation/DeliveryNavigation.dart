import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/DeliverySummary.dart';

/// Check whether the confirm button should be enabled.
bool confirmButtonEnabled(DeliverySummary delivery) {
  return delivery.status == "Ready To Ship" || delivery.status == "In Transit";
}

/// Handle navigation to the correct verification screen.
void handleDeliveryNavigation(BuildContext context, DeliverySummary delivery) {
  if (delivery.status == "Ready To Ship") {
    context.push('/home/deliveryDetail/${delivery.orderId}/pickupVerification');
  } else {
    context.push('/home/deliveryDetail/${delivery.orderId}/dropoffVerification');
  }
}