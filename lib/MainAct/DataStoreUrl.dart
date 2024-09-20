import 'package:cloud_firestore/cloud_firestore.dart';

class DataStoreUrl {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<String> getStoreUrl(String storeName) async {
    try {
      DocumentSnapshot doc = await firestore.collection('ministore').doc(storeName).get();
      if (doc.exists) {
        return doc['url'] ?? '';
        // Get the URL field from Firestore

      } else {
        throw Exception('No document found for $storeName');
      }
    } catch (e) {
      throw Exception('Error fetching URL: $e');
    }
  }
}