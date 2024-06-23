import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:jumping_dot/jumping_dot.dart';

class InfoScreen extends StatefulWidget {
  const InfoScreen({required this.title, required this.url, super.key});

  final String title;
  final String url;

  @override
  State<InfoScreen> createState() => InfoScreenState();
}

class InfoScreenState extends State<InfoScreen> {
  String? _text;

  Future<void> _fetchHttpText(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        setState(() {
          _text = '';
        });
        return;
      }

      setState(() {
        _text = response.body;
      });
    } catch (_) {
      setState(() {
        _text = '';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchHttpText(widget.url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      primary: MediaQuery.of(context).orientation == Orientation.portrait,
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _text != null
            ? Markdown(
                data: _text!,
              )
            : Padding(
                padding: const EdgeInsets.all(25.0),
                child: JumpingDots(
                  color: Colors.grey,
                  radius: 6,
                  innerPadding: 5,
                ),
              ),
      ),
    );
  }
}
