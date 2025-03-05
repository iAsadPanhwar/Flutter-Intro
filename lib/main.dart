import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; 

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, String>> messages = [];
  final String openAIKey = "YOUR_OPENAI_API_KEY"; // Replace with your key

  Future<void> sendMessage(String text) async {
    setState(() {
      messages.insert(0, {"text": text, "sender": "user"});
    });

    String response = await fetchChatResponse(text);

    setState(() {
      messages.insert(0, {"text": response, "sender": "bot"});
    });
  }

  Future<String> fetchChatResponse(String message) async {
    final url = Uri.parse("https://api.openai.com/v1/chat/completions");

    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $openAIKey",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "model": "gpt-3.5-turbo",
        "messages": [
          {"role": "system", "content": "You are a helpful assistant."},
          {"role": "user", "content": message}
        ]
      }),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return data["choices"][0]["message"]["content"];
    } else {
      return "Error: ${response.reasonPhrase}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chatbot")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Align(
                    alignment: messages[index]["sender"] == "user"
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: messages[index]["sender"] == "user"
                            ? Colors.blue[100]
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(messages[index]["text"]!),
                    ),
                  ),
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
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      sendMessage(_controller.text);
                      _controller.clear();
                    }
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
