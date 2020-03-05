import 'dart:convert';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:flutter_tts/flutter_tts.dart';

class Helper{

  AudioPlayer player = AudioPlayer();
  FlutterTts flutterTts = FlutterTts();

  String basicAuthorizationHeader(String apikey) {
    return 'Basic ' + base64Encode(utf8.encode('apikey:$apikey'));
  }

  String backend_url = "http://c092aec0.ngrok.io";


  String assistant_url = "https://api.us-south.assistant.watson.cloud.ibm.com/instances/40d4daac-3ebb-4208-92bc-d35fd7d9766b/v1/workspaces/0eb6a96f-9a22-4fe6-8ccd-4954b73cced6/message?version=2020-02-05";
  String assistant_key = "6lMZ90JznaEro75XVOYlZeTBW_1hxQX8c7p3FPDpnnKC";

  Future<String> retakeOrNot(String text) async{
    Response response = await Dio().post(
      assistant_url,
      data: {'input': {'text':text}},
      options: Options( responseType: ResponseType.json, headers: {'authorization': 'Basic YXBpa2V5OjZsTVo5MEp6bmFFcm83NVhWT1lsWmVUQldfMWh4UVg4YzdwM0ZQRHBubktD',
      'Content-Type':"application/json"})
    );

    String result = "no";
    if(response.data['entities'].length>0){
      result = response.data['entities'][0]['entity'];
    }
    print(result);
    return result;
  }

  playUnclearAudio() {
    text2audio("Does not hear what you said");
  }
  
  playPhotoConfirmationAudio() {
    text2audio("Photo has been taken. Retake or not?");
  }

  playAudioConfirmationAudio() {
    text2audio("Audio has been recorded. Retake or not?");
  }

  playSendConfirmationAudio() {
    text2audio("Ready to send ?");
  }

  playAudioPrompt(){
    text2audio("Please record a voice");
  }

  playPhotoPrompt(){
    text2audio("Please take a photo");
  }

  text2audio(String text) {
    flutterTts.speak(text);
  }

  Future<String> audio2text(audio_path) async {
  
    var audio_file = MultipartFile.fromFileSync(audio_path);
    FormData formData = FormData.fromMap({
      "audio_file" : audio_file
    });

    Response re;
    String audio_text;
    try{
      re = await Dio().post(
        backend_url+"/speech2text",
        data:formData,
        options: Options(responseType: ResponseType.plain)
      );
    }catch(e){
      audio_text = "not clear";
      return audio_text;
    }
    audio_text = re.data;
    return audio_text;
  }

  Future<String> get_answer(audio_path, image_path) async{
    
    var audio_file = MultipartFile.fromFileSync(audio_path);
    var image_file = MultipartFile.fromFileSync(image_path);

    FormData formData = FormData.fromMap({
      "audio_file" : audio_file,
      "image_file" : image_file
    });

    Response re = await Dio().post(
      backend_url+"/getanswer",
      data:formData,
      options: Options(responseType: ResponseType.plain)
    );
    
    String answer_text = re.data;

    text2audio(answer_text);

    return answer_text;
  
  }
}