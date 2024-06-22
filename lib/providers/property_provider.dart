import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:real_estate/data.dart';
import 'package:path/path.dart';


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
  List<Map<String, dynamic>> _equipmentList = [];
  List<Map<String, dynamic>> get equipmentList => _equipmentList;



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

  Future<void> addProperty(Map<String, dynamic> propertyData, List<Map<String, String>> images, List<Map<String, String>> videos) async {
    var url = '${dotenv.env['API_ENDPOINT']}/api/houses/list/create';
    var request = http.MultipartRequest('POST', Uri.parse(url));
    final prefs = await SharedPreferences.getInstance();

    // Add the property data to the request fields
    propertyData.forEach((key, value) {
      if (key == 'equipment') {
        for (int i = 0; i < propertyData['equipment'].length; i++) {
          request.fields['equipment[$i][equipment]'] = propertyData['equipment'][i]['equipment'].toString();
          request.fields['equipment[$i][quantity]'] = propertyData['equipment'][i]['quantity'].toString();
        }
      } else {
        request.fields[key] = value.toString();
      }
    });

    // Add images to the request files
    for (var image in images) {
      if (image.containsKey('image')) {
        String imagePath = image['image']!;
        request.files.add(await http.MultipartFile.fromPath('images', imagePath, filename: basename(imagePath)));
      }
    }

    // Add videos to the request files
    for (var video in videos) {
      if (video.containsKey('video')) {
        String videoPath = video['video']!;
        request.files.add(await http.MultipartFile.fromPath('videos', videoPath, filename: basename(videoPath)));
      }
    }

    // Add headers to the request
    request.headers.addAll({
      'Authorization': 'Token ${prefs.getString('loginToken')}',
      'Content-Type': 'application/json',
    });

    // Send the request
    final response = await request.send();
    

    if (response.statusCode == 201) {
      final responseData = await http.Response.fromStream(response);
      // Handle successful response
      // You can parse the responseData.body if needed
      notifyListeners();
    } else {
      throw Exception('Failed to add property');
    }
  }

  Future<void> editProperty(Map<String, dynamic> propertyData, List<Map<String, String>> newImages, List<Map<String, String>> newVideos, List<String> existingImages, List<String> existingVideos, int propertyId) async {
    var url = '${dotenv.env['API_ENDPOINT']}/api/houses/list/update/$propertyId';
    var request = http.MultipartRequest('PUT', Uri.parse(url));
    final prefs = await SharedPreferences.getInstance();

    // Add the property data to the request fields
    propertyData.forEach((key, value) {
      if (key == 'equipment') {
        for (int i = 0; i < propertyData['equipment'].length; i++) {
          request.fields['equipment[$i][equipment]'] = propertyData['equipment'][i]['equipment'].toString();
          request.fields['equipment[$i][quantity]'] = propertyData['equipment'][i]['quantity'].toString();
        }
      } else {
        request.fields[key] = value.toString();
      }
    });

    // Add new images to the request files
    for (var image in newImages) {
      if (image.containsKey('image')) {
        String imagePath = image['image']!;
        request.files.add(await http.MultipartFile.fromPath('images', imagePath, filename: basename(imagePath)));
      }
    }

    // Add new videos to the request files
    for (var video in newVideos) {
      if (video.containsKey('video')) {
        String videoPath = video['video']!;
        request.files.add(await http.MultipartFile.fromPath('videos', videoPath, filename: basename(videoPath)));
      }
    }

    // Add existing images URLs to the request fields
    for (int i = 0; i < existingImages.length; i++) {
      request.fields['existing_images[$i]'] = existingImages[i];
    }

    // Add existing videos URLs to the request fields
    for (int i = 0; i < existingVideos.length; i++) {
      request.fields['existing_videos[$i]'] = existingVideos[i];
    }

    // Add headers to the request
    request.headers.addAll({
      'Authorization': 'Token ${prefs.getString('loginToken')}',
      'Content-Type': 'application/json',
    });

    // Send the request
    final response = await request.send();
    
    if (response.statusCode == 201) {
      final responseData = await http.Response.fromStream(response);
      // Handle successful response
      // You can parse the responseData.body if needed
      notifyListeners();
    } else {
      throw Exception('Failed to edit property');
    }
  }

  Future<void> fetchEquipment() async {
    var url = Uri.parse('${dotenv.env['API_ENDPOINT']}/equipment/');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var utf8Decoder = Utf8Decoder();
      // _equipmentList = List<Map<String, dynamic>>.from(json.decode(response.body));
      _equipmentList = List<Map<String, dynamic>>.from(json.decode(utf8Decoder.convert(response.bodyBytes)));
      notifyListeners();
    } else {
      throw Exception('Failed to load equipment');
    }
  }
}
