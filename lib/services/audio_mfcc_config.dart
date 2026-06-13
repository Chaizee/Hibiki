/// Shared audio / MFCC parameters — must match [ml/train_voice_mood.ipynb].
abstract final class AudioMfccConfig {
  static const int sampleRate = 16000;
  static const int nMfcc = 20;
  static const int nFft = 512;
  static const int hopLength = 256;
  static const int nMels = 40;
  static const double durationSec = 3.0;

  static int get targetSamples => (sampleRate * durationSec).round();

  /// Flattened mean MFCC vector length fed to the TFLite model.
  static int get featureLength => nMfcc;
}
