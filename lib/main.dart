import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'screens/login_screen.dart';
import 'screens/user_screen.dart';
import 'screens/register_screen.dart';
import 'screens/forgot_password_screen.dart';

void main() {
  runApp(const AppStateContainer(child: MyApp()));
}

class AppStateContainer extends StatefulWidget {
  final Widget child;
  const AppStateContainer({super.key, required this.child});

  static _AppStateContainerState? of(BuildContext context) {
    return context.findAncestorStateOfType<_AppStateContainerState>();
  }

  @override
  State<AppStateContainer> createState() => _AppStateContainerState();
}

class _AppStateContainerState extends State<AppStateContainer> {
  bool isDarkMode = false;

  void toggleTheme(bool isDark) {
    setState(() {
      isDarkMode = isDark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return InheritedThemeController(
      isDarkMode: isDarkMode,
      toggleTheme: toggleTheme,
      child: widget.child,
    );
  }
}

class InheritedThemeController extends InheritedWidget {
  final bool isDarkMode;
  final void Function(bool) toggleTheme;

  const InheritedThemeController({
    required this.isDarkMode,
    required this.toggleTheme,
    required super.child,
    super.key,
  });

  static InheritedThemeController? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<InheritedThemeController>();
  }

  @override
  bool updateShouldNotify(InheritedThemeController oldWidget) =>
      isDarkMode != oldWidget.isDarkMode;
}

// App chính
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = InheritedThemeController.of(context);
    final isDarkMode = themeController?.isDarkMode ?? false;

    return GetMaterialApp(
      title: 'Find Work For Everyone',
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF4F1FB),
        primarySwatch: Colors.deepPurple,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        primarySwatch: Colors.deepPurple,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      getPages: [
        GetPage(name: '/login', page: () => const LoginScreen()),
        GetPage(name: '/user', page: () => const UserScreen()),
        GetPage(name: '/register', page: () => const RegisterScreen()),
        GetPage(name: '/forgot-password', page: () => const ForgotPasswordScreen()),
      ],
    );
  }
}
