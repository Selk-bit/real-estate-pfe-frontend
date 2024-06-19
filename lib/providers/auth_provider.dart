import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  String _token = "";
  String _id = "";
  Map<String, dynamic> _userData = {};

  bool get isLoggedIn => _isLoggedIn;
  String get token => _token;
  String get userId => _id;
  Map<String, dynamic> get userData => _userData;

  AuthProvider() {
    validateToken();
  }

  Future<void> validateToken() async {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('loginToken');

      if (token != null) {
        var response = await http.get(
          Uri.parse('${dotenv.env['API_ENDPOINT']}/api/token/check/'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Token $token',
          },
        );
        if (response.statusCode == 200 && jsonDecode(response.body)['valid']) {
          _isLoggedIn = true;
        } else {
          _isLoggedIn = false;
        }
      } else {
        _isLoggedIn = false;
      }
      notifyListeners();
  }

  Future<void> login(String username, String password) async {
    var url = Uri.parse('${dotenv.env['API_ENDPOINT']}/api/signin/');
    var response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      _token = data['token'];
      _id = data['user_id'].toString();
      _isLoggedIn = true;
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('loginToken', _token);
      await prefs.setString('userId', _id);
    } else {
      throw Exception('Failed to login');
    }
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _token = '';
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('loginToken');
    await prefs.remove('userId');
    notifyListeners();
  }

  Future<void> fetchUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('loginToken');
    String? id = prefs.getString('userId');
    if (token != null && id != null) {
      var response = await http.get(
        Uri.parse("${dotenv.env['API_ENDPOINT']}/users/$id/"),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        // _userData = json.decode(response.body);
        _userData = jsonDecode(Utf8Decoder().convert(response.bodyBytes));

      } else {
        print('Failed to load user data');
        _userData = {};
      }
      notifyListeners();
    }
  }


  Future<void> updateUserProfile(Map<String, String> profileData, {String? imagePath}) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('loginToken');
    String? id = prefs.getString('userId');

    var url = Uri.parse('${dotenv.env['API_ENDPOINT']}/users/$id/');
    var request = http.MultipartRequest('PUT', url);

    request.headers['Authorization'] = 'Token $token';
    profileData.forEach((key, value) {
      request.fields[key] = value;
    });

    if (imagePath != null) {
      request.files.add(await http.MultipartFile.fromPath('profile_picture', imagePath));
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      fetchUserProfile(); 
    } else {
      throw Exception('Failed to update profile');
    }
  }


  Future<void> register(Map<String, String> registrationData) async {
    var url = Uri.parse('${dotenv.env['API_ENDPOINT']}/users/');
    var response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(registrationData),
    );

    if (response.statusCode == 201) {
      var data = json.decode(response.body);
      _token = data['token'];
      _id = data['user_id'];
      _isLoggedIn = true;
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('loginToken', _token);
      await prefs.setString('userId', _id);
    } else {
      throw Exception('Failed to register');
    }
  }

}
