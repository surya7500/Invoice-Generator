import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import '../providers/hotel_provider.dart';
import '../models/hotel_details.dart';

final _formKey = GlobalKey<FormState>();

class HotelDetailsTab extends StatefulWidget {
  const HotelDetailsTab({super.key});

  @override
  _HotelDetailsTabState createState() => _HotelDetailsTabState();
}

class _HotelDetailsTabState extends State<HotelDetailsTab> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _gstinController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String? _logoPath;
  String? _backgroundPath;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HotelProvider>(context as BuildContext, listen: false).loadHotelDetails();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    _gstinController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      // Copy the file to a permanent location
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = basename(pickedFile.path);
      final permanentPath = join(appDir.path, 'logos', fileName);
      final permanentFile = File(permanentPath);
      await permanentFile.create(recursive: true);
      await permanentFile.writeAsBytes(await pickedFile.readAsBytes());
      setState(() {
        _logoPath = permanentPath;
      });
    }
  }

  Future<void> _pickBackground() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      // Copy the file to a permanent location
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = basename(pickedFile.path);
      final permanentPath = join(appDir.path, 'backgrounds', fileName);
      final permanentFile = File(permanentPath);
      await permanentFile.create(recursive: true);
      await permanentFile.writeAsBytes(await pickedFile.readAsBytes());
      setState(() {
        _backgroundPath = permanentPath;
      });
    }
  }

  void _save(BuildContext context) {
    HotelDetails hotel = HotelDetails(
      id: Provider.of<HotelProvider>(context, listen: false).hotelDetails?.id,
      name: _nameController.text,
      contact: _contactController.text,
      address: _addressController.text,
      gstin: _gstinController.text,
      email: _emailController.text,
      logoPath: _logoPath,
      backgroundPath: _backgroundPath,
    );
    Provider.of<HotelProvider>(context, listen: false).updateHotelDetails(hotel);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved')));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HotelProvider>(
      builder: (context, hotelProvider, child) {
        HotelDetails? hotel = hotelProvider.hotelDetails;
        // Initialize controllers with hotel data
        if (hotel != null) {
          _nameController.text = hotel.name;
          _contactController.text = hotel.contact;
          _addressController.text = hotel.address;
          _gstinController.text = hotel.gstin;
          _emailController.text = hotel.email;
          _logoPath ??= hotel.logoPath;
          _backgroundPath ??= hotel.backgroundPath;
        }
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Hotel Name',
                              hintText: 'Enter hotel name',
                              prefixIcon: Icon(Icons.business),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter hotel name';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            controller: _contactController,
                            decoration: InputDecoration(
                              labelText: 'Contact Number',
                              hintText: 'Enter contact number',
                              prefixIcon: Icon(Icons.phone),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter contact number';
                              }
                              if (value.length < 10) {
                                return 'Contact number must be at least 10 digits';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            controller: _addressController,
                            decoration: InputDecoration(
                              labelText: 'Address',
                              hintText: 'Enter address',
                              prefixIcon: Icon(Icons.location_on),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            maxLines: 2,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter address';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            controller: _gstinController,
                            decoration: InputDecoration(
                              labelText: 'GSTIN',
                              hintText: 'Enter GSTIN',
                              prefixIcon: Icon(Icons.assignment),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter GSTIN';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              hintText: 'Enter email',
                              prefixIcon: Icon(Icons.email),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter email';
                              }
                              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Media',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              children: [
                                _logoPath != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                          File(_logoPath!),
                                          height: 100,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Container(
                                        height: 100,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(Icons.image, size: 50, color: Colors.grey),
                                      ),
                                SizedBox(height: 8),
                                Text('Logo', style: TextStyle(fontWeight: FontWeight.w500)),
                                SizedBox(height: 8),
                                ElevatedButton.icon(
                                  onPressed: _pickLogo,
                                  icon: Icon(Icons.upload),
                                  label: Text('Pick Logo'),
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              children: [
                                _backgroundPath != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                          File(_backgroundPath!),
                                          height: 100,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Container(
                                        height: 100,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(Icons.image, size: 50, color: Colors.grey),
                                      ),
                                SizedBox(height: 8),
                                Text('Background', style: TextStyle(fontWeight: FontWeight.w500)),
                                SizedBox(height: 8),
                                ElevatedButton.icon(
                                  onPressed: _pickBackground,
                                  icon: Icon(Icons.upload),
                                  label: Text('Pick Background'),
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _save(context);
                        }
                      },
                      child: Text('Save Details'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
