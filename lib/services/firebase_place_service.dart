import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/place.dart';

class FirebasePlaceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'places';
  final String _usersCollection = 'users';
  final String _savedPlacesSubcollection = 'saved_places';

  Future<List<Place>> getAllPlaces() async {
    try {
      print('Fetching all places from Firestore...');
      final snapshot = await _firestore.collection(_collection).get();
      print('Retrieved ${snapshot.docs.length} documents');
      
      final places = snapshot.docs.map((doc) {
        try {
          print('Processing document ${doc.id}');
          final place = Place.fromFirestore(doc);
          print('Successfully created place: ${place.name}');
          return place;
        } catch (e) {
          print('Error processing document ${doc.id}: $e');
          print('Document data: ${doc.data()}');
          rethrow;
        }
      }).toList();
      
      print('Successfully processed ${places.length} places');
      return places;
    } catch (e) {
      print('Error getting places: $e');
      print('Stack trace: ${StackTrace.current}');
      return [];
    }
  }

  Future<List<Place>> getPlacesByType(PlaceType type) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('type', isEqualTo: type.toString().split('.').last)
          .get();
      return snapshot.docs.map((doc) => Place.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting places by type: $e');
      return [];
    }
  }

  Future<List<Place>> searchPlaces(String query) async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      return snapshot.docs
          .map((doc) => Place.fromFirestore(doc))
          .where((place) =>
              place.name.toLowerCase().contains(query.toLowerCase()) ||
              place.area.toLowerCase().contains(query.toLowerCase()) ||
              place.city.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } catch (e) {
      print('Error searching places: $e');
      return [];
    }
  }

  Future<String> addPlace(Map<String, dynamic> placeData, String userId) async {
    try {
      final docRef = await _firestore.collection(_collection).add({
        ...placeData,
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      // Update the document with its own ID
      await docRef.update({
        'id': docRef.id,
      });
      
      return docRef.id;
    } catch (e) {
      print('Error adding place: $e');
      rethrow;
    }
  }

  Future<void> updatePlace(String id, Map<String, dynamic> placeData) async {
    try {
      await _firestore.collection(_collection).doc(id).update(placeData);
    } catch (e) {
      print('Error updating place: $e');
      rethrow;
    }
  }

  Future<void> deletePlace(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      print('Error deleting place: $e');
      rethrow;
    }
  }

  Future<void> savePlace(String placeId, String userId) async {
    try {
      print('Saving place: $placeId for user: $userId');
      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection(_savedPlacesSubcollection)
          .doc(placeId)
          .set({
        'placeId': placeId,
        'savedAt': FieldValue.serverTimestamp(),
      });
      print('Successfully saved place');
    } catch (e) {
      print('Error saving place: $e');
      rethrow;
    }
  }

  Future<void> unsavePlace(String placeId, String userId) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection(_savedPlacesSubcollection)
          .doc(placeId)
          .delete();
    } catch (e) {
      print('Error unsaving place: $e');
      rethrow;
    }
  }

  Future<bool> isPlaceSaved(String placeId, String userId) async {
    try {
      final doc = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection(_savedPlacesSubcollection)
          .doc(placeId)
          .get();
      return doc.exists;
    } catch (e) {
      print('Error checking if place is saved: $e');
      return false;
    }
  }

  Future<List<Place>> getSavedPlaces(String userId) async {
    try {
      print('Getting saved places for user: $userId');
      
      // First check if user document exists
      final userDoc = await _firestore.collection(_usersCollection).doc(userId).get();
      print('User document exists: ${userDoc.exists}');
      
      final snapshot = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection(_savedPlacesSubcollection)
          .get();

      print('Found ${snapshot.docs.length} saved places in user collection');
      print('Saved place documents: ${snapshot.docs.map((doc) => doc.data()).toList()}');
      
      if (snapshot.docs.isEmpty) {
        print('No saved places found for user');
        return [];
      }

      final placeIds = snapshot.docs.map((doc) => doc['placeId'] as String).toList();
      print('Place IDs to fetch: $placeIds');
      
      // Check if places exist in main collection
      for (final placeId in placeIds) {
        final placeDoc = await _firestore.collection(_collection).doc(placeId).get();
        print('Place $placeId exists in main collection: ${placeDoc.exists}');
      }
      
      final placesSnapshot = await _firestore
          .collection(_collection)
          .where(FieldPath.documentId, whereIn: placeIds)
          .get();

      print('Retrieved ${placesSnapshot.docs.length} places from places collection');
      print('Retrieved place IDs: ${placesSnapshot.docs.map((doc) => doc.id).toList()}');
      
      if (placesSnapshot.docs.isEmpty) {
        print('No places found in places collection for the saved place IDs');
        return [];
      }

      final places = placesSnapshot.docs.map((doc) {
        try {
          final place = Place.fromFirestore(doc);
          print('Successfully created place: ${place.name} (${place.id})');
          return place;
        } catch (e) {
          print('Error creating place from document ${doc.id}: $e');
          print('Document data: ${doc.data()}');
          rethrow;
        }
      }).toList();
      
      print('Successfully created ${places.length} Place objects');
      return places;
    } catch (e) {
      print('Error getting saved places: $e');
      print('Stack trace: ${StackTrace.current}');
      return [];
    }
  }

  Future<void> updatePlaceRating(String placeId, double newRating, String userId) async {
    try {
      final placeRef = _firestore.collection(_collection).doc(placeId);
      final ratingRef = placeRef.collection('ratings').doc(userId);

      // Get current place data
      final placeDoc = await placeRef.get();
      final currentData = placeDoc.data() as Map<String, dynamic>;
      final currentRating = currentData['rating'] as double? ?? 0.0;
      final totalRatings = currentData['totalRatings'] as int? ?? 0;

      // Check if user has already rated
      final existingRatingDoc = await ratingRef.get();
      final bool isNewRating = !existingRatingDoc.exists;
      final double? oldUserRating = existingRatingDoc.exists 
          ? (existingRatingDoc.data() as Map<String, dynamic>)['rating'] as double 
          : null;

      // Update individual rating
      await ratingRef.set({
        'rating': newRating,
        'userId': userId,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Calculate new average rating
      double newAverageRating;
      int newTotalRatings;

      if (isNewRating) {
        // For new ratings, add to the total
        newTotalRatings = totalRatings + 1;
        newAverageRating = ((currentRating * totalRatings) + newRating) / newTotalRatings;
      } else {
        // For rating updates, adjust the average without changing total count
        newTotalRatings = totalRatings;
        newAverageRating = currentRating + ((newRating - oldUserRating!) / totalRatings);
      }

      // Update place document with new average rating
      await placeRef.update({
        'rating': newAverageRating,
        'totalRatings': newTotalRatings,
      });
    } catch (e) {
      print('Error updating rating: $e');
      rethrow;
    }
  }

  Future<double?> getUserRating(String placeId, String userId) async {
    try {
      final ratingDoc = await _firestore
          .collection(_collection)
          .doc(placeId)
          .collection('ratings')
          .doc(userId)
          .get();
      
      if (ratingDoc.exists) {
        return (ratingDoc.data() as Map<String, dynamic>)['rating'] as double;
      }
      return null;
    } catch (e) {
      print('Error getting user rating: $e');
      return null;
    }
  }

  Future<List<Place>> getPlacesByIds(List<String> placeIds) async {
    if (placeIds.isEmpty) return [];

    try {
      final snapshot = await _firestore
          .collection('places')
          .where(FieldPath.documentId, whereIn: placeIds)
          .get();

      return snapshot.docs.map((doc) => Place.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting places by IDs: $e');
      return [];
    }
  }

  Future<List<Place>> getFilteredPlaces(Map<String, dynamic> filters) async {
    try {
      Query query = _firestore.collection(_collection);
      
      // Apply type filter
      if (filters['types'] != null && (filters['types'] as List).isNotEmpty) {
        final typeStrings = (filters['types'] as List<PlaceType>)
            .map((type) => type.toString().split('.').last)
            .toList();
        query = query.where('type', whereIn: typeStrings);
      }
      
      // Apply working friendly filter
      if (filters['isWorkingFriendly'] != null) {
        query = query.where('isWorkingFriendly', isEqualTo: filters['isWorkingFriendly']);
      }
      
      // Apply reading friendly filter
      if (filters['isReadingFriendly'] != null) {
        query = query.where('isReadingFriendly', isEqualTo: filters['isReadingFriendly']);
      }
      
      // Apply seating cost filter
      if (filters['seatingCosts'] != null && (filters['seatingCosts'] as List).isNotEmpty) {
        final costStrings = (filters['seatingCosts'] as List<SeatingCost>)
            .map((cost) => cost.toString().split('.').last)
            .toList();
        query = query.where('seatingCost', whereIn: costStrings);
      }
      
      // Apply indoor/outdoor filter
      if (filters['hasIndoor'] != null) {
        query = query.where('seatingLocation.hasIndoor', isEqualTo: filters['hasIndoor']);
      }
      
      if (filters['hasOutdoor'] != null) {
        query = query.where('seatingLocation.hasOutdoor', isEqualTo: filters['hasOutdoor']);
      }
      
      // Get all places that match the filters
      final snapshot = await query.get();
      List<Place> places = snapshot.docs.map((doc) => Place.fromFirestore(doc)).toList();
      
      // Apply price range filter in memory
      if (filters['minPrice'] != null && filters['maxPrice'] != null) {
        places = places.where((place) => 
          place.priceLevel >= filters['minPrice'] && 
          place.priceLevel <= filters['maxPrice']
        ).toList();
      }
      
      // Apply duration range filter in memory
      if (filters['minDuration'] != null && filters['maxDuration'] != null) {
        places = places.where((place) => 
          place.durationRating >= filters['minDuration'] && 
          place.durationRating <= filters['maxDuration']
        ).toList();
      }
      
      // Apply current time filter
      if (filters['isCurrentlyOpen'] == true) {
        places = places.where((place) => place.isCurrentlyOpen).toList();
      }
      
      print('Filtered places count: ${places.length}');
      print('Applied filters: $filters');
      
      return places;
    } catch (e) {
      print('Error getting filtered places: $e');
      return [];
    }
  }
} 