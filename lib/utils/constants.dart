import 'package:flutter/material.dart';

class ErrorMessages {
  static const String required = 'Ce champ est obligatoire';
  static const String invalidAmount = 'Veuillez entrer un montant valide';
  static const String invalidDate = 'Veuillez entrer une date valide';
  static const String categoryRequired = 'Veuillez sélectionner une catégorie';
  static const String deleteConfirmation = 'Êtes-vous sûr de vouloir supprimer ?';
}

class SuccessMessages {
  static const String transactionAdded = 'Transaction ajoutée avec succès';
  static const String transactionUpdated = 'Transaction mise à jour avec succès';
  static const String categoryAdded = 'Catégorie ajoutée avec succès';
  static const String categoryUpdated = 'Catégorie mise à jour avec succès';
}

class AppColors {
  static const Color primary = Colors.blue;
  static const Color income = Colors.green;
  static const Color expense = Colors.red;
  static const Color background = Colors.white;
  static const Color text = Colors.black87;
  static const Color lightText = Colors.black54;
}

class DefaultCategories {
  static const List<Map<String, dynamic>> categories = [
    {
      'name': 'Alimentation',
      'icon': '🍔',
      'colorValue': 0xFF4CAF50, // Green
    },
    {
      'name': 'Transport',
      'icon': '🚗',
      'colorValue': 0xFF2196F3, // Blue
    },
    {
      'name': 'Logement',
      'icon': '🏠',
      'colorValue': 0xFF9C27B0, // Purple
    },
    {
      'name': 'Loisirs',
      'icon': '🎮',
      'colorValue': 0xFFFF9800, // Orange
    },
    {
      'name': 'Santé',
      'icon': '🏥',
      'colorValue': 0xFFF44336, // Red
    },
    {
      'name': 'Shopping',
      'icon': '🛒',
      'colorValue': 0xFF3F51B5, // Indigo
    },
    {
      'name': 'Éducation',
      'icon': '📚',
      'colorValue': 0xFF009688, // Teal
    },
    {
      'name': 'Salaire',
      'icon': '💰',
      'colorValue': 0xFF795548, // Brown
    },
    {
      'name': 'Cadeaux',
      'icon': '🎁',
      'colorValue': 0xFFE91E63, // Pink
    },
    {
      'name': 'Autres',
      'icon': '📝',
      'colorValue': 0xFF607D8B, // Blue Grey
    },
  ];
}