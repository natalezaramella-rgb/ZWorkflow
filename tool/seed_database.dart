import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:z_workflow/core/services/database_seeder.dart';
import 'package:z_workflow/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // ignore: avoid_print
  print('Inizializzazione Firebase per il database seeder...');

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // ignore: avoid_print
    print('Avvio seeding del tenant: ${DatabaseSeeder.defaultTenantId}...');
    final seeder = DatabaseSeeder();
    await seeder.seedTenant();
    // ignore: avoid_print
    print('Seeding completato con successo nel database Firestore!');
  } catch (e) {
    // ignore: avoid_print
    print('Errore durante il seeding: $e');
  }
}
