import 'package:flutter/material.dart';
import '../models/place.dart';
import '../services/firebase_place_service.dart';
import '../services/auth_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'saved_places_screen.dart';

class PlaceDetailsScreen extends StatefulWidget {
  final Place place;

  const PlaceDetailsScreen({super.key, required this.place});

  @override
  State<PlaceDetailsScreen> createState() => _PlaceDetailsScreenState();
}

class _PlaceDetailsScreenState extends State<PlaceDetailsScreen> {
  final _placeService = FirebasePlaceService();
  final _auth = AuthService();
  bool _isSaved = false;
  bool _isLoading = true;
  double? _userRating;

  @override
  void initState() {
    super.initState();
    print('PlaceDetailsScreen initialized with place: ${widget.place.id}');
    _checkIfSaved();
    _loadUserRating();
  }

  Future<void> _loadUserRating() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final rating = await _placeService.getUserRating(widget.place.id, user.uid);
        setState(() {
          _userRating = rating;
        });
      }
    } catch (e) {
      print('Error loading user rating: $e');
    }
  }

  Future<void> _checkIfSaved() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        print('Checking if place ${widget.place.id} is saved for user ${user.uid}');
        final isSaved = await _placeService.isPlaceSaved(widget.place.id, user.uid);
        setState(() {
          _isSaved = isSaved;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error checking if saved: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleSave() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please sign in to save places')),
        );
        return;
      }

      print('Current place ID: ${widget.place.id}');
      print('Current place data: ${widget.place.toMap()}');

      if (widget.place.id.isEmpty) {
        print('Invalid place ID detected');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid place ID')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      if (_isSaved) {
        print('Unsaving place ${widget.place.id}');
        await _placeService.unsavePlace(widget.place.id, user.uid);
      } else {
        print('Saving place ${widget.place.id}');
        await _placeService.savePlace(widget.place.id, user.uid);
      }

      setState(() {
        _isSaved = !_isSaved;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isSaved ? 'Place saved!' : 'Place unsaved'),
          action: SnackBarAction(
            label: 'View Saved',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SavedPlacesScreen(),
                ),
              );
            },
          ),
        ),
      );
    } catch (e) {
      print('Error toggling save: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _showRatingDialog() async {
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to rate places')),
      );
      return;
    }

    double rating = _userRating ?? 0;
    bool isSubmitting = false;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Rate this place'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RatingBar.builder(
                initialRating: rating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (value) {
                  setState(() {
                    rating = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Your rating: ${rating.toStringAsFixed(1)}',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      setState(() {
                        isSubmitting = true;
                      });
                      try {
                        await _placeService.updatePlaceRating(
                          widget.place.id,
                          rating,
                          user.uid,
                        );
                        if (mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Rating submitted!')),
                          );
                          setState(() {
                            _userRating = rating;
                          });
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
                      }
                    },
              child: isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final splashImageHeight = size.height * 0.3;
    final splashTitleSize = size.width * 0.06;
    final splashSubtitleSize = size.width * 0.04;
    final splashPadding = size.width * 0.04;
    final splashSpacing = size.height * 0.02;

    return Scaffold(
      body: Stack(
        children: [
          // Main content
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: splashImageHeight,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Hero(
                    tag: 'place_image_${widget.place.id}',
                    child: CachedNetworkImage(
                      imageUrl: widget.place.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom + 80, // 80 is the height of the bottom bar
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Title and basic info section
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  widget.place.name,
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: _showRatingDialog,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.amber,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.star, size: 16, color: Colors.white),
                                      const SizedBox(width: 4),
                                      Text(
                                        widget.place.rating.toStringAsFixed(1),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                widget.place.typeName,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                              Row(
                                children: [
                                  ...List.generate(4, (index) {
                                    final isActive = index < widget.place.priceText.length;
                                    return Text(
                                      '฿',
                                      style: TextStyle(
                                        color: isActive ? Theme.of(context).primaryColor : Colors.grey[300],
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '${widget.place.area}, ${widget.place.city}',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Details section
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey[200]!),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Details',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.place.description,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Features section
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey[200]!),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.timer, color: Theme.of(context).primaryColor),
                              const SizedBox(width: 8),
                              Text(
                                'Recommended Duration',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const Spacer(),
                              Text(
                                '${widget.place.durationRating} min',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          if (widget.place.hasWifi) const Divider(height: 24),
                          if (widget.place.hasWifi)
                            Row(
                              children: [
                                Icon(Icons.wifi, color: Theme.of(context).primaryColor),
                                const SizedBox(width: 8),
                                const Text('WiFi Available'),
                              ],
                            ),
                          if (widget.place.isWorkingFriendly) const Divider(height: 24),
                          if (widget.place.isWorkingFriendly)
                            Row(
                              children: [
                                Icon(Icons.work, color: Theme.of(context).primaryColor),
                                const SizedBox(width: 8),
                                const Text('Work Friendly'),
                              ],
                            ),
                          if (widget.place.isReadingFriendly) const Divider(height: 24),
                          if (widget.place.isReadingFriendly)
                            Row(
                              children: [
                                Icon(Icons.book, color: Theme.of(context).primaryColor),
                                const SizedBox(width: 8),
                                const Text('Reading Friendly'),
                              ],
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Seating section
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey[200]!),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Seating Information',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.place.seatingDescription,
                            style: const TextStyle(fontSize: 16),
                          ),
                          if (widget.place.seatingNotes != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              widget.place.seatingNotes!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              if (widget.place.seatingLocation.hasIndoor)
                                Expanded(
                                  child: _buildSeatingInfo(
                                    context,
                                    icon: Icons.chair,
                                    title: 'Indoor',
                                    note: widget.place.seatingLocation.indoorNote,
                                  ),
                                ),
                              if (widget.place.seatingLocation.hasIndoor &&
                                  widget.place.seatingLocation.hasOutdoor)
                                const SizedBox(width: 16),
                              if (widget.place.seatingLocation.hasOutdoor)
                                Expanded(
                                  child: _buildSeatingInfo(
                                    context,
                                    icon: Icons.deck,
                                    title: 'Outdoor',
                                    note: widget.place.seatingLocation.outdoorNote,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
          // Bottom bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 12,
                bottom: 12 + MediaQuery.of(context).padding.bottom,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _toggleSave,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                              ),
                            )
                          : Icon(
                              _isSaved ? Icons.bookmark : Icons.bookmark_border,
                              color: Theme.of(context).primaryColor,
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final url = Uri.parse(
                          'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent('${widget.place.area}, ${widget.place.city}')}',
                        );
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Could not launch maps')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Get Directions',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeatingInfo(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? note,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          if (note != null) ...[
            const SizedBox(height: 4),
            Text(
              note,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }
} 