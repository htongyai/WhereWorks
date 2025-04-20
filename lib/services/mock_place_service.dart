import '../models/place.dart';

class MockPlaceService {
  static final List<Place> _places = [
    Place(
      id: '1',
      name: 'Cafe 46',
      area: '7 Avenue',
      city: 'Pune',
      type: PlaceType.cafe,
      rating: 4.0,
      durationRating: 120,
      isWorkingFriendly: true,
      isReadingFriendly: true,
      hasWifi: true,
      imageUrl: 'https://images.unsplash.com/photo-1554118811-1e0d58224f24',
      description: 'A cozy cafe with fast WiFi and plenty of power outlets',
      isOpenNow: true,
      seatingCost: SeatingCost.purchaseRequired,
      seatingNotes: 'Minimum order of one drink per 2 hours recommended',
      priceLevel: 2,
      seatingLocation: const SeatingLocation(
        hasIndoor: true,
        hasOutdoor: true,
        indoorNote: 'Air-conditioned seating with power outlets',
        outdoorNote: 'Garden seating available, covered area',
      ),
    ),
    Place(
      id: '2',
      name: 'Ambrosia',
      area: 'Park Street',
      city: 'Pune',
      type: PlaceType.restaurant,
      rating: 4.6,
      durationRating: 90,
      isWorkingFriendly: true,
      isReadingFriendly: false,
      hasWifi: true,
      imageUrl: 'https://images.unsplash.com/photo-1537047902294-62a40c20a6ae',
      description: 'Modern restaurant with quiet corners perfect for working',
      isOpenNow: true,
      seatingCost: SeatingCost.purchaseRequired,
      seatingNotes: 'Please order food or drinks while using the space',
      priceLevel: 3,
      seatingLocation: const SeatingLocation(
        hasIndoor: true,
        hasOutdoor: false,
        indoorNote: 'Spacious indoor seating with booth options',
      ),
    ),
    Place(
      id: '3',
      name: 'WorkHub Coworking',
      area: 'Tech Park',
      city: 'Baner',
      type: PlaceType.coworkingSpace,
      rating: 4.8,
      durationRating: 240,
      isWorkingFriendly: true,
      isReadingFriendly: true,
      hasWifi: true,
      imageUrl: 'https://images.unsplash.com/photo-1497366216548-37526070297c',
      description: 'Professional coworking space with meeting rooms',
      isOpenNow: true,
      seatingCost: SeatingCost.paid,
      seatingNotes: 'Daily and monthly passes available',
      priceLevel: 4,
      seatingLocation: const SeatingLocation(
        hasIndoor: true,
        hasOutdoor: true,
        indoorNote: 'Multiple floors with different working environments',
        outdoorNote: 'Rooftop working space with city view',
      ),
    ),
    Place(
      id: '4',
      name: 'FitLife Gym',
      area: 'MG Road',
      city: 'Pune',
      type: PlaceType.gym,
      rating: 4.3,
      durationRating: 120,
      isWorkingFriendly: false,
      isReadingFriendly: false,
      hasWifi: true,
      imageUrl: 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48',
      description: 'Modern gym with a dedicated workspace area',
      isOpenNow: true,
      seatingCost: SeatingCost.paid,
      seatingNotes: 'Gym membership required for workspace access',
      priceLevel: 3,
      seatingLocation: const SeatingLocation(
        hasIndoor: true,
        hasOutdoor: false,
        indoorNote: 'Dedicated quiet area for working',
      ),
    ),
    Place(
      id: '5',
      name: 'Central Park',
      area: 'Park Avenue',
      city: 'Bangkok',
      description: 'A large public park with various seating areas and free WiFi.',
      imageUrl: 'https://example.com/centralpark.jpg',
      type: PlaceType.publicSpace,
      rating: 4.2,
      durationRating: 180,
      isWorkingFriendly: true,
      isReadingFriendly: true,
      hasWifi: true,
      isOpenNow: true,
      priceLevel: 1,
      seatingCost: SeatingCost.free,
      seatingNotes: 'Public space with no purchase advised',
      seatingLocation: const SeatingLocation(
        hasIndoor: false,
        hasOutdoor: true,
        outdoorNote: 'Multiple shaded areas and benches available',
      ),
    ),
    Place(
      id: '6',
      name: 'City Library',
      area: 'Book Street',
      city: 'Bangkok',
      description: 'A modern public library with study areas and free WiFi.',
      imageUrl: 'https://example.com/citylibrary.jpg',
      type: PlaceType.publicSpace,
      rating: 4.7,
      durationRating: 240,
      isWorkingFriendly: true,
      isReadingFriendly: true,
      hasWifi: true,
      isOpenNow: true,
      priceLevel: 1,
      seatingCost: SeatingCost.free,
      seatingNotes: 'Free public access, library card required for some services',
      seatingLocation: const SeatingLocation(
        hasIndoor: true,
        hasOutdoor: false,
        indoorNote: 'Quiet study areas with power outlets',
      ),
    ),
    Place(
      id: '7',
      name: 'Community Fitness Center',
      area: 'Fitness Street',
      city: 'Bangkok',
      description: 'A community-run fitness center with basic equipment and free access.',
      imageUrl: 'https://example.com/communityfitness.jpg',
      type: PlaceType.gym,
      rating: 4.0,
      durationRating: 120,
      isWorkingFriendly: false,
      isReadingFriendly: false,
      hasWifi: false,
      isOpenNow: true,
      priceLevel: 1,
      seatingCost: SeatingCost.free,
      seatingNotes: 'Free access to all facilities, donations welcome',
      seatingLocation: const SeatingLocation(
        hasIndoor: true,
        hasOutdoor: false,
        indoorNote: 'Basic equipment and workout area',
      ),
    ),
  ];

  static List<Place> getAllPlaces() {
    return List.from(_places);
  }

  static List<Place> getPlacesByType(PlaceType type) {
    return _places.where((place) => place.type == type).toList();
  }

  static List<Place> searchPlaces(String query) {
    query = query.toLowerCase();
    return _places.where((place) {
      return place.name.toLowerCase().contains(query) ||
          place.area.toLowerCase().contains(query) ||
          place.city.toLowerCase().contains(query) ||
          place.description.toLowerCase().contains(query);
    }).toList();
  }

  static Future<void> addPlace(Map<String, dynamic> placeData) async {
    final newPlace = Place(
      id: ((_places.length + 1).toString()),
      name: placeData['name'],
      area: placeData['area'],
      city: placeData['city'],
      type: PlaceType.values.firstWhere(
        (e) => e.toString() == 'PlaceType.${placeData['type']}',
        orElse: () => PlaceType.cafe,
      ),
      rating: (placeData['rating'] ?? 0.0).toDouble(),
      durationRating: placeData['durationRating'] ?? 60,
      isWorkingFriendly: placeData['isWorkingFriendly'] ?? false,
      isReadingFriendly: placeData['isReadingFriendly'] ?? false,
      hasWifi: placeData['hasWifi'] ?? false,
      imageUrl: placeData['imageUrl'],
      description: placeData['description'] ?? '',
      isOpenNow: placeData['isOpenNow'] ?? false,
      seatingCost: SeatingCost.values.firstWhere(
        (e) => e.toString() == 'SeatingCost.${placeData['seatingCost']}',
        orElse: () => SeatingCost.purchaseRequired,
      ),
      seatingNotes: placeData['seatingNotes'] ?? '',
      priceLevel: placeData['priceLevel'] ?? 2,
      seatingLocation: SeatingLocation.fromMap(placeData['seatingLocation'] ?? {}),
    );
    _places.add(newPlace);
  }
} 