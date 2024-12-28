import 'package:flutter/material.dart';
import '../models/social_models.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:flutter/services.dart';

class SocialFeedWidgets {
  static Widget buildNavItem(
    IconData icon,
    String label,
    bool isSelected, {
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.black87,
          size: 26,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        hoverColor: Colors.grey[200],
        onTap: onTap,
      ),
    );
  }

  static Widget buildActionButton(
      IconData icon, String count, VoidCallback onTap,
      {Color? color}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: color ?? Colors.grey.shade600,
              ),
              if (count.isNotEmpty) ...[
                const SizedBox(width: 4),
                Text(
                  count,
                  style: TextStyle(
                    color: color ?? Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static Widget buildStoryItem(String userName, String imageUrl, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF1D9BF0),
                width: 2,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: CircleAvatar(
                backgroundImage: NetworkImage(imageUrl),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.more_horiz,
              color: Colors.grey[700],
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  static Widget buildCommentCard(
    String postId,
    Comment comment,
    String currentUserId,
    Function(String, String) handleLikeComment,
    Function(String, String, String) handleReplyComment,
    BuildContext context,
  ) {
    final bool isLiked = comment.likedBy.contains(currentUserId);

    Widget buildReplyCard(Comment reply, {bool isNested = false}) {
      return Container(
        margin: EdgeInsets.only(
          left: isNested ? 48 : 24,
          top: 8,
        ),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isNested ? Colors.grey[50] : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundImage: NetworkImage(reply.userAvatar),
                ),
                const SizedBox(width: 8),
                Text(
                  reply.userName,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              reply.text,
              style: const TextStyle(color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                buildActionButton(
                  Icons.favorite,
                  reply.likedBy.length.toString(),
                  () => handleLikeComment(postId, reply.id),
                  color: reply.likedBy.contains(currentUserId)
                      ? Colors.red
                      : Colors.grey[700],
                ),
                const SizedBox(width: 16),
                buildActionButton(
                  Icons.reply,
                  '0',
                  () {
                    SocialFeedWidgets.showCommentModal(
                      context,
                      postId,
                      (postId, text) =>
                          handleReplyComment(postId, reply.id, text),
                      replyToName: reply.userName,
                      commentId: reply.id,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(comment.userAvatar),
              ),
              const SizedBox(width: 8),
              Text(
                comment.userName,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            comment.text,
            style: const TextStyle(color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              buildActionButton(
                Icons.favorite,
                comment.likedBy.length.toString(),
                () => handleLikeComment(postId, comment.id),
                color: isLiked ? Colors.red : Colors.grey[700],
              ),
              const SizedBox(width: 16),
              buildActionButton(
                Icons.reply,
                comment.replies.length.toString(),
                () {
                  SocialFeedWidgets.showCommentModal(
                    context,
                    postId,
                    (postId, text) =>
                        handleReplyComment(postId, comment.id, text),
                    replyToName: comment.userName,
                    commentId: comment.id,
                  );
                },
              ),
            ],
          ),
          if (comment.replies.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...comment.replies.map((reply) => buildReplyCard(reply)),
          ],
        ],
      ),
    );
  }

  static Widget buildSearchBar() {
    final TextEditingController searchController = TextEditingController();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.grey[700]),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: searchController,
              style: const TextStyle(color: Colors.black87),
              decoration: InputDecoration(
                hintText: 'Buscar',
                hintStyle: TextStyle(color: Colors.grey[700]),
                border: InputBorder.none,
              ),
              onChanged: (value) {
                print('Buscando: $value');
              },
            ),
          ),
          if (searchController.text.isNotEmpty)
            IconButton(
              icon: Icon(Icons.close, color: Colors.grey[700]),
              onPressed: () {
                searchController.clear();
              },
            ),
        ],
      ),
    );
  }

  static void showCreatePostModal(
    BuildContext context,
    TextEditingController postController,
    String? selectedImageUrl,
    Function(String, String?) onCreatePost,
  ) {
    String? tempImageUrl = selectedImageUrl;
    File? selectedFile;

    void submitPost() {
      if (postController.text.trim().isNotEmpty) {
        onCreatePost(postController.text, tempImageUrl);
        Navigator.pop(context);
      }
    }

    Future<void> pickImage() async {
      try {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: false,
        );

        if (result != null) {
          selectedFile = File(result.files.single.path!);
          tempImageUrl = 'https://via.placeholder.com/500x300';
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar la imagen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 10,
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.grey[700]),
                      onPressed: () => Navigator.pop(context),
                    ),
                    ElevatedButton(
                      onPressed: submitPost,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1D9BF0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('Publicar'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage:
                          NetworkImage('https://via.placeholder.com/150'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: RawKeyboardListener(
                        focusNode: FocusNode(),
                        onKey: (event) {
                          if (event.isKeyPressed(LogicalKeyboardKey.enter) &&
                              !event.isShiftPressed) {
                            submitPost();
                          }
                        },
                        child: TextField(
                          controller: postController,
                          autofocus: true,
                          style: const TextStyle(color: Colors.black87),
                          decoration: InputDecoration(
                            hintText: '¿Qué está pasando?',
                            hintStyle: TextStyle(color: Colors.grey[700]),
                            border: InputBorder.none,
                          ),
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                        ),
                      ),
                    ),
                  ],
                ),
                if (selectedFile != null || tempImageUrl != null) ...[
                  const SizedBox(height: 16),
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: selectedFile != null
                            ? Image.file(
                                selectedFile!,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              )
                            : Image.network(
                                tempImageUrl!,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () => setState(() {
                            selectedFile = null;
                            tempImageUrl = null;
                          }),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.image, color: Color(0xFF1D9BF0)),
                      onPressed: () async {
                        await pickImage().then((_) => setState(() {}));
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.gif_box, color: Color(0xFF1D9BF0)),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon:
                          const Icon(Icons.list_alt, color: Color(0xFF1D9BF0)),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.emoji_emotions_outlined,
                          color: Color(0xFF1D9BF0)),
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void showCommentModal(
    BuildContext context,
    String postId,
    Function(String, String) handleComment, {
    String? replyToName,
    String? commentId,
    Function(String, String, String)? handleReplyComment,
  }) {
    final TextEditingController commentController = TextEditingController();
    final FocusNode focusNode = FocusNode();

    void submitComment() {
      final text = commentController.text.trim();
      if (text.isNotEmpty) {
        if (replyToName != null &&
            commentId != null &&
            handleReplyComment != null) {
          handleReplyComment(postId, commentId, text);
        } else {
          handleComment(postId, text);
        }
        Navigator.pop(context);
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage:
                        NetworkImage('https://via.placeholder.com/150'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: commentController,
                      focusNode: focusNode,
                      style: const TextStyle(color: Colors.black87),
                      decoration: InputDecoration(
                        hintText: replyToName != null
                            ? 'Responder a $replyToName...'
                            : 'Escribe un comentario...',
                        hintStyle: TextStyle(color: Colors.grey[700]),
                        border: InputBorder.none,
                      ),
                      maxLines: 3,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => submitComment(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.image, color: Color(0xFF1D9BF0)),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.emoji_emotions_outlined,
                            color: Color(0xFF1D9BF0)),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: submitComment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1D9BF0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(replyToName != null ? 'Responder' : 'Comentar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    focusNode.requestFocus();
  }
}
