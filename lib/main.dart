import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';
import 'package:workmanager/workmanager.dart';

/// Used for Background Updates using Workmanager Plugin
// Main function to run periodically
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) {
    return Future.wait<bool>([
      HomeWidget.saveWidgetData(
        'title',
        '“updated routine, Quote of the day”',
      ),
      HomeWidget.saveWidgetData(
        'message',
        'Updated routine, Author',
      ),
      HomeWidget.updateWidget(
        name: 'HomeWidgetExampleProvider',
        iOSName: 'HomeWidgetExample',
      ),
    ]).then((value) {
      return !value.contains(false);
    });
  });
}

/// Called when Doing Background Work initiated from Widget
void backgroundCallback(Uri data) async {
  print(data);

  if (data.host == 'titleclicked') {
    await HomeWidget.saveWidgetData<String>('title', 'Hello');
    await HomeWidget.updateWidget(
        name: 'HomeWidgetExampleProvider', iOSName: 'HomeWidgetExample');
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: kDebugMode,
  ); //* release mode

  runApp(
    MaterialApp(
      home: const MyApp(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Nunito'),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    HomeWidget.setAppGroupId('QUOTES_APP_ID');
    HomeWidget.registerBackgroundCallback(backgroundCallback);
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   _checkForWidgetLaunch();
  //   HomeWidget.widgetClicked.listen(_launchedFromWidget);
  // }

  Future<void> _sendData(String title, String message) async {
    try {
      return Future.wait([
        HomeWidget.saveWidgetData<String>(
          'title',
          '“$title”',
        ),
        HomeWidget.saveWidgetData<String>(
          'message',
          message,
        ),
      ]);
    } on PlatformException catch (exception) {
      debugPrint('Error Sending Data. $exception');
    }
  }

  Future<void> _updateWidget() async {
    try {
      return HomeWidget.updateWidget(
          name: 'HomeWidgetExampleProvider', iOSName: 'HomeWidgetExample');
    } on PlatformException catch (exception) {
      debugPrint('Error Updating Widget. $exception');
    }
  }

  // Future<void> _loadData() async {
  //   try {
  //     return Future.wait([
  //       HomeWidget.getWidgetData<String>('title', defaultValue: 'Default Title')
  //           .then((value) {
  //         print(value);
  //       }),
  //       HomeWidget.getWidgetData<String>('message',
  //               defaultValue: 'Default Message')
  //           .then((value) {
  //         print(value);
  //       }),
  //     ]);
  //   } on PlatformException catch (exception) {
  //     debugPrint('Error Getting Data. $exception');
  //   }
  // }

  Future<void> _sendAndUpdate(String title, String message) async {
    await _sendData(title, message);
    await _updateWidget();
  }

  // void _checkForWidgetLaunch() {
  //   HomeWidget.initiallyLaunchedFromHomeWidget().then(_launchedFromWidget);
  // }

  // void _launchedFromWidget(Uri uri) {
  //   if (uri != null) {
  //     showDialog(
  //       context: context,
  //       builder: (buildContext) => AlertDialog(
  //         title: const Text('App started from HomeScreenWidget'),
  //         content: Text('Here is the URI: $uri'),
  //       ),
  //     );
  //   }
  // }

  void _startBackgroundUpdate() {
    Workmanager().registerPeriodicTask(
        'motivational_quotes_app_1', 'BackgroundUpdate',
        frequency: const Duration(hours: 12),
        initialDelay: const Duration(seconds: 10));
  }

  void _stopBackgroundUpdate() {
    Workmanager().cancelByUniqueName('motivational_quotes_app_1');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HomeWidget Example'),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _sendAndUpdate(
                      "Don't be tempted to break momentum-work through it.",
                      "Lorii Myers",
                    );
                  },
                  child: Text('Send Data to Widget'),
                ),
                if (Platform.isAndroid)
                  ElevatedButton(
                    onPressed: _startBackgroundUpdate,
                    child: Text('Update in background'),
                  ),
                if (Platform.isAndroid)
                  ElevatedButton(
                    onPressed: _stopBackgroundUpdate,
                    child: Text('Stop updating in background'),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
