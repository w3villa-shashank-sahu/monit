import 'package:flutter/material.dart';
import 'package:monit/utils/routes.dart';
import 'package:provider/provider.dart';
import 'package:monit/models/user.dart';
import 'package:monit/utils/const.dart';
import 'package:monit/providers/product_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Add providers for state management
        ChangeNotifierProvider<ChildModel>(
          create: (_) => ChildModel(),
        ),
        ChangeNotifierProvider<SpendingLimitModel>(
          create: (_) => SpendingLimitModel(),
        ),
        ChangeNotifierProvider<ProductProvider>(
          create: (_) => ProductProvider(),
        ),
        ChangeNotifierProvider<ParentModel>(
          create: (_) => ParentModel(),
        ),
      ],
      child: MaterialApp.router(
        title: MyConst.appName,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Poppins',
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            primary: Colors.blue,
          ),
          useMaterial3: true,
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              minimumSize: const Size(120, 48),
            ),
          ),
        ),
        routerConfig: router,
      ),
    );
  }
}
