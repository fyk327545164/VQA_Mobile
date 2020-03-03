import 'package:flutter/material.dart';

class MessageWidget extends StatefulWidget{
  @override
  MessageState createState() => MessageState();

  final String question;
  final String answer;
  
  MessageWidget({
    Key key,
    @required this.question,
    @required this.answer,

  }) : super(key: key);
}
class MessageState extends State<MessageWidget>{
  @override
  Widget build(BuildContext context) {
    
    return GestureDetector(
      child:Center(
        child:Text(this.widget.question + ' : ' + this.widget.answer),
      ),
    );
  }
}