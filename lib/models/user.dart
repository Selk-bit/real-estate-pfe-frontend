import 'package:flutter/foundation.dart';

class User extends ChangeNotifier {
  String? username;
  String? firstName;
  String? lastName;
  String? email;
  String? phone;
  String? profilePicture;
  String? prompt;

  void updateUser(Map<String, dynamic> userData) {
    username = userData['username'];
    firstName = userData['first_name'];
    lastName = userData['last_name'];
    email = userData['email'];
    phone = userData['profile']['phone'];
    profilePicture = userData['profile']['profile_picture'];
    prompt = userData['profile']['prompt'];
    notifyListeners();
  }
}
