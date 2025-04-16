import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/place.dart';

class FirebasePlaceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'places';
  final String _usersCollection = 'users';
  final String _savedPlacesSubcollection = 'saved_places';

  Future<List<Place>> getAllPlaces() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      return snapshot.docs.map((doc) => Place.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting places: $e');
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
              place.address.toLowerCase().contains(query.toLowerCase()) ||
              place.description.toLowerCase().contains(query.toLowerCase()))
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
      final snapshot = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection(_savedPlacesSubcollection)
          .get();

      print('Found ${snapshot.docs.length} saved places');
      
      if (snapshot.docs.isEmpty) return [];

      final placeIds = snapshot.docs.map((doc) => doc['placeId'] as String).toList();
      print('Place IDs: $placeIds');
      
      final placesSnapshot = await _firestore
          .collection(_collection)
          .where(FieldPath.documentId, whereIn: placeIds)
          .get();

      print('Retrieved ${placesSnapshot.docs.length} places from places collection');
      return placesSnapshot.docs.map((doc) => Place.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting saved places: $e');
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

      // Update individual rating
      await ratingRef.set({
        'rating': newRating,
        'userId': userId,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Calculate new average rating
      final newTotalRatings = totalRatings + 1;
      final newAverageRating = ((currentRating * totalRatings) + newRating) / newTotalRatings;

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
} 