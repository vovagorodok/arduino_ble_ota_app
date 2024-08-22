import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:ble_device_provider/scanner_screen.dart';
import 'package:ble_ota_app/src/ble/ble.dart';
import 'package:ble_ota_app/src/ble/ble_uuids.dart';
import 'package:ble_ota_app/src/screens/settings_screen.dart' as app_screan_settings;
import 'package:ble_ota_app/src/screens/upload_screen.dart';


void main() async {
  await Settings.init();
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
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
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
      ),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      home: ScannerScreen(ble, 
                          serviceUuid,  
                          (device, context) async => await Navigator.push(
                            context, 
                            MaterialPageRoute(
                              builder: (context) => UploadScreen(deviceId: device.id, deviceName: device.name)
                              ),
                            ), 
                            const app_screan_settings.SettingsScreen()
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
