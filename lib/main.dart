import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:memorize/models/user.dart';
import 'package:memorize/models/note.dart';
import 'package:provider/provider.dart';
import 'package:memorize/navigation.dart';
import 'package:memorize/providers/auth_provider.dart';
import 'package:memorize/providers/notes_provider.dart';
import 'package:memorize/providers/currency_provider.dart';
import 'package:memorize/providers/location_provider.dart';
import 'package:memorize/pages/auth/login_screen.dart';
import 'package:memorize/pages/auth/splash_screen.dart';
import 'package:memorize/services/notification_service.dart';
import 'package:memorize/services/crypto_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  await Hive.initFlutter();
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(NoteAdapter());
  
  await Hive.openBox<User>('users');
  await Hive.openBox<Note>('notes');

  final usersBox = Hive.box<User>('users');
  for (var i = 0; i < usersBox.length; i++) {
    final user = usersBox.getAt(i);
    if (user != null && user.password.length != 64) {
      final hashedPassword = CryptoService.hashPassword(user.password);
      final updatedUser = User(
        username: user.username,
        email: user.email,
        password: hashedPassword,
        saranKesan: user.saranKesan,
        profileImagePath: user.profileImagePath,
      );
      await usersBox.putAt(i, updatedUser);
    }
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => LocationProvider(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, NotesProvider>(
          create: (ctx) => NotesProvider(Provider.of<AuthProvider>(ctx, listen: false)),
          update: (ctx, auth, previousNotes) => previousNotes!..updateAuth(auth),
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
          if (auth.isAuth) { 
            return const HomeScreen(); 
          } else {
            return const AuthGate();
          }
        },
      ),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late Future<void> _autoLoginFuture;

  @override
  void initState() {
    super.initState();
    _autoLoginFuture = Provider.of<AuthProvider>(context, listen: false).tryAutoLogin();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _autoLoginFuture,
      builder: (ctx, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen(); 
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}