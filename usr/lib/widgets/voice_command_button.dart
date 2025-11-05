import 'package:flutter/material.dart';

class VoiceCommandButton extends StatefulWidget {
  final bool isListening;
  final VoidCallback onPressed;

  const VoiceCommandButton({
    super.key,
    required this.isListening,
    required this.onPressed,
  });

  @override
  State<VoiceCommandButton> createState() => _VoiceCommandButtonState();
}

class _VoiceCommandButtonState extends State<VoiceCommandButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: widget.isListening ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
        builder: (context, child) {
          return Transform.scale(
            scale: widget.isListening ? _pulseAnimation.value : 1.0,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: widget.isListening
                      ? [
                          Colors.red,
                          Colors.redAccent,
                        ]
                      : [
                          Colors.blue,
                          Colors.blueAccent,
                        ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: (widget.isListening ? Colors.red : Colors.blue)
                        .withOpacity(0.5),
                    blurRadius: widget.isListening ? 20 : 10,
                    spreadRadius: widget.isListening ? 5 : 2,
                  ),
                ],
              ),
              child: Icon(
                widget.isListening ? Icons.mic : Icons.mic_none,
                color: Colors.white,
                size: 35,
              ),
            ),
          );
        },
      ),
    );
  }
}
