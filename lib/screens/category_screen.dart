import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/firestore_service.dart';
import '../widgets/category_card.dart';
import 'add_category_screen.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({Key? key}) : super(key: key);

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catégories'),
      ),
      body: StreamBuilder<List<Category>>(
        stream: _firestoreService.getCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final categories = snapshot.data ?? [];
          
          if (categories.isEmpty) {
            return const Center(
              child: Text('Aucune catégorie. Ajoutez-en une !'),
            );
          }
          
          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              
              return CategoryCard(
                category: category,
                onDelete: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Confirmation'),
                      content: const Text(
                          'Voulez-vous vraiment supprimer cette catégorie ? '
                          'Toutes les transactions associées seront également supprimées.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Annuler'),
                        ),
                        TextButton(
                          onPressed: () {
                            _firestoreService.deleteCategory(category.id);
                            Navigator.pop(context);
                          },
                          child: const Text('Supprimer'),
                        ),
                      ],
                    ),
                  );
                },
                onEdit: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddCategoryScreen(
                        category: category,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddCategoryScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}