# PhoneNumberField

A Flutter widget to format and validate phone numbers in a text field.

---

## ✨ Features

- ✅ Formats phone numbers
- 📦 Supports 100+ countries
- 🧩 Supports auto-completion
- 🔍 Supports search
- 📝 Supports custom widget
- 📱 Auto-format
- 🎉 Easy to use
- 🚀 Fast and stable
- 🌟 Easy to customize

---

## Usage

```dart
import 'package:flutter/material.dart';
import 'package:phone_number_field/phone_number_field.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late TextEditingController _controller;
  Country? _country;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Example'),
        actions: [
          IconButton(
            onPressed: () {
              showSearch(context: context, delegate: CountrySearchDelegate()).then((value) {
                if (value != null) {
                  setState(() {
                    _country = value;
                  });
                }
              });
            },
            icon: Icon(Icons.search),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          spacing: 20,
          children: [
            TextField(controller: _controller, readOnly: true),
            PhoneNumberField(
              initialCountry: _country,
              label: 'Phone Number',
              isLabelInside: false,
              onCountrySelected: (country) {
                _controller.text = '${country?.emoji ?? ''} ${country?.name ?? ''}';
              },
              onCompleted: (value) {
                print("phone number => $value");
              },
            ),
          ],
        ),
      ),
    );
  }
}
```                         