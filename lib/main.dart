import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const apiKey = '본인이 발급 받은 API key';
const apiUrl = 'https://api.openai.com/v1/completions';

List<Chat> messages = []; // 채팅 내용을 저장할 List

bool isLoading = false;

void main() {
  runApp(const MyApp());
}

Future<String> generateText(String prompt) async {
  final response = await http.post(
    Uri.parse(apiUrl),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey'
    },
    body: jsonEncode({
      "model": "text-davinci-003",
      'prompt': prompt,
      'max_tokens': 1000,
      'temperature': 0,
      'top_p': 1,
      'frequency_penalty': 0,
      'presence_penalty': 0
    }),
  );

  Map<String, dynamic> newresponse =
      jsonDecode(utf8.decode(response.bodyBytes));

  return newresponse['choices'][0]['text'];
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    final TextEditingController textController = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: const Text("ChatGPT API", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        actions: <Widget>[
          Visibility(
              visible: isLoading,
              child: Container(
                color: Colors.black,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ))
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return Card(
                    child: ListTile(
                  leading: messages[index].talker == 'me'
                      ? const Icon(Icons.person)
                      : const Icon(Icons.adb),
                  title: Text(
                    messages[index].message.trim(),
                    textAlign: TextAlign.left,
                  ),
                ));
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                  child: TextField(
                controller: textController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Prompt',
                ),
              )),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isLoading = true;
                    messages
                        .add(Chat(talker: "me", message: textController.text));
                  });
                  Future<String> data = generateText(textController.text);
                  textController.clear();
                  data.then((value) {
                    setState(() {
                      messages.add(Chat(talker: "you", message: value));
                      isLoading = false;
                    });
                  });
                },
                child: const Text('전송'),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class Chat {
  final String talker;
  final String message;

  Chat({required this.talker, required this.message});

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      talker: json['talker'] as String,
      message: json['message'] as String,
    );
  }
}
