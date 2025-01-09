# The Spy Next Door

An app to connect with the backend and send audio streams ("Spying")

**Current Limitation:**
- Fails to work in the background due to native code issues (under development).

## How to Use

### Backend
1. Ensure you have Node.js installed.
2. Navigate to the backend directory:
   ```bash
   cd backend
   ```
3. Install the required dependencies:
   ```bash
   npm install ws speaker wav
   ```
4. Start the server:
   ```bash
   node server.js
   ```
5. Copy the IP address and port, then paste it into `lib/main.dart`:
   ```dart
   _channel = IOWebSocketChannel.connect('ws://192.168.1.12:3000');
   ```

### Flutter App
1. Ensure Flutter is installed and working properly by running:
   ```bash
   flutter doctor
   ```
2. Navigate to the Flutter project directory:
   ```bash
   cd ../linguini
   ```
3. Clean the project:
   ```bash
   flutter clean
   ```
4. Fetch the required dependencies:
   ```bash
   flutter pub get
   ```
5. Build the release APK:
   ```bash
   flutter build apk --release
   ```
6. Find the APK in the following directory:
   ```
   build/app/outputs/apk/release/app-release.apk
   ```
7. Install the APK on the target Android phone.

**Note:** The app fails to work in the background due to native code issues. This is currently under development.

## TODO
1. Implement auto-discovery of the backend web server.
2. Debug and implement foreground service functionality.

Feel free to fork and contribute to this open-source project! 😀

