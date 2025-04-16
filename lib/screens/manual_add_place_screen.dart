import 'package:flutter/material.dart';
import '../models/place.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../services/firebase_place_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../services/auth_service.dart';

class ManualAddPlaceScreen extends StatefulWidget {
  const ManualAddPlaceScreen({super.key});

  @override
  State<ManualAddPlaceScreen> createState() => _ManualAddPlaceScreenState();
}

class _ManualAddPlaceScreenState extends State<ManualAddPlaceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _seatingNotesController = TextEditingController();
  final _indoorNotesController = TextEditingController();
  final _outdoorNotesController = TextEditingController();
  final _auth = AuthService();
  
  PlaceType _selectedType = PlaceType.cafe;
  double _rating = 0;
  int _durationRating = 60;
  bool _isWorkingFriendly = false;
  bool _isReadingFriendly = false;
  bool _hasWifi = false;
  bool _isOpenNow = true;
  int _priceLevel = 1;
  bool _hasIndoorSeating = false;
  bool _hasOutdoorSeating = false;
  bool _isSeatingFree = true;

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        final user = _auth.currentUser;
        if (user == null) {
          throw Exception('User not logged in');
        }

        await FirebasePlaceService().addPlace({
          'name': _nameController.text,
          'address': _addressController.text,
          'description': _descriptionController.text,
          'imageUrl': 'https://example.com/placeholder.jpg', // Default placeholder image
          'type': _selectedType.toString().split('.').last,
          'rating': _rating,
          'durationRating': _durationRating,
          'isWorkingFriendly': _isWorkingFriendly,
          'isReadingFriendly': _isReadingFriendly,
          'hasWifi': _hasWifi,
          'isOpenNow': _isOpenNow,
          'priceLevel': _priceLevel,
          'seatingNotes': _seatingNotesController.text,
          'seatingLocation': {
            'hasIndoor': _hasIndoorSeating,
            'hasOutdoor': _hasOutdoorSeating,
            'indoorNote': _hasIndoorSeating ? _indoorNotesController.text : null,
            'outdoorNote': _hasOutdoorSeating ? _outdoorNotesController.text : null,
          },
        }, user.uid);
        
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Place added successfully!')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding place: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    _seatingNotesController.dispose();
    _indoorNotesController.dispose();
    _outdoorNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Place'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Place Name',
                  hintText: 'Enter place name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  hintText: 'Enter address',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter description',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<PlaceType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Type',
                ),
                items: PlaceType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_getNameForType(type)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
              ),
              const SizedBox(height: 24),
              const Text('Price Level'),
              Slider(
                value: _priceLevel.toDouble(),
                min: 1,
                max: 4,
                divisions: 3,
                label: '฿' * _priceLevel,
                onChanged: (value) {
                  setState(() {
                    _priceLevel = value.round();
                  });
                },
              ),
              const SizedBox(height: 16),
              const Text('Rating'),
              RatingBar.builder(
                initialRating: _rating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemSize: 40,
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  setState(() {
                    _rating = rating;
                  });
                },
              ),
              const SizedBox(height: 16),
              const Text('Duration Rating (minutes)'),
              Slider(
                value: _durationRating.toDouble(),
                min: 30,
                max: 240,
                divisions: 7,
                label: '$_durationRating min',
                onChanged: (value) {
                  setState(() {
                    _durationRating = value.round();
                  });
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Working Friendly'),
                value: _isWorkingFriendly,
                onChanged: (value) {
                  setState(() {
                    _isWorkingFriendly = value;
                  });
                },
              ),
              SwitchListTile(
                title: const Text('Reading Friendly'),
                value: _isReadingFriendly,
                onChanged: (value) {
                  setState(() {
                    _isReadingFriendly = value;
                  });
                },
              ),
              SwitchListTile(
                title: const Text('Currently Open'),
                value: _isOpenNow,
                onChanged: (value) {
                  setState(() {
                    _isOpenNow = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Has WiFi'),
                subtitle: const Text('Does this place provide WiFi access?'),
                value: _hasWifi,
                onChanged: (value) {
                  setState(() {
                    _hasWifi = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Seating Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _seatingNotesController,
                decoration: const InputDecoration(
                  labelText: 'Seating Notes',
                  hintText: 'Enter any general notes about seating',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Indoor Seating Available'),
                value: _hasIndoorSeating,
                onChanged: (value) {
                  setState(() {
                    _hasIndoorSeating = value!;
                  });
                },
              ),
              if (_hasIndoorSeating) ...[
                TextFormField(
                  controller: _indoorNotesController,
                  decoration: const InputDecoration(
                    labelText: 'Indoor Seating Notes',
                    hintText: 'Describe the indoor seating area',
                  ),
                ),
                const SizedBox(height: 16),
              ],
              CheckboxListTile(
                title: const Text('Outdoor Seating Available'),
                value: _hasOutdoorSeating,
                onChanged: (value) {
                  setState(() {
                    _hasOutdoorSeating = value!;
                  });
                },
              ),
              if (_hasOutdoorSeating) ...[
                TextFormField(
                  controller: _outdoorNotesController,
                  decoration: const InputDecoration(
                    labelText: 'Outdoor Seating Notes',
                    hintText: 'Describe the outdoor seating area',
                  ),
                ),
                const SizedBox(height: 16),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Add Place'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getNameForType(PlaceType type) {
    switch (type) {
      case PlaceType.restaurant:
        return 'Restaurant';
      case PlaceType.cafe:
        return 'Cafe';
      case PlaceType.gym:
        return 'Gym';
      case PlaceType.coworkingSpace:
        return 'Coworking Space';
      case PlaceType.publicSpace:
        return 'Public Space';
    }
  }
} 