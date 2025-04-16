import 'package:cloud_firestore/cloud_firestore.dart';

enum PlaceType {
  restaurant,
  cafe,
  gym,
  coworkingSpace,
  publicSpace
}

enum SeatingCost {
  free,
  purchaseRequired,
  paid
}

class SeatingLocation {
  final bool hasIndoor;
  final bool hasOutdoor;
  final String? indoorNote;
  final String? outdoorNote;

  const SeatingLocation({
    required this.hasIndoor,
    required this.hasOutdoor,
    this.indoorNote,
    this.outdoorNote,
  });

  factory SeatingLocation.fromMap(Map<String, dynamic> map) {
    return SeatingLocation(
      hasIndoor: map['hasIndoor'] ?? false,
      hasOutdoor: map['hasOutdoor'] ?? false,
      indoorNote: map['indoorNote'],
      outdoorNote: map['outdoorNote'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'hasIndoor': hasIndoor,
      'hasOutdoor': hasOutdoor,
      'indoorNote': indoorNote,
      'outdoorNote': outdoorNote,
    };
  }
}

class Place {
  final String id;
  final String name;
  final String address;
  final PlaceType type;
  final double rating;
  final int durationRating;
  final bool isWorkingFriendly;
  final bool isReadingFriendly;
  final bool hasWifi;
  final String imageUrl;
  final String description;
  final bool isOpenNow;
  final SeatingCost seatingCost;
  final String? seatingNotes;
  final int priceLevel;
  final SeatingLocation seatingLocation;

  Place({
    required this.id,
    required this.name,
    required this.address,
    required this.type,
    required this.rating,
    required this.durationRating,
    required this.isWorkingFriendly,
    required this.isReadingFriendly,
    this.hasWifi = false,
    required this.imageUrl,
    required this.description,
    required this.isOpenNow,
    this.seatingCost = SeatingCost.purchaseRequired,
    this.seatingNotes,
    required this.priceLevel,
    required this.seatingLocation,
  }) : assert(priceLevel >= 1 && priceLevel <= 4, 'Price level must be between 1 and 4');

  String get seatingCostText {
    switch (seatingCost) {
      case SeatingCost.free:
        return 'Free Seating';
      case SeatingCost.purchaseRequired:
        return 'Purchase Required';
      case SeatingCost.paid:
        return 'Paid Seating';
    }
  }

  String get priceText {
    return '฿' * priceLevel;
  }

  String get seatingDescription {
    switch (type) {
      case PlaceType.cafe:
        return 'It\'s courteous to purchase at least a cup of coffee while using the space.';
      case PlaceType.restaurant:
        return 'It\'s expected to order food or drinks while using the space.';
      case PlaceType.coworkingSpace:
        return seatingCost == SeatingCost.free 
            ? 'Free coworking space available.'
            : 'Paid coworking space - see venue for rates.';
      case PlaceType.gym:
        return seatingCost == SeatingCost.free
            ? 'Free access to gym facilities.'
            : 'Membership or day pass required for using the facilities.';
      case PlaceType.publicSpace:
        return 'Public space with free access.';
    }
  }

  String get typeName {
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

  factory Place.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Place(
      id: doc.id,
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      type: PlaceType.values.firstWhere(
        (e) => e.toString() == 'PlaceType.${data['type']}',
        orElse: () => PlaceType.cafe,
      ),
      rating: (data['rating'] ?? 0.0).toDouble(),
      durationRating: data['durationRating'] ?? 60,
      isWorkingFriendly: data['isWorkingFriendly'] ?? false,
      isReadingFriendly: data['isReadingFriendly'] ?? false,
      hasWifi: data['hasWifi'] ?? false,
      imageUrl: data['imageUrl'] ?? '',
      description: data['description'] ?? '',
      isOpenNow: data['isOpenNow'] ?? false,
      seatingCost: SeatingCost.values.firstWhere(
        (e) => e.toString() == 'SeatingCost.${data['seatingCost']}',
        orElse: () => SeatingCost.purchaseRequired,
      ),
      seatingNotes: data['seatingNotes'],
      priceLevel: data['priceLevel'] ?? 1,
      seatingLocation: SeatingLocation.fromMap(
        (data['seatingLocation'] as Map<String, dynamic>?) ?? 
        {'hasIndoor': false, 'hasOutdoor': false}
      ),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'address': address,
      'type': type.toString().split('.').last,
      'rating': rating,
      'durationRating': durationRating,
      'isWorkingFriendly': isWorkingFriendly,
      'isReadingFriendly': isReadingFriendly,
      'hasWifi': hasWifi,
      'imageUrl': imageUrl,
      'description': description,
      'isOpenNow': isOpenNow,
      'seatingCost': seatingCost.toString().split('.').last,
      'seatingNotes': seatingNotes,
      'priceLevel': priceLevel,
      'seatingLocation': seatingLocation.toMap(),
    };
  }

  factory Place.fromMap(Map<String, dynamic> map) {
    print('Creating Place from map: $map'); // Debug log
    
    final id = map['id'] as String?;
    if (id == null || id.isEmpty) {
      print('Warning: Place created with empty ID. Map: $map');
    }
    
    return Place(
      id: id ?? '',
      name: map['name'] as String? ?? '',
      address: map['address'] as String? ?? '',
      description: map['description'] as String? ?? '',
      imageUrl: map['imageUrl'] as String? ?? '',
      type: PlaceType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
        orElse: () => PlaceType.cafe,
      ),
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      durationRating: map['durationRating'] as int? ?? 60,
      isWorkingFriendly: map['isWorkingFriendly'] as bool? ?? false,
      isReadingFriendly: map['isReadingFriendly'] as bool? ?? false,
      hasWifi: map['hasWifi'] as bool? ?? false,
      isOpenNow: map['isOpenNow'] as bool? ?? true,
      priceLevel: map['priceLevel'] as int? ?? 1,
      seatingNotes: map['seatingNotes'] as String?,
      seatingLocation: SeatingLocation.fromMap(map['seatingLocation'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'description': description,
      'imageUrl': imageUrl,
      'type': type.toString().split('.').last,
      'rating': rating,
      'durationRating': durationRating,
      'isWorkingFriendly': isWorkingFriendly,
      'isReadingFriendly': isReadingFriendly,
      'hasWifi': hasWifi,
      'isOpenNow': isOpenNow,
      'priceLevel': priceLevel,
      'seatingNotes': seatingNotes,
      'seatingLocation': seatingLocation.toMap(),
    };
  }
} 