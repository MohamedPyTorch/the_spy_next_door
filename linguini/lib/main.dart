import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:web_socket_channel/io.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';

Future<bool> requestPermissions() async {
  var status = await Permission.microphone.status;

  if (!status.isGranted) {
    print("Requesting microphone permissions...");
    status = await Permission.microphone.request();
  }

  if (!status.isGranted) {
    print("Microphone permissions denied.");
    return false;
  }

  print("Microphone permissions granted.");
  return true;
}

void main() {
  runApp(const BackgroundApp());
}

class BackgroundApp extends StatelessWidget {
  const BackgroundApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamingScreen(),
    );
  }
}

class StreamingScreen extends StatefulWidget {
  const StreamingScreen({super.key});

  @override
  _StreamingScreenState createState() => _StreamingScreenState();
}

class _StreamingScreenState extends State<StreamingScreen> {
  late AudioStreamService _audioStreamService;

  @override
  void initState() {
    super.initState();
    _audioStreamService = AudioStreamService();
  }

  @override
  void dispose() {
    super.dispose();
    _audioStreamService.stopStreaming();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Audio Streaming"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await _audioStreamService.startStreaming();
          },
          child: Text("Start Streaming"),
        ),
      ),
    );
  }
}

class AudioStreamService {
  static const platform = MethodChannel('com.example.linguini/foregroundService');
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  late final IOWebSocketChannel _channel; // WebSocket channel is late
  final StreamController<Uint8List> _audioStreamController = StreamController<Uint8List>();

  // Initialize _channel in the constructor
  AudioStreamService() {
    _channel = IOWebSocketChannel.connect('ws://192.168.1.12:3000');
  }

  Future<void> startStreaming() async {
    try {
      print("Callinng startForegroundService");
      await platform.invokeMethod('startForegroundService');
    } on PlatformException catch (e) {
      print("Failed to start service: '${e.message}'");
    }

    await _recorder.openRecorder();
    await _recorder.setSubscriptionDuration(const Duration(milliseconds: 500));

    // Listen to the audio stream and send data via WebSocket
    _audioStreamController.stream.listen((audioData) {
      _channel.sink.add(audioData); // Send audio data to the WebSocket server
    });

    await _recorder.startRecorder(
      codec: Codec.pcm16,
      numChannels: 1,
      sampleRate: 16000,
      toStream: _audioStreamController.sink,
    );
  }

  Future<void> stopStreaming() async {
    await _recorder.stopRecorder();
    await _recorder.closeRecorder();
    await _audioStreamController.close();
    _channel.sink.close(); // Close WebSocket connection
  }
}