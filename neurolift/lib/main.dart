import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(DeepSeekApp());
}

class DeepSeekApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DeepSeek Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: DeepSeekHome(),
    );
  }
}

class DeepSeekHome extends StatefulWidget {
  @override
  _DeepSeekHomeState createState() => _DeepSeekHomeState();
}

class _DeepSeekHomeState extends State<DeepSeekHome> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _response = '';
  bool _isLoading = false;

  Future<void> _performSearch() async {
    setState(() {
      _isLoading = true;
    });

    final String apiKey =
        'YOUR_OPENAI_API_KEY'; // Replace with your OpenAI API key
    final String apiUrl = 'https://api.openai.com/v1/chat/completions';

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {'role': 'user', 'content': _searchQuery},
        ],
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final String botResponse = data['choices'][0]['message']['content'];

      setState(() {
        _response = botResponse;
        _isLoading = false;
      });
    } else {
      setState(() {
        _response = 'Error: ${response.statusCode}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('DeepSeek Flutter App')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Ask me anything...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    setState(() {
                      _searchQuery = _searchController.text;
                    });
                    _performSearch();
                  },
                ),
              ),
            ),
            SizedBox(height: 20),

            // Loading Indicator
            if (_isLoading) Center(child: CircularProgressIndicator()),

            // Search Results
            if (_response.isNotEmpty)
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(_response, style: TextStyle(fontSize: 16)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
