import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'add_post_screen.dart';
import 'add_story_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';

class SocialFeed extends StatefulWidget {
  const SocialFeed({super.key});

  @override
  State<SocialFeed> createState() => _SocialFeedState();
}

class _SocialFeedState extends State<SocialFeed> {
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

  Future<void> _toggleLike(int index) async {
    setState(() {
      _likedPosts[index] = !_likedPosts[index];
    });
    await _prefs.setBool('post_liked_$index', _likedPosts[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SocialTeco',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Sección de historias
          Container(
            height: 100,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 5,
              itemBuilder: (context, index) {
                return _buildStoryAvatar(index == 0);
              },
            ),
          ),
          // Sección de posts
          Expanded(
            child: ListView.builder(
              itemCount: 2,
              itemBuilder: (context, index) {
                return _buildPost(index);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPostScreen()),
          );
        },
        backgroundColor: Colors.lightBlue,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: Colors.blue[400],
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.home, color: Colors.white),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () {},
              ),
              const SizedBox(width: 40),
              IconButton(
                icon: const Icon(Icons.favorite_border, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const FavoritesScreen()),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.person_outline, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ProfileScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStoryAvatar(bool isFirst) {
    return GestureDetector(
      onTap: isFirst
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddStoryScreen()),
              );
            }
          : null,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.lightBlue,
                  width: 2,
                ),
              ),
              child: CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey[200],
                child: isFirst
                    ? const Icon(Icons.add, size: 30, color: Colors.black54)
                    : null,
              ),
            ),
            const SizedBox(height: 4),
            const Text('', style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildPost(int index) {
    if (_likedPosts.isEmpty) {
      return const SizedBox(); // Retorna un widget vacío mientras se cargan los datos
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
            trailing: IconButton(
              icon: const Icon(Icons.more_horiz),
              onPressed: () {},
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 12,
              width: double.infinity,
              color: Colors.grey[200],
            ),
          ),
          const SizedBox(height: 8),
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
                IconButton(
                  icon: Icon(
                    _likedPosts[index] ? Icons.favorite : Icons.favorite_border,
                    color: _likedPosts[index] ? Colors.red : null,
                  ),
                  onPressed: () => _toggleLike(index),
                ),
                const SizedBox(width: 8),
                Text(_likedPosts[index] ? '1 others' : '0 others',
                    style: TextStyle(color: Colors.grey[600])),
                const Spacer(),
                const Icon(Icons.comment_outlined),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
