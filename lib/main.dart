import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart'; // Import the services package
import 'Page2.dart';

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




  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: controller,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Enter City',
            ),
          ),
        ),
        ElevatedButton(

          onPressed: () {
            Get.closeAllSnackbars();
            if(controller.text.isNotEmpty) {
              Get.to(const Page2());
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
