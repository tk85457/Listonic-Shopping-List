import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VoiceService {
  static final VoiceService _instance = VoiceService._internal();
  factory VoiceService() => _instance;
  VoiceService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  final SpeechToText _speechToText = SpeechToText();

  bool _isListening = false;
  bool get isListening => _isListening;

  String _lastWords = '';
  String get lastWords => _lastWords;

  Function(String)? onResult;
  Function(bool)? onListeningChanged;

  Future<bool> initialize() async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    final available = await _speechToText.initialize(
      onStatus: (status) {
        _isListening = _speechToText.isListening;
        onListeningChanged?.call(_isListening);
      },
      onError: (errorNotification) {
        _isListening = false;
        onListeningChanged?.call(false);
      },
    );
    return available;
  }

  Future<void> startListening({
    Function(String)? onResult,
    Function(bool)? onListeningChanged,
  }) async {
    if (!_speechToText.isAvailable || _isListening) return;

    this.onResult = onResult;
    this.onListeningChanged = onListeningChanged;

    _isListening = true;
    onListeningChanged?.call(true);

    _speechToText.listen(
      onResult: (SpeechRecognitionResult result) {
        _lastWords = result.recognizedWords;
        onResult?.call(_lastWords);
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 5),
      localeId: 'en_US',
      listenOptions: SpeechListenOptions(partialResults: true),
    );
  }

  Future<void> stopListening() async {
    if (!_isListening) return;
    await _speechToText.stop();
    _isListening = false;
    onListeningChanged?.call(false);
  }

  Future<void> speak(String text) async {
    await _flutterTts.speak(text);
  }

  Future<void> stopSpeaking() async {
    await _flutterTts.stop();
  }

  void dispose() {
    _flutterTts.stop();
    _speechToText.stop();
    _speechToText.cancel();
  }

  List<String> parseGroceryItems(String voiceText) {
    final text = voiceText.toLowerCase();
    String cleanText = text
        .replaceAll('add', '')
        .replaceAll('i need', '')
        .replaceAll('i want', '')
        .replaceAll('get', '')
        .replaceAll('buy', '')
        .replaceAll('please', '')
        .replaceAll('can you', '')
        .trim();

    List<String> items;
    if (cleanText.contains(' and ')) {
      items = cleanText.split(' and ');
    } else if (cleanText.contains(',')) {
      items = cleanText.split(',');
    } else if (cleanText.contains(' then ')) {
      items = cleanText.split(' then ');
    } else if (cleanText.contains(' also ')) {
      items = cleanText.split(' also ');
    } else {
      items = [cleanText];
    }

    return items
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty && item.length > 1)
        .toList();
  }
}

