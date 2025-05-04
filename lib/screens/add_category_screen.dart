import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/firestore_service.dart';

class AddCategoryScreen extends StatefulWidget {
  final Category? category;

  const AddCategoryScreen({
    Key? key,
    this.category,
  }) : super(key: key);

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _iconController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  
  Color _selectedColor = Colors.blue;
  final List<Color> _colors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
  ];
  
  final List<String> _icons = [
    '🏠', '🍔', '🚗', '🚌', '🛒', '🏥', '📚', '🎭', '🎮', '👕', '💼', 
    '📱', '💻', '🎁', '💰', '💳', '🏦', '📝', '✈️', '🛎️', '⚽', '🎵',
  ];
  
  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nameController.text = widget.category!.name;
      _iconController.text = widget.category!.icon;
      _selectedColor = Color(widget.category!.colorValue);
    } else {
      _iconController.text = _icons[0];
    }
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _iconController.dispose();
    super.dispose();
  }
  
  void _saveCategory() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final icon = _iconController.text;
      
      if (widget.category == null) {
        _firestoreService.addCategory(name, icon, _selectedColor);
      } else {
        final updatedCategory = Category(
          id: widget.category!.id,
          name: name,
          icon: icon,
          colorValue: _selectedColor.value,
        );
        _firestoreService.updateCategory(updatedCategory);
      }
      
      Navigator.pop(context);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final isEditing = widget.category != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier la catégorie' : 'Nouvelle catégorie'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom de la catégorie',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nom pour la catégorie';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
              
              const Text(
                'Choisir une icône',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12.0,
                runSpacing: 12.0,
                children: _icons.map((icon) {
                  final isSelected = _iconController.text == icon;
                  
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _iconController.text = icon;
                      });
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: isSelected ? _selectedColor.withOpacity(0.3) : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: isSelected ? Border.all(color: _selectedColor) : null,
                      ),
                      child: Center(
                        child: Text(
                          icon,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 24),
              
              const Text(
                'Choisir une couleur',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12.0,
                runSpacing: 12.0,
                children: _colors.map((color) {
                  final isSelected = _selectedColor.value == color.value;
                  
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColor = color;
                      });
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(8),
                        border: isSelected 
                            ? Border.all(color: Colors.black, width: 2) 
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 32),
              
              const Text(
                'Aperçu',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: _selectedColor,
                      child: Text(
                        _iconController.text,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      _nameController.text.isEmpty ? 'Nom de la catégorie' : _nameController.text,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              
              const Spacer(),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveCategory,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      isEditing ? 'Mettre à jour' : 'Ajouter',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}