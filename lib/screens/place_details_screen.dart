import 'package:flutter/material.dart';
import '../models/place.dart';
import '../services/firebase_place_service.dart';
import '../services/auth_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'saved_places_screen.dart';
import 'home_screen.dart';

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
    print('Place data: ${widget.place.toMap()}');
    _isLoading = false;
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
          // action: SnackBarAction(
          //   label: 'View Saved',
          //   onPressed: () {
          //     // Find the HomeScreen ancestor and change its current index
          //     context.findAncestorStateOfType<HomeScreenState>()?.setState(() {
          //       context.findAncestorStateOfType<HomeScreenState>()?.currentIndex = 1;
          //     });
          //   },
          // ),
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

  Widget _buildFeaturesSection() {
    final features = <Widget>[];
    
    // Add duration rating
    features.add(
      ListTile(
        leading: const Icon(Icons.access_time),
        title: const Text('Duration'),
        subtitle: Text('${widget.place.durationRating} minutes'),
      ),
    );

    // Add WiFi status
    if (widget.place.hasWifi) {
      features.add(
        ListTile(
          leading: const Icon(Icons.wifi),
          title: const Text('WiFi Available'),
        ),
      );
    }

    // Add pet-friendly status
    if (widget.place.isPetFriendly) {
      features.add(
        ListTile(
          leading: const Icon(Icons.pets),
          title: const Text('Pet Friendly'),
        ),
      );
    }

    // Add working friendly status
    if (widget.place.isWorkingFriendly) {
      features.add(
        ListTile(
          leading: const Icon(Icons.computer),
          title: const Text('Working Friendly'),
        ),
      );
    }

    // Add reading friendly status
    if (widget.place.isReadingFriendly) {
      features.add(
        ListTile(
          leading: const Icon(Icons.menu_book),
          title: const Text('Reading Friendly'),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Features',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...features,
      ],
    );
  }

  Widget _buildHoursSection() {
    final now = DateTime.now();
    final currentDay = now.weekday - 1; // Convert to 0-6 range (0 = Monday)
    final isTodayClosed = widget.place.closingDays != null && 
                         widget.place.closingDays!.isNotEmpty && 
                         widget.place.closingDays!.contains(currentDay);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hours',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (widget.place.is24Hours)
          Row(
            children: [
              Icon(Icons.schedule, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              const Text('Open 24 Hours'),
            ],
          )
        else if (isTodayClosed)
          Row(
            children: [
              Icon(Icons.event_busy, color: Colors.red),
              const SizedBox(width: 8),
              const Text('Closed Today'),
            ],
          )
        else if (widget.place.weekdayHours != null && currentDay < 5)
          Row(
            children: [
              Icon(Icons.schedule, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Text(
                'Today: ${widget.place.weekdayHours!['opening']} - ${widget.place.weekdayHours!['closing']}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          )
        else if (widget.place.weekendHours != null && currentDay >= 5)
          Row(
            children: [
              Icon(Icons.schedule, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Text(
                'Today: ${widget.place.weekendHours!['opening']} - ${widget.place.weekendHours!['closing']}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        if (!widget.place.is24Hours) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              const Text('Weekday Hours'),
              const Spacer(),
              Text(
                widget.place.weekdayHours != null
                    ? '${widget.place.weekdayHours!['opening']} - ${widget.place.weekdayHours!['closing']}'
                    : 'N/A',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              const Text('Weekend Hours'),
              const Spacer(),
              Text(
                widget.place.weekendHours != null
                    ? '${widget.place.weekendHours!['opening']} - ${widget.place.weekendHours!['closing']}'
                    : 'N/A',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
        if (widget.place.closingDays != null && widget.place.closingDays!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.event_busy, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 8),
                  const Text('Closing Days'),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: List.generate(7, (index) {
                  final isClosed = widget.place.closingDays!.contains(index);
                  return Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isClosed ? Colors.red.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                      border: Border.all(
                        color: isClosed ? Colors.red : Colors.grey,
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        ['S', 'M', 'T', 'W', 'T', 'F', 'S'][index],
                        style: TextStyle(
                          color: isClosed ? Colors.red : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final splashImageHeight = size.height * 0.2;
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
                    tag: 'place_image_${widget.place.id}_${_auth.currentUser?.uid ?? 'anonymous'}',
                    child: CachedNetworkImage(
                      imageUrl: widget.place.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom + 60, // Reduced from 80 to 60
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Title and basic info section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Container(
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
                                Row(
                                  children: [
                                    Icon(
                                      _getIconForType(widget.place.type),
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      widget.place.typeName,
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
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
                    ),
                    const SizedBox(height: 24),
                    // Details section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Container(
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
                            const SizedBox(height: 16),
                            _buildHoursSection(),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Features section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Container(
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
                                  'Guilty-free duration',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const Spacer(),
                                Text(
                                  '${widget.place.durationRating} min',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Divider(height: 24, color: Colors.grey[200]),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.wifi, color: Theme.of(context).primaryColor),
                                    const SizedBox(width: 8),
                                    const Text('WiFi Available'),
                                  ],
                                ),
                                Text(
                                  widget.place.hasWifi ? 'Yes' : 'No',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: widget.place.hasWifi ? Colors.green : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                            if (widget.place.isWorkingFriendly) Divider(height: 24, color: Colors.grey[200]),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.work, color: Theme.of(context).primaryColor),
                                    const SizedBox(width: 8),
                                    const Text('Work Friendly'),
                                  ],
                                ),
                                Text(
                                  widget.place.isWorkingFriendly ? 'Yes' : 'No',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: widget.place.isWorkingFriendly ? Colors.green : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                            if (widget.place.isReadingFriendly) Divider(height: 24, color: Colors.grey[200]),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.book, color: Theme.of(context).primaryColor),
                                    const SizedBox(width: 8),
                                    const Text('Reading Friendly'),
                                  ],
                                ),
                                Text(
                                  widget.place.isReadingFriendly ? 'Yes' : 'No',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: widget.place.isReadingFriendly ? Colors.green : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Seating section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Container(
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
                                    child: Container(
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
                                              Icon(Icons.chair, size: 20, color: Theme.of(context).primaryColor),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Indoor',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(context).primaryColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (widget.place.seatingLocation.indoorNote != null) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              widget.place.seatingLocation.indoorNote!,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                if (widget.place.seatingLocation.hasIndoor &&
                                    widget.place.seatingLocation.hasOutdoor)
                                  const SizedBox(width: 16),
                                if (widget.place.seatingLocation.hasOutdoor)
                                  Expanded(
                                    child: Container(
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
                                              Icon(Icons.deck, size: 20, color: Theme.of(context).primaryColor),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Outdoor',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(context).primaryColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (widget.place.seatingLocation.outdoorNote != null) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              widget.place.seatingLocation.outdoorNote!,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.1),
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
                bottom: MediaQuery.of(context).padding.bottom + 12, // Removed extra padding
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
                          'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(widget.place.name)}',
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
} 