import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:real_estate/providers/property_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:real_estate/main.dart';
import 'package:real_estate/data.dart';

class EditProperty extends StatefulWidget {
  final Property property;

  EditProperty({required this.property});

  @override
  _EditPropertyState createState() => _EditPropertyState();
}

class _EditPropertyState extends State<EditProperty> {
  int propertyId = 0;
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _cityController;
  late TextEditingController _addressController;
  late TextEditingController _surfaceController;
  late TextEditingController _ageController;
  late TextEditingController _roomsController;
  late TextEditingController _salonsController;
  late TextEditingController _toiletsController;
  late TextEditingController _interestPercentageController;
  late TextEditingController _floorNumberController;

  String _houseType = 'sell';
  String _rentability = 'full';
  List<Map<String, String>> _newImages = [];
  List<Map<String, String>> _newVideos = [];
  List<String> _existingImages = [];
  List<String> _existingVideos = [];
  List<Map<String, String>> _selectedEquipment = [];

  @override
  void initState() {
    super.initState();
    _initializeFields();
    _fetchEquipment();
  }

  void _initializeFields() {
    propertyId = widget.property.property_id;
    _titleController = TextEditingController(text: widget.property.name);
    _descriptionController = TextEditingController(text: widget.property.description);
    _priceController = TextEditingController(text: widget.property.price);
    _cityController = TextEditingController(text: widget.property.city);
    _addressController = TextEditingController(text: widget.property.address);
    _surfaceController = TextEditingController(text: widget.property.sqm);
    _ageController = TextEditingController(text: widget.property.age);
    _roomsController = TextEditingController(text: widget.property.number_of_rooms);
    _salonsController = TextEditingController(text: widget.property.number_of_salons);
    _toiletsController = TextEditingController(text: widget.property.number_of_toilets);
    _interestPercentageController = TextEditingController(text: widget.property.interest_percentage);
    _floorNumberController = TextEditingController(text: widget.property.floor_number);

    _houseType = 'sell';
    _rentability = 'full';

    _existingImages = widget.property.images;
    _existingVideos = [];
    _selectedEquipment = widget.property.equipments.map((equipment) => {
      'equipment': equipment.id.toString(),
      'quantity': '1',
    }).toList();
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
        title: Text('Edit Property'),
        backgroundColor: Colors.teal,
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
              _buildFileUpload('New Images', _newImages, FileType.image, (files) {
                setState(() {
                  _newImages = files.map((file) => {'image': file.path!, 'name': file.name}).toList();
                });
              }),
              _buildExistingImages('Existing Images', _existingImages),
              SizedBox(height: 20),
              _buildFileUpload('New Videos', _newVideos, FileType.video, (files) {
                setState(() {
                  _newVideos = files.map((file) => {'video': file.path!}).toList();
                });
              }),
              _buildExistingVideos('Existing Videos', _existingVideos),
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
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                  onPressed: _editProperty,
                  child: Text('Edit Property', style: TextStyle(fontSize: 16)),
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
        labelStyle: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.teal),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.teal, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
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
        labelStyle: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.teal),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.teal, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
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

  Widget _buildExistingImages(String label, List<String> files) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal)),
        SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: files
              .map((file) => Stack(
                    children: [
                      Image.network(
                        file,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _existingImages.remove(file);
                            });
                          },
                          child: Icon(
                            Icons.remove_circle,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildExistingVideos(String label, List<String> files) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal)),
        SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: files
              .map((file) => Stack(
                    children: [
                      Image.network(
                        file, // Placeholder for video thumbnails
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _existingVideos.remove(file);
                            });
                          },
                          child: Icon(
                            Icons.remove_circle,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
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
        Text('Equipment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal)),
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
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      padding: EdgeInsets.all(10),
                      margin: EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.yellow[200] : Colors.white,
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

  Future<void> _editProperty() async {
    try {
      await Provider.of<PropertyProvider>(context, listen: false).editProperty({
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
      }, _newImages, _newVideos, _existingImages, _existingVideos, widget.property.property_id);

      Navigator.of(context).pop();
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => MyApp()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to edit property: $e')));
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
