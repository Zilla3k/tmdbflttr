class MoviesModel {
  // Movie
  final int id;
  final String title;
  final String overview;
  final String backdropPath;
  final String posterPath;
  final String releaseDate;
  final int runtime;
  final double voteAverage;
  final List<int> genreIds;

  // Details
  final List<Map<String, dynamic>> genresTypes;
  final String homepage;

  // Cast
  final List<Map<String, dynamic>> cast;

  MoviesModel({
    required this.id,
    required this.title,
    required this.overview,
    required this.backdropPath,
    required this.posterPath,
    required this.releaseDate,
    required this.runtime,
    required this.voteAverage,
    required this.genreIds,
    //
    required this.genresTypes,
    required this.homepage,
    //
    required this.cast,
  });

  factory MoviesModel.fromMap(Map<String, dynamic> json) {
    return MoviesModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Título desconhecido',
      overview: json['overview'] ?? 'Descrição não disponível',
      backdropPath: json['backdrop_path'] ?? '',
      posterPath: json['poster_path'] ?? '',
      releaseDate: json['release_date'] ?? '',
      runtime: json['runtime'] ?? 0,
      voteAverage: (json['vote_average'] ?? 0).toDouble(),
      genreIds: List<int>.from(json['genre_ids'] ?? []),
      //
      genresTypes: List<Map<String, dynamic>>.from(json['genres'] ?? []),
      homepage: json['homepage'] ?? '',
      //
      cast: List<Map<String, dynamic>>.from(json['cast'] ?? []),
    );
  }
}
