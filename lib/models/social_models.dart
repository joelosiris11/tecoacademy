class Post {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final String description;
  final String imageUrl;
  final DateTime timestamp;
  final List<String> likedBy;
  final List<Comment> comments;
  final String category;
  final Map<String, dynamic> metadata;

  Post({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.description,
    required this.imageUrl,
    required this.timestamp,
    required this.likedBy,
    required this.comments,
    required this.category,
    this.metadata = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'description': description,
      'imageUrl': imageUrl,
      'timestamp': timestamp.toIso8601String(),
      'likedBy': likedBy,
      'category': category,
      'metadata': metadata,
    };
  }

  factory Post.fromMap(String id, Map<String, dynamic> map) {
    return Post(
      id: id,
      userId: map['userId'],
      userName: map['userName'],
      userAvatar: map['userAvatar'],
      description: map['description'],
      imageUrl: map['imageUrl'],
      timestamp: DateTime.parse(map['timestamp']),
      likedBy: List<String>.from(map['likedBy'] ?? []),
      comments: (map['comments'] as List<dynamic>? ?? [])
          .map((c) => Comment.fromMap(c as Map<String, dynamic>))
          .toList(),
      category: map['category'],
      metadata: map['metadata'] ?? {},
    );
  }
}

class Comment {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final String text;
  final DateTime timestamp;
  final List<String> likedBy;
  final List<Comment> replies;

  Comment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.text,
    required this.timestamp,
    this.likedBy = const [],
    this.replies = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'likedBy': likedBy,
      'replies': replies.map((r) => r.toMap()).toList(),
    };
  }

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'],
      userId: map['userId'],
      userName: map['userName'],
      userAvatar: map['userAvatar'],
      text: map['text'],
      timestamp: DateTime.parse(map['timestamp']),
      likedBy: List<String>.from(map['likedBy'] ?? []),
      replies: (map['replies'] as List<dynamic>? ?? [])
          .map((r) => Comment.fromMap(r as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Message {
  final String id;
  final String senderId;
  final String receiverId;
  final String senderName;
  final String senderAvatar;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final String? imageUrl;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.senderName,
    required this.senderAvatar,
    required this.content,
    required this.timestamp,
    this.isRead = false,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'senderName': senderName,
      'senderAvatar': senderAvatar,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'imageUrl': imageUrl,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'],
      senderId: map['senderId'],
      receiverId: map['receiverId'],
      senderName: map['senderName'],
      senderAvatar: map['senderAvatar'],
      content: map['content'],
      timestamp: DateTime.parse(map['timestamp']),
      isRead: map['isRead'] ?? false,
      imageUrl: map['imageUrl'],
    );
  }
}

class Chat {
  final String id;
  final List<String> participants;
  final Message lastMessage;
  final bool isGroup;
  final String? groupName;
  final String? groupAvatar;

  Chat({
    required this.id,
    required this.participants,
    required this.lastMessage,
    this.isGroup = false,
    this.groupName,
    this.groupAvatar,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'participants': participants,
      'lastMessage': lastMessage.toMap(),
      'isGroup': isGroup,
      'groupName': groupName,
      'groupAvatar': groupAvatar,
    };
  }

  factory Chat.fromMap(Map<String, dynamic> map) {
    return Chat(
      id: map['id'],
      participants: List<String>.from(map['participants']),
      lastMessage: Message.fromMap(map['lastMessage']),
      isGroup: map['isGroup'] ?? false,
      groupName: map['groupName'],
      groupAvatar: map['groupAvatar'],
    );
  }
}
