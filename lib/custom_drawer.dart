import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:real_estate/providers/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:real_estate/search.dart'; // Adjust imports according to your file structure
import 'package:real_estate/favorites.dart';
import 'package:real_estate/searchables.dart';
import 'package:real_estate/addProperty.dart';
import 'package:real_estate/myProperties.dart';

class CustomDrawer extends StatefulWidget {
  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  bool isLoggedIn = false;
  String username = '';
  String email = '';
  String profilePictureUrl = '';

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  void checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('loginToken');
    setState(() {
      isLoggedIn = (token == null) ? false : true;
    });
    if (isLoggedIn) {
      fetchUserProfile();
    }
  }

  void fetchUserProfile() async {
    var provider = Provider.of<AuthProvider>(context, listen: false);
    await provider.fetchUserProfile();
    var userData = provider.userData;
    setState(() {
      username = userData['username'];
      email = userData['email'];
      profilePictureUrl = userData['profile']['profile_picture'] ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoggedIn) {
      return Container(); // or any other placeholder widget
    }

    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.yellow[700]!, Colors.orange],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              accountName: Text(
                username,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              accountEmail: Text(
                email,
                style: TextStyle(fontSize: 16),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundImage: profilePictureUrl.isNotEmpty
                    ? NetworkImage(profilePictureUrl)
                    : AssetImage('assets/images/profile_picture.png') as ImageProvider,
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(
                    icon: Icons.home,
                    text: 'Home',
                    onTap: () => _navigateTo(context, Search()),
                  ),
                  _buildDrawerItem(
                    icon: Icons.favorite,
                    text: 'Favorites',
                    onTap: () => _navigateTo(context, Favorites()),
                  ),
                  _buildDrawerItem(
                    icon: Icons.search,
                    text: 'Searchables',
                    onTap: () => _navigateTo(context, Searchables()),
                  ),
                  _buildDrawerItem(
                    icon: Icons.add,
                    text: 'Add Property',
                    onTap: () => _navigateTo(context, AddProperty()),
                  ),
                  _buildDrawerItem(
                    icon: Icons.business,
                    text: 'My Properties',
                    onTap: () => _navigateTo(context, MyProperties()),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                // Add logout functionality
              },
            ),
          ],
        ),
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
