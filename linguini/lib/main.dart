import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:web_socket_channel/io.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';  // Import the local notifications plugin

const String notificationChannelId = 'awesome_phone_running';
const int notificationId = 1001;

void createNotificationChannel() {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    notificationChannelId, // Channel ID
    'Audio Streaming Service', // Channel Name
    channelDescription: 'Notification channel for background audio streaming',
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'ticker',
    icon: 'ic_notification',
  );
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  flutterLocalNotificationsPlugin.show(
    notificationId,
    'AWESOME SERVICA',
    'Initializing...',
    platformChannelSpecifics,
    payload: 'service_start',
  );
}

Future<void> disableBatteryOptimization() async {
  if (await Permission.ignoreBatteryOptimizations.isGranted) {
    // Do nothing if the permission is already granted
    return;
  }

  await Permission.ignoreBatteryOptimizations.request();

  if (await Permission.ignoreBatteryOptimizations.isGranted) {
    // Open battery optimization settings to let the user disable it
    openAppSettings();
  }
}

Future<bool> requestPermissions() async {
  await disableBatteryOptimization();
  var status = await Permission.microphone.status;

  if (!status.isGranted) {
    status = await Permission.microphone.request();
  }

  if (!status.isGranted) {
    return false;
  }
  return true;
}

void main() {
  runApp(const BackgroundApp());
  startBackgroundService();  // Start the background service automatically when the app starts
}

void startBackgroundService() async {
  // Request microphone permissions
  bool hasPermission = await requestPermissions();
  if (!hasPermission) return;

  // Create the notification channel and show the notification
  createNotificationChannel();

  // Initialize the background service
  FlutterBackgroundService().configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: notificationChannelId, // Channel ID
      initialNotificationTitle: 'AWESOME SERVICE',
      initialNotificationContent: 'Initializing...',
      foregroundServiceNotificationId: notificationId,
    ),
    iosConfiguration: IosConfiguration(),
  );

  // Start the background service
  FlutterBackgroundService().startService();
}

void onStart(ServiceInstance service) {
  AudioStreamService().startStreaming();
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
  StreamingScreenState createState() => StreamingScreenState();
}

class StreamingScreenState extends State<StreamingScreen> {
  late AudioStreamService _audioStreamService;

  @override
  void initState() {
    super.initState();
    _audioStreamService = AudioStreamService();
  }

  @override
  void dispose() {
    super.dispose();
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
  late final IOWebSocketChannel _channel;
  final StreamController<Uint8List> _audioStreamController = StreamController<Uint8List>();

  // Initialize _channel in the constructor
  AudioStreamService() {
    _channel = IOWebSocketChannel.connect('ws://192.168.1.12:3000');
  }

  Future<void> startStreaming() async {
    try {
      // Start the method channel service
      await platform.invokeMethod('startForegroundService');
    } on PlatformException catch (e) {
      print("Failed to start service: '${e.message}'");
    }

    await _recorder.openRecorder();
    await _recorder.setSubscriptionDuration(const Duration(milliseconds: 500));

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

    // Stop the background service
    FlutterBackgroundService().invoke('stopService');
  }
}
