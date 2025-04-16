import 'package:flutter/material.dart';
import '../models/place.dart';
import '../services/firebase_place_service.dart';
import '../services/auth_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'place_details_screen.dart';

class SavedPlacesScreen extends StatefulWidget {
  const SavedPlacesScreen({super.key});

  @override
  State<SavedPlacesScreen> createState() => _SavedPlacesScreenState();
}

class _SavedPlacesScreenState extends State<SavedPlacesScreen> {
  final _placeService = FirebasePlaceService();
  final _auth = AuthService();
  List<Place> _savedPlaces = [];
  bool _isLoading = true;

  double _getResponsiveSize(BuildContext context, double size) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final shortestSide = screenWidth < screenHeight ? screenWidth : screenHeight;
    return size * (shortestSide / 375); // 375 is a standard mobile width
  }

  double _getImageSize(BuildContext context) {
    return _getResponsiveSize(context, 120);
  }

  double _getPadding(BuildContext context) {
    return _getResponsiveSize(context, 16);
  }

  double _getIconSize(BuildContext context) {
    return _getResponsiveSize(context, 24);
  }

  double _getFontSize(BuildContext context, double baseSize) {
    return _getResponsiveSize(context, baseSize);
  }

  @override
  void initState() {
    super.initState();
    _loadSavedPlaces();
  }

  Future<void> _loadSavedPlaces() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final places = await _placeService.getSavedPlaces(user.uid);
        setState(() {
          _savedPlaces = places;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading saved places: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteSavedPlace(String placeId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      setState(() {
        _savedPlaces.removeWhere((place) => place.id == placeId);
      });

      await _placeService.unsavePlace(placeId, user.uid);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
     SnackBar(
            content: Text('Place removed from saved list'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                _placeService.savePlace(placeId, user.uid);
                _loadSavedPlaces();
              },
            ),
          ),
        );
      }
    } catch (e) {
      print('Error deleting saved place: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
      _loadSavedPlaces(); // Reload to ensure consistency
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageSize = _getImageSize(context);
    final padding = _getPadding(context);
    final iconSize = _getIconSize(context);
    final titleFontSize = _getFontSize(context, 18);
    final subtitleFontSize = _getFontSize(context, 14);
    final emptyStateIconSize = _getFontSize(context, 64);
    final emptyStateFontSize = _getFontSize(context, 18);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Saved Places',
          style: TextStyle(fontSize: _getFontSize(context, 20)),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _savedPlaces.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.bookmark_border,
                        size: emptyStateIconSize,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: padding),
                      Text(
                        'No saved places yet',
                        style: TextStyle(
                          fontSize: emptyStateFontSize,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadSavedPlaces,
                  child: ListView.builder(
                    padding: EdgeInsets.all(padding),
                    itemCount: _savedPlaces.length,
                    itemBuilder: (context, index) {
                      final place = _savedPlaces[index];
                      return Dismissible(
                        key: Key(place.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.only(right: padding),
                          child: Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: iconSize,
                          ),
                        ),
                        onDismissed: (direction) => _deleteSavedPlace(place.id),
                        child: Card(
                          margin: EdgeInsets.only(bottom: padding),
                          child: ListTile(
                            contentPadding: EdgeInsets.all(padding),
                            minVerticalPadding: padding,
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(padding / 2),
                              child: CachedNetworkImage(
                                imageUrl: place.imageUrl,
                                width: imageSize,
                                height: imageSize,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  width: imageSize,
                                  height: imageSize,
                                  color: Colors.grey[200],
                                ),
                                errorWidget: (context, url, error) => Container(
                                  width: imageSize,
                                  height: imageSize,
                                  color: Colors.grey[200],
                                  child: Icon(Icons.error, size: iconSize),
                                ),
                              ),
                            ),
                            title: Text(
                              place.name,
                              style: TextStyle(fontSize: titleFontSize),
                            ),
                            subtitle: Text(
                              place.address,
                              style: TextStyle(fontSize: subtitleFontSize),
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete_outline, size: iconSize),
                              onPressed: () => _deleteSavedPlace(place.id),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PlaceDetailsScreen(place: place),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
} 