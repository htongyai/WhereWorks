import 'package:flutter/material.dart';
import '../models/place.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../services/firebase_place_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../services/auth_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as img;
import 'dart:io';
import 'package:image_cropper/image_cropper.dart';

class ManualAddPlaceScreen extends StatefulWidget {
  const ManualAddPlaceScreen({super.key});

  @override
  State<ManualAddPlaceScreen> createState() => _ManualAddPlaceScreenState();
}

class _ManualAddPlaceScreenState extends State<ManualAddPlaceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _areaController = TextEditingController();
  final _cityController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _seatingNotesController = TextEditingController();
  final _indoorNotesController = TextEditingController();
  final _outdoorNotesController = TextEditingController();
  final _auth = AuthService();
  final ImagePicker _picker = ImagePicker();
  File? _image;
  bool _isLoading = false;
  
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
  SeatingCost _seatingCost = SeatingCost.purchaseRequired;

  final List<String> _thaiProvinces = [
    'Amnat Charoen',
    'Ang Thong',
    'Bangkok',
    'Bueng Kan',
    'Buri Ram',
    'Chachoengsao',
    'Chai Nat',
    'Chaiyaphum',
    'Chanthaburi',
    'Chiang Mai',
    'Chiang Rai',
    'Chonburi',
    'Chumphon',
    'Kalasin',
    'Kamphaeng Phet',
    'Kanchanaburi',
    'Khon Kaen',
    'Krabi',
    'Lampang',
    'Lamphun',
    'Loei',
    'Lopburi',
    'Mae Hong Son',
    'Maha Sarakham',
    'Mukdahan',
    'Nakhon Nayok',
    'Nakhon Pathom',
    'Nakhon Phanom',
    'Nakhon Ratchasima (Korat)',
    'Nakhon Sawan',
    'Nakhon Si Thammarat',
    'Nan',
    'Narathiwat',
    'Nong Bua Lam Phu',
    'Nong Khai',
    'Nonthaburi',
    'Pathum Thani',
    'Pattani',
    'Phang Nga',
    'Phatthalung',
    'Phayao',
    'Phetchabun',
    'Phetchaburi',
    'Phichit',
    'Phitsanulok',
    'Phrae',
    'Phuket',
    'Prachinburi',
    'Prachuap Khiri Khan',
    'Ranong',
    'Ratchaburi',
    'Rayong',
    'Roi Et',
    'Sa Kaeo',
    'Sakon Nakhon',
    'Samut Prakan',
    'Samut Sakhon',
    'Samut Songkhram',
    'Saraburi',
    'Satun',
    'Sing Buri',
    'Si Sa Ket',
    'Songkhla',
    'Sukhothai',
    'Suphan Buri',
    'Surat Thani',
    'Surin',
    'Tak',
    'Trang',
    'Trat',
    'Ubon Ratchathani',
    'Udon Thani',
    'Uthai Thani',
    'Uttaradit',
    'Yala',
    'Yasothon',
  ];

  String _selectedCity = 'Bangkok';

  @override
  void initState() {
    super.initState();
    _cityController.text = _selectedCity;
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _isLoading = true;
        });

        try {
          // Step 1: Crop the image
          final croppedFile = await ImageCropper().cropImage(
            sourcePath: image.path,
            aspectRatio: const CropAspectRatio(ratioX: 16, ratioY: 9),
            uiSettings: [
              AndroidUiSettings(
                toolbarTitle: 'Crop Image',
                toolbarColor: Colors.deepPurple,
                toolbarWidgetColor: Colors.white,
                initAspectRatio: CropAspectRatioPreset.ratio16x9,
                lockAspectRatio: true,
              ),
              IOSUiSettings(
                title: 'Crop Image',
                aspectRatioLockEnabled: true,
                resetAspectRatioEnabled: false,
                aspectRatioPickerButtonHidden: true,
              ),
            ],
          );
          
          if (croppedFile != null) {
            // Step 2: Compress the cropped image
            final compressedFile = await _compressImage(File(croppedFile.path));
            
            // Step 3: Update the UI with the compressed image
            setState(() {
              _image = compressedFile;
              _isLoading = false;
            });
          }
        } catch (e) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error processing image: $e')),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<File> _compressImage(File file) async {
    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes);
    if (image == null) throw Exception('Could not decode image');

    // Start with a reasonable size
    final resized = img.copyResize(
      image,
      width: 1200, // Start with a larger size
      height: 675, // 16:9 aspect ratio
      maintainAspect: true,
    );

    int quality = 85;
    List<int> compressedBytes;
    do {
      compressedBytes = img.encodeJpg(resized, quality: quality);
      quality -= 5;
    } while (compressedBytes.length > 200 * 1024 && quality > 5);
    
    final compressedFile = File(file.path.replaceAll('.jpg', '_compressed.jpg'));
    await compressedFile.writeAsBytes(compressedBytes);
    
    print('Final image size: ${compressedBytes.length / 1024}KB with quality: ${quality + 5}');
    return compressedFile;
  }

  Future<String?> _uploadImage() async {
    if (_image == null) return null;

    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('place_images')
          .child('${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg');

      await storageRef.putFile(_image!, SettableMetadata(contentType: 'image/jpeg'));
      return await storageRef.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final user = _auth.currentUser;
        if (user == null) {
          throw Exception('User not logged in');
        }

        String? imageUrl = await _uploadImage();
        if (imageUrl == null) {
          imageUrl = 'https://example.com/placeholder.jpg';
        }

        await FirebasePlaceService().addPlace({
          'name': _nameController.text,
          'area': _areaController.text,
          'city': _cityController.text,
          'description': _descriptionController.text,
          'imageUrl': imageUrl,
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
          'seatingCost': _seatingCost.toString().split('.').last,
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
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _areaController.dispose();
    _cityController.dispose();
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
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    image: _image != null
                        ? DecorationImage(
                            image: FileImage(_image!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _image == null
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate, size: 50),
                            SizedBox(height: 8),
                            Text('Tap to add a photo'),
                          ],
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 16),
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
                controller: _areaController,
                decoration: const InputDecoration(
                  labelText: 'Area',
                  hintText: 'Enter area (e.g., Sukhumvit, Silom)',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an area';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCity,
                decoration: const InputDecoration(
                  labelText: 'City',
                  hintText: 'Select city',
                ),
                items: _thaiProvinces.map((String city) {
                  return DropdownMenuItem<String>(
                    value: city,
                    child: Text(city),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedCity = newValue;
                      _cityController.text = newValue;
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a city';
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
              const SizedBox(height: 16),
              DropdownButtonFormField<SeatingCost>(
                value: _seatingCost,
                decoration: const InputDecoration(
                  labelText: 'Seating Cost',
                ),
                items: SeatingCost.values.map((cost) {
                  return DropdownMenuItem(
                    value: cost,
                    child: Text(_getSeatingCostText(cost)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _seatingCost = value!;
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
              const SizedBox(height: 8),
              Text(
                'The duration that you feel comfortable sitting or guilty free',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
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
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Add Place'),
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

  String _getSeatingCostText(SeatingCost cost) {
    switch (cost) {
      case SeatingCost.free:
        return 'Free Entry';
      case SeatingCost.purchaseRequired:
        return 'Purchase Required';
      case SeatingCost.paid:
        return 'Paid Entry';
    }
  }
} 