import 'package:flutter/material.dart';
import 'package:memorize/providers/notes_provider.dart';
import 'package:provider/provider.dart';
import 'package:memorize/providers/auth_provider.dart';
import 'package:memorize/screen/login_screen.dart';
import 'package:memorize/screen/home_screen.dart';
import 'package:memorize/screen/splash_screen.dart';
import 'package:memorize/providers/currency_provider.dart';
import 'package:memorize/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => NotesProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => CurrencyProvider(),
        ),
      ],
      child: const Memorize(),
    ),
  );
}

class Memorize extends StatelessWidget {
  const Memorize({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memorize',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: Consumer<AuthProvider>(
        builder: (ctx, auth, _) {
          // Jika "isAuth == true" (sudah login)
          if (auth.isAuth) { 
            return HomeScreen(); 
          } else {
            return AuthGate();
          }
        },
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<AuthProvider>(context, listen: false).tryAutoLogin(),
      builder: (ctx, authSnapshot) {
        
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return SplashScreen(); 
        } else {
          return LoginScreen();
        }
      },
    );
  }
}