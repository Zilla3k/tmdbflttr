import 'package:flutter/widgets.dart';
import 'package:movie_database/app/data/models/movies_model.dart';
import 'package:movie_database/app/data/repositories/movie_repository.dart';

class HomeProvider extends ChangeNotifier {
  List<MoviesModel> trending = [];
  List<MoviesModel> popular = [];
  List<MoviesModel> topRated = [];
  List<MoviesModel> upcoming = [];
  bool loading = false;

  Future<void> fetchAll() async {
    loading = true;
    notifyListeners();
    final repo = MovieRepository();
    trending = await repo.fetchTrending();
    popular = await repo.fetchPopular();
    topRated = await repo.fetchTopRated();
    upcoming = await repo.fetchUpcoming();
    loading = false;
    notifyListeners();
  }
}
