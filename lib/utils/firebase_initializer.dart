import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseInitializer {
  static Future<void> initializeData() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Leer el JSON (asumiendo que está en los assets)
    // final String jsonString = await rootBundle.loadString('assets/firestore_initial_data.json');
    // final Map<String, dynamic> data = json.decode(jsonString);

    // O usar directamente el mapa de datos
    final Map<String, dynamic> data = {
      // Aquí va todo el JSON anterior
    };

    // Subir datos por colección
    for (var collection in data.keys) {
      final collectionRef = firestore.collection(collection);

      final documents = data[collection] as Map<String, dynamic>;
      for (var docId in documents.keys) {
        await collectionRef.doc(docId).set(documents[docId]);
      }
    }
  }
}
