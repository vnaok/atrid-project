import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/auth/presentation/AuthGate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://heyrfhfrkbahwhcimqqu.supabase.co',
    publishableKey: 'sb_publishable_laMgZaV4jEQSn5BhrWlvZw_SQgQwRb_',
  );

  runApp(const PruebaFlutterApp());
}

class PruebaFlutterApp extends StatelessWidget {
  const PruebaFlutterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Atrid App',
      debugShowCheckedModeBanner: false,
      home: const AuthGate(),
    );
  }
}