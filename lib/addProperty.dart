import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:real_estate/providers/property_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:real_estate/main.dart';

class AddProperty extends StatefulWidget {
  @override
  _AddPropertyState createState() => _AddPropertyState();
}

class _AddPropertyState extends State<AddProperty> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _surfaceController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _roomsController = TextEditingController();
  final TextEditingController _salonsController = TextEditingController();
  final TextEditingController _toiletsController = TextEditingController();
  final TextEditingController _interestPercentageController = TextEditingController();
  final TextEditingController _floorNumberController = TextEditingController();

  String _houseType = 'sell';
  String _rentability = 'full';
  List<Map<String, String>> _images = [];
  List<Map<String, String>> _videos = [];
  List<Map<String, String>> _selectedEquipment = [];

  @override
  void initState() {
    super.initState();
    _fetchEquipment();
  }

  Future<void> _fetchEquipment() async {
    try {
      await Provider.of<PropertyProvider>(context, listen: false).fetchEquipment();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load equipment: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    var equipmentList = Provider.of<PropertyProvider>(context).equipmentList;

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Property'),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildTextField(_titleController, 'Title'),
              SizedBox(height: 20),
              _buildTextField(_descriptionController, 'Description', maxLines: 3),
              SizedBox(height: 20),
              _buildTextField(_priceController, 'Price (DHs)', inputType: TextInputType.number),
              SizedBox(height: 20),
              _buildTextField(_cityController, 'City'),
              SizedBox(height: 20),
              _buildTextField(_addressController, 'Address', maxLines: 3),
              SizedBox(height: 20),
              _buildTextField(_surfaceController, 'Surface (m2)', inputType: TextInputType.number),
              SizedBox(height: 20),
              _buildTextField(_ageController, 'Age (years)', inputType: TextInputType.number),
              SizedBox(height: 20),
              _buildTextField(_roomsController, 'Number of Rooms', inputType: TextInputType.number),
              SizedBox(height: 20),
              _buildTextField(_salonsController, 'Number of Salons', inputType: TextInputType.number),
              SizedBox(height: 20),
              _buildTextField(_toiletsController, 'Number of Toilets', inputType: TextInputType.number),
              SizedBox(height: 20),
              _buildTextField(_interestPercentageController, 'Interest Percentage (%)', inputType: TextInputType.number),
              SizedBox(height: 20),
              _buildTextField(_floorNumberController, 'Floor Number'),
              SizedBox(height: 20),
              _buildDropdown('House Type', ['sell', 'rent'], _houseType, (value) {
                setState(() {
                  _houseType = value!;
                });
              }),
              SizedBox(height: 20),
              _buildDropdown('Rentability', ['full', 'partial'], _rentability, (value) {
                setState(() {
                  _rentability = value!;
                });
              }),
              SizedBox(height: 20),
              _buildFileUpload('Images', _images, FileType.image, (files) {
                setState(() {
                  _images = files.map((file) => {'image': file.path!, 'name': file.name}).toList();
                });
              }),
              SizedBox(height: 20),
              _buildFileUpload('Videos', _videos, FileType.video, (files) {
                setState(() {
                  _videos = files.map((file) => {'video': file.path!}).toList();
                });
              }),
              SizedBox(height: 20),
              _buildEquipmentSelector(equipmentList),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                  onPressed: _addProperty,
                  child: Text('Add Property'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {int maxLines = 1, TextInputType inputType = TextInputType.text}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.teal),
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.teal),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String value, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.teal),
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.teal),
        ),
      ),
    );
  }

  Widget _buildFileUpload(String label, List<Map<String, String>> files, FileType fileType, Function(List<PlatformFile>) onFilePicked) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal)),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: () async {
            FilePickerResult? result = await FilePicker.platform.pickFiles(
              type: fileType,
              allowMultiple: true,
            );
            if (result != null) {
              onFilePicked(result.files);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.yellow,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          ),
          child: Text('Upload $label'),
        ),
        SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: files
              .map((file) => Chip(
                    label: Text(file['name'] ?? file['image'] ?? file['video'] ?? ''),
                    deleteIcon: Icon(Icons.close, color: Colors.red),
                    onDeleted: () {
                      setState(() {
                        files.remove(file);
                      });
                    },
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildEquipmentSelector(List<Map<String, dynamic>> equipmentList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Equipment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Container(
          height: 300, // Set height for the scrollable area
          child: Stack(
            children: [
              ListView.builder(
                itemCount: equipmentList.length,
                itemBuilder: (context, index) {
                  var equipment = equipmentList[index];
                  bool isSelected = _selectedEquipment.any((e) => e['equipment'] == equipment['id'].toString());

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedEquipment.removeWhere((e) => e['equipment'] == equipment['id'].toString());
                        } else {
                          _selectedEquipment.add({
                            'equipment': equipment['id'].toString(),
                            'quantity': '1',
                          });
                        }
                      });
                    },
                    child: AnimatedContainer(
                      width: MediaQuery.of(context).size.width * 0.9,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      padding: EdgeInsets.all(10),
                      margin: EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.teal[100] : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          SvgPicture.string(equipment['icon_svg'], height: 50, width: 50),
                          SizedBox(width: 10),
                          Text(equipment['name']),
                        ],
                      ),
                    ),
                  );
                },
              ),
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 20,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Colors.white, Colors.white.withOpacity(0.0)],
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                width: 20,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [Colors.white, Colors.white.withOpacity(0.0)],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _addProperty() async {
    try {
      await Provider.of<PropertyProvider>(context, listen: false).addProperty({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'house_type': _houseType,
        'age': int.tryParse(_ageController.text),
        'number_of_rooms': int.tryParse(_roomsController.text),
        'surface': double.tryParse(_surfaceController.text),
        'rentability': _rentability,
        'price': double.tryParse(_priceController.text),
        'interest_percentage': double.tryParse(_interestPercentageController.text),
        'floor_number': _floorNumberController.text,
        'number_of_salons': int.tryParse(_salonsController.text),
        'number_of_toilets': int.tryParse(_toiletsController.text),
        'city': _cityController.text,
        'address': _addressController.text,
        'equipment': _selectedEquipment.map((e) => {
          'equipment': e['equipment'] ?? '',
          'quantity': int.tryParse(e['quantity'] ?? '0') ?? 0
        }).toList(),
      }, _images, _videos);

      Navigator.of(context).pop();
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => MyApp()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add property: $e')));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _surfaceController.dispose();
    _ageController.dispose();
    _roomsController.dispose();
    _salonsController.dispose();
    _toiletsController.dispose();
    _interestPercentageController.dispose();
    _floorNumberController.dispose();
    super.dispose();
  }
}
