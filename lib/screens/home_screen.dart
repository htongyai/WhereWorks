import 'package:flutter/material.dart';
import '../models/place.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'add_place_options_screen.dart';
import '../services/firebase_place_service.dart';
import 'place_details_screen.dart';
import 'filter_options_screen.dart';
import 'saved_places_screen.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import 'preferences_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FirebasePlaceService _placeService = FirebasePlaceService();
  PlaceType? _selectedCategory;
  List<Place> _places = [];
  String _searchQuery = '';
  bool _isLoading = true;
  String? _userName;
  final _auth = AuthService();
  final _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadPlaces();
    _searchController.addListener(_onSearchChanged);
    _loadUserName();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _loadPlaces();
    });
  }

  Future<void> _loadPlaces() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<Place> places;
      if (_searchQuery.isNotEmpty) {
        places = await _placeService.searchPlaces(_searchQuery);
      } else if (_selectedCategory != null) {
        places = await _placeService.getPlacesByType(_selectedCategory!);
      } else {
        places = await _placeService.getAllPlaces();
      }

      setState(() {
        _places = places;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading places: $e')),
        );
      }
    }
  }

  Future<void> _loadUserName() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          _userName = doc.data()?['name'] as String?;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final avatarSize = size.width * 0.1;
    final titleSize = size.width * 0.045;
    final subtitleSize = size.width * 0.035;
    final padding = size.width * 0.04;
    final spacing = size.height * 0.02;
    final categoryIconSize = size.width * 0.08;
    final categoryTextSize = size.width * 0.03;
    final cardImageHeight = size.height * 0.25;
    final cardTitleSize = size.width * 0.04;
    final cardSubtitleSize = size.width * 0.03;
    final chipTextSize = size.width * 0.025;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(padding),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: avatarSize,
                    backgroundImage: const AssetImage('assets/images/profile.png'),
                  ),
                  SizedBox(width: spacing),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello ${_userName ?? 'there'},',
                        style: TextStyle(
                          fontSize: titleSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Let\'s find a productive place for you',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: subtitleSize,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PreferencesScreen(),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.bookmark),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SavedPlacesScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: padding),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search Places / Area',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: GestureDetector(
                    onTap: _showFilterOptions,
                    child: Container(
                      margin: EdgeInsets.all(spacing),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.tune,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
            ),
            SizedBox(height: spacing),
            SizedBox(
              height: size.height * 0.12,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: padding),
                children: PlaceType.values.map((type) {
                  return Padding(
                    padding: EdgeInsets.only(right: spacing),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = _selectedCategory == type ? null : type;
                          _loadPlaces();
                        });
                      },
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(spacing),
                            decoration: BoxDecoration(
                              color: _selectedCategory == type
                                  ? Colors.grey[900]
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _getIconForType(type),
                              size: categoryIconSize,
                              color: _selectedCategory == type
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                          SizedBox(height: spacing * 0.5),
                          Text(
                            _getNameForType(type),
                            style: TextStyle(
                              fontSize: categoryTextSize,
                              color: _selectedCategory == type
                                  ? Colors.grey[900]
                                  : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(padding),
                itemCount: _places.length,
                itemBuilder: (context, index) {
                  return PlaceCard(
                    place: _places[index],
                    imageHeight: cardImageHeight,
                    titleSize: cardTitleSize,
                    subtitleSize: cardSubtitleSize,
                    chipTextSize: chipTextSize,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => AddPlaceOptionsScreen.show(context),
        backgroundColor: Colors.grey[900],
        child: const Icon(Icons.add),
      ),
    );
  }

  IconData _getIconForType(PlaceType type) {
    switch (type) {
      case PlaceType.restaurant:
        return Icons.restaurant;
      case PlaceType.cafe:
        return Icons.coffee;
      case PlaceType.gym:
        return Icons.fitness_center;
      case PlaceType.coworkingSpace:
        return Icons.business;
      case PlaceType.publicSpace:
        return Icons.park;
    }
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
        return 'Coworking';
      case PlaceType.publicSpace:
        return 'Public';
    }
  }

  Future<void> _showFilterOptions() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FilterOptionsScreen(),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedCategory = result['type'];
        // TODO: Apply other filters
      });
      _loadPlaces();
    }
  }
}

class PlaceCard extends StatelessWidget {
  final Place place;
  final double imageHeight;
  final double titleSize;
  final double subtitleSize;
  final double chipTextSize;

  const PlaceCard({
    super.key,
    required this.place,
    required this.imageHeight,
    required this.titleSize,
    required this.subtitleSize,
    required this.chipTextSize,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlaceDetailsScreen(place: place),
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.02),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Hero(
                    tag: 'place_image_${place.id}',
                    child: CachedNetworkImage(
                      imageUrl: place.imageUrl,
                      height: imageHeight,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.015,
                  right: MediaQuery.of(context).size.width * 0.03,
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.02,
                          vertical: MediaQuery.of(context).size.height * 0.005,
                        ),
                        decoration: BoxDecoration(
                          color: place.seatingCost == SeatingCost.free ? Colors.green : Colors.orange,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          place.seatingCost == SeatingCost.free ? 'Free' : 'Not Free',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: chipTextSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.02,
                          vertical: MediaQuery.of(context).size.height * 0.005,
                        ),
                        decoration: BoxDecoration(
                          color: place.isOpenNow ? Colors.green : Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          place.isOpenNow ? 'Open Now' : 'Closed',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: chipTextSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        place.name,
                        style: TextStyle(
                          fontSize: titleSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                      const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 20,
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.01),
                      Text(
                        place.rating.toString(),
                        style: TextStyle(
                          fontSize: subtitleSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          ...List.generate(4, (index) {
                            final isActive = index < place.priceText.length;
                            return Text(
                              '฿',
                              style: TextStyle(
                                color: isActive ? Theme.of(context).primaryColor : Colors.grey[300],
                                fontSize: subtitleSize,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  Row(
                    children: [
                      Icon(
                        Icons.wifi,
                        size: MediaQuery.of(context).size.width * 0.04,
                        color: place.hasWifi ? Colors.green : Colors.grey,
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.01),
                      Text(
                        place.hasWifi ? 'WiFi' : 'No WiFi',
                        style: TextStyle(
                          fontSize: chipTextSize,
                          color: place.hasWifi ? Colors.green : Colors.grey,
                        ),
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.04),
                      Icon(
                        Icons.location_on,
                        size: MediaQuery.of(context).size.width * 0.04,
                        color: Colors.grey,
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.01),
                      Expanded(
                        child: Text(
                          place.address,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: chipTextSize,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.015),
                  Row(
                    children: [
                      _buildFeatureChip(
                        context: context,
                        icon: Icons.timer,
                        label: '${place.durationRating} min',
                        size: chipTextSize,
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                      if (place.seatingLocation.hasIndoor)
                        _buildFeatureChip(
                          context: context,
                          icon: Icons.home,
                          label: 'Indoor',
                          color: Colors.blue,
                          size: chipTextSize,
                        ),
                      if (place.seatingLocation.hasIndoor && 
                          place.seatingLocation.hasOutdoor)
                        SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                      if (place.seatingLocation.hasOutdoor)
                        _buildFeatureChip(
                          context: context,
                          icon: Icons.park,
                          label: 'Outdoor',
                          color: Colors.blue,
                          size: chipTextSize,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureChip({
    required BuildContext context,
    required IconData icon,
    required String label,
    Color? color,
    required double size,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.02,
        vertical: MediaQuery.of(context).size.height * 0.005,
      ),
      decoration: BoxDecoration(
        color: (color ?? Colors.grey[700])!.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (color ?? Colors.grey[700])!.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: MediaQuery.of(context).size.width * 0.04,
            color: color ?? Colors.grey[700],
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.01),
          Text(
            label,
            style: TextStyle(
              fontSize: size,
              color: color ?? Colors.grey[700],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
} 