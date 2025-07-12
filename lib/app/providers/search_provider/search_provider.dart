import 'package:flutter/widgets.dart';
import 'package:movie_database/app/data/models/movies_model.dart';
import 'package:movie_database/app/data/repositories/movie_repository.dart';

class SearchProvider extends ChangeNotifier {
  List<MoviesModel> movies = [];
  bool loading = false;
  String error = '';

  Future<void> search(String query) async {
    loading = true;
    error = '';
    notifyListeners();
    try {
      movies = await MovieRepository().searchMovie(query);
      movies.sort((a, b) {
        final yearComparison = b.releaseDate.compareTo(a.releaseDate);
        if (yearComparison != 0) {
          return yearComparison;
        }
        return a.title.compareTo(b.title);
      });
    } catch (e) {
      error = 'Search error: $e';
      movies = [];
    }
    loading = false;
    notifyListeners();
  }
}
