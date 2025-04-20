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
  bool _is24Hours = false;
  bool _isPetFriendly = false;
  bool _useSameHours = true;
  bool _useIndividualWeekdays = false;
  bool _useIndividualWeekends = false;
  Map<int, TimeOfDay> _individualOpeningTimes = {};
  Map<int, TimeOfDay> _individualClosingTimes = {};
  int _priceLevel = 1;
  bool _hasIndoorSeating = false;
  bool _hasOutdoorSeating = false;
  SeatingCost _seatingCost = SeatingCost.purchaseRequired;
  TimeOfDay _weekdayOpeningTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _weekdayClosingTime = const TimeOfDay(hour: 20, minute: 0);
  TimeOfDay _weekendOpeningTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _weekendClosingTime = const TimeOfDay(hour: 18, minute: 0);
  final List<int> _closingDays = [];
  String? _seatingNotes;
  String? _indoorSeatingNotes;
  String? _outdoorSeatingNotes;

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
      // Validate only essential fields
      bool hasMissingFields = _nameController.text.isEmpty ||
          _areaController.text.isEmpty ||
          _descriptionController.text.isEmpty;

      if (!_is24Hours) {
        if (_useIndividualWeekdays) {
          // Check if all weekday times are set
          for (int i = 1; i <= 5; i++) {
            if (!_closingDays.contains(i) && 
                (_individualOpeningTimes[i] == null || _individualClosingTimes[i] == null)) {
              hasMissingFields = true;
              break;
            }
          }
        } else if (_weekdayOpeningTime == null || _weekdayClosingTime == null) {
          hasMissingFields = true;
        }

        if (!_useSameHours) {
          if (_useIndividualWeekends) {
            // Check if all weekend times are set
            for (int i in [6, 0]) {
              if (!_closingDays.contains(i) && 
                  (_individualOpeningTimes[i] == null || _individualClosingTimes[i] == null)) {
                hasMissingFields = true;
                break;
              }
            }
          } else if (_weekendOpeningTime == null || _weekendClosingTime == null) {
            hasMissingFields = true;
          }
        }
      }

      if (hasMissingFields) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill out the essential details'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      // Show confirmation dialog
      final bool? confirmed = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirm Details'),
            content: const Text('Are you sure all the details are correct?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Yes'),
              ),
            ],
          );
        },
      );

      if (confirmed != true) {
        return;
      }

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

        Map<String, dynamic> weekdayHours;
        Map<String, dynamic> weekendHours;

        if (_useIndividualWeekdays || _useIndividualWeekends) {
          // Convert individual times to weekday/weekend format
          final weekdayOpening = _individualOpeningTimes[1]?.format(context) ?? '08:00';
          final weekdayClosing = _individualClosingTimes[1]?.format(context) ?? '20:00';
          final weekendOpening = _individualOpeningTimes[6]?.format(context) ?? '09:00';
          final weekendClosing = _individualClosingTimes[6]?.format(context) ?? '18:00';

          weekdayHours = {
            'opening': weekdayOpening,
            'closing': weekdayClosing,
          };
          weekendHours = _useSameHours ? weekdayHours : {
            'opening': weekendOpening,
            'closing': weekendClosing,
          };
        } else {
          weekdayHours = {
            'opening': _weekdayOpeningTime.format(context),
            'closing': _weekdayClosingTime.format(context),
          };
          weekendHours = _useSameHours ? weekdayHours : {
            'opening': _weekendOpeningTime.format(context),
            'closing': _weekendClosingTime.format(context),
          };
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
          'seatingNotes': _seatingNotesController.text.isEmpty ? null : _seatingNotesController.text,
          'seatingLocation': {
            'hasIndoor': _hasIndoorSeating,
            'hasOutdoor': _hasOutdoorSeating,
            'indoorNote': _hasIndoorSeating && _indoorNotesController.text.isNotEmpty ? _indoorNotesController.text : null,
            'outdoorNote': _hasOutdoorSeating && _outdoorNotesController.text.isNotEmpty ? _outdoorNotesController.text : null,
          },
          'seatingCost': _seatingCost.toString().split('.').last,
          'is24Hours': _is24Hours,
          'weekdayHours': _is24Hours ? null : weekdayHours,
          'weekendHours': _is24Hours ? null : weekendHours,
          'closingDays': _closingDays,
          'isPetFriendly': _isPetFriendly,
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

  Future<void> _selectTime(BuildContext context, bool isOpening, bool isWeekend, {int? dayIndex}) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        if (dayIndex != null) {
          // Individual day time selection
          if (isOpening) {
            _individualOpeningTimes[dayIndex] = picked;
          } else {
            _individualClosingTimes[dayIndex] = picked;
          }
        } else if (isWeekend) {
          if (isOpening) {
            _weekendOpeningTime = picked;
          } else {
            _weekendClosingTime = picked;
          }
        } else {
          if (isOpening) {
            _weekdayOpeningTime = picked;
          } else {
            _weekdayClosingTime = picked;
          }
        }
      });
    }
  }

  Future<void> _selectIndividualTime(BuildContext context, int dayIndex, bool isOpening) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isOpening 
          ? (_individualOpeningTimes[dayIndex] ?? const TimeOfDay(hour: 8, minute: 0))
          : (_individualClosingTimes[dayIndex] ?? const TimeOfDay(hour: 20, minute: 0)),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isOpening) {
          _individualOpeningTimes[dayIndex] = picked;
        } else {
          _individualClosingTimes[dayIndex] = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Add New Place'),
        elevation: 0,
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
                title: const Text('Pet Friendly'),
                subtitle: const Text('Are pets allowed in this place?'),
                value: _isPetFriendly,
                onChanged: (value) {
                  setState(() {
                    _isPetFriendly = value;
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
              const SizedBox(height: 16),
              const Text(
                'Closing Days',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (int i = 0; i < 7; i++)
                    FilterChip(
                      label: Text(_getDayName(i)[0]),
                      selected: _closingDays.contains(i),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _closingDays.add(i);
                          } else {
                            _closingDays.remove(i);
                          }
                        });
                      },
                      shape: const CircleBorder(),
                      showCheckmark: false,
                      padding: const EdgeInsets.all(8),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('24 Hours Open'),
                value: _is24Hours,
                onChanged: (value) {
                  setState(() {
                    _is24Hours = value;
                  });
                },
              ),
              if (!_is24Hours) ...[
                const SizedBox(height: 16),
                const Text(
                  'Weekday Hours',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Weekday Hours',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              const Text(
                                'Individual Days',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              Switch(
                                value: _useIndividualWeekdays,
                                onChanged: (value) {
                                  setState(() {
                                    _useIndividualWeekdays = value;
                                    if (value) {
                                      // Initialize all weekday times with 8:00-20:00
                                      for (int i = 1; i <= 5; i++) {
                                        if (!_closingDays.contains(i)) {
                                          _individualOpeningTimes[i] = const TimeOfDay(hour: 8, minute: 0);
                                          _individualClosingTimes[i] = const TimeOfDay(hour: 20, minute: 0);
                                        }
                                      }
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (!_useIndividualWeekdays) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 120,
                              child: OutlinedButton.icon(
                                onPressed: () => _selectTime(context, true, false),
                                icon: const Icon(Icons.access_time),
                                label: Text(
                                  _weekdayOpeningTime.format(context),
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Text('to'),
                            const SizedBox(width: 16),
                            SizedBox(
                              width: 120,
                              child: OutlinedButton.icon(
                                onPressed: () => _selectTime(context, false, false),
                                icon: const Icon(Icons.access_time),
                                label: Text(
                                  _weekdayClosingTime.format(context),
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        // Individual weekday time slots
                        for (int i = 1; i <= 5; i++) ...[
                          const SizedBox(height: 8),
                          Text(
                            _getDayName(i),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: _closingDays.contains(i) ? Colors.grey : null,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (_closingDays.contains(i))
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.block, color: Colors.grey),
                                  SizedBox(width: 8),
                                  Text(
                                    'Closed',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 120,
                                  child: OutlinedButton.icon(
                                    onPressed: () => _selectTime(context, true, false, dayIndex: i),
                                    icon: const Icon(Icons.access_time),
                                    label: Text(
                                      _individualOpeningTimes[i]?.format(context) ?? 'Select time',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                const Text('to'),
                                const SizedBox(width: 16),
                                SizedBox(
                                  width: 120,
                                  child: OutlinedButton.icon(
                                    onPressed: () => _selectTime(context, false, false, dayIndex: i),
                                    icon: const Icon(Icons.access_time),
                                    label: Text(
                                      _individualClosingTimes[i]?.format(context) ?? 'Select time',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Weekend Hours',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Weekend Hours',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              const Text(
                                'Individual Days',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              Switch(
                                value: _useIndividualWeekends,
                                onChanged: (value) {
                                  setState(() {
                                    _useIndividualWeekends = value;
                                    if (value) {
                                      // Initialize all weekend times with 8:00-20:00
                                      if (!_closingDays.contains(6)) {
                                        _individualOpeningTimes[6] = const TimeOfDay(hour: 8, minute: 0); // Saturday
                                        _individualClosingTimes[6] = const TimeOfDay(hour: 20, minute: 0);
                                      }
                                      if (!_closingDays.contains(0)) {
                                        _individualOpeningTimes[0] = const TimeOfDay(hour: 8, minute: 0); // Sunday
                                        _individualClosingTimes[0] = const TimeOfDay(hour: 20, minute: 0);
                                      }
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (!_useIndividualWeekends) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 120,
                              child: OutlinedButton.icon(
                                onPressed: () => _selectTime(context, true, true),
                                icon: const Icon(Icons.access_time),
                                label: Text(
                                  _weekendOpeningTime.format(context),
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Text('to'),
                            const SizedBox(width: 16),
                            SizedBox(
                              width: 120,
                              child: OutlinedButton.icon(
                                onPressed: () => _selectTime(context, false, true),
                                icon: const Icon(Icons.access_time),
                                label: Text(
                                  _weekendClosingTime.format(context),
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        // Individual weekend time slots
                        for (int i in [6, 0]) ...[
                          const SizedBox(height: 8),
                          Text(
                            _getDayName(i),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: _closingDays.contains(i) ? Colors.grey : null,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (_closingDays.contains(i))
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.block, color: Colors.grey),
                                  SizedBox(width: 8),
                                  Text(
                                    'Closed',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 120,
                                  child: OutlinedButton.icon(
                                    onPressed: () => _selectTime(context, true, true, dayIndex: i),
                                    icon: const Icon(Icons.access_time),
                                    label: Text(
                                      _individualOpeningTimes[i]?.format(context) ?? 'Select time',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                const Text('to'),
                                const SizedBox(width: 16),
                                SizedBox(
                                  width: 120,
                                  child: OutlinedButton.icon(
                                    onPressed: () => _selectTime(context, false, true, dayIndex: i),
                                    icon: const Icon(Icons.access_time),
                                    label: Text(
                                      _individualClosingTimes[i]?.format(context) ?? 'Select time',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ],
                    ],
                  ),
                ),
              ],
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
        return 'Purchase Advised';
      case SeatingCost.paid:
        return 'Paid Entry';
    }
  }

  String _getDayName(int index) {
    switch (index) {
      case 0:
        return 'Sunday';
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      default:
        throw Exception('Invalid day index');
    }
  }
} 