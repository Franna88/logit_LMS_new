import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DiverBuddyChatBot extends StatefulWidget {
  const DiverBuddyChatBot({super.key});

  @override
  State<DiverBuddyChatBot> createState() => _DiverBuddyChatBotState();
}

class _DiverBuddyChatBotState extends State<DiverBuddyChatBot> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Add welcome message
    _messages.add(ChatMessage(
      text: "Hi there! I'm your Diver Buddy 🤿\n\nI'm here to help with diving questions and guide you through the website. What would you like to know?",
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        text: message,
        isUser: true,
        timestamp: DateTime.now(),
      ));
    });

    _messageController.clear();
    _scrollToBottom();

    // Simulate bot response
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            text: _getBotResponse(message),
            isUser: false,
            timestamp: DateTime.now(),
          ));
        });
        _scrollToBottom();
      }
    });
  }

  String _getBotResponse(String userMessage) {
    final message = userMessage.toLowerCase();
    
    if (message.contains('depth') || message.contains('pressure')) {
      return "Great question about depth! Remember that pressure increases by 1 atmosphere every 10 meters (33 feet) of depth. Always plan your dives within your certification limits and use proper decompression procedures. 🌊";
    } else if (message.contains('equipment') || message.contains('gear')) {
      return "Diving equipment is crucial for safety! Make sure to regularly service your regulator, check your BCD, and always do a buddy check before diving. In our courses, you'll learn about all the essential gear! 🎯";
    } else if (message.contains('certification') || message.contains('course')) {
      return "Our platform offers various diving courses from beginner to advanced levels! Navigate to different POIs on the map to explore courses like Open Water, Advanced, Wreck Diving, and more. Each location specializes in different skills! 📚";
    } else if (message.contains('safety') || message.contains('emergency')) {
      return "Safety first! Always dive with a buddy, plan your dive and dive your plan, maintain proper buoyancy, and know your emergency procedures. Our courses cover comprehensive safety training! ⚠️";
    } else if (message.contains('navigation') || message.contains('website') || message.contains('how')) {
      return "Navigate the map by clicking on different POIs (Points of Interest) to discover diving courses. Use your boat to travel between locations. Visit the Hub for account management and course tracking! 🗺️";
    } else if (message.contains('buy') || message.contains('purchase') || message.contains('price')) {
      return "You can purchase courses at each POI location. Make sure you have enough funds in your account - visit the Hub to add more money if needed. Completed courses earn you rewards! 💰";
    } else if (message.contains('marine life') || message.contains('fish') || message.contains('coral')) {
      return "Marine life is amazing! Our Marine Biology and Photography courses teach you about underwater ecosystems, species identification, and how to interact responsibly with marine creatures. 🐠🦑";
    } else if (message.contains('wreck') || message.contains('shipwreck')) {
      return "Wreck diving is thrilling! Our Wreck Diving and Maritime Archaeology courses teach safe penetration techniques, historical research, and how to explore underwater heritage responsibly. 🚢";
    } else if (message.contains('cave') || message.contains('cavern')) {
      return "Cave diving requires specialized training! Our Cave Diving courses cover guideline techniques, emergency procedures, and the unique challenges of overhead environments. Always get proper training first! 🕳️";
    } else {
      return "That's an interesting question! I'm here to help with diving topics and website navigation. Feel free to ask about diving safety, equipment, courses, or how to use our platform. What specific diving topic interests you? 🤔";
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E3A8A),
            Color(0xFF3B82F6),
            Color(0xFF60A5FA),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: Image.asset(
                      'assets/images/diver_buddy_chat_bot.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Diver Buddy',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Your diving assistant',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
          
          // Chat messages
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return _buildMessageBubble(message);
                },
              ),
            ),
          ),
          
          // Message input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Ask me about diving...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.yellow, Colors.orange],
                    ),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _sendMessage,
                      borderRadius: BorderRadius.circular(25),
                      child: const Padding(
                        padding: EdgeInsets.all(12),
                        child: Icon(
                          Icons.send,
                          color: Color(0xFF1E3A8A),
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.0, 1.0),
          duration: const Duration(milliseconds: 400),
          curve: Curves.elasticOut,
        )
        .fadeIn(duration: const Duration(milliseconds: 300));
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/images/diver_buddy_chat_bot.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isUser 
                    ? Colors.yellow.withOpacity(0.9)
                    : Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  fontSize: 14,
                  color: message.isUser ? const Color(0xFF1E3A8A) : Colors.black87,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (message.isUser) ...[
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(left: 8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.8),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
} 