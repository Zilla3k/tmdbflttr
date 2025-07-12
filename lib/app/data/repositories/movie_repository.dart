import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:movie_database/app/data/models/movies_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MovieRepository {
  final String baseUrl = "https://api.themoviedb.org/3";
  final String bearerToken = dotenv.env['BEARER_TOKEN'] ?? '';
  final Map<String, dynamic> _cache = {};

  dynamic _getFromCache(String key) => _cache[key];

  void _saveToCache(String key, dynamic value) {
    _cache[key] = value;
  }

  Future<List<MoviesModel>> searchMovie(String movie) async {
    final cacheKey = 'search_$movie';
    final cachedData = _getFromCache(cacheKey);

    if (cachedData != null) {
      debugPrint('Returning cached data for search: $movie');
      return cachedData;
    }

    try {
      final url = Uri.parse('$baseUrl/search/movie?query=$movie');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json;charset=utf-8',
        },
      );

      if (response.statusCode == 200) {
        final List results = jsonDecode(response.body)['results'];
        if (results.isEmpty) {
          throw Exception('No movies found.');
        }
        final movies = results
            .map((json) => MoviesModel.fromMap(json))
            .toList();
        _saveToCache(cacheKey, movies);
        return movies;
      } else {
        throw Exception('Error fetching movies: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error in searchMovie: $e');
      return [];
    }
  }

  Future<List<MoviesModel>> fetchMovieRecommendations(int movieId) async {
    final cacheKey = 'recommendations_$movieId';
    final cachedData = _getFromCache(cacheKey);

    if (cachedData != null) {
      debugPrint('Returning cached recommendations for movie ID: $movieId');
      return cachedData;
    }

    try {
      final url = Uri.parse('$baseUrl/movie/$movieId/recommendations');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json;charset=utf-8',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> results = data['results'];
        final recommendations = results
            .map((movie) => MoviesModel.fromMap(movie))
            .toList();
        _saveToCache(cacheKey, recommendations);
        return recommendations;
      } else {
        throw Exception('Error fetching recommendations: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error fetchMovieRecommendations: $e');
      throw Exception('Error fetching recommendations!');
    }
  }

  Future<MoviesModel> fetchMovieDetails(int movieId) async {
    final cacheKey = 'details_$movieId';
    final cachedData = _getFromCache(cacheKey);

    if (cachedData != null) {
      debugPrint('Returning cached details for movie ID: $movieId');
      return cachedData;
    }

    try {
      final url = Uri.parse('$baseUrl/movie/$movieId');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json;charset=utf-8',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> result = jsonDecode(response.body);

        if (result.isEmpty) {
          throw Exception('No movie details found for ID: $movieId');
        }

        final movie = MoviesModel.fromMap(result);
        _saveToCache(cacheKey, movie);
        return movie;
      } else {
        throw Exception('Error fetching movie details: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error fetchMovieDetails: $e');
      throw Exception('Error fetchMovieDetails!');
    }
  }

  Future<List<Map<String, dynamic>>> fetchCast(int movieId) async {
    final cacheKey = 'cast_$movieId';
    final cachedData = _getFromCache(cacheKey);

    if (cachedData != null) {
      debugPrint('Returning cached cast for movie ID: $movieId');
      return List<Map<String, dynamic>>.from(cachedData);
    }

    try {
      final url = Uri.parse('$baseUrl/movie/$movieId/credits');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json;charset=utf-8',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final castList = data['cast'] is List
            ? List<Map<String, dynamic>>.from(data['cast'])
            : <Map<String, dynamic>>[];
        _saveToCache(cacheKey, castList);
        return castList;
      } else {
        throw Exception('Error fetching cast: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error fetchCast: $e');
      return <Map<String, dynamic>>[];
    }
  }

  Future<List<MoviesModel>> fetchTrending() async {
    const cacheKey = 'trending';
    final cachedData = _getFromCache(cacheKey);

    if (cachedData != null) {
      debugPrint('Returning cached trending movies');
      return cachedData;
    }

    try {
      final url = Uri.parse('$baseUrl/trending/movie/week');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json;charset=utf-8',
        },
      );

      if (response.statusCode == 200) {
        final List results = json.decode(response.body)['results'];
        final movies = results
            .map((json) => MoviesModel.fromMap(json))
            .toList();
        _saveToCache(cacheKey, movies);
        return movies;
      } else {
        throw Exception('Error fetching trending movies: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error fetchTrending: $e');
      throw Exception('Error fetchTrending');
    }
  }

  Future<List<MoviesModel>> fetchPopular() async {
    const cacheKey = 'popular';
    final cachedData = _getFromCache(cacheKey);

    if (cachedData != null) {
      debugPrint('Returning cached popular movies');
      return cachedData;
    }

    try {
      final url = Uri.parse('$baseUrl/movie/popular');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json;charset=utf-8',
        },
      );

      if (response.statusCode == 200) {
        final List results = json.decode(response.body)['results'];
        final movies = results
            .map((json) => MoviesModel.fromMap(json))
            .toList();
        _saveToCache(cacheKey, movies);
        return movies;
      } else {
        throw Exception('Error fetching popular movies: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error fetchPopular: $e');
      throw Exception('Error fetchPopular');
    }
  }

  Future<List<MoviesModel>> fetchTopRated() async {
    const cacheKey = 'top_rated';
    final cachedData = _getFromCache(cacheKey);

    if (cachedData != null) {
      debugPrint('Returning cached top rated movies');
      return cachedData;
    }

    try {
      final url = Uri.parse('$baseUrl/movie/top_rated');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json;charset=utf-8',
        },
      );

      if (response.statusCode == 200) {
        final List results = json.decode(response.body)['results'];
        final movies = results
            .map((json) => MoviesModel.fromMap(json))
            .toList();
        _saveToCache(cacheKey, movies);
        return movies;
      } else {
        throw Exception('Error fetching top rated movies: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error fetchTopRated: $e');
      throw Exception('Error fetchTopRated');
    }
  }

  Future<List<MoviesModel>> fetchUpcoming() async {
    const cacheKey = 'upcoming';
    final cachedData = _getFromCache(cacheKey);

    if (cachedData != null) {
      debugPrint('Returning cached upcoming movies');
      return cachedData;
    }

    try {
      final url = Uri.parse('$baseUrl/movie/upcoming');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json;charset=utf-8',
        },
      );

      if (response.statusCode == 200) {
        final List results = json.decode(response.body)['results'];
        final movies = results
            .map((json) => MoviesModel.fromMap(json))
            .toList();
        _saveToCache(cacheKey, movies);
        return movies;
      } else {
        throw Exception('Error fetching upcoming movies: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error fetchUpcoming: $e');
      throw Exception('Error fetchUpcoming');
    }
  }

  Future<String?> fetchMovieTrailer(int movieId) async {
    final cacheKey = 'trailer_$movieId';
    final cachedData = _getFromCache(cacheKey);

    if (cachedData != null) {
      debugPrint('Returning cached trailer for movie ID: $movieId');
      return cachedData;
    }

    try {
      final url = Uri.parse('$baseUrl/movie/$movieId/videos');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json;charset=utf-8',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final videos = data['results'] as List;

        for (var video in videos) {
          if (video['site'] == 'YouTube') {
            final trailerKey = video['key'];
            _saveToCache(cacheKey, trailerKey);
            return trailerKey;
          }
        }
        return null;
      } else {
        throw Exception('Error fetching trailer: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error fetchMovieTrailer: $e');
      return null;
    }
  }
}
