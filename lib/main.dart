// necessary imports for the project
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:sparkli/global_variables/dynamic_content/database.dart';
import 'package:sparkli/global_variables/dynamic_content/notification_service.dart';
import 'package:sparkli/global_variables/dynamic_content/stream_signal.dart';
import 'package:sparkli/startup/splash_page.dart';

// pages
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:sparkli/startup/upgrade_app.dart';
import 'global_variables/static_content/themes.dart';

/*
Main method
- Initializes connection with the database (supabase)
- Initializes local storage
- Initializes notification services
- Runs the app
* */

// initialize main stream signal
final StreamController<StreamSignal> mainStream =
    StreamController<StreamSignal>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // init connection to supabase
  await DataBase.tryInitialize();

  // set orientation
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // init local storage
  await initLocalStorage();

  // double check theme initialized
  Themes.checkTheme();
  
  await NotificationService.setup();

  // ensure theme stream has a listener
  if (!mainStream.hasListener) {
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  //Application root widget
  @override
  Widget build(BuildContext context) {
    //Streambuilder; refreshes on theme change
    return StreamBuilder(
        stream: mainStream.stream,
        initialData: StreamSignal(streamController: mainStream, newData: {
          'theme': DataBase.account['theme'] ?? 'Scarlet',
        }),
        builder: (context, snapshot) {
          //Primary application
          return MaterialApp(
            title: 'Sparkli',
            theme: Themes.themeData[snapshot.data?.data['theme']] ??
                Themes.themeData['Scarlet'],
            //Loading screen; processes auth
            home: const UpgradeApp(),
            debugShowCheckedModeBanner: false,
          );
        });
  }
}

//Globally attaches showSnackBar() to BuildContext variables
extension ContextExtension on BuildContext {
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message, overflow: TextOverflow.fade),
        backgroundColor: isError
            ? Theme.of(this).colorScheme.error
            : Theme.of(this).snackBarTheme.backgroundColor,
      ),
    );
  }
}
