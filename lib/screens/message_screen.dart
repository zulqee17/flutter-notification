import 'package:flutter/material.dart';

class MessageScreen extends StatefulWidget {
  final String id;
   const MessageScreen({super.key,required this.id});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title:  Text('Message Screen ${widget.id}'),
        centerTitle: true,
      ),
      body: const Column(
        children: [

        ],
      ),
    );
  }
}
