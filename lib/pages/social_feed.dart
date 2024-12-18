import 'package:flutter/material.dart';

class SocialFeed extends StatelessWidget {
  const SocialFeed({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Social Feed'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const Center(
        child: Text('Social Feed Coming Soon'),
      ),
    );
  }
} 