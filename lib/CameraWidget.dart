import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';


class CameraWidget extends StatefulWidget{
  @override 
  CameraState createState() => CameraState();

  final String imagePath;
  
  CameraWidget({
    Key key,
    @required this.imagePath,
  }) : super(key: key);
}
class CameraState extends State<CameraWidget>{

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: this.widget.imagePath==null?
          Center(child:Icon(Icons.camera_alt,color:Theme.of(context).primaryColor,size:30)):Image.file(io.File(this.widget.imagePath))
    );
  }
}