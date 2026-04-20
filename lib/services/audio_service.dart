import 'dart:async';
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _leftPlayer = AudioPlayer();
  final AudioPlayer _rightPlayer = AudioPlayer();

  bool _isPlaying = false;
  bool _isPaused = false;
  double _volume = 0.8;
  double _leftHz = 200.0;
  double _rightHz = 204.0;

  bool get isPlaying => _isPlaying;
  bool get isPaused => _isPaused;
  double get volume => _volume;
  double get leftHz => _leftHz;
  double get rightHz => _rightHz;

  /// Initialize audio session for background playback
  Future<void> initialize() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playback,
      avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.duckOthers,
      avAudioSessionMode: AVAudioSessionMode.defaultMode,
      avAudioSessionRouteSharingPolicy:
          AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: AndroidAudioAttributes(
        contentType: AndroidAudioContentType.music,
        flags: AndroidAudioFlags.none,
        usage: AndroidAudioUsage.media,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));
  }

  /// Generate a sine wave audio source at a given frequency
  /// Returns an AudioSource that plays a continuous sine wave tone
  AudioSource _generateToneSource(double hz, bool isLeftChannel) {
    // Generate PCM bytes for a sine wave
    // Sample rate: 44100 Hz, 16-bit, mono
    const int sampleRate = 44100;
    const int durationSeconds = 30; // Loop every 30 seconds
    const int numSamples = sampleRate * durationSeconds;

    final ByteData byteData = ByteData(44 + numSamples * 2);
    int offset = 0;

    // WAV Header
    // ChunkID "RIFF"
    byteData.setUint8(offset++, 0x52); // R
    byteData.setUint8(offset++, 0x49); // I
    byteData.setUint8(offset++, 0x46); // F
    byteData.setUint8(offset++, 0x46); // F

    // ChunkSize
    final int chunkSize = 36 + numSamples * 2;
    byteData.setUint32(offset, chunkSize, Endian.little);
    offset += 4;

    // Format "WAVE"
    byteData.setUint8(offset++, 0x57); // W
    byteData.setUint8(offset++, 0x41); // A
    byteData.setUint8(offset++, 0x56); // V
    byteData.setUint8(offset++, 0x45); // E

    // Subchunk1ID "fmt "
    byteData.setUint8(offset++, 0x66); // f
    byteData.setUint8(offset++, 0x6D); // m
    byteData.setUint8(offset++, 0x74); // t
    byteData.setUint8(offset++, 0x20); //

    // Subchunk1Size = 16 for PCM
    byteData.setUint32(offset, 16, Endian.little);
    offset += 4;

    // AudioFormat = 1 (PCM)
    byteData.setUint16(offset, 1, Endian.little);
    offset += 2;

    // NumChannels = 1 (mono)
    byteData.setUint16(offset, 1, Endian.little);
    offset += 2;

    // SampleRate
    byteData.setUint32(offset, sampleRate, Endian.little);
    offset += 4;

    // ByteRate = SampleRate * NumChannels * BitsPerSample / 8
    byteData.setUint32(offset, sampleRate * 2, Endian.little);
    offset += 4;

    // BlockAlign = NumChannels * BitsPerSample / 8
    byteData.setUint16(offset, 2, Endian.little);
    offset += 2;

    // BitsPerSample = 16
    byteData.setUint16(offset, 16, Endian.little);
    offset += 2;

    // Subchunk2ID "data"
    byteData.setUint8(offset++, 0x64); // d
    byteData.setUint8(offset++, 0x61); // a
    byteData.setUint8(offset++, 0x74); // t
    byteData.setUint8(offset++, 0x61); // a

    // Subchunk2Size
    byteData.setUint32(offset, numSamples * 2, Endian.little);
    offset += 4;

    // Generate sine wave samples
    for (int i = 0; i < numSamples; i++) {
      final double t = i / sampleRate;
      final double sample = math.sin(2 * math.pi * hz * t);
      final int pcmValue = (sample * 32767).round().clamp(-32768, 32767);
      byteData.setInt16(offset, pcmValue, Endian.little);
      offset += 2;
    }

    return MyCustomSource(byteData.buffer.asUint8List());
  }

  /// Play binaural beats with given frequencies
  Future<void> playBinaural({
    required double leftHz,
    required double rightHz,
  }) async {
    _leftHz = leftHz;
    _rightHz = rightHz;

    await stop();

    await initialize();

    try {
      // Set up left channel (left ear)
      await _leftPlayer.setAudioSource(
        _generateToneSource(leftHz, true),
        initialPosition: Duration.zero,
      );
      await _leftPlayer.setLoopMode(LoopMode.one);
      await _leftPlayer.setVolume(_volume);

      // Set up right channel (right ear)
      await _rightPlayer.setAudioSource(
        _generateToneSource(rightHz, false),
        initialPosition: Duration.zero,
      );
      await _rightPlayer.setLoopMode(LoopMode.one);
      await _rightPlayer.setVolume(_volume);

      // Start both simultaneously
      await Future.wait([
        _leftPlayer.play(),
        _rightPlayer.play(),
      ]);

      _isPlaying = true;
      _isPaused = false;
    } catch (e) {
      _isPlaying = false;
      rethrow;
    }
  }

  /// Pause audio
  Future<void> pause() async {
    if (_isPlaying && !_isPaused) {
      await Future.wait([
        _leftPlayer.pause(),
        _rightPlayer.pause(),
      ]);
      _isPaused = true;
    }
  }

  /// Resume audio
  Future<void> resume() async {
    if (_isPaused) {
      await Future.wait([
        _leftPlayer.play(),
        _rightPlayer.play(),
      ]);
      _isPaused = false;
    }
  }

  /// Stop audio completely
  Future<void> stop() async {
    await Future.wait([
      _leftPlayer.stop(),
      _rightPlayer.stop(),
    ]);
    _isPlaying = false;
    _isPaused = false;
  }

  /// Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    await Future.wait([
      _leftPlayer.setVolume(_volume),
      _rightPlayer.setVolume(_volume),
    ]);
  }

  /// Dispose players
  Future<void> dispose() async {
    await _leftPlayer.dispose();
    await _rightPlayer.dispose();
  }
}

/// Custom audio source that streams in-memory WAV bytes
class MyCustomSource extends StreamAudioSource {
  final Uint8List _bytes;
  MyCustomSource(this._bytes);

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    start ??= 0;
    end ??= _bytes.length;
    return StreamAudioResponse(
      sourceLength: _bytes.length,
      contentLength: end - start,
      offset: start,
      stream: Stream.value(List<int>.from(_bytes.sublist(start, end))),
      contentType: 'audio/wav',
    );
  }
}
