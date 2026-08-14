import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'amplifyconfiguration.dart';
import 'layout/app_layout.dart';
import 'screens/login_screen.dart';
import 'screens/style_gallery.dart';
import 'core/theme/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _configureAmplify();
  runApp(const HydrotekApp());
}

Future<void> _configureAmplify() async {
  try {
    final auth = AmplifyAuthCognito();
    final storage = AmplifyStorageS3();
    await Amplify.addPlugins([auth, storage]);

    // call Amplify.configure to use the initialized categories in your app
    await Amplify.configure(amplifyconfig);
  } on Exception catch (e) {
    safePrint('An error occurred configuring Amplify: $e');
  }
}

class HydrotekApp extends StatelessWidget {
  const HydrotekApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hydrotek Farm',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: AppColors.lightColorScheme,
        scaffoldBackgroundColor: AppColors.surface,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.onSurface,
        ),
        // If 'Manrope' is added to pubspec.yaml, you can uncomment this
        // fontFamily: 'Manrope', 
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: AppColors.darkColorScheme,
        scaffoldBackgroundColor: AppColors.darkColorScheme.surface,
      ),
      themeMode: ThemeMode.system,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const AppLayout(initialIndex: 0),
        '/control': (context) => const AppLayout(initialIndex: 1),
        '/analytics': (context) => const AppLayout(initialIndex: 2),
        '/camera': (context) => const AppLayout(initialIndex: 3),
        '/style_gallery': (context) => const StyleGalleryScreen(),
      },
    );
  }
}
