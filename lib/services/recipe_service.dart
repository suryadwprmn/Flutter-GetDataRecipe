import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:resepmakanan_5b/models/recipe_model.dart';
import 'package:resepmakanan_5b/services/session_service.dart';

const String baseurl = 'https://recipe.incube.id/api';

class RecipeService {
  SessionService _sessionService = SessionService();

  Future<List<RecipeModel>> getAllRecipe() async {
    final token = await _sessionService.getToken();

    if (token == null || token.isEmpty) {
      print('Tidak ada token');
    }

    final response = await http.get(Uri.parse('$baseurl/recipes'), headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });

    print(response.body);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body)['data']['data'];
      return data.map((json) => RecipeModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load recipes');
    }
  }
}
