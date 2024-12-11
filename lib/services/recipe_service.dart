import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:resepmakanan_5b/models/recipe_model.dart';
import 'package:resepmakanan_5b/services/session_service.dart';

const String baseurl = 'https://recipe.incube.id/api';

class RecipeService {
  final SessionService _sessionService = SessionService();

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

  Future<RecipeModel> getRecipeById(String id) async {
    final token = await _sessionService.getToken();

    if (token == null || token.isEmpty) {
      print('Tidak ada token');
    }
    final response =
        await http.get(Uri.parse('$baseurl/recipes/$id'), headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      return RecipeModel.fromJson(data);
    } else if (response.statusCode == 404) {
      throw Exception('Recipe not found');
    } else {
      throw Exception('Failed to load recipe');
    }
  }

  Future<Map<String, dynamic>> createRecipe({
    required String title,
    required String description,
    required String cookingMethod,
    required String ingredients,
    required File photo,
  }) async {
    final token = await _sessionService.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Token tidak tersedia');
    }

    var uri = Uri.parse('$baseurl/recipes');
    var request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['title'] = title
      ..fields['description'] = description
      ..fields['cooking_method'] = cookingMethod
      ..fields['ingredients'] = ingredients
      ..files.add(await http.MultipartFile.fromPath('photo', photo.path));

    final response = await request.send();

    final responseBody = await response.stream.bytesToString();
    final decodedResponse = jsonDecode(responseBody);

    if (response.statusCode == 201) {
      return {"status": true, "message": decodedResponse['message']};
    } else if (response.statusCode == 422) {
      return {
        "status": false,
        "message": decodedResponse['message'],
        "errors": decodedResponse['errors']
      };
    } else {
      throw Exception('Failed to create recipe');
    }
  }
}
