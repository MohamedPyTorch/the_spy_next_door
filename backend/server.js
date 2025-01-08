const WebSocket = require('ws');
const Speaker = require('speaker');

const wss = new WebSocket.Server({ port: 3000 });

wss.on('connection', (ws) => {
  console.log('Client connected');

  const speaker = new Speaker({
    channels: 1, // Mono audio
    bitDepth: 16, // 16-bit PCM
    sampleRate: 16000, // 16 kHz sampling rate
  });

  ws.on('message', (data) => {
    // Directly write raw PCM data to the speaker
    speaker.write(data);
  });

  ws.on('close', () => {
    console.log('Client disconnected');
    speaker.close();
  });

  ws.on('error', (err) => {
    console.error('Error:', err);
  });
});

console.log('WebSocket server running on ws://localhost:3000');
