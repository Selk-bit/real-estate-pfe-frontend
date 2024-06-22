import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:real_estate/providers/auth_provider.dart';
import 'package:real_estate/providers/property_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:real_estate/search.dart';
import 'package:real_estate/custom_drawer.dart';


void main() async {
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(),
        ),
        ChangeNotifierProvider<PropertyProvider>(
          create: (context) => PropertyProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Rental',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          textTheme: GoogleFonts.openSansTextTheme(),
        ),
        debugShowCheckedModeBanner: false,
        home: Consumer2<AuthProvider, PropertyProvider>(
          builder: (context, auth, property, _) {
            return Scaffold(
              appBar: AppBar(
                title: Text('Real Estate App'),
              ),
              drawer: CustomDrawer(), // Use the custom drawer
              body: Search(), // Your home page content
            );
          },
        ),
      ),
    );
  }
}
