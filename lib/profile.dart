import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:real_estate/providers/auth_provider.dart';
import 'dart:io';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _promptController = TextEditingController();
  bool _dataLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Provider.of<AuthProvider>(context, listen: false).isLoggedIn) {
        var provider = Provider.of<AuthProvider>(context, listen: false);
        provider.fetchUserProfile().then((_) {
          var userData = provider.userData;
          _firstNameController.text = userData['first_name'];
          _lastNameController.text = userData['last_name'];
          _usernameController.text = userData['username'];
          _emailController.text = userData['email'];
          _phoneController.text = userData['profile']['phone'] ?? "";
          _promptController.text = userData['profile']['prompt'] ?? "";
          setState(() {
            _dataLoaded = true;
          });
        });
      }
    });
  }

  Future<void> pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var authProvider = Provider.of<AuthProvider>(context);
    var userData = authProvider.userData;

    if (!authProvider.isLoggedIn || !_dataLoaded) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Edit Profile'),
          backgroundColor: Colors.blueGrey,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        backgroundColor: Colors.blueGrey,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              if (userData['profile']['profile_picture'] != null || _imageFile != null) ...[
                GestureDetector(
                  onTap: pickImage,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: _imageFile != null
                        ? FileImage(File(_imageFile!.path)) as ImageProvider<Object>
                        : NetworkImage(userData['profile']['profile_picture']) as ImageProvider<Object>,
                  ),
                ),
                SizedBox(height: 8),
                // if (_imageFile != null)
                //   Image.file(File(_imageFile!.path), height: 150),
              ],
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(labelText: 'First Name'),
              ),
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(labelText: 'Last Name'),
              ),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Username'),
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Phone'),
              ),
              TextFormField(
                controller: _promptController,
                decoration: InputDecoration(labelText: 'Prompt'),
                maxLines: null,
                keyboardType: TextInputType.multiline,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  Map<String, String> profileData = {
                    'first_name': _firstNameController.text,
                    'last_name': _lastNameController.text,
                    'username': _usernameController.text,
                    'email': _emailController.text,
                    'phone': _phoneController.text,
                    'prompt': _promptController.text,
                  };

                  try {
                    await authProvider.updateUserProfile(profileData, imagePath: _imageFile?.path);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile updated successfully')));
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update profile: $e')));
                  }
                },
                child: Text('Update Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _promptController.dispose();
    super.dispose();
  }
}
