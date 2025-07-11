import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:movie_database/app/data/models/movies_model.dart';
import 'package:movie_database/app/data/repositories/movie_repository.dart';
import 'package:movie_database/app/screens/movie/movie_details.screen.dart';
import 'package:movie_database/app/screens/search/search_screen.dart';
import 'package:movie_database/app/widgets/movie_carousel/movie_carousel.dart';
import 'package:movie_database/app/widgets/search_bar/search_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  final MovieCarousel movieCarousel = MovieCarousel();
  List<MoviesModel> _trending = [];
  List<MoviesModel> _popular = [];
  List<MoviesModel> _topRated = [];
  List<MoviesModel> _upcoming = [];

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchAllData();
  }

  void _search() {
    _controller.text.trim().isEmpty
        ? Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SearchScreen(initialQuery: "Spider Man"),
            ),
          )
        : Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SearchScreen(initialQuery: _controller.text),
            ),
          );
  }

  Future<void> _fetchAllData() async {
    try {
      setState(() => _loading = true);
      final results = await Future.wait([
        MovieRepository().fetchTrending(),
        MovieRepository().fetchPopular(),
        MovieRepository().fetchTopRated(),
        MovieRepository().fetchUpcoming(),
      ]);

      setState(() {
        _trending = results[0];
        _popular = results[1];
        _topRated = results[2];
        _upcoming = results[3];
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      debugPrint('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Color(0xFF1F1D2B),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(10, 60, 10, 0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SearchBarWidget(controller: _controller, onSearch: _search),
              SizedBox(height: 20),
              _loading
                  ? CircularProgressIndicator()
                  : Column(
                      children: [
                        Column(
                          children: [
                            CarouselSlider.builder(
                              itemCount: _trending.length,
                              itemBuilder: (context, index, realIndex) {
                                final movie = _trending[index];
                                final imageUrl =
                                    'https://image.tmdb.org/t/p/original${movie.backdropPath}';
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            MovieDetailScreen(movie: movie),
                                      ),
                                    );
                                  },
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: CachedNetworkImage(
                                          imageUrl: imageUrl,
                                          width: screenWidth * .8,
                                          placeholder: (context, url) =>
                                              Container(
                                                color: Colors.transparent,
                                                child: Icon(
                                                  Icons.image,
                                                  color: Colors.transparent,
                                                ),
                                              ),
                                          errorWidget: (context, url, error) =>
                                              Icon(
                                                Icons.error,
                                                color: Colors.red,
                                              ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: screenHeight / 12,
                                        left: 16,
                                        child: Container(
                                          padding: EdgeInsets.all(8),
                                          child: Text(
                                            _wrapText(movie.title, 26),
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: screenHeight / 15,
                                        left: 16,
                                        child: Container(
                                          padding: EdgeInsets.all(8),
                                          child: Text(
                                            movie.releaseDate.substring(0, 4),
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              options: CarouselOptions(
                                enlargeCenterPage: true,
                                autoPlay: true,
                                autoPlayInterval: Duration(seconds: 5),
                                autoPlayAnimationDuration: Duration(seconds: 2),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
              movieCarousel.buildCarousel("Most Popular", _popular, _loading),
              SizedBox(height: 20),
              movieCarousel.buildCarousel("Top Rated", _topRated, _loading),
              SizedBox(height: 20),
              movieCarousel.buildCarousel("Upcoming", _upcoming, _loading),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<MoviesModel>> fetchMovies(String category) {
    switch (category) {
      case "Popular":
        return MovieRepository().fetchPopular();
      case "TopRated":
        return MovieRepository().fetchTopRated();
      case "Upcoming":
        return MovieRepository().fetchUpcoming();
      default:
        throw Exception("Invalid category");
    }
  }

  Widget buildMovieSection(String category) {
    return FutureBuilder<List<MoviesModel>>(
      future: fetchMovies(category),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text("Error loading $category");
        } else if (snapshot.hasData) {
          return movieCarousel.buildCarousel(category, snapshot.data!, false);
        } else {
          return Text("No movies found");
        }
      },
    );
  }
}

String _wrapText(String title, int i) {
  if (title.length <= i) {
    return title;
  }
  return '${title.substring(0, i)}...';
}
