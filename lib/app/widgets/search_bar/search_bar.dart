import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSearch;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        prefixIconColor: Color(0xFF92929D),
        hintText: "Spider Man",
        prefixIcon: Icon(Icons.local_movies_sharp, color: Color(0xFF92929D)),
        suffixIcon: IconButton(
          icon: Icon(Icons.search),
          onPressed: onSearch,
          color: Color(0xFF92929D),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
        filled: true,
        fillColor: Color(0xFF252836),
      ),
      style: TextStyle(color: Color(0xFFFFFFFF)),
    );
  }
}
