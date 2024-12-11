import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:resepmakanan_5b/services/recipe_service.dart';

class CreateRecipeScreen extends StatefulWidget {
  const CreateRecipeScreen({super.key});

  @override
  State<CreateRecipeScreen> createState() => _CreateRecipeScreenState();
}

class _CreateRecipeScreenState extends State<CreateRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final RecipeService _recipeService = RecipeService();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _cookingMethodController =
      TextEditingController();
  final TextEditingController _ingredientsController = TextEditingController();

  File? _image;

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitRecipe() async {
    if (_formKey.currentState!.validate() && _image != null) {
      try {
        final result = await _recipeService.createRecipe(
          title: _titleController.text,
          description: _descriptionController.text,
          cookingMethod: _cookingMethodController.text,
          ingredients: _ingredientsController.text,
          photo: _image!,
        );

        if (result['status']) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(result['message'])));
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(result['message'])));
        }
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } else if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select an image")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Recipe")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (value) =>
                      value!.isEmpty ? 'Title is required' : null,
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  validator: (value) =>
                      value!.isEmpty ? 'Description is required' : null,
                ),
                TextFormField(
                  controller: _cookingMethodController,
                  decoration:
                      const InputDecoration(labelText: 'Cooking Method'),
                  validator: (value) =>
                      value!.isEmpty ? 'Cooking Method is required' : null,
                ),
                TextFormField(
                  controller: _ingredientsController,
                  decoration: const InputDecoration(labelText: 'Ingredients'),
                  validator: (value) =>
                      value!.isEmpty ? 'Ingredients are required' : null,
                ),
                const SizedBox(height: 16),
                _image == null
                    ? const Text("No image selected")
                    : Image.file(_image!, height: 150),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: const Text("Pick Image"),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _submitRecipe,
                  child: const Text("Submit Recipe"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
