import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
  final String area;
  final String city;
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
  final String? openingTime;
  final String? closingTime;
  final bool is24Hours;
  final bool isPetFriendly;
  final Map<String, String>? weekdayHours;
  final Map<String, String>? weekendHours;
  final List<int>? closingDays;

  const Place({
    required this.id,
    required this.name,
    required this.area,
    required this.city,
    required this.description,
    required this.imageUrl,
    required this.type,
    required this.rating,
    required this.durationRating,
    required this.isWorkingFriendly,
    required this.isReadingFriendly,
    required this.hasWifi,
    required this.isOpenNow,
    required this.priceLevel,
    required this.seatingLocation,
    required this.seatingCost,
    this.seatingNotes,
    this.openingTime,
    this.closingTime,
    this.is24Hours = false,
    this.isPetFriendly = false,
    this.weekdayHours,
    this.weekendHours,
    this.closingDays,
  }) : assert(priceLevel >= 1 && priceLevel <= 4, 'Price level must be between 1 and 4');

  String get seatingCostText {
    switch (seatingCost) {
      case SeatingCost.free:
        return 'Free';
      case SeatingCost.purchaseRequired:
        return 'Purchase Advised';
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
    final data = doc.data() as Map<String, dynamic>;
    return Place(
      id: doc.id,
      name: data['name'] as String? ?? '',
      area: data['area'] as String? ?? '',
      city: data['city'] as String? ?? '',
      description: data['description'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      type: PlaceType.values.firstWhere(
        (e) => e.toString().split('.').last == data['type'],
        orElse: () => PlaceType.cafe,
      ),
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      durationRating: data['durationRating'] as int? ?? 60,
      isWorkingFriendly: data['isWorkingFriendly'] as bool? ?? false,
      isReadingFriendly: data['isReadingFriendly'] as bool? ?? false,
      hasWifi: data['hasWifi'] as bool? ?? false,
      isOpenNow: data['isOpenNow'] as bool? ?? true,
      priceLevel: data['priceLevel'] as int? ?? 1,
      seatingNotes: data['seatingNotes'] as String?,
      seatingLocation: SeatingLocation.fromMap(data['seatingLocation'] as Map<String, dynamic>? ?? {}),
      seatingCost: SeatingCost.values.firstWhere(
        (e) => e.toString().split('.').last == data['seatingCost'],
        orElse: () => SeatingCost.purchaseRequired,
      ),
      openingTime: data['openingTime'] as String?,
      closingTime: data['closingTime'] as String?,
      is24Hours: data['is24Hours'] as bool? ?? false,
      isPetFriendly: data['isPetFriendly'] as bool? ?? false,
      weekdayHours: data['weekdayHours'] != null 
          ? Map<String, String>.from(data['weekdayHours'] as Map)
          : null,
      weekendHours: data['weekendHours'] != null 
          ? Map<String, String>.from(data['weekendHours'] as Map)
          : null,
      closingDays: data['closingDays'] != null
          ? (data['closingDays'] as List).map((e) => e as int).toList()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'area': area,
      'city': city,
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
      'openingTime': openingTime,
      'closingTime': closingTime,
      'is24Hours': is24Hours,
      'isPetFriendly': isPetFriendly,
      'weekdayHours': weekdayHours,
      'weekendHours': weekendHours,
      'closingDays': closingDays,
    };
  }

  factory Place.fromMap(Map<String, dynamic> map, {String? id}) {
    return Place(
      id: id ?? '',
      name: map['name'] as String? ?? '',
      area: map['area'] as String? ?? '',
      city: map['city'] as String? ?? '',
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
      seatingCost: SeatingCost.values.firstWhere(
        (e) => e.toString().split('.').last == map['seatingCost'],
        orElse: () => SeatingCost.purchaseRequired,
      ),
      openingTime: map['openingTime'] as String?,
      closingTime: map['closingTime'] as String?,
      is24Hours: map['is24Hours'] as bool? ?? false,
      isPetFriendly: map['isPetFriendly'] as bool? ?? false,
      weekdayHours: map['weekdayHours'] as Map<String, String>?,
      weekendHours: map['weekendHours'] as Map<String, String>?,
      closingDays: map['closingDays'] as List<int>?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'area': area,
      'city': city,
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
      'seatingCost': seatingCost.toString().split('.').last,
      'openingTime': openingTime,
      'closingTime': closingTime,
      'is24Hours': is24Hours,
      'isPetFriendly': isPetFriendly,
      'weekdayHours': weekdayHours,
      'weekendHours': weekendHours,
      'closingDays': closingDays,
    };
  }

  bool get isCurrentlyOpen {
    if (is24Hours) return true;
    
    final now = DateTime.now();
    final currentTime = TimeOfDay(hour: now.hour, minute: now.minute);
    final currentDay = now.weekday - 1; // 0 = Sunday, 6 = Saturday
    
    // Check if it's a closing day
    if (closingDays != null && closingDays!.contains(currentDay)) {
      return false;
    }
    
    // Check if it's weekend (Saturday or Sunday)
    final isWeekend = currentDay == 6 || currentDay == 0;
    final hours = isWeekend ? weekendHours : weekdayHours;
    
    if (hours == null) return false;
    
    final openingTime = _parseTimeOfDay(hours['opening']!);
    final closingTime = _parseTimeOfDay(hours['closing']!);
    
    if (openingTime == null || closingTime == null) return false;
    
    // Handle cases where closing time is the next day
    if (closingTime.hour < openingTime.hour) {
      return currentTime.hour >= openingTime.hour || currentTime.hour < closingTime.hour;
    }
    
    return currentTime.hour >= openingTime.hour && currentTime.hour < closingTime.hour;
  }
  
  TimeOfDay? _parseTimeOfDay(String timeStr) {
    try {
      final parts = timeStr.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (e) {
      return null;
    }
  }

  String get currentDayHours {
    if (is24Hours) return 'Open 24 Hours';
    
    final now = DateTime.now();
    final currentDay = now.weekday - 1; // 0 = Sunday, 6 = Saturday
    
    // Check if it's a closing day
    if (closingDays != null && closingDays!.contains(currentDay)) {
      return 'Closed Today';
    }
    
    // Check if it's weekend (Saturday or Sunday)
    final isWeekend = currentDay == 6 || currentDay == 0;
    final hours = isWeekend ? weekendHours : weekdayHours;
    
    if (hours == null) return 'No Hours Available';
    
    return '${hours['opening']} - ${hours['closing']}';
  }
} 