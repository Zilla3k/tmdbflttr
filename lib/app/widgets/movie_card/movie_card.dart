import 'package:flutter/material.dart';
import 'package:movie_database/app/data/models/movies_model.dart';
import 'package:movie_database/app/data/repositories/movie_repository.dart';
import 'package:movie_database/app/widgets/movie_info/movie_info.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MovieCard extends StatefulWidget {
  final MoviesModel movie;
  final VoidCallback onTap;

  const MovieCard({super.key, required this.movie, required this.onTap});

  @override
  State<MovieCard> createState() => _MovieCardState();
}

class _MovieCardState extends State<MovieCard> {
  List<MoviesModel> _movieDetails = [];

  @override
  void initState() {
    super.initState();
    _search();
  }

  void _search() async {
    try {
      final movies = await MovieRepository().fetchMovieDetails(widget.movie.id);
      setState(() {
        _movieDetails = [movies];
      });
    } catch (e) {
      setState(() {
        _movieDetails = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.movie.posterPath.isNotEmpty
        ? 'https://image.tmdb.org/t/p/w200${widget.movie.posterPath}'
        : null;

    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        height: 170,
        child: Row(
          children: [
            imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      placeholder: (context, url) => Container(
                        color: Colors.transparent,
                        child: Icon(Icons.image, color: Colors.transparent),
                      ),
                      errorWidget: (context, url, error) =>
                          Icon(Icons.error, color: Colors.red),
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                  )
                : Container(
                    width: 100,
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: Colors.grey.shade300,
                    ),
                    child: Icon(Icons.image_not_supported),
                  ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      widget.movie.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    InfoRow(
                      icon: Icons.calendar_month,
                      text: widget.movie.releaseDate.isNotEmpty
                          ? '${widget.movie.releaseDate.substring(8, 10)}/${widget.movie.releaseDate.substring(5, 7)}/${widget.movie.releaseDate.substring(0, 4)}'
                          : "Unknown",
                    ),
                    SizedBox(height: 4),
                    InfoRow(
                      icon: Icons.access_time_filled_rounded,
                      text: _movieDetails.isNotEmpty
                          ? '${_movieDetails.first.runtime} min'
                          : 'Unknown',
                    ),
                    SizedBox(height: 4),
                    InfoRow(
                      icon: Icons.local_movies_sharp,
                      text: _movieDetails.isNotEmpty
                          ? _movieDetails.first.genresTypes
                                .map((genre) => genre['name'].toString())
                                .take(1)
                                .join(', ')
                          : 'Unknown',
                    ),
                    SizedBox(height: 4),
                    InfoRow(
                      icon: Icons.star,
                      text: widget.movie.voteAverage > 0
                          ? 'Rating: ${widget.movie.voteAverage.toStringAsFixed(1)}'
                          : 'No rating',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
