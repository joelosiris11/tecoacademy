import 'package:flutter/material.dart';
import '../models/social_models.dart';
import '../widgets/social_feed_widgets.dart';
import '../pages/messages_page.dart';

class SocialFeed extends StatefulWidget {
  final String userId;

  const SocialFeed({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<SocialFeed> createState() => _SocialFeedState();
}

class _SocialFeedState extends State<SocialFeed> {
  List<Post> _posts = [];
  late final String _currentUserId;
  final TextEditingController _newPostController = TextEditingController();
  String? _selectedImageUrl;

  @override
  void dispose() {
    _newPostController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _currentUserId = widget.userId;
    _loadPosts();
  }

  // Métodos de datos
  Future<void> _loadPosts() async {
    // Simulación de carga desde Firebase
    setState(() {
      _posts = [
        Post(
          id: 'post1',
          userId: 'user_1',
          userName: 'María García',
          userAvatar: 'https://via.placeholder.com/150',
          description: '¡Acabo de terminar mi primer proyecto en Flutter! 🚀',
          imageUrl: 'https://via.placeholder.com/500',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          likedBy: ['user_2', 'user_3'],
          category: 'desarrollo',
          comments: [
            Comment(
              id: 'comment1',
              userId: 'user_2',
              userName: 'Juan Pérez',
              userAvatar: 'https://via.placeholder.com/150',
              text: '¡Increíble trabajo! 👏',
              timestamp: DateTime.now().subtract(const Duration(hours: 1)),
              likedBy: ['user_1'],
              replies: [
                Comment(
                  id: 'reply1',
                  userId: 'user_1',
                  userName: 'María García',
                  userAvatar: 'https://via.placeholder.com/150',
                  text: '¡Gracias Juan! 😊',
                  timestamp:
                      DateTime.now().subtract(const Duration(minutes: 30)),
                ),
              ],
            ),
          ],
        ),
      ];
    });
  }

  void _createNewPost(String text, String? imageUrl) {
    final newPost = Post(
      id: 'post_${DateTime.now().millisecondsSinceEpoch}',
      userId: _currentUserId,
      userName: 'Usuario Actual',
      userAvatar: 'https://via.placeholder.com/150',
      description: text,
      imageUrl: imageUrl ?? '',
      timestamp: DateTime.now(),
      likedBy: [],
      comments: [],
      category: 'general',
    );

    setState(() {
      _posts.insert(0, newPost);
    });
  }

  // Métodos de acción
  void _handleComment(String postId, String commentText) {
    if (commentText.trim().isEmpty) return;

    setState(() {
      final postIndex = _posts.indexWhere((p) => p.id == postId);
      if (postIndex != -1) {
        final post = _posts[postIndex];
        final comments = List<Comment>.from(post.comments);

        comments.add(Comment(
          id: 'comment_${DateTime.now().millisecondsSinceEpoch}',
          userId: _currentUserId,
          userName: 'Usuario Actual',
          userAvatar: 'https://via.placeholder.com/150',
          text: commentText,
          timestamp: DateTime.now(),
        ));

        _posts[postIndex] = Post(
          id: post.id,
          userId: post.userId,
          userName: post.userName,
          userAvatar: post.userAvatar,
          description: post.description,
          imageUrl: post.imageUrl,
          timestamp: post.timestamp,
          likedBy: post.likedBy,
          comments: comments,
          category: post.category,
        );
      }
    });
  }

  void _handleShare(String postId) {
    // TODO: Implementar compartir post
  }

  void _handleLike(String postId) {
    setState(() {
      final postIndex = _posts.indexWhere((p) => p.id == postId);
      if (postIndex != -1) {
        final post = _posts[postIndex];
        final likedBy = List<String>.from(post.likedBy);

        if (likedBy.contains(_currentUserId)) {
          likedBy.remove(_currentUserId);
        } else {
          likedBy.add(_currentUserId);
        }

        _posts[postIndex] = Post(
          id: post.id,
          userId: post.userId,
          userName: post.userName,
          userAvatar: post.userAvatar,
          description: post.description,
          imageUrl: post.imageUrl,
          timestamp: post.timestamp,
          likedBy: likedBy,
          comments: post.comments,
          category: post.category,
        );
      }
    });
  }

  void _handleLikeComment(String postId, String commentId) {
    setState(() {
      final postIndex = _posts.indexWhere((p) => p.id == postId);
      if (postIndex != -1) {
        final post = _posts[postIndex];
        final comments = List<Comment>.from(post.comments);

        for (var i = 0; i < comments.length; i++) {
          if (comments[i].id == commentId) {
            final comment = comments[i];
            final likedBy = List<String>.from(comment.likedBy);

            if (likedBy.contains(_currentUserId)) {
              likedBy.remove(_currentUserId);
            } else {
              likedBy.add(_currentUserId);
            }

            comments[i] = Comment(
              id: comment.id,
              userId: comment.userId,
              userName: comment.userName,
              userAvatar: comment.userAvatar,
              text: comment.text,
              timestamp: comment.timestamp,
              likedBy: likedBy,
              replies: comment.replies,
            );
            break;
          }
        }

        _posts[postIndex] = Post(
          id: post.id,
          userId: post.userId,
          userName: post.userName,
          userAvatar: post.userAvatar,
          description: post.description,
          imageUrl: post.imageUrl,
          timestamp: post.timestamp,
          likedBy: post.likedBy,
          comments: comments,
          category: post.category,
        );
      }
    });
  }

  void _handleReplyComment(String postId, String commentId, String replyText) {
    if (replyText.trim().isEmpty) return;

    setState(() {
      final postIndex = _posts.indexWhere((p) => p.id == postId);
      if (postIndex != -1) {
        final post = _posts[postIndex];
        final comments = List<Comment>.from(post.comments);

        for (var i = 0; i < comments.length; i++) {
          if (comments[i].id == commentId) {
            final comment = comments[i];
            final replies = List<Comment>.from(comment.replies);

            replies.add(Comment(
              id: 'reply_${DateTime.now().millisecondsSinceEpoch}',
              userId: _currentUserId,
              userName: 'Usuario Actual',
              userAvatar: 'https://via.placeholder.com/150',
              text: replyText,
              timestamp: DateTime.now(),
            ));

            comments[i] = Comment(
              id: comment.id,
              userId: comment.userId,
              userName: comment.userName,
              userAvatar: comment.userAvatar,
              text: comment.text,
              timestamp: comment.timestamp,
              likedBy: comment.likedBy,
              replies: replies,
            );
            break;
          }
        }

        _posts[postIndex] = Post(
          id: post.id,
          userId: post.userId,
          userName: post.userName,
          userAvatar: post.userAvatar,
          description: post.description,
          imageUrl: post.imageUrl,
          timestamp: post.timestamp,
          likedBy: post.likedBy,
          comments: comments,
          category: post.category,
        );
      }
    });
  }

  // Métodos de UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          _buildSideMenu(),
          _buildMainContent(),
          _buildTrendingSection(),
        ],
      ),
    );
  }

  Widget _buildSideMenu() {
    return Container(
      width: 275,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(
            color: Colors.grey[300]!,
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(12.0),
            child: Icon(
              Icons.school,
              color: Colors.black87,
              size: 32,
            ),
          ),
          Column(
            children: [
              SocialFeedWidgets.buildNavItem(Icons.home, 'Inicio', true),
              SocialFeedWidgets.buildNavItem(Icons.explore, 'Explorar', false),
              SocialFeedWidgets.buildNavItem(
                  Icons.notifications_outlined, 'Notificaciones', false),
              SocialFeedWidgets.buildNavItem(
                Icons.mail_outline,
                'Mensajes',
                false,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MessagesPage()),
                ),
              ),
              SocialFeedWidgets.buildNavItem(
                  Icons.bookmark_border, 'Guardados', false),
              SocialFeedWidgets.buildNavItem(Icons.list_alt, 'Listas', false),
              SocialFeedWidgets.buildNavItem(
                  Icons.person_outline, 'Perfil', false),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              SocialFeedWidgets.showCreatePostModal(
                context,
                _newPostController,
                _selectedImageUrl,
                _createNewPost,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1D9BF0),
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
              ),
            ),
            child: const Text(
              'Publicar',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey[300]!,
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              children: [
                Text(
                  'Inicio',
                  style: TextStyle(
                    color: Colors.grey[900],
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.auto_awesome, color: Colors.grey[900]),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _posts.length,
              itemBuilder: (context, index) {
                final post = _posts[index];
                return Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey[200]!,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    border: Border.all(color: Colors.grey[100]!),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(post.userAvatar),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  post.userName,
                                  style: TextStyle(
                                    color: Colors.grey[900],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '@${post.userId}',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          post.description,
                          style: TextStyle(color: Colors.grey[800]),
                        ),
                        if (post.imageUrl.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(post.imageUrl),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SocialFeedWidgets.buildActionButton(
                              Icons.chat_bubble_outline,
                              post.comments.length.toString(),
                              () {
                                SocialFeedWidgets.showCommentModal(
                                  context,
                                  post.id,
                                  _handleComment,
                                );
                              },
                            ),
                            SocialFeedWidgets.buildActionButton(
                              Icons.repeat,
                              '0',
                              () => _handleShare(post.id),
                            ),
                            SocialFeedWidgets.buildActionButton(
                              post.likedBy.contains(_currentUserId)
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              post.likedBy.length.toString(),
                              () => _handleLike(post.id),
                              color: post.likedBy.contains(_currentUserId)
                                  ? Colors.red
                                  : null,
                            ),
                            SocialFeedWidgets.buildActionButton(
                              Icons.share_outlined,
                              '',
                              () => _handleShare(post.id),
                            ),
                          ],
                        ),
                        if (post.comments.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          ...post.comments.map(
                            (comment) => SocialFeedWidgets.buildCommentCard(
                              post.id,
                              comment,
                              _currentUserId,
                              _handleLikeComment,
                              _handleReplyComment,
                              context,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingSection() {
    return Container(
      width: 350,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          left: BorderSide(
            color: Colors.grey[300]!,
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        children: [
          SocialFeedWidgets.buildSearchBar(),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey[200]!,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(color: Colors.grey[100]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Historias',
                  style: TextStyle(
                    color: Colors.grey[900],
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SocialFeedWidgets.buildStoryItem(
                  'María García',
                  'https://via.placeholder.com/150',
                  'Hace 5m',
                ),
                SocialFeedWidgets.buildStoryItem(
                  'Juan Pérez',
                  'https://via.placeholder.com/150',
                  'Hace 15m',
                ),
                SocialFeedWidgets.buildStoryItem(
                  'Ana López',
                  'https://via.placeholder.com/150',
                  'Hace 30m',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
