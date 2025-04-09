import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/bloc/chat_bloc_bloc.dart';
import 'package:flutter_application/bloc/google_map_bloc.dart';
import 'package:flutter_application/components/bar.dart';
import 'package:flutter_application/repos/google_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application/components/bar.dart'; // Assuming this is your navigation bar
import 'package:flutter_application/utils/firebase_option.dart';
import 'package:flutter_application/pages/login_page.dart'; // Import LoginPage

Future<void> main() async {
  // Initialize Flutter bindings and Firebase
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Get data from the cache
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ChatBlocBloc()),
        BlocProvider(create: (context) => GoogleMapBloc(RestaurantRepo())),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Eat Meh',
        theme: ThemeData(
          fontFamily: "Poppins",
          scaffoldBackgroundColor: Colors.white,
        ),
        home: AuthWrapper(),
      ),
    );
  }
}

// AuthWrapper listens to authentication state changes
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // If the connection state is waiting, show a loading indicator
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If the user is signed in, show the authenticated page (NutritionScreen with Bar)
        if (snapshot.hasData) {
          return const Bar(); // Assuming Bar includes Navigation to NutritionScreen
        }

        // If the user is not signed in, show the LoginPage
        return const LoginPage(); // Show the login page
      },
    );
  }
}
