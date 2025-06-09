import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'diver_buddy_chat_bot.dart';

class DiverBuddyButton extends StatefulWidget {
  const DiverBuddyButton({super.key});

  @override
  State<DiverBuddyButton> createState() => _DiverBuddyButtonState();
}

class _DiverBuddyButtonState extends State<DiverBuddyButton> {
  bool _showWelcomeBubble = true;

  @override
  void initState() {
    super.initState();
    // Auto-hide welcome bubble after 8 seconds
    Future.delayed(const Duration(seconds: 8), () {
      if (mounted) {
        setState(() {
          _showWelcomeBubble = false;
        });
      }
    });
  }

  void _showChatBot(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: const DiverBuddyChatBot(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 40,
      right: 20,
      child: SafeArea(
        child: IntrinsicHeight(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome speech bubble (on left of buddy)
              if (_showWelcomeBubble)
                Container(
                  margin: const EdgeInsets.only(right: 12, top: 8),
                  padding: const EdgeInsets.all(16),
                  constraints: const BoxConstraints(maxWidth: 250),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset(
                                  'assets/images/diver_buddy_chat_bot.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Diver Buddy',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E3A8A),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _showWelcomeBubble = false;
                                });
                              },
                              child: Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Hi! I\'m your diving assistant 🤿\n\nTap me anytime for diving tips, course info, or website help!',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                    .animate()
                    .slideX(
                      begin: 1.0,
                      end: 0.0,
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOut,
                    )
                    .fadeIn(
                      delay: const Duration(milliseconds: 1000),
                      duration: const Duration(milliseconds: 500),
                    ),
              
              // Chat bot button with padding
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(36),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _showWelcomeBubble = false;
                    });
                    _showChatBot(context);
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: const Color(0xFF3B82F6).withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Image.asset(
                        'assets/images/diver_buddy_chat_bot.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              )
                  .animate()
                  .scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1.0, 1.0),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.elasticOut,
                  )
                  .fadeIn(duration: const Duration(milliseconds: 600)),
            ],
          ),
        ),
      ),
    );
  }
} 