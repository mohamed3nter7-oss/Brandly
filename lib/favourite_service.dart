import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'brand_model.dart';

class FavoritesService {
  static final FavoritesService _instance = FavoritesService._internal();

  factory FavoritesService() {
    return _instance;
  }

  FavoritesService._internal();

  final List<BrandModel> _favorites = [];

  List<BrandModel> get favorites => _favorites;

  /// Load favorites from SharedPreferences
  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = prefs.getStringList('favorites') ?? [];
    _favorites.clear();
    _favorites.addAll(favoritesJson.map((jsonStr) {
      final json = jsonDecode(jsonStr);
      return BrandModel.fromJson(json);
    }).toList());
  }

  /// Save favorites to SharedPreferences
  Future<void> saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson =
        _favorites.map((brand) => jsonEncode(brand.toJson())).toList();
    await prefs.setStringList('favorites', favoritesJson);
  }

  void addFavorite(BrandModel brand) {
    if (!_favorites.any((b) => b.id == brand.id)) {
      _favorites.add(brand);
      saveFavorites();
    }
  }

  void removeFavorite(String brandId) {
    _favorites.removeWhere((b) => b.id == brandId);
    saveFavorites();
  }

  bool isFavorite(String brandId) {
    return _favorites.any((b) => b.id == brandId);
  }

  void clearAll() {
    _favorites.clear();
    saveFavorites();
  }
}
