import 'package:flutter/foundation.dart';

class VoiceService {
  bool _isInitialized = false;
  bool _isListening = false;
  
  Function(String)? onCommandReceived;
  Function(bool)? onListeningStateChanged;

  Future<void> initialize() async {
    // TODO: Implementar inicialização do speech_to_text
    // Aguardando integração com package real
    _isInitialized = true;
    if (kDebugMode) {
      print('VoiceService: Serviço de voz inicializado (modo simulação)');
    }
  }

  Future<void> startListening() async {
    if (!_isInitialized) {
      await initialize();
    }

    _isListening = true;
    onListeningStateChanged?.call(true);

    if (kDebugMode) {
      print('VoiceService: Iniciando escuta...');
      
      // Simulação para testes - remover quando implementar speech_to_text real
      Future.delayed(const Duration(seconds: 2), () {
        _simulateCommand();
      });
    }

    // TODO: Implementar speech_to_text real
    // await _speech.listen(
    //   onResult: (result) {
    //     if (result.finalResult) {
    //       onCommandReceived?.call(result.recognizedWords);
    //       stopListening();
    //     }
    //   },
    // );
  }

  void _simulateCommand() {
    // Comandos simulados para teste
    final commands = [
      'Lembrar de tomar remédio às 18 horas',
      'Abrir WhatsApp',
      'Responder mensagem do João',
      'Olá',
      'Abrir galeria',
    ];
    
    final command = (commands..shuffle()).first;
    onCommandReceived?.call(command);
    stopListening();
  }

  void stopListening() {
    _isListening = false;
    onListeningStateChanged?.call(false);
    
    if (kDebugMode) {
      print('VoiceService: Escuta interrompida');
    }

    // TODO: Implementar parada do speech_to_text real
    // _speech.stop();
  }

  bool get isListening => _isListening;
  bool get isInitialized => _isInitialized;

  void dispose() {
    stopListening();
    _isInitialized = false;
  }
}
