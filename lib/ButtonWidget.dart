import 'dart:async';
import 'dart:io' as io;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:path_provider/path_provider.dart';
import 'package:camera/camera.dart';

import 'package:path/path.dart' show join;

import 'FunctionHandler.dart';
import 'CameraWidget.dart';
import 'MessageWidget.dart';


class QASectionWidget extends StatefulWidget{
  @override
  QASectionState createState() => QASectionState();
}
class QASectionState extends State<QASectionWidget>{
  @override
  Widget build(BuildContext context) {
    
    return GestureDetector(
      child:Center(
        child:Text('Your Questions:')
      )
    );
  }
}

class ButtonWidget extends StatefulWidget{
  @override
  ButtonState createState() => ButtonState();

  final CameraDescription camera;
  
  ButtonWidget({
    Key key,
    @required this.camera,
  }) : super(key: key);
}
enum recording_status  {
    Initialized,
    Recording
}
enum recording_type {
    Question,
    Confirmation
}

class ButtonState extends State<ButtonWidget> {

  String imagePath;
  var recorder_status;
  // CameraWidget camState = CameraWi/dget();
    
  Helper helper = Helper();

  String mode = "photo";

  FlutterAudioRecorder recorder;

  Recording recording;
  String _alert = "";
  String text = "not recording";
  CameraController _controller;
  Future<void> _initializeControllerFuture;
  String question = "Your question";
  String answer = "Answer";
  // String imagePath;
  String audioPath;
  var current_type;
  Widget imageDisplay;
  
  @override
  Widget build(BuildContext context) {

    if(mode=="audio"){
  
      return GestureDetector(
        child:Flex(direction: Axis.vertical, children:<Widget>[
          Expanded(flex:1, child: Flex(direction: Axis.horizontal, children: <Widget>[
            Expanded(flex: 1, child: Container(child: CameraWidget(imagePath: imagePath), decoration: BoxDecoration(
              border:Border(right:BorderSide(color:Colors.lightBlue,width:3.0),
                            bottom: BorderSide( color:Colors.lightBlue,width:3.0)))),
            ),
            Expanded(flex:1, child: Container(child:MessageWidget(question: question, answer: answer), decoration:BoxDecoration(
              border: Border(left:BorderSide(color:Colors.lightBlue, width:3.0),
                            bottom: BorderSide(color:Colors.lightBlue,width:3.0))))
            )
          ],)),
          Expanded(flex:3,
            child: GestureDetector(onTap: _opt,
              child: ConstrainedBox(constraints: BoxConstraints(minWidth: double.infinity),
                child: Container(decoration: BoxDecoration(border: Border.all(color: Colors.transparent)),
                  child: Column(mainAxisSize: MainAxisSize.max,mainAxisAlignment: MainAxisAlignment.center,
                    children:[ Icon(Icons.keyboard_voice, color:Theme.of(context).primaryColor, size:60),
                    Text("$text")
                    ],
                  ) 
                )
              )
            )
          )]
        )
      );
    }else{
      return GestureDetector(
        child:Flex(direction: Axis.vertical, children:<Widget>[
          Expanded(flex:1, child: Flex(direction: Axis.horizontal, children: <Widget>[
            Expanded(flex: 1, child: Container(child: CameraWidget(imagePath: imagePath), decoration: BoxDecoration(
              border:Border(right:BorderSide(color:Colors.lightBlue,width:3.0),
                            bottom: BorderSide( color:Colors.lightBlue,width:3.0)))),
            ),
            Expanded(flex:1, child: Container(child:MessageWidget(question: question, answer: answer), decoration:BoxDecoration(
              border: Border(left:BorderSide(color:Colors.lightBlue, width:3.0),
                            bottom: BorderSide(color:Colors.lightBlue,width:3.0))))
            )
          ],)),
          Expanded(flex:3,
            child:GestureDetector(
              onTap: takePicture,
              child: CameraPreview(_controller)
            )
          )]
        )
      );
    }
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  takePicture() async {
    
    await _initializeControllerFuture;
    final path = join((await getTemporaryDirectory()).path,'${DateTime.now()}.png',);
    await _controller.takePicture(path).then((_)=> imagePath = path);//.then((_)=> switchToImageDisplay(imagePath));
    
    // await _startRecording();
    // await _stopRecording();
    // print("1111111:   "+recording.path);
    // await _prepare();
    // await _startRecording();
    // await _stopRecording();
    // print("2222222:   "+recording.path);
    await helper.playPhotoConfirmationAudio();
    
    io.sleep(Duration(seconds: 3));
    await _startRecording(true);
    await _stopRecording();
    // await _play();
    
    String response_text = await helper.audio2text(recording.path);
    String reponse_result = await helper.retakeOrNot(response_text);
    await _prepare();
    if(reponse_result == "yes"){
      
      setState((){
        mode = "photo";
        helper.playPhotoPrompt();
      });
    }else{
      setState((){
        mode = "audio";
        helper.playAudioPrompt();
      });
    }
  }
    
  // switchToImageDisplay(String p) async{
  //   setState(() {q
  //     camState.imagePath = imagePath;
  //   });
  //   // setState((){
  //   //   camWidget. = GestureDetector(
  //   //     child: imagePath==null?Center(
  //   //       child:Icon(Icons.camera_alt,color:Theme.of(context).primaryColor,size:30)
  //   //     ):Image.file(io.File(imagePath))
  //   //   );
  //   // });
  // }

  // Future _prepare_q() async{
  //   // helper.playAudioPrompt();

  //   var hasPermission = await FlutterAudioRecorder.hasPermissions;
  //   if (hasPermission) {
  //     String customPath = "/flutter_audio_recorderq_";
  //     io.Directory appDocDirectory;
  //     if (io.Platform.isIOS) {
  //       appDocDirectory = await getApplicationDocumentsDirectory();
  //     } else {
  //       appDocDirectory = await getExternalStorageDirectory();
  //     }
  //     customPath = appDocDirectory.path +
  //         customPath +
  //         DateTime.now().millisecondsSinceEpoch.toString();

  //     recorder_q = FlutterAudioRecorder(customPath, audioFormat: AudioFormat.WAV, sampleRate: 22050);      
  //     await recorder_q.initialized;

  //     var result = await recorder_q.current();
  //     setState(() {
  //       recording_q = result;
  //     });
  //   }
  // }

  Future _prepare() async{
    var hasPermission = await FlutterAudioRecorder.hasPermissions;
    if (hasPermission) {
      String customPath = '/flutter_audio_recorder_';
      io.Directory appDocDirectory;
      if (io.Platform.isIOS) {
        appDocDirectory = await getApplicationDocumentsDirectory();
      } else {
        appDocDirectory = await getExternalStorageDirectory();
      }
      customPath = appDocDirectory.path +
          customPath +
          DateTime.now().millisecondsSinceEpoch.toString();
      recorder = FlutterAudioRecorder(customPath, audioFormat: AudioFormat.WAV, sampleRate: 22050);
      await recorder.initialized;
      var result = await recorder.current();
      setState(() {
        recording = result;
  
      });
    }
  }
  
  @override
  void initState() {
    recorder_status = recording_status.Initialized;
    current_type = recording_type.Confirmation;
    helper.playPhotoPrompt();

    super.initState();
    _prepare();
    
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture =  _controller.initialize();
  
  }
  
  
  void _opt() async {
    switch (recorder_status) {
      case recording_status.Initialized:
        {
          await _startRecording(false);
          recorder_status = recording_status.Recording;
          
          break;
        }
      case recording_status.Recording:
        {
          await _stopRecording();
          recorder_status = recording_status.Initialized;
          audioPath = recording.path;
          await _prepare();
          await helper.playAudioConfirmationAudio();
          io.sleep(Duration(seconds: 3));
          await _startRecording(true);
          await _stopRecording();
          await _prepare();
          String response_text = await helper.audio2text(recording.path);
          
          String reponse_result = await helper.retakeOrNot(response_text);
          print(reponse_result);
            if(reponse_result == "yes"){
              setState(() {
                mode = "audio";
              });
            }else{
              await helper.playSendConfirmationAudio();
              io.sleep(Duration(seconds: 2));
              await _startRecording(true);
              await _stopRecording();
              // await _play();

              String response_text = await helper.audio2text(recording.path);
              print("Ready to Send: "+response_text);
              String reponse_result = await helper.retakeOrNot(response_text);
              String tmp_q = "Your question";
              String tmp_a = "Answer";
              if(reponse_result == 'yes'){
                tmp_a = await helper.get_answer(audioPath, imagePath);
                tmp_q = await helper.audio2text(audioPath);
              }
              await _prepare();

              await helper.playAskAgainConfirmationAudio();
              io.sleep(Duration(seconds: 2));
              await _startRecording(true);
              await _stopRecording();
              String confirmation_text = await helper.audio2text(recording.path);
              String confirmation_res = await helper.retakeOrNot(confirmation_text);
              print("Bool:     ");
              print(confirmation_res == "yes");
              print(confirmation_res == 'yes');
              await _prepare();
              if(confirmation_res == "yes"){
                print("Helloooooooo");
                  setState((){
                    question = tmp_q;
                    answer = tmp_a;
                    mode = 'audio';
                });
              }else{
                setState((){
                  question = tmp_q;
                  answer = tmp_a;
                  mode = 'photo';
                  helper.playPhotoPrompt();
                });
              }
            }
           
          break;
        }
      default:
        break;
    }
  }
  
  Future _startRecording(bool needIdle) async {
    //print(m=="question");
      await recorder.start();
      var current = await recorder.current();
      setState(() {
        recording = current;
        text = "recording";
      });
      if(needIdle) io.sleep(Duration(seconds: 3));
  }

  Future _stopRecording() async {
      var result = await recorder.stop();
      setState(() {
        recording = result;
        text = "not recording";
      });
  }

  Future<void> _play() async {
      AudioPlayer player = AudioPlayer();
      player.play(recording.path, isLocal: true);
  }
}
