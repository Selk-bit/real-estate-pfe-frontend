import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:real_estate/data.dart';
import 'package:provider/provider.dart';
import 'package:real_estate/providers/auth_provider.dart';
import 'package:real_estate/main.dart';
import 'package:real_estate/login.dart';
import 'package:real_estate/register.dart';
import 'package:real_estate/profile.dart';
import 'package:real_estate/filter.dart';
import 'package:real_estate/detail.dart';
import 'package:real_estate/favorites.dart';
import 'package:real_estate/searchables.dart';
import 'package:real_estate/search.dart';


abstract class PropertyListState<T extends StatefulWidget> extends State<T> {
  List<Property> properties = [];
  ScrollController scrollController = ScrollController();
  TextEditingController textController = TextEditingController();
  int currentPage = 1;
  bool hasMore = true;
  bool isLoading = false;
  String? min = "0";
  String? max = "0";
  String? chambres = "Any";
  String searchQuery = "";
  int paginationNumber = 10;
  int fetchedProperties = 0;
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
    loadProperties(scrollDown: false);
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent && hasMore) {
        loadProperties(searchTerm: searchQuery, minPrice: min, maxPrice: max, bedrooms: chambres, scrollDown: true);
      }
    });
  }

  void checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('loginToken');
    setState(() {
      isLoggedIn = (token == null) ? false : true;
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    textController.dispose();
    super.dispose();
  }

  void loadProperties({String searchTerm = "", String? minPrice, String? maxPrice, String? bedrooms, bool scrollDown = false}) async {
    if (isLoading || !hasMore) return;
    setState(() {
      if (searchTerm.isNotEmpty && searchTerm != searchQuery) {
        properties.clear();
        currentPage = 1;
      }

      isLoading = true;
      searchQuery = searchTerm;
    });

    try {
      if (!hasMore) {
        setState(() => isLoading = false);
      }
      while (scrollDown || (fetchedProperties < 10 && hasMore)) {
        setState(() => isLoading = true);
        Map<String, dynamic> result = await getPropertyList(page: currentPage, query: searchQuery, minPrice: min, maxPrice: max, bedrooms: chambres, favorites: isFavoritesPage(), searchables: isSearchablesPage());
        List<Property> newProperties = result['properties'];
        int flooredNumber = (result['totalResults'] / paginationNumber).truncate() * paginationNumber;
        if (newProperties.isEmpty) {
          setState(() {
            isLoading = false;
          });
        }

        setState(() {
          properties.addAll(newProperties);
          hasMore = flooredNumber > (currentPage * paginationNumber);
          fetchedProperties += newProperties.length;
          currentPage++;
          isLoading = false;
        });
        if (fetchedProperties < 10) {
          continue;
        }
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  bool isFavoritesPage();
  bool isSearchablesPage();


  void performSearch(String searchTerm) {
    setState(() {
      properties.clear();
      currentPage = 1;
      hasMore = true;
      fetchedProperties = 0;
    });
    loadProperties(searchTerm: searchTerm, bedrooms: chambres, maxPrice: max, minPrice: min, scrollDown: false);
  }

  void applyFilters({String? bedrooms, String? minPrice, String? maxPrice, String? toilet}) {
    setState(() {
      properties.clear();
      currentPage = 1;
      hasMore = true;
      chambres = bedrooms;
      min = minPrice;
      max = maxPrice;
      fetchedProperties = 0;
    });
    loadProperties(bedrooms: chambres, minPrice: min, maxPrice: max, scrollDown: false);
  }

  Widget loggedInListView() {
    return ListView(
      physics: BouncingScrollPhysics(),
      scrollDirection: Axis.horizontal,
      children: [
        SizedBox(width: 24),
        buildButton("Profile"),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12),
          margin: EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            border: Border.all(
              color: Colors.grey[300] ?? Colors.transparent,
              width: 1,
            ),
          ),
          child: InkWell(
            onTap: () async {
              var authProvider = Provider.of<AuthProvider>(context, listen: false);
              await authProvider.logout();
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => MyApp()));
            },
            child: Center(
              child: Text(
                "Se Déconnecter",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 8),
      ],
    );
  }

  Widget loggedOutListView() {
    return ListView(
      physics: BouncingScrollPhysics(),
      scrollDirection: Axis.horizontal,
      children: [
        SizedBox(width: 24),
        buildButton("Se Connecter"),
        buildButton("S'inscrire"),
        SizedBox(width: 8),
      ],
    );
  }

  Widget buildButton(String filterName) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) {
            if (filterName == "Se Connecter") {
              return Login();
            } else if (filterName == "S'inscrire") {
              return Register();
            } else if (filterName == "Profile") {
              return Profile();
            } else if (filterName == "Favorites") {
              return Favorites();
            } else if (filterName == "Searchables") {
              return Profile();
            }
            return Container();
          }),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12),
        margin: EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          border: Border.all(
            color: Colors.grey[300] ?? Colors.transparent,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            filterName,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildPropertyList() {
    return ListView.builder(
      controller: scrollController,
      itemCount: properties.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == properties.length) {
          return Center(child: CircularProgressIndicator());
        }
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 14),
          child: buildProperty(properties[index], index),
        );
      },
    );
  }

  Widget buildProperty(Property property, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Detail(property: property)),
        );
      },
      child: Card(
        margin: EdgeInsets.only(bottom: 24),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        child: Container(
          height: 210,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(property.frontImage),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.yellow[700],
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                  ),
                  width: 80,
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Center(
                    child: Text(
                      "FOR " + property.label,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(),
                ),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            property.name,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          property.price + r" DHs",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.location_on, color: Colors.white, size: 14),
                            SizedBox(width: 4),
                            Text(
                              property.location,
                              style: TextStyle(color: Colors.white, fontSize: 14),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.zoom_out_map, color: Colors.white, size: 16),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.yellow[700], size: 14),
                            SizedBox(width: 4),
                            Text(
                              property.review,
                              style: TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      builder: (BuildContext context) {
        return Wrap(
          children: [
            Filter(
              onApplyFilters: (String selectedChambre, RangeValues priceRange, String selectedToilet) {
                applyFilters(
                  bedrooms: selectedChambre,
                  minPrice: priceRange.start.toString(),
                  maxPrice: priceRange.end.toString(),
                  toilet: selectedToilet,
                );
              },
            ),
          ],
        );
      },
    );
  }

  VoidCallback get showBottomSheetCallback {
    return () => showBottomSheet(context);
  }
}