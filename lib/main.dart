import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  State createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  TextEditingController messageController = TextEditingController();
  List<Map<String, String>> messages = [];

  @override
  void initState() {
    fetchMessages();
    super.initState();
  }

  void fetchMessages() async {
    final response = await http.get(
      Uri.parse('http://localhost:8001/messagesget'),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        messages = List<Map<String, String>>.from(data);
      });
    } else {
      throw Exception('Failed to load messages');
    }
  }

  void sendMessage() async {
    final user = "User"; // Replace with user authentication logic
    final text = messageController.text;

    final response = await http.post(
      Uri.parse('http://localhost:8001/messages'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user': user, 'text': text}),
    );

    if (response.statusCode == 200) {
      fetchMessages(); // Update the message list after sending a new message
      messageController.clear();
    } else {
      throw Exception('Failed to send message');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat App'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return ListTile(
                  title: Text('${message['user']}: ${message['text']}'),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration:
                        InputDecoration(hintText: 'Enter your message...'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    setState(() {
                      sendMessage();
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
