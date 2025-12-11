/*import 'brand_model.dart';

class FavoritesService {
  static final FavoritesService _instance = FavoritesService._internal();
  
  factory FavoritesService() {
    return _instance;
  }
  
  FavoritesService._internal();
  
  final List<BrandModel> _favorites = [];
  
  List<BrandModel> get favorites => _favorites;
  
  void addFavorite(BrandModel brand) {
    if (!_favorites.any((b) => b.name == brand.name)) {
      _favorites.add(brand);
    }
  }
  
  void removeFavorite(String brandName) {
    _favorites.removeWhere((b) => b.name == brandName);
  }
  
  bool isFavorite(String brandName) {
    return _favorites.any((b) => b.name == brandName);
  }
  
  void clearAll() {
    _favorites.clear();
  }
}*/

import 'brand_model.dart';

class FavoritesService {
  static final FavoritesService _instance = FavoritesService._internal();
  
  factory FavoritesService() {
    return _instance;
  }
  
  FavoritesService._internal();
  
  final List<BrandModel> _favorites = [];
  
  List<BrandModel> get favorites => _favorites;
  
  void addFavorite(BrandModel brand) {
    if (!_favorites.any((b) => b.name == brand.name)) {
      _favorites.add(brand);
    }
  }
  
  void removeFavorite(String brandName) {
    _favorites.removeWhere((b) => b.name == brandName);
  }
  
  bool isFavorite(String brandName) {
    return _favorites.any((b) => b.name == brandName);
  }
  
  void clearAll() {
    _favorites.clear();
  }
}