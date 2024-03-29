import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rent_bik/screens/auth/auth.dart';
import 'package:rent_bik/utils/db_process.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

DbProcess dbProcess = DbProcess();

void main() async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  await dbProcess.connect();
  runApp(
    const MyApp(),
  );

  doWhenWindowReady(() {
    const initialSize = Size(1280, 900);
    appWindow.minSize = initialSize;
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.title = "Quản lý thư viện";
    appWindow.show();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
         colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 53, 63, 103),
         primary: const Color.fromARGB(255, 53, 63, 103),
         secondary: const Color.fromARGB(255, 74, 53, 103),
         tertiary: const Color.fromARGB(255, 244, 235, 217)
         ),
        useMaterial3: true,
        textTheme: GoogleFonts.nunitoTextTheme(),
      ),
      home: const LoginLayout(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('vi'),
      ],
      locale: const Locale('vi'),
      debugShowCheckedModeBanner: false,
    );
  }
}
