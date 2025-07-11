import 'package:flutter/material.dart';
import 'package:movie_database/app/data/models/movies_model.dart';
import 'package:movie_database/app/data/repositories/movie_repository.dart';
import 'package:movie_database/app/screens/movie/movie_details.screen.dart';
import 'package:movie_database/app/widgets/movie_card/movie_card.dart';
import 'package:movie_database/app/widgets/search_bar/search_bar.dart';

class SearchScreen extends StatefulWidget {
  final String initialQuery;

  const SearchScreen({super.key, required this.initialQuery});

  @override
  // ignore: library_private_types_in_public_api
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  List<MoviesModel> _movies = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.initialQuery;
    if (widget.initialQuery.isNotEmpty) {
      _search();
    }
  }

  void _search() async {
    setState(() => _loading = true);

    try {
      final movies = await MovieRepository().searchMovie(_controller.text);

      setState(() {
        _movies = movies
          ..sort((a, b) {
            final yearComparison = b.releaseDate.compareTo(a.releaseDate);
            if (yearComparison != 0) {
              return yearComparison;
            }
            return a.title.compareTo(b.title);
          });
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _movies = [];
        _loading = false;
      });
      debugPrint('Search error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Color(0xFFFFFFFF),
        title: Text(
          'Search Results',
          style: TextStyle(color: Color(0xFFFFFFFF)),
        ),
        backgroundColor: Color(0xFF1F1D2B),
      ),
      backgroundColor: Color(0xFF1F1D2B),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
        child: Column(
          children: [
            SearchBarWidget(controller: _controller, onSearch: _search),
            SizedBox(height: 20),
            _loading
                ? Expanded(child: Center(child: CircularProgressIndicator()))
                : Expanded(
                    child: _movies.isEmpty
                        ? Center(
                            child: Text(
                              'No results found.',
                              style: TextStyle(color: Color(0xFF92929D)),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _movies.length,
                            itemBuilder: (context, index) {
                              final movie = _movies[index];
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
  }
}
