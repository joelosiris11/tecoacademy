import 'package:flutter/material.dart';
import '../models/social_models.dart';

// Clase utilitaria para funciones comunes
class MessageUtils {
  static String getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'ahora';
    }
  }
}

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final List<Chat> _chats = [
    Chat(
      id: 'chat1',
      participants: ['user_123', 'user_456'],
      lastMessage: Message(
        id: 'msg1',
        senderId: 'user_456',
        receiverId: 'user_123',
        senderName: 'María García',
        senderAvatar: 'https://via.placeholder.com/150',
        content: '¡Hola! ¿Cómo vas con el proyecto?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        isRead: false,
      ),
    ),
    Chat(
      id: 'chat2',
      participants: ['user_123', 'user_789'],
      lastMessage: Message(
        id: 'msg2',
        senderId: 'user_123',
        receiverId: 'user_789',
        senderName: 'Juan Pérez',
        senderAvatar: 'https://via.placeholder.com/150',
        content: 'Gracias por la ayuda con el código',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        isRead: true,
      ),
    ),
    Chat(
      id: 'chat3',
      participants: ['user_123', 'user_101', 'user_102'],
      lastMessage: Message(
        id: 'msg3',
        senderId: 'user_101',
        receiverId: 'user_123',
        senderName: 'Ana López',
        senderAvatar: 'https://via.placeholder.com/150',
        content: '¿Nos vemos en la clase de mañana?',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: true,
      ),
      isGroup: true,
      groupName: 'Grupo de Flutter',
      groupAvatar: 'https://via.placeholder.com/150',
    ),
  ];

  void _openChat(BuildContext context, Chat chat) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatDetailPage(chat: chat),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF15202B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF15202B),
        elevation: 0,
        title: const Text(
          'Mensajes',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_square, color: Colors.white),
            onPressed: () {
              // TODO: Implementar nuevo mensaje
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Buscar en mensajes',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF253341),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _chats.length,
              itemBuilder: (context, index) {
                final chat = _chats[index];
                return InkWell(
                  onTap: () => _openChat(context, chat),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Color(0xFF38444D),
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundImage: NetworkImage(
                                chat.isGroup
                                    ? chat.groupAvatar!
                                    : chat.lastMessage.senderAvatar,
                              ),
                            ),
                            if (!chat.lastMessage.isRead)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF1D9BF0),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                chat.isGroup
                                    ? chat.groupName!
                                    : chat.lastMessage.senderName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                chat.lastMessage.content,
                                style: TextStyle(
                                  color: chat.lastMessage.isRead
                                      ? Colors.grey
                                      : Colors.white,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              MessageUtils.getTimeAgo(
                                  chat.lastMessage.timestamp),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (!chat.lastMessage.isRead)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1D9BF0),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  'Nuevo',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implementar nuevo mensaje
        },
        backgroundColor: const Color(0xFF1D9BF0),
        child: const Icon(Icons.message),
      ),
    );
  }
}

class ChatDetailPage extends StatefulWidget {
  final Chat chat;

  const ChatDetailPage({super.key, required this.chat});

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<Message> _messages = [];
  final String _currentUserId = 'user_123';

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  void _loadMessages() {
    // Simulación de mensajes
    setState(() {
      _messages.addAll([
        Message(
          id: 'msg1',
          senderId: widget.chat.lastMessage.senderId,
          receiverId: _currentUserId,
          senderName: widget.chat.lastMessage.senderName,
          senderAvatar: widget.chat.lastMessage.senderAvatar,
          content: '¡Hola! ¿Cómo estás?',
          timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
          isRead: true,
        ),
        Message(
          id: 'msg2',
          senderId: _currentUserId,
          receiverId: widget.chat.lastMessage.senderId,
          senderName: 'Tú',
          senderAvatar: 'https://via.placeholder.com/150',
          content: '¡Hola! Todo bien, ¿y tú?',
          timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
          isRead: true,
        ),
        Message(
          id: 'msg3',
          senderId: widget.chat.lastMessage.senderId,
          receiverId: _currentUserId,
          senderName: widget.chat.lastMessage.senderName,
          senderAvatar: widget.chat.lastMessage.senderAvatar,
          content: widget.chat.lastMessage.content,
          timestamp: widget.chat.lastMessage.timestamp,
          isRead: false,
        ),
      ]);
    });
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add(
        Message(
          id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
          senderId: _currentUserId,
          receiverId: widget.chat.lastMessage.senderId,
          senderName: 'Tú',
          senderAvatar: 'https://via.placeholder.com/150',
          content: _messageController.text,
          timestamp: DateTime.now(),
          isRead: false,
        ),
      );
    });

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF15202B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF15202B),
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(
                widget.chat.isGroup
                    ? widget.chat.groupAvatar!
                    : widget.chat.lastMessage.senderAvatar,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              widget.chat.isGroup
                  ? widget.chat.groupName!
                  : widget.chat.lastMessage.senderName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.video_call, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[_messages.length - 1 - index];
                final bool isMe = message.senderId == _currentUserId;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    mainAxisAlignment:
                        isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isMe) ...[
                        CircleAvatar(
                          radius: 16,
                          backgroundImage: NetworkImage(message.senderAvatar),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.6,
                        ),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isMe
                              ? const Color(0xFF1D9BF0)
                              : const Color(0xFF253341),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!isMe)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(
                                  message.senderName,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            Text(
                              message.content,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              MessageUtils.getTimeAgo(message.timestamp),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF253341),
              border: Border(
                top: BorderSide(
                  color: Color(0xFF38444D),
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.image, color: Color(0xFF1D9BF0)),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.gif_box, color: Color(0xFF1D9BF0)),
                  onPressed: () {},
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Enviar mensaje...',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF1D9BF0)),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
