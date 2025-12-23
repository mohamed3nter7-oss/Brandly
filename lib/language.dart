import 'package:flutter/material.dart';

class LanguagePage extends StatefulWidget {
  const LanguagePage({super.key});

  @override
  _LanguagePageState createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  String selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Language")),
      body: ListView(
        children: [
          RadioListTile(
            title: Text("English"),
            value: 'English',
            groupValue: selectedLanguage,
            onChanged: (value) {
              setState(() {
                selectedLanguage = value.toString();
              });
            },
          ),
          RadioListTile(
            title: Text("Arabic"),
            value: 'Arabic',
            groupValue: selectedLanguage,
            onChanged: (value) {
              setState(() {
                selectedLanguage = value.toString();
              });
            },
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Text("Selected Language: $selectedLanguage"),
          ),
        ],
      ),
    );
  }
}