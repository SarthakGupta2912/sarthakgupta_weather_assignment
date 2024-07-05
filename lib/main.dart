import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart'; // Import the services package
import 'Page2.dart';
import 'package:http/http.dart' as http;

dynamic weatherData;
final TextEditingController controller = TextEditingController();

void main() {


  runApp(const MainApp());
  // Set the app to fullscreen mode.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const GetMaterialApp(
      home: Scaffold(
        body: Center(
          child: WeatherApp(),
        ),
      ),
    );
  }
}

class WeatherApp extends StatefulWidget {
  const WeatherApp({super.key});
  @override
  _WeatherAppState createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  final RegExp regExp = RegExp(r'[a-zA-Z\s]');
  //check internet connection
  Future<bool> hasInternetConnection() async {
    debugPrint('Checking internet connection ...');
    try {
      final result = await InternetAddress.lookup('www.google.com');
      if (result.isNotEmpty) {
        if (result[0].rawAddress.isNotEmpty) {
          return true;
        }
      }
    } on SocketException catch (_) {
      return false;
    }
    return false;
  }
  Future<bool> checkCity(String city) async {
    const apiKey = '6233729271b0443193a154447240207';
    final response = await http.get(
      Uri.parse('http://api.weatherapi.com/v1/search.json?key=$apiKey&q=$city'),
    );

    if (response.statusCode == 200) {
      List<dynamic> cityResponse = json.decode(response.body);
      debugPrint('test2912: ${cityResponse}');

      if (cityResponse.isNotEmpty) {
        bool cityFound = false;
        for(int i=0;i<cityResponse.length; i++){
          if(cityResponse[i]['name'].toString().toLowerCase() == controller.text.toLowerCase().trim()){
            cityFound=true;
            break;
          }
        }
        return cityFound;
      } else {
        return false;
      }
    } else {
      throw Exception('Failed to load city data');
    }
  }

  void getWeather() async {
    if (await checkCity(controller.text.trim())) {
      Get.to(const Page2());
    } else {
      Get.closeAllSnackbars();
      Get.snackbar(
        'Error',
        'City not found. Please enter a valid city.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  void _onTextChanged(String text) {
    final filteredText = text.replaceAll(RegExp(r'[^a-zA-Z\s]'), '');
    if (text != filteredText) {
      controller.text = filteredText;
      controller.selection = TextSelection.collapsed(offset: filteredText.length);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: controller,
            inputFormatters: [
              LengthLimitingTextInputFormatter(50),
            ],
onChanged: _onTextChanged,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Enter City',
            ),
          ),
        ),
        ElevatedButton(

          onPressed: () async {
            Get.closeAllSnackbars();
            if(controller.text.isNotEmpty) {
              if(await hasInternetConnection()) {
                getWeather();
              }
              else{
                Get.snackbar(
                    'Error',
                    'Please check your internet connection',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red,
                    colorText: Colors.white,

                    icon: const Icon(Icons.error)

                );
              }
            }
            else{
              Get.snackbar(
                'Error',
                'City cannot be empty',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red,
                colorText: Colors.white,
                icon: const Icon(Icons.error)

              );
            }
          },
          child: const Text('Get Weather Data'),
        ),

      ],
    );
  }
}
