const supportedImageExtensions = <String>{'.jpg', '.jpeg', '.png', '.webp'};

bool isSupportedImage(String filename) {
  final lower = filename.toLowerCase();
  return supportedImageExtensions.any((ext) => lower.endsWith(ext));
}
