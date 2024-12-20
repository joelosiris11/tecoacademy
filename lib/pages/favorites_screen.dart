import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<bool> _likedPosts = [];
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _loadLikedPosts();
  }

  Future<void> _loadLikedPosts() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _likedPosts = List.generate(
          2, (index) => _prefs.getBool('post_liked_$index') ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Favoritos',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _likedPosts.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _likedPosts.length,
              itemBuilder: (context, index) {
                if (!_likedPosts[index]) return const SizedBox.shrink();
                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  elevation: 0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey[200],
                        ),
                        title: Container(
                          height: 14,
                          width: 100,
                          color: Colors.grey[200],
                        ),
                        subtitle: Container(
                          height: 10,
                          width: 50,
                          margin: const EdgeInsets.only(top: 4),
                          color: Colors.grey[200],
                        ),
                      ),
                      Container(
                        height: 200,
                        width: double.infinity,
                        color: Colors.grey[100],
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Icon(Icons.favorite, color: Colors.red),
                            const SizedBox(width: 8),
                            Text('Te gusta esta publicación',
                                style: TextStyle(color: Colors.grey[600])),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
