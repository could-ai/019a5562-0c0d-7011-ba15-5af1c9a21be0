import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../widgets/face_widget.dart';
import '../widgets/voice_command_button.dart';
import '../services/voice_service.dart';
import '../services/task_service.dart';

class FaceLauncherScreen extends StatefulWidget {
  const FaceLauncherScreen({super.key});

  @override
  State<FaceLauncherScreen> createState() => _FaceLauncherScreenState();
}

class _FaceLauncherScreenState extends State<FaceLauncherScreen>
    with SingleTickerProviderStateMixin {
  final VoiceService _voiceService = VoiceService();
  final TaskService _taskService = TaskService();
  
  bool _isListening = false;
  String _currentCommand = '';
  String _lastAction = '';
  FaceExpression _expression = FaceExpression.neutral;
  
  late AnimationController _blinkController;

  @override
  void initState() {
    super.initState();
    _initializeVoiceService();
    _setupBlinkAnimation();
  }

  void _setupBlinkAnimation() {
    _blinkController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    // Piscar aleatoriamente
    _scheduleNextBlink();
  }

  void _scheduleNextBlink() {
    final random = math.Random();
    final delay = 2000 + random.nextInt(3000); // 2-5 segundos
    
    Future.delayed(Duration(milliseconds: delay), () {
      if (mounted) {
        _blinkController.forward().then((_) {
          _blinkController.reverse();
          _scheduleNextBlink();
        });
      }
    });
  }

  Future<void> _initializeVoiceService() async {
    await _voiceService.initialize();
    
    _voiceService.onCommandReceived = (command) {
      setState(() {
        _currentCommand = command;
        _expression = FaceExpression.listening;
      });
      _processCommand(command);
    };
    
    _voiceService.onListeningStateChanged = (isListening) {
      setState(() {
        _isListening = isListening;
        if (isListening) {
          _expression = FaceExpression.listening;
        } else {
          _expression = FaceExpression.neutral;
        }
      });
    };
  }

  void _processCommand(String command) async {
    final lowerCommand = command.toLowerCase();
    
    setState(() {
      _expression = FaceExpression.thinking;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    try {
      if (lowerCommand.contains('lembrete') || lowerCommand.contains('lembrar')) {
        await _taskService.createReminder(command);
        setState(() {
          _lastAction = 'Lembrete agendado: $command';
          _expression = FaceExpression.happy;
        });
      } else if (lowerCommand.contains('abrir') || lowerCommand.contains('abra')) {
        final appName = _extractAppName(lowerCommand);
        await _taskService.openApp(appName);
        setState(() {
          _lastAction = 'Abrindo $appName...';
          _expression = FaceExpression.happy;
        });
      } else if (lowerCommand.contains('mensagem') || lowerCommand.contains('responder')) {
        await _taskService.replyToMessage(command);
        setState(() {
          _lastAction = 'Respondendo mensagem...';
          _expression = FaceExpression.happy;
        });
      } else if (lowerCommand.contains('olá') || lowerCommand.contains('oi')) {
        setState(() {
          _lastAction = 'Olá! Como posso ajudar?';
          _expression = FaceExpression.happy;
        });
      } else {
        setState(() {
          _lastAction = 'Desculpe, não entendi o comando';
          _expression = FaceExpression.confused;
        });
      }
    } catch (e) {
      setState(() {
        _lastAction = 'Erro ao executar comando';
        _expression = FaceExpression.sad;
      });
    }

    // Voltar para expressão neutra após 3 segundos
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _expression = FaceExpression.neutral;
        });
      }
    });
  }

  String _extractAppName(String command) {
    final words = command.split(' ');
    final openIndex = words.indexWhere((w) => w.contains('abr'));
    if (openIndex != -1 && openIndex < words.length - 1) {
      return words[openIndex + 1];
    }
    return 'aplicativo';
  }

  void _toggleListening() {
    if (_isListening) {
      _voiceService.stopListening();
    } else {
      _voiceService.startListening();
    }
  }

  @override
  void dispose() {
    _blinkController.dispose();
    _voiceService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onDoubleTap: _toggleListening,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black,
                Colors.grey.shade900,
                Colors.black,
              ],
            ),
          ),
          child: Stack(
            children: [
              // Rosto 2D centralizado
              Center(
                child: FaceWidget(
                  expression: _expression,
                  blinkAnimation: _blinkController,
                ),
              ),
              
              // Indicador de escuta
              if (_isListening)
                Positioned(
                  top: 60,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.mic,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Escutando...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              
              // Comando atual
              if (_currentCommand.isNotEmpty)
                Positioned(
                  top: 120,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.blue.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _currentCommand,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              
              // Última ação
              if (_lastAction.isNotEmpty)
                Positioned(
                  bottom: 120,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.green.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _lastAction,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              
              // Botão de voz
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Center(
                  child: VoiceCommandButton(
                    isListening: _isListening,
                    onPressed: _toggleListening,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
