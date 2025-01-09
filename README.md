# The spy next door

An app to connect with the backend and send audio stream "Spying"
*fail to work in the background

How to use:

backend "make sure you have node.js installed
`cd ../backend
 npm install ws speaker wav
 node server.js'
copy the ip address and port paste it into lib/main.dart
`_channel = IOWebSocketChannel.connect('ws://192.168.1.12:3000');`


flutter app
ensure you have flutter installed and healthy with `flutter doctor` terminal command
`cd linguini
 flutter clean
 flutter pub get
 flutter build apk --release`
then you will find the apk in directory
`build/app/outputs/apk/release/app-release.apk`
then install it on the target android phone

note: the app fails to work in the background because of native code proplem and it's under dev
TODO: 1.make auto discover of the backend web server
      2.foreground service debugging

feel free to fork and add to this open source project 😀