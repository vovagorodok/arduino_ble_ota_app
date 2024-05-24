import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:ble_ota_app/src/screens/scanner_screen.dart';

void main() async {
  await Settings.init();
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(
    EasyLocalization(
        supportedLocales: const [
          Locale('en', 'US'),
          Locale('pl', 'PL'),
          Locale('ru', 'RU'),
          Locale('uk', 'UA'),
        ],
        path: 'assets/translations',
        fallbackLocale: const Locale('en', 'US'),
        child: const BleOtaApp()),
  );
}

class BleOtaApp extends StatelessWidget {
  const BleOtaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ble Ota',
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      home: const ScannerScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
