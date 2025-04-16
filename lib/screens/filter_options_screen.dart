import 'package:flutter/material.dart';
import '../models/place.dart';

class FilterOptionsScreen extends StatefulWidget {
  final PlaceType? selectedType;
  final bool? isWorkingFriendly;
  final bool? isReadingFriendly;
  final bool? isOpenNow;
  final SeatingCost? seatingCost;
  final bool? hasIndoor;
  final bool? hasOutdoor;
  final int? minDuration;
  final int? maxDuration;
  final int? minPrice;
  final int? maxPrice;

  const FilterOptionsScreen({
    super.key,
    this.selectedType,
    this.isWorkingFriendly,
    this.isReadingFriendly,
    this.isOpenNow,
    this.seatingCost,
    this.hasIndoor,
    this.hasOutdoor,
    this.minDuration,
    this.maxDuration,
    this.minPrice,
    this.maxPrice,
  });

  @override
  State<FilterOptionsScreen> createState() => _FilterOptionsScreenState();
}

class _FilterOptionsScreenState extends State<FilterOptionsScreen> {
  late PlaceType? _selectedType;
  late bool? _isWorkingFriendly;
  late bool? _isReadingFriendly;
  late bool? _isOpenNow;
  late SeatingCost? _seatingCost;
  late bool? _hasIndoor;
  late bool? _hasOutdoor;
  late RangeValues _durationRange;
  late RangeValues _priceRange;
  bool _showWorkingFriendly = false;
  bool _showReadingFriendly = false;
  bool _showHasWifi = false;
  Set<PlaceType> _selectedTypes = {};
  Set<SeatingCost> _selectedSeatingCosts = {};

  @override
  void initState() {
    super.initState();
    _selectedType = widget.selectedType;
    _isWorkingFriendly = widget.isWorkingFriendly;
    _isReadingFriendly = widget.isReadingFriendly;
    _isOpenNow = widget.isOpenNow;
    _seatingCost = widget.seatingCost;
    _hasIndoor = widget.hasIndoor;
    _hasOutdoor = widget.hasOutdoor;
    _durationRange = RangeValues(
      widget.minDuration?.toDouble() ?? 30,
      widget.maxDuration?.toDouble() ?? 240,
    );
    _priceRange = RangeValues(
      widget.minPrice?.toDouble() ?? 1,
      widget.maxPrice?.toDouble() ?? 4,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filter Options'),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedType = null;
                _isWorkingFriendly = null;
                _isReadingFriendly = null;
                _isOpenNow = null;
                _seatingCost = null;
                _hasIndoor = null;
                _hasOutdoor = null;
                _durationRange = const RangeValues(30, 240);
                _priceRange = const RangeValues(1, 4);
                _showWorkingFriendly = false;
                _showReadingFriendly = false;
                _showHasWifi = false;
                _selectedTypes.clear();
                _selectedSeatingCosts.clear();
              });
            },
            child: const Text('Reset'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Place Type',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: PlaceType.values.map((type) {
                String typeName;
                switch (type) {
                  case PlaceType.restaurant:
                    typeName = 'Restaurant';
                    break;
                  case PlaceType.cafe:
                    typeName = 'Cafe';
                    break;
                  case PlaceType.gym:
                    typeName = 'Gym';
                    break;
                  case PlaceType.coworkingSpace:
                    typeName = 'Coworking Space';
                    break;
                  case PlaceType.publicSpace:
                    typeName = 'Public Space';
                    break;
                }
                return FilterChip(
                  label: Text(typeName),
                  selected: _selectedTypes.contains(type),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedTypes.add(type);
                      } else {
                        _selectedTypes.remove(type);
                      }
                    });
                  },
                  showCheckmark: false,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  backgroundColor: Colors.grey[200],
                  selectedColor: const Color(0xFF90C8AC),
                  labelStyle: TextStyle(
                    color: _selectedTypes.contains(type) ? Colors.white : Colors.black,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                  side: BorderSide.none,
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            const Text(
              'Features',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilterChip(
                  label: const Text('Working Friendly'),
                  selected: _isWorkingFriendly == true,
                  onSelected: (selected) {
                    setState(() {
                      _isWorkingFriendly = selected ? true : null;
                    });
                  },
                  showCheckmark: false,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  backgroundColor: Colors.grey[200],
                  selectedColor: Colors.grey[900],
                  labelStyle: TextStyle(
                    color: _isWorkingFriendly == true ? Colors.white : Colors.black,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                  side: BorderSide.none,
                ),
                FilterChip(
                  label: const Text('Reading Friendly'),
                  selected: _isReadingFriendly == true,
                  onSelected: (selected) {
                    setState(() {
                      _isReadingFriendly = selected ? true : null;
                    });
                  },
                  showCheckmark: false,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  backgroundColor: Colors.grey[200],
                  selectedColor: Colors.grey[900],
                  labelStyle: TextStyle(
                    color: _isReadingFriendly == true ? Colors.white : Colors.black,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                  side: BorderSide.none,
                ),
                FilterChip(
                  label: const Text('Open Now'),
                  selected: _isOpenNow == true,
                  onSelected: (selected) {
                    setState(() {
                      _isOpenNow = selected ? true : null;
                    });
                  },
                  showCheckmark: false,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  backgroundColor: Colors.grey[200],
                  selectedColor: Colors.grey[900],
                  labelStyle: TextStyle(
                    color: _isOpenNow == true ? Colors.white : Colors.black,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                  side: BorderSide.none,
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Seating Cost',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: SeatingCost.values.map((cost) {
                String label;
                switch (cost) {
                  case SeatingCost.free:
                    label = 'Free Entry';
                    break;
                  case SeatingCost.purchaseRequired:
                    label = 'Purchase Required';
                    break;
                  case SeatingCost.paid:
                    label = 'Paid Entry';
                    break;
                }
                return FilterChip(
                  label: Text(label),
                  selected: _selectedSeatingCosts.contains(cost),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedSeatingCosts.add(cost);
                      } else {
                        _selectedSeatingCosts.remove(cost);
                      }
                    });
                  },
                  showCheckmark: false,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  backgroundColor: Colors.grey[200],
                  selectedColor: const Color(0xFF90C8AC),
                  labelStyle: TextStyle(
                    color: _selectedSeatingCosts.contains(cost) ? Colors.white : Colors.black,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                  side: BorderSide.none,
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            const Text(
              'Seating Location',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilterChip(
                  label: const Text('Indoor'),
                  selected: _hasIndoor == true,
                  onSelected: (selected) {
                    setState(() {
                      _hasIndoor = selected ? true : null;
                    });
                  },
                  showCheckmark: false,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  backgroundColor: Colors.grey[200],
                  selectedColor: Colors.grey[900],
                  labelStyle: TextStyle(
                    color: _hasIndoor == true ? Colors.white : Colors.black,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                  side: BorderSide.none,
                ),
                FilterChip(
                  label: const Text('Outdoor'),
                  selected: _hasOutdoor == true,
                  onSelected: (selected) {
                    setState(() {
                      _hasOutdoor = selected ? true : null;
                    });
                  },
                  showCheckmark: false,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  backgroundColor: Colors.grey[200],
                  selectedColor: Colors.grey[900],
                  labelStyle: TextStyle(
                    color: _hasOutdoor == true ? Colors.white : Colors.black,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                  side: BorderSide.none,
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Duration Range (minutes)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            RangeSlider(
              values: _durationRange,
              min: 30,
              max: 240,
              divisions: 7,
              labels: RangeLabels(
                '${_durationRange.start.round()} min',
                '${_durationRange.end.round()} min',
              ),
              onChanged: (values) {
                setState(() {
                  _durationRange = values;
                });
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Price Range',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            RangeSlider(
              values: _priceRange,
              min: 1,
              max: 4,
              divisions: 3,
              labels: RangeLabels(
                '฿' * _priceRange.start.round(),
                '฿' * _priceRange.end.round(),
              ),
              onChanged: (values) {
                setState(() {
                  _priceRange = values;
                });
              },
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, {
                    'types': _selectedTypes.toList(),
                    'isWorkingFriendly': _isWorkingFriendly,
                    'isReadingFriendly': _isReadingFriendly,
                    'isOpenNow': _isOpenNow,
                    'seatingCosts': _selectedSeatingCosts.toList(),
                    'hasIndoor': _hasIndoor,
                    'hasOutdoor': _hasOutdoor,
                    'minDuration': _durationRange.start.round(),
                    'maxDuration': _durationRange.end.round(),
                    'minPrice': _priceRange.start.round(),
                    'maxPrice': _priceRange.end.round(),
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Apply Filters'),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 