import 'package:api100ms_test/main_model.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final log = Logger(printer: PrettyPrinter());

  final providers = [
    Provider<Logger>.value(value: log),
    ChangeNotifierProvider(create: (_) => MainModel(log))
  ];

  runApp(
    App(
      providers: providers,
    ),
  );
}

class App extends StatelessWidget {
  // ***************************** INJECTED VARS *************************** //

  final List<SingleChildWidget> providers;

  // ***************************** CONSTRUCTORS **************************** //

  const App({required this.providers});

  // ****************************** LIFECYCLE ****************************** //

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: providers,
      child: MaterialApp(
        title: '100ms API Test',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MainScreen(),
      ),
    );
  }
}

class MainScreen extends StatelessWidget {
  // ********************************* VARS ******************************** //

  static const _padding = EdgeInsets.only(left: 16.0, top: 24.0, right: 16.0);

  // ***************************** CONSTRUCTORS **************************** //

  const MainScreen();

  // ****************************** LIFECYCLE ****************************** //

  @override
  Widget build(BuildContext context) {
    return Consumer<MainModel>(
      builder: (context, model, child) => Scaffold(
        appBar: AppBar(
          title: const Text('100ms API Test'),
        ),
        body: ListView(
          children: [
            // Permissions
            Container(
              padding: _padding,
              child: Center(
                child: ElevatedButton(
                  child: const Text('Grant permissions'),
                  onPressed: () async {
                    await Permission.camera.request();
                    await Permission.microphone.request();
                  },
                ),
              ),
            ),
            // Join / leave room
            Container(
              padding: _padding,
              child: Center(
                child: ElevatedButton(
                  onPressed:
                      model.hmsSdk != null ? model.leaveRoom : model.joinRoom,
                  child:
                      Text(model.hmsSdk != null ? 'Leave room' : 'Join room'),
                ),
              ),
            ),
            // Screen Share
            if (model.hmsSdk != null)
              Container(
                padding: _padding,
                child: Center(
                  child: ElevatedButton(
                    onPressed: model.isScreenShareActive
                        ? model.stopScreenShare
                        : model.startScreenShare,
                    child: Text(
                      model.isScreenShareActive
                          ? 'Stop screen share'
                          : 'Start screen share',
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
