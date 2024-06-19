import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:real_estate/data.dart';

class PropertyProvider with ChangeNotifier {
  List<Property> _properties = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  String _currentSearchTerm = "";
  String? _minPrice;
  String? _maxPrice;
  String? _bedrooms;
  int _fetchedProperties = 0;
  int _paginationNumber = 10;


  List<Property> get properties => _properties;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  int get fetchedProperties => _fetchedProperties;  
  int get currentPage => _currentPage;
  int get paginationNumber => _paginationNumber;


  Future<bool> isFavorite(int houseId) async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    if (userId == null) {
      throw Exception("User not logged in");
    }
    var url = Uri.parse('${dotenv.env['API_ENDPOINT']}/api/houses/$houseId/isfavorite/');
    var response = await http.post(
      url,
      headers: {
        'Authorization': 'Token ${prefs.getString('loginToken')}',
        'Content-Type': 'application/json'
      },
      body: json.encode({'user_id': userId}),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }


  Future<void> favorite(int houseId) async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    if (userId == null) {
      throw Exception("User not logged in");
    }
    var url = Uri.parse('${dotenv.env['API_ENDPOINT']}/api/houses/$houseId/add_to_favorites/');
    var response = await http.post(
      url,
      headers: {
        'Authorization': 'Token ${prefs.getString('loginToken')}',
        'Content-Type': 'application/json'
      },
      body: json.encode({'user_id': userId}),
    );

    if (response.statusCode == 201) {
      // Optionally handle successful favorite addition
    } else {
      throw Exception('Failed to add to favorites');
    }
  }

  Future<void> removeFavorite(int houseId) async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    if (userId == null) {
      throw Exception("User not logged in");
    }
    var url = Uri.parse('${dotenv.env['API_ENDPOINT']}/api/houses/$houseId/remove_from_favorotes/');
    var response = await http.post(
      url,
      headers: {
        'Authorization': 'Token ${prefs.getString('loginToken')}',
        'Content-Type': 'application/json'
      },
      body: json.encode({'user_id': userId}),
    );

    if (response.statusCode == 201) {
      // Optionally handle successful favorite addition
    } else {
      throw Exception('Failed to add to favorites');
    }
  }
}
