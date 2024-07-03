import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:sarthakgupta_weather_assignment/main.dart';

RxBool isRefreshing = false.obs;

class Page2 extends StatefulWidget {
  const Page2({super.key});

  @override
  State<Page2> createState() => _Page2State();
}

class _Page2State extends State<Page2> {
  late Future<Map<String, dynamic>> weatherDataFuture;
  String city = controller.text; // Replace with the default city

  @override
  void initState() {
    super.initState();
    weatherDataFuture = fetchWeather(city);
  }


  Future<Map<String, dynamic>> fetchWeather(String city) async {
    const apiKey = '6233729271b0443193a154447240207';
    final response = await http.get(
      Uri.parse('https://api.weatherapi.com/v1/current.json?key=$apiKey&q=$city&aqi=no'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Weather Details'),
          leading: IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back_ios_new),
          ),
        ),
        body: Center(
          child: FutureBuilder<Map<String, dynamic>>(
            future: weatherDataFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting || isRefreshing.value) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                if(snapshot.error.toString().contains('Socket')){
                  return const Text('Please check your internet connection and try again!',style: TextStyle(color: Colors.red),textAlign: TextAlign.center,);
                }
                return Text('${snapshot.error.toString().replaceFirst('Exception: ', '')}!',style: const TextStyle(color: Colors.red),textAlign: TextAlign.center);
              } else if (snapshot.hasData) {
                final weatherData = snapshot.data!;
                return SingleChildScrollView(
                  child: SizedBox(
                    width: screenWidth*0.8,
                    child: Column(
                      children: [
                        Image.network(
                          'https:${weatherData['current']['condition']['icon']}',
                          height: 100,
                          width: 100,
                        ),
                        Text('City: ${weatherData['location']['name']}',textAlign: TextAlign.center,),
                        Text('Temperature: ${weatherData['current']['temp_c']}°C',textAlign: TextAlign.center,),
                        Text('Condition: ${weatherData['current']['condition']['text']}',textAlign: TextAlign.center,),
                        Text('Humidity percentage: ${weatherData['current']['humidity']}%',textAlign: TextAlign.center,),
                        Text('Wind speed: ${weatherData['current']['wind_kph']} kph',textAlign: TextAlign.center,),
                        IconButton(
                          onPressed: () async {
                            setState(() {
                              isRefreshing.value = true;
                            });
                            weatherDataFuture = fetchWeather(weatherData['location']['name']);
                            weatherDataFuture.whenComplete(() {
                              setState(() {
                                isRefreshing.value = false;
                              });
                            });
                          },
                          icon: const Icon(Icons.refresh_rounded),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                return const Text('No data available!');
              }
            },
          ),
        ),
      ),
    );
  }
}