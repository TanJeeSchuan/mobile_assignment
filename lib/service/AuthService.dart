
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_assignment/models/UserData.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static Future<UserData?> getCurrentUser() async {
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
      return UserData.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(response.statusCode.toString() + response.body);
      //print('Error: ${response.statusCode} - ${response.body}');
    }

    return null;
  }
}