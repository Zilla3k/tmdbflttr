import 'package:flutter/material.dart';
import 'package:movie_database/app/screens/movie/movie_details.screen.dart';
import 'package:movie_database/app/widgets/movie_card/movie_card.dart';
import 'package:movie_database/app/widgets/search_bar/search_bar.dart';
import 'package:provider/provider.dart';
import '../../providers/search_provider/search_provider.dart';

class SearchScreen extends StatefulWidget {
  final String initialQuery;

  const SearchScreen({super.key, required this.initialQuery});

  @override
  SearchScreenState createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
    if (widget.initialQuery.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<SearchProvider>(
          context,
          listen: false,
        ).search(widget.initialQuery);
      });
    }
  }

  void _onSearch() {
    final query = _controller.text.trim();
    if (query.isNotEmpty) {
      Provider.of<SearchProvider>(context, listen: false).search(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            foregroundColor: const Color(0xFFFFFFFF),
            title: const Text(
              'Search Results',
              style: TextStyle(color: Color(0xFFFFFFFF)),
            ),
            backgroundColor: const Color(0xFF1F1D2B),
          ),
          backgroundColor: const Color(0xFF1F1D2B),
          body: Padding(
            padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
            child: Column(
              children: [
                SearchBarWidget(controller: _controller, onSearch: _onSearch),
                const SizedBox(height: 20),
                provider.loading
                    ? const CircularProgressIndicator()
                    : Expanded(
                        child: provider.movies.isEmpty
                            ? Center(
                                child: Text(
                                  'No results found.',
                                  style: TextStyle(color: Color(0xFF92929D)),
                                ),
                              )
                            : ListView.builder(
                                itemCount: provider.movies.length,
                                itemBuilder: (context, index) {
                                  final movie = provider.movies[index];
                                  return MovieCard(
                                    movie: movie,
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            MovieDetailScreen(movie: movie),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
              ],
            ),
          ),
        );
      },
    );
  }
}
