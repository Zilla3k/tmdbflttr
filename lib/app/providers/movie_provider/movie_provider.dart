import 'package:flutter/widgets.dart';
import 'package:movie_database/app/data/models/movies_model.dart';
import 'package:movie_database/app/data/repositories/movie_repository.dart';

class MovieProvider extends ChangeNotifier {
  List<MoviesModel> movieDetails = [];
  List<Map<String, dynamic>> cast = [];
  String? trailerKey;
  List<MoviesModel> recommendations = [];
  bool loading = false;

  Future<void> fetchAll(int movieId) async {
    loading = true;
    movieDetails = [];
    cast = [];
    trailerKey = null;
    recommendations = [];
    notifyListeners();

    final repo = MovieRepository();
    final details = await repo.fetchMovieDetails(movieId);
    movieDetails = [details];
    cast = await repo.fetchCast(movieId);
    trailerKey = await repo.fetchMovieTrailer(movieId);
    recommendations = await repo.fetchMovieRecommendations(movieId);

    loading = false;
    notifyListeners();
  }
}
