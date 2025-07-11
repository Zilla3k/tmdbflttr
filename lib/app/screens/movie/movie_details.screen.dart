import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:movie_database/app/data/models/movies_model.dart';
import 'package:movie_database/app/data/repositories/movie_repository.dart';
import 'package:movie_database/app/widgets/movie_carousel/movie_carousel.dart';
import 'package:movie_database/app/widgets/movie_info/movie_info.dart';
import 'package:movie_database/app/widgets/share_modal/share_modal.dart';
import 'package:url_launcher/url_launcher.dart';

class MovieDetailScreen extends StatefulWidget {
  final MoviesModel movie;

  const MovieDetailScreen({super.key, required this.movie});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  List<MoviesModel> _movieDetails = [];
  List<Map<String, dynamic>> _cast = [];
  String? _trailerKey;
  final MovieCarousel movieCarousel = MovieCarousel();
  List<MoviesModel> _recommendations = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _movieDetailsFunction();
    _castFunction();
    _fetchTrailer();
    _fetchRecommendations();
  }

  void _fetchRecommendations() async {
    setState(() {
      _loading = true;
    });
    try {
      final List<MoviesModel> recommendations = await MovieRepository()
          .fetchMovieRecommendations(widget.movie.id);
      setState(() {
        _recommendations = recommendations;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _recommendations = [];
        _loading = false;
      });
      debugPrint('Error fetching recommendations: $e');
    }
  }

  void _movieDetailsFunction() async {
    try {
      final movieDetails = await MovieRepository().fetchMovieDetails(
        widget.movie.id,
      );
      setState(() {
        _movieDetails = [movieDetails];
      });
    } catch (e) {
      setState(() {
        _movieDetails = [];
      });
      debugPrint('Error _movieDetails: $e');
    }
  }

  void _castFunction() async {
    try {
      final cast = await MovieRepository().fetchCast(widget.movie.id);
      setState(() {
        _cast = List<Map<String, dynamic>>.from(cast['cast'] ?? []);
      });
    } catch (e) {
      setState(() {
        _cast = [];
      });
      debugPrint('Error _cast: $e');
    }
  }

  void _fetchTrailer() async {
    try {
      final trailerKey = await MovieRepository().fetchMovieTrailer(
        widget.movie.id,
      );
      setState(() {
        _trailerKey = trailerKey;
      });
    } catch (e) {
      debugPrint('Error fetching trailer: $e');
    }
  }

  Future<void> _openTrailer() async {
    if (_trailerKey != null) {
      final String trailerUrl = 'https://www.youtube.com/watch?v=$_trailerKey';
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

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Color(0xFFFFFFFF),
        title: Text(
          widget.movie.title.toString(),
          style: TextStyle(color: Color(0xFFFFFFFF)),
        ),
        backgroundColor: Color(0xFF1F1D2B),
        centerTitle: true,
      ),
      backgroundColor: Color(0xFF1F1D2B),
      body: Stack(
        children: [
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: posterPath,
              fit: BoxFit.fill,
              placeholder: (context, url) => Container(
                color: Colors.transparent,
                child: Icon(Icons.image, color: Colors.transparent),
              ),
              errorWidget: (context, url, error) =>
                  Icon(Icons.error, color: Colors.red),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black54, Color(0xFF1F1D2B)],
                ),
              ),
            ),
          ),
          SingleChildScrollView(
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
                          child: Icon(Icons.image, color: Colors.transparent),
                        ),
                        errorWidget: (context, url, error) =>
                            Icon(Icons.error, color: Colors.red),
                      ),
                    ),
                  )
                else
                  const SizedBox.shrink(),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InfoRow(
                      icon: Icons.calendar_month,
                      text: widget.movie.releaseDate.length >= 10
                          ? widget.movie.releaseDate.substring(0, 4)
                          : 'Unknown',
                    ),
                    SizedBox(width: 12),
                    Text('|', style: TextStyle(color: Color(0xFF92929D))),
                    SizedBox(width: 12),
                    InfoRow(
                      icon: Icons.access_time_filled_rounded,
                      text: _movieDetails.isNotEmpty
                          ? '${_movieDetails.first.runtime} minutes'
                          : 'Unknown',
                    ),
                    SizedBox(width: 12),
                    Text('|', style: TextStyle(color: Color(0xFF92929D))),
                    SizedBox(width: 12),
                    InfoRow(
                      icon: Icons.local_movies_sharp,
                      text: _movieDetails.isNotEmpty
                          ? _movieDetails.first.genresTypes
                                .map((genre) => genre['name'].toString())
                                .take(1)
                                .join(', ')
                          : 'Unknown',
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 55,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Color(0xFF252836),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 16),
                          SizedBox(width: 4),
                          Text(
                            widget.movie.voteAverage > 0
                                ? widget.movie.voteAverage.toStringAsFixed(1)
                                : 'N/A',
                            style: TextStyle(color: Colors.amber, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _trailerKey != null ? _openTrailer : null,
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(
                          _trailerKey != null ? Color(0xFF12CDD9) : Colors.grey,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.play_arrow, color: Color(0xFFFFFFFF)),
                          SizedBox(width: 8),
                          Text(
                            _trailerKey != null ? "Trailer" : "No Trailer",
                            style: TextStyle(color: Color(0xFFFFFFFF)),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _showShareModal,
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(
                          Color(0xFF252836),
                        ),
                      ),
                      child: Row(
                        children: [Icon(Icons.share, color: Color(0xFF12CDD9))],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                Text(
                  "Story Line",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFFFFFF),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  widget.movie.overview,
                  style: TextStyle(color: Color(0xFFFFFFFF)),
                ),
                SizedBox(height: 24),
                Text(
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
                        itemCount: _cast.length,
                        itemBuilder: (context, index) {
                          final castMember = _cast[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  child: ClipOval(
                                    child: CachedNetworkImage(
                                      imageUrl:
                                          castMember['profile_path'] != null
                                          ? 'https://image.tmdb.org/t/p/w200${castMember['profile_path']}'
                                          : 'https://www.themoviedb.org/assets/2/apple-touch-icon-cfba7699efe7a742de25c28e08c38525f19381d31087c69e89d6bcb8e3c0ddfa.png',
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        color: Colors.transparent,
                                        child: Icon(
                                          Icons.image,
                                          color: Colors.transparent,
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Container(
                                            color: Colors.grey[800],
                                            width: 40,
                                            height: 40,
                                            child: Icon(
                                              Icons.person,
                                              color: Colors.white,
                                            ),
                                          ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      castMember['name'] ?? 'Unknown',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFFFFFFFF),
                                      ),
                                    ),
                                    Text(
                                      castMember['character'] ?? 'Unknown',
                                      style: TextStyle(
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
                    SizedBox(height: 20),

                    movieCarousel.buildCarousel(
                      "Recommendations",
                      _recommendations,
                      _loading,
                    ),
                    SizedBox(height: 30),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
