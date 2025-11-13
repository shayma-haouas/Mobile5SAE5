import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static Future<String> getMotivationalQuote() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.quotable.io/random?tags=motivational'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['content'] ?? 'Stay strong and keep going!';
      }
    } catch (e) {
    }
    return 'Every day is a step closer to your goal!';
  }

  static Future<Map<String, String>> getHealthTip() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.quotable.io/random?tags=health'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'tip': data['content'] ?? 'Take care of your health!',
          'author': data['author'] ?? 'Health Expert'
        };
      }
    } catch (e) {
    
    }
    return {
      'tip': 'A healthy lifestyle is the best investment you can make.',
      'author': 'Health Expert'
    };
  }

  static Future<String> getWeatherMotivation(String city) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.openweathermap.org/data/2.5/weather?q=$city&appid=demo&units=metric'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final weather = data['weather'][0]['main'];
        final temp = data['main']['temp'].round();
        
        if (weather == 'Clear') {
          return 'Perfect ${temp}°C weather for outdoor activities! 🌞';
        } else if (weather == 'Rain') {
          return 'Rainy day? Perfect for indoor goals! 🌧️';
        } else {
          return 'Weather is ${temp}°C - great day for your goals! 🌤️';
        }
      }
    } catch (e) {
    }
    return 'Great day to work on your goals! 🌟';
  }

  static Future<Map<String, dynamic>> getRandomFact() async {
    try {
      final response = await http.get(
        Uri.parse('https://uselessfacts.jsph.pl/random.json?language=en'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'fact': data['text'] ?? 'Did you know? Every goal completed makes you stronger!',
          'source': 'Fun Facts API'
        };
      }
    } catch (e) {
      // Fallback
    }
    return {
      'fact': 'Did you know? People who write down goals are 42% more likely to achieve them!',
      'source': 'Goal Research'
    };
  }
}