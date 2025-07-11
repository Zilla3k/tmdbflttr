import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:movie_database/app/data/models/movies_model.dart';
import 'package:movie_database/app/screens/movie/movie_details.screen.dart';

class MovieCarousel extends StatelessWidget {
  const MovieCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox.shrink();
  }

  Widget buildCarousel(String title, List<MoviesModel> movies, bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 10),
        isLoading
            ? CircularProgressIndicator()
            : CarouselSlider.builder(
                itemCount: movies.length,
                itemBuilder: (context, index, realIndex) {
                  final movie = movies[index];
                  final imageUrl =
                      'https://image.tmdb.org/t/p/w500${movie.posterPath}';
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MovieDetailScreen(movie: movie),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.fitHeight,
                        placeholder: (context, url) => Container(
                          color: Colors.transparent,
                          child: Icon(Icons.image, color: Colors.transparent),
                        ),
                        errorWidget: (context, url, error) =>
                            Icon(Icons.error, color: Colors.red),
                      ),
                    ),
                  );
                },
                options: CarouselOptions(
                  viewportFraction: 0.4,
                  padEnds: false,
                  enableInfiniteScroll: false,
                ),
              ),
      ],
    );
  }
}
