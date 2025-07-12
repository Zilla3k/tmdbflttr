import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:movie_database/app/data/models/movies_model.dart';
import 'package:movie_database/app/widgets/movie_carousel/movie_carousel.dart';
import 'package:movie_database/app/widgets/movie_info/movie_info.dart';
import 'package:movie_database/app/widgets/share_modal/share_modal.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../../providers/movie_provider/movie_provider.dart';

class MovieDetailScreen extends StatefulWidget {
  final MoviesModel movie;

  const MovieDetailScreen({super.key, required this.movie});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  final MovieCarousel movieCarousel = MovieCarousel();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MovieProvider>(
        context,
        listen: false,
      ).fetchAll(widget.movie.id);
    });
  }

  Future<void> _openTrailer(String? trailerKey) async {
    if (trailerKey != null) {
      final String trailerUrl = 'https://www.youtube.com/watch?v=$trailerKey';
      final Uri url = Uri.parse(trailerUrl);

      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } else {
      debugPrint('Trailer not available');
    }
  }

  void _showShareModal() {
    final String movieTitle = widget.movie.title;
    final String movieYear = widget.movie.releaseDate.length >= 4
        ? widget.movie.releaseDate.substring(0, 4)
        : 'Unknown';
    final String rating = widget.movie.voteAverage > 0
        ? widget.movie.voteAverage.toStringAsFixed(1)
        : 'N/A';

    final String shareMessage =
        'Check out this amazing movie: $movieTitle ($movieYear) ⭐ $rating/10';
    final String tmdbLink =
        'https://www.themoviedb.org/movie/${widget.movie.id}';
    final String fullMessage = '$shareMessage\n\n$tmdbLink';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ShareModal(
        message: shareMessage,
        link: tmdbLink,
        fullMessage: fullMessage,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final posterPath =
        "https://image.tmdb.org/t/p/w500${widget.movie.posterPath}";

    return Consumer<MovieProvider>(
      builder: (context, provider, child) {
        final movieDetails = provider.movieDetails;
        final cast = provider.cast;
        final trailerKey = provider.trailerKey;
        final recommendations = provider.recommendations;
        final loading = provider.loading;

        return Scaffold(
          appBar: AppBar(
            foregroundColor: const Color(0xFFFFFFFF),
            title: Text(
              widget.movie.title.toString(),
              style: const TextStyle(color: Color(0xFFFFFFFF)),
            ),
            backgroundColor: const Color(0xFF1F1D2B),
            centerTitle: true,
          ),
          backgroundColor: const Color(0xFF1F1D2B),
          body: Stack(
            children: [
              Positioned.fill(
                child: CachedNetworkImage(
                  imageUrl: posterPath,
                  fit: BoxFit.fill,
                  placeholder: (context, url) => Container(
                    color: Colors.transparent,
                    child: const Icon(Icons.image, color: Colors.transparent),
                  ),
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.error, color: Colors.red),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black54, Color(0xFF1F1D2B)],
                    ),
                  ),
                ),
              ),
              loading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.movie.posterPath.isNotEmpty)
                            Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: CachedNetworkImage(
                                  imageUrl: posterPath,
                                  width: screenWidth * .5,
                                  placeholder: (context, url) => Container(
                                    color: Colors.transparent,
                                    child: const Icon(
                                      Icons.image,
                                      color: Colors.transparent,
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      const Icon(
                                        Icons.error,
                                        color: Colors.red,
                                      ),
                                ),
                              ),
                            )
                          else
                            const SizedBox.shrink(),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              InfoRow(
                                icon: Icons.calendar_month,
                                text: widget.movie.releaseDate.length >= 10
                                    ? widget.movie.releaseDate.substring(0, 4)
                                    : 'Unknown',
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                '|',
                                style: TextStyle(color: Color(0xFF92929D)),
                              ),
                              const SizedBox(width: 12),
                              InfoRow(
                                icon: Icons.access_time_filled_rounded,
                                text: movieDetails.isNotEmpty
                                    ? '${movieDetails.first.runtime} minutes'
                                    : 'Unknown',
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                '|',
                                style: TextStyle(color: Color(0xFF92929D)),
                              ),
                              const SizedBox(width: 12),
                              InfoRow(
                                icon: Icons.local_movies_sharp,
                                text: movieDetails.isNotEmpty
                                    ? movieDetails.first.genresTypes
                                          .map(
                                            (genre) => genre['name'].toString(),
                                          )
                                          .take(1)
                                          .join(', ')
                                    : 'Unknown',
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 55,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF252836),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      widget.movie.voteAverage > 0
                                          ? widget.movie.voteAverage
                                                .toStringAsFixed(1)
                                          : 'N/A',
                                      style: const TextStyle(
                                        color: Colors.amber,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: trailerKey != null
                                    ? () => _openTrailer(trailerKey)
                                    : null,
                                style: ButtonStyle(
                                  backgroundColor: WidgetStateProperty.all(
                                    trailerKey != null
                                        ? const Color(0xFF12CDD9)
                                        : Colors.grey,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.play_arrow,
                                      color: Color(0xFFFFFFFF),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      trailerKey != null
                                          ? "Trailer"
                                          : "No Trailer",
                                      style: const TextStyle(
                                        color: Color(0xFFFFFFFF),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              ElevatedButton(
                                onPressed: _showShareModal,
                                style: ButtonStyle(
                                  backgroundColor: WidgetStateProperty.all(
                                    const Color(0xFF252836),
                                  ),
                                ),
                                child: Row(
                                  children: const [
                                    Icon(Icons.share, color: Color(0xFF12CDD9)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            "Story Line",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFFFFFFF),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.movie.overview,
                            style: const TextStyle(color: Color(0xFFFFFFFF)),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            "Cast",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFFFFFFF),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 60,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: cast.length,
                                  itemBuilder: (context, index) {
                                    final castMember = cast[index];
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        right: 16.0,
                                      ),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 20,
                                            child: ClipOval(
                                              child: CachedNetworkImage(
                                                imageUrl:
                                                    castMember['profile_path'] !=
                                                        null
                                                    ? 'https://image.tmdb.org/t/p/w200${castMember['profile_path']}'
                                                    : 'https://www.themoviedb.org/assets/2/apple-touch-icon-cfba7699efe7a742de25c28e08c38525f19381d31087c69e89d6bcb8e3c0ddfa.png',
                                                width: 40,
                                                height: 40,
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) =>
                                                    Container(
                                                      color: Colors.transparent,
                                                      child: const Icon(
                                                        Icons.image,
                                                        color:
                                                            Colors.transparent,
                                                      ),
                                                    ),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Container(
                                                          color:
                                                              Colors.grey[800],
                                                          width: 40,
                                                          height: 40,
                                                          child: const Icon(
                                                            Icons.person,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                castMember['name'] ?? 'Unknown',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Color(0xFFFFFFFF),
                                                ),
                                              ),
                                              Text(
                                                castMember['character'] ??
                                                    'Unknown',
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  color: Color(0xFF92929D),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 20),
                              movieCarousel.buildCarousel(
                                "Recommendations",
                                recommendations,
                                loading,
                              ),
                              const SizedBox(height: 30),
                            ],
                          ),
                        ],
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }
}
