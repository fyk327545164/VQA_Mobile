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


class ButtonWidget extends StatefulWidget{
  @override
  ButtonState createState() => ButtonState();

  final CameraDescription camera;
  
  ButtonWidget({
    Key key,
    @required this.camera,
  }) : super(key: key);
}

class ButtonState extends State<ButtonWidget> {
    
  Helper helper = Helper();

  String mode = "audio";

  FlutterAudioRecorder recorder;
  FlutterAudioRecorder recorder_q;

  Recording recording;
  Recording recording_q;

  String _alert = "";
  CameraController _controller;
  Future<void> _initializeControllerFuture;

  String imagePath;
  String audioPath;

  String question = "Question";
  String answer = "Answer";

  Widget imageDisplay;

  @override
  Widget build(BuildContext context) {

    if(mode=='audio'){
  
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
                    children:[ Icon(Icons.keyboard_voice, color:Theme.of(context).primaryColor, size:60)
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
    await _controller.takePicture(path).then((_){
        setState((){
          imagePath = path;
          question = "Question";
          answer = "Answer";
        });
      }
    );

    await helper.playPhotoConfirmationAudio();
    
    io.sleep(Duration(seconds: 3));
    await _startRecording('null');
    await _stopRecording('null');
    
    String response_text = await helper.audio2text(recording.path);
    String reponse_result = await helper.retakeOrNot(response_text);
    
    if(reponse_result == 'yes'){
      setState((){
        mode = 'photo';
        helper.playPhotoPrompt();
      });
    }else{
      setState((){
        mode = 'audio';
        helper.playAudioPrompt();
      });
    }
  }

  Future _prepare_q() async{

    var hasPermission = await FlutterAudioRecorder.hasPermissions;
    if (hasPermission) {
      String customPath = '/flutter_audio_recorderq_';
      io.Directory appDocDirectory;
      if (io.Platform.isIOS) {
        appDocDirectory = await getApplicationDocumentsDirectory();
      } else {
        appDocDirectory = await getExternalStorageDirectory();
      }
      customPath = appDocDirectory.path +
          customPath +
          DateTime.now().millisecondsSinceEpoch.toString();

      recorder_q = FlutterAudioRecorder(customPath, audioFormat: AudioFormat.WAV, sampleRate: 22050);
      await recorder_q.initialized;

      var result = await recorder_q.current();
      setState(() {
        recording_q = result;
      });
    }
  }

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

    helper.playPhotoPrompt();

    super.initState();

    _prepare_q();
    _prepare();

    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture =  _controller.initialize();
  
  }
  
  
  void _opt() async {


    switch (recording_q.status) {
      case RecordingStatus.Initialized:
        {
          await _startRecording('question');
          break;
        }
      case RecordingStatus.Recording:
        {
          await _stopRecording("question");

          audioPath = recording_q.path;

          setState(() {
            question = helper.audio2text(audioPath) as String;
          });

          await helper.playAudioConfirmationAudio();
          io.sleep(Duration(seconds: 3));
          await _startRecording('null');
          await _stopRecording('null');

          String response_text = await helper.audio2text(recording.path);
          
          String reponse_result = await helper.retakeOrNot(response_text);

            if(reponse_result == 'yes'){
              setState(() {
                mode = 'audio';
              });

            }else{
              await helper.playSendConfirmationAudio();
              io.sleep(Duration(seconds: 2));
              await _startRecording('null');
              await _stopRecording('null');

              String response_text = await helper.audio2text(recording.path);
          
              String reponse_result = await helper.retakeOrNot(response_text);

              if(reponse_result == 'yes'){
                String a = await helper.get_answer(audioPath, imagePath);
                setState(() {
                  answer = a;
                });
                
                io.sleep(Duration(seconds: 3));
              }
              setState((){
                mode = 'photo';
                helper.playPhotoPrompt();
              });
            }  
          break;
        }
      default:
        break;
    }
  }
  
  Future _startRecording(String m) async {
    if(m=='question'){
      await recorder_q.start();
      var current = await recorder_q.current();
      setState(() {
        recording_q = current;
      });
    }else{
      await recorder.start();
      var current = await recorder.current();
      setState(() {
        recording = current;
      });
      io.sleep(Duration(seconds: 3));
    }
  }

  Future _stopRecording(String m) async {
    if(m=='question'){
      var result = await recorder_q.stop();
      // await _play();
      setState(() {
        recording_q = result;
      });
    }else{
      var result = await recorder.stop();
      setState(() {
        recording = result;
      });
    }
  }

  Future<void> _play() async {
      AudioPlayer player = AudioPlayer();
      player.play(recording.path, isLocal: true);
  }
}
