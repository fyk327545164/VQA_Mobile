import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

import 'ButtonWidget.dart';

Future<void> main () async {
  WidgetsFlutterBinding.ensureInitialized();

  // Obtain a list of the available cameras on the device.
  final  cameras = await availableCameras();
  // Get a specific camera from the list of available cameras.
  final firstCamera = cameras.first;
  runApp(
    MaterialApp(
      home: Scaffold(
        appBar:AppBar(
          title:Text('Aoligei')
        ),
        body:  ButtonWidget(camera: firstCamera)
      ),
    ),
  );
}