enum PdfCompressionLevel {
  extreme(dpi: 78, quality: 42, maxWidth: 1050),
  recommended(dpi: 105, quality: 58, maxWidth: 1450),
  less(dpi: 144, quality: 80, maxWidth: 2200);

  const PdfCompressionLevel({
    required this.dpi,
    required this.quality,
    required this.maxWidth,
  });

  final int dpi;
  final int quality;
  final int maxWidth;

  /// Target output size relative to the original file size.
  double get targetSizeRatio => switch (this) {
    PdfCompressionLevel.extreme => 0.25,
    PdfCompressionLevel.recommended => 0.50,
    PdfCompressionLevel.less => 0.67,
  };

  /// Profiles are tried in order until the requested size is reached.
  /// Extreme uses a single, readable high-compression profile.
  List<PdfCompressionProfile> get profiles => switch (this) {
    PdfCompressionLevel.extreme => const [
      PdfCompressionProfile(dpi: 78, quality: 42, maxWidth: 1050),
    ],
    PdfCompressionLevel.recommended => const [
      PdfCompressionProfile(dpi: 105, quality: 58, maxWidth: 1450),
      PdfCompressionProfile(dpi: 90, quality: 48, maxWidth: 1250),
      PdfCompressionProfile(dpi: 78, quality: 40, maxWidth: 1050),
      PdfCompressionProfile(dpi: 65, quality: 32, maxWidth: 900),
      PdfCompressionProfile(dpi: 50, quality: 24, maxWidth: 700),
      PdfCompressionProfile(dpi: 40, quality: 18, maxWidth: 580),
      PdfCompressionProfile(dpi: 32, quality: 12, maxWidth: 450),
      PdfCompressionProfile(dpi: 26, quality: 8, maxWidth: 350),
      PdfCompressionProfile(dpi: 20, quality: 5, maxWidth: 260),
    ],
    PdfCompressionLevel.less => const [
      PdfCompressionProfile(dpi: 144, quality: 80, maxWidth: 2200),
      PdfCompressionProfile(dpi: 130, quality: 74, maxWidth: 2000),
      PdfCompressionProfile(dpi: 115, quality: 68, maxWidth: 1800),
      PdfCompressionProfile(dpi: 105, quality: 58, maxWidth: 1450),
      PdfCompressionProfile(dpi: 90, quality: 48, maxWidth: 1250),
      PdfCompressionProfile(dpi: 78, quality: 40, maxWidth: 1050),
      PdfCompressionProfile(dpi: 65, quality: 32, maxWidth: 900),
      PdfCompressionProfile(dpi: 50, quality: 24, maxWidth: 700),
      PdfCompressionProfile(dpi: 40, quality: 18, maxWidth: 580),
      PdfCompressionProfile(dpi: 32, quality: 12, maxWidth: 450),
      PdfCompressionProfile(dpi: 26, quality: 8, maxWidth: 350),
      PdfCompressionProfile(dpi: 20, quality: 5, maxWidth: 260),
    ],
  };
}

class PdfCompressionProfile {
  const PdfCompressionProfile({
    required this.dpi,
    required this.quality,
    required this.maxWidth,
  });

  final int dpi;
  final int quality;
  final int maxWidth;
}
