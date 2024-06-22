import 'package:flutter/material.dart';
import 'property_list.dart';
import 'package:real_estate/profile.dart';
import 'package:real_estate/searchables.dart';
import 'package:real_estate/favorites.dart';
import 'package:real_estate/addProperty.dart';
import 'package:real_estate/myProperties.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends PropertyListState<Search> {
  @override
  bool isFavoritesPage() {
    return false;
  }
  bool isSearchablesPage() {
    return false;
  }
  bool isMypropertiesPage() {
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: isLoggedIn
          ? AppBar(
              title: Text('Immobiler'),
            )
          : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 48, left: 24, right: 24, bottom: 16),
            child: TextField(
              controller: textController,
              onSubmitted: (value) {
                setState(() {
                  currentPage = 1;
                });
                if (value.length > 2) {
                  performSearch(value);
                } else {
                  loadProperties(scrollDown: false);
                }
              },
              style: TextStyle(
                fontSize: 28,
                height: 1,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: TextStyle(
                  fontSize: 28,
                  color: Colors.grey[400] ?? Colors.transparent,
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[400] ?? Colors.transparent),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[400] ?? Colors.transparent),
                ),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[400] ?? Colors.transparent),
                ),
                suffixIcon: Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Icon(Icons.search, color: Colors.grey[400], size: 28),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    height: 32,
                    child: Stack(
                      children: [
                        isLoggedIn ? loggedInListView() : loggedOutListView(),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            width: 28,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerRight,
                                end: Alignment.centerLeft,
                                colors: [
                                  Theme.of(context).scaffoldBackgroundColor,
                                  Theme.of(context).scaffoldBackgroundColor.withOpacity(0.0),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: showBottomSheetCallback,
                  child: Padding(
                    padding: EdgeInsets.only(left: 16, right: 24),
                    child: Text(
                      "Filters",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 24, left: 24, top: 24, bottom: 12),
            child: Row(
              children: [
                Text(
                  fetchedProperties.toString(),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  "Résultat trouvé",
                  style: TextStyle(
                    fontSize: 24,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: buildPropertyList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({required IconData icon, required String text, GestureTapCallback? onTap}) {
  return ListTile(
    leading: Icon(icon, color: Colors.black),
    title: Text(
      text,
      style: TextStyle(
        color: Colors.black,
        fontSize: 18,
      ),
    ),
    onTap: onTap,
  );
}

void _navigateTo(BuildContext context, Widget page) {
  Navigator.pop(context);
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => page),
  );
}
}
