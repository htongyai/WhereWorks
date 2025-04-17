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
import 'profile_upload_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _placeService = FirebasePlaceService();
  final _authService = AuthService();
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();
  bool _isSearching = false;
  List<Place> _places = [];
  List<Place> _filteredPlaces = [];
  String? _userName;
  String? _profileImageUrl;
  bool _isLoading = true;
  PlaceType? _selectedCategory;
  String _searchQuery = '';
  int _currentIndex = 0;

  final Map<int, Widget> _pages = {
    0: Column(
      children: const [],  // This will be populated in build method
    ),
    1: const SavedPlacesScreen(),
  };

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _filterPlaces();
    });
  }

  void _filterPlaces() {
    if (_searchQuery.isEmpty && _selectedCategory == null) {
      setState(() {
        _filteredPlaces = _places;
      });
      return;
    }

    setState(() {
      _filteredPlaces = _places.where((place) {
        final matchesSearch = _searchQuery.isEmpty ||
            place.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            place.area.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            place.city.toLowerCase().contains(_searchQuery.toLowerCase());
        final matchesCategory = _selectedCategory == null || place.type == _selectedCategory;
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final places = await _placeService.getAllPlaces();
      final user = _authService.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          setState(() {
            _userName = userDoc.data()?['name'];
            _profileImageUrl = userDoc.data()?['profileImageUrl'];
          });
        }
      }
      setState(() {
        _places = places;
        _filteredPlaces = places;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;

    // Define responsive sizes
    final avatarSize = screenWidth * 0.12;
    final titleSize = screenWidth * 0.05;
    final subtitleSize = screenWidth * 0.035;
    final padding = screenWidth * 0.04;
    final spacing = screenHeight * 0.02;
    final categoryIconSize = screenWidth * 0.08;
    final categoryTextSize = screenWidth * 0.035;
    final cardImageHeight = screenHeight * 0.2;
    final cardTitleSize = screenWidth * 0.045;
    final cardSubtitleSize = screenWidth * 0.035;
    final chipTextSize = screenWidth * 0.03;

    // Update the home page content
    _pages[0] = Column(
      children: [
        Padding(
          padding: EdgeInsets.all(padding),
          child: Row(
            children: [
              GestureDetector(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileUploadScreen(),
                    ),
                  );
                  if (result != null) {
                    setState(() {
                      _profileImageUrl = result;
                    });
                  }
                },
                child: Container(
                  width: avatarSize * 1,
                  height: avatarSize * 1,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: NetworkImage(
                        _profileImageUrl!,
                      ),
                      fit: BoxFit.cover,
                      onError: (exception, stackTrace) => const Icon(
                        Icons.person,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  child: _profileImageUrl == null
                      ? const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : null,
                ),
              ),
              SizedBox(width: spacing),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello ${_userName?.split(' ').first ?? 'there'},',
                    style: TextStyle(
                      fontSize: titleSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Let\'s find a place for you',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: subtitleSize,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.settings, color: Colors.grey[900]),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PreferencesScreen(),
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
                      _filterPlaces();
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
          child: RefreshIndicator(
            onRefresh: _refreshPlaces,
            child: ListView.builder(
              padding: EdgeInsets.only(
                left: padding,
                right: padding,
                top: padding,
                bottom: size.height * 0.1,
              ),
              itemCount: _filteredPlaces.length,
              itemBuilder: (context, index) {
                return PlaceCard(
                  place: _filteredPlaces[index],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlaceDetailsScreen(place: _filteredPlaces[index]),
                      ),
                    );
                  },
                  imageHeight: cardImageHeight,
                  titleSize: cardTitleSize,
                  subtitleSize: cardSubtitleSize,
                  chipTextSize: chipTextSize,
                );
              },
            ),
          ),
        ),
      ],
    );

    if (_isLoading) {
      return Scaffold(
        resizeToAvoidBottomInset: true,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Loading...',
                style: TextStyle(
                  fontSize: titleSize * 0.5,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
          child: Stack(
            alignment: Alignment.center,
            children: [
              IndexedStack(
                index: _currentIndex,
                children: _pages.values.toList(),
              ),
              Positioned(
                bottom: 0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  transform: Matrix4.translationValues(
                    0,
                    MediaQuery.of(context).viewInsets.bottom > 0 ? 100 : 0,
                    0,
                  ),
                  width: size.width * 0.95,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: size.width * 0.5,
                        height: size.height * 0.075,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildNavItem(0, Icons.home_outlined, Icons.home, 'Home'),
                              _buildNavItem(1, Icons.bookmark_border_outlined, Icons.bookmark, 'Saved'),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          AddPlaceOptionsScreen.show(context).then((value) {
                            if (value == true) {
                              _loadData();
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? Colors.black : Colors.white,
              size: 24,
            ),
            if (label.isNotEmpty && isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
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
      _loadData();
    }
  }

  Future<void> _refreshPlaces() async {
    try {
      final places = await _placeService.getAllPlaces();
      setState(() {
        _places = places;
        _filterPlaces();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error refreshing places: $e')),
        );
      }
    }
  }

  void _onCategorySelected(PlaceType? category) {
    setState(() {
      _selectedCategory = category;
      _filterPlaces();
    });
  }

  void _onSearchSubmitted(String query) {
    setState(() {
      _searchQuery = query;
      _filterPlaces();
    });
  }

  void _onSearchCleared() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _filterPlaces();
    });
  }

  void _onSearchFocusChanged(bool hasFocus) {
    setState(() {
      _isSearching = hasFocus;
    });
  }

  Future<void> _onRefresh() async {
    await _loadData();
  }
}

class PlaceCard extends StatelessWidget {
  final Place place;
  final VoidCallback onTap;
  final double imageHeight;
  final double titleSize;
  final double subtitleSize;
  final double chipTextSize;

  const PlaceCard({
    Key? key,
    required this.place,
    required this.onTap,
    required this.imageHeight,
    required this.titleSize,
    required this.subtitleSize,
    required this.chipTextSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
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
                      placeholder: (context, url) => Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.015,
                  right: MediaQuery.of(context).size.width * 0.03,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: place.seatingCost == SeatingCost.free
                              ? Colors.green
                              : place.seatingCost == SeatingCost.purchaseRequired
                                  ? Colors.orange
                                  : Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          place.seatingCost == SeatingCost.free
                              ? 'Free'
                              : place.seatingCost == SeatingCost.purchaseRequired
                                  ? 'Purchase Required'
                                  : 'Paid Entry',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
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
                      Expanded(
                        child: Text(
                          place.name,
                          style: TextStyle(
                            fontSize: titleSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            place.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '฿' * place.priceLevel,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
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
                          '${place.area}, ${place.city}',
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