import 'package:flutter/material.dart';
import '../models/place.dart';
import '../services/firebase_place_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import 'place_details_screen.dart';
import 'home_screen.dart';

class SavedPlacesScreen extends StatefulWidget {
  const SavedPlacesScreen({super.key});

  @override
  State<SavedPlacesScreen> createState() => _SavedPlacesScreenState();
}

class _SavedPlacesScreenState extends State<SavedPlacesScreen> {
  final FirebasePlaceService _placeService = FirebasePlaceService();
  final _auth = AuthService();
  final _firestore = FirebaseFirestore.instance;
  final _searchController = TextEditingController();
  List<Place> _savedPlaces = [];
  List<Place> _filteredPlaces = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadSavedPlaces();
    _searchController.addListener(_onSearchChanged);
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
      _filterPlaces();
    });
  }

  void _filterPlaces() {
    if (_searchQuery.isEmpty) {
      setState(() {
        _filteredPlaces = _savedPlaces;
      });
      return;
    }

    setState(() {
      _filteredPlaces = _savedPlaces.where((place) {
        return _searchQuery.isEmpty ||
            place.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            place.area.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            place.city.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    });
  }

  Future<void> _loadSavedPlaces() async {
    print('Loading saved places...');
    setState(() {
      _isLoading = true;
    });

    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('No user logged in');
        setState(() {
          _isLoading = false;
        });
        return;
      }
      print('User ID: ${user.uid}');

      // Check if user document exists
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      print('User document exists: ${userDoc.exists}');
      
      // Check saved places subcollection
      final savedPlacesSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('saved_places')
          .get();
      print('Number of saved places in subcollection: ${savedPlacesSnapshot.docs.length}');
      print('Saved place IDs: ${savedPlacesSnapshot.docs.map((doc) => doc.id).toList()}');

      final places = await _placeService.getSavedPlaces(user.uid);
      print('Retrieved ${places.length} saved places from service');
      
      setState(() {
        _savedPlaces = places;
        _filteredPlaces = places;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading saved places: $e');
      print('Stack trace: ${StackTrace.current}');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading saved places: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = size.width * 0.04;
    final spacing = size.height * 0.02;
    final cardImageHeight = size.height * 0.15;
    final cardTitleSize = size.width * 0.04;
    final cardSubtitleSize = size.width * 0.03;
    final chipTextSize = size.width * 0.025;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(padding),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Saved Places',
                    style: TextStyle(
                      fontSize: size.width * 0.06,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Your favorite workspaces',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: size.width * 0.035,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: padding),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search from your saved list',
              prefixIcon: const Icon(Icons.search),
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
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadSavedPlaces,
            child: _savedPlaces.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bookmark_border,
                          size: size.width * 0.2,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: spacing),
                        Text(
                          'No saved places yet',
                          style: TextStyle(
                            fontSize: size.width * 0.045,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: spacing * 0.5),
                        Text(
                          'Save places to see them here',
                          style: TextStyle(
                            fontSize: size.width * 0.035,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
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
                              builder: (context) =>
                                  PlaceDetailsScreen(place: _filteredPlaces[index]),
                            ),
                          );
                        },
                        imageHeight: cardImageHeight,
                        titleSize: cardTitleSize,
                        subtitleSize: cardSubtitleSize,
                        chipTextSize: chipTextSize,
                        userId: _auth.currentUser?.uid ?? 'anonymous',
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
} 