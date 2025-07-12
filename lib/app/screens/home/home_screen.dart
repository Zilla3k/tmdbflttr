import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../providers/home_provider/home_provider.dart';
import '../movie/movie_details.screen.dart';
import '../search/search_screen.dart';
import '../../widgets/movie_carousel/movie_carousel.dart';
import '../../widgets/search_bar/search_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  final MovieCarousel movieCarousel = MovieCarousel();

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

  String _wrapText(String title, int i) {
    if (title.length <= i) {
      return title;
    }
    return '${title.substring(0, i)}...';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final provider = Provider.of<HomeProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF1F1D2B),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(10, 60, 10, 0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SearchBarWidget(controller: _controller, onSearch: _search),
              const SizedBox(height: 20),
              provider.loading
                  ? const CircularProgressIndicator()
                  : Column(
                      children: [
                        CarouselSlider.builder(
                          itemCount: provider.trending.length,
                          itemBuilder: (context, index, realIndex) {
                            final movie = provider.trending[index];
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
                                  Positioned(
                                    bottom: screenHeight / 12,
                                    left: 16,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      child: Text(
                                        _wrapText(movie.title, 26),
                                        style: const TextStyle(
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
                                      padding: const EdgeInsets.all(8),
                                      child: Text(
                                        movie.releaseDate.substring(0, 4),
                                        style: const TextStyle(
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
                            autoPlayInterval: const Duration(seconds: 5),
                            autoPlayAnimationDuration: const Duration(
                              seconds: 2,
                            ),
                          ),
                        ),
                        movieCarousel.buildCarousel(
                          "Most Popular",
                          provider.popular,
                          provider.loading,
                        ),
                        const SizedBox(height: 20),
                        movieCarousel.buildCarousel(
                          "Top Rated",
                          provider.topRated,
                          provider.loading,
                        ),
                        const SizedBox(height: 20),
                        movieCarousel.buildCarousel(
                          "Upcoming",
                          provider.upcoming,
                          provider.loading,
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
