import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';




class Equipment {
  final int id;
  final String name;
  final String? description;
  final String iconSvg;

  Equipment({
    required this.id,
    required this.name,
    this.description,
    required this.iconSvg,
  });

  factory Equipment.fromJson(Map<String, dynamic> json) {
    return Equipment(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      iconSvg: json['icon_svg'],
    );
  }
}


class Property {
  int property_id;
  String label;
  String name;
  String price;
  String location;
  String city;
  String address;
  String sqm;
  String review;
  String interest_percentage;
  String description;
  String frontImage;
  String ownerImage;
  List<String> images;
  String ownerName;
  String phone;
  String number_of_rooms;
  String number_of_salons;
  String number_of_toilets;
  String floor_number;
  String age;
  List<Equipment> equipments;
  bool favorite;
  bool mine;


  Property(
    this.property_id,
    this.label,
    this.name,
    this.price,
    this.location,
    this.city,
    this.address,
    this.sqm,
    this.review,
    this.interest_percentage,
    this.description,
    this.frontImage,
    this.ownerImage,
    this.images,
    this.ownerName,
    this.phone,
    this.number_of_rooms,
    this.number_of_salons,
    this.number_of_toilets,
    this.floor_number,
    this.age,
    this.equipments,
    this.favorite,
    this.mine
  );
}

Future<Map<String, dynamic>> getPropertyList({int page = 1, String query = "", String? minPrice, String? maxPrice, String? bedrooms, bool? favorites, bool? searchables, bool? myproperties}) async {
  final prefs = await SharedPreferences.getInstance();
  var endpoint = '${dotenv.env['API_ENDPOINT']}/houses/';
  var queryParams = '?page=$page';

  if (minPrice != null && maxPrice != null) {
    queryParams += '&min_price=$minPrice&max_price=$maxPrice';
  }

  if (bedrooms != null) {
    queryParams += '&number_of_rooms=$bedrooms';
  }

  if(query != ""){
      queryParams += '&search=$query';
  }

  if(favorites == true){
      String? user_id = prefs.getString('userId');
      if(user_id != "" && user_id != null){
        queryParams += '&favorites=$user_id';
      }
      else{
        queryParams += '&favorites=0';
      }
  }

  if(searchables == true){
      String? user_id = prefs.getString('userId');
      if(user_id != "" && user_id != null){
        queryParams += '&searchables=$user_id';
      }
      else{
        queryParams += '&searchables=0';
      }
  }

  if(myproperties == true){
      String? user_id = prefs.getString('userId');
      if(user_id != "" && user_id != null){
        queryParams += '&myproperties=$user_id';
      }
      else{
        queryParams += '&myproperties=0';
      }
  }

  Uri url = Uri.parse('$endpoint$queryParams');

  String? token = prefs.getString('loginToken');

  var response = null;
  
  if(token != "" &&  token != null){
    response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      },
    );
  }
  else {
    response = await http.get(url);
  }

  if (response.statusCode == 200) {
    List<dynamic> jsonList = jsonDecode(Utf8Decoder().convert(response.bodyBytes))['results'];
    int totalResults = jsonDecode(Utf8Decoder().convert(response.bodyBytes))['count'];
    List<Property> properties = [];
    for (var json in jsonList) {
      var imagesList = (json['images'] as List).map((image) => image['image'] as String).toList();
      var equipmentsList = (json['equipment'] as List).map((equipment) => Equipment.fromJson(equipment)).toList();

      if (imagesList.isNotEmpty) {
        String firstImage = imagesList[0];
        properties.add(Property(
          json["id"] ?? "",
          json['house_type'] == "sell" ? "SALE" : "RENT",
          json["title"] ?? "",
          json["price"] ?? "",
          "${json['city']}, ${json['address']}",
          json['city'] ?? "",
          json['address'] ?? "",
          json["surface"] ?? "",
          "7.5",
          json["interest_percentage"] ?? "",
          json["description"] ?? "",
          firstImage,
          json["owner_picture"] ?? "",
          imagesList,
          json["owner_name"] ?? "",
          json["phone"] ?? "",
          json["number_of_rooms"].toString() ?? "",
          json["number_of_salons"].toString() ?? "",
          json["number_of_toilets"].toString() ?? "",
          json["floor_number"].toString() ?? "",
          json["age"].toString() ?? "",
          equipmentsList,
          json["favorite"],
          json["mine"],
        ));
      }
    }
    return {'properties': properties, 'totalResults': totalResults};
  } else {
    throw Exception('Failed to load property data');
  }
}