import '../../domain/models/video_model.dart';

class ActiveCaptionData {
  final Caption? caption;
  final String? highlightedWord;
  final String translation;

  const ActiveCaptionData({
    this.caption,
    this.highlightedWord,
    this.translation = '',
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ActiveCaptionData &&
        other.caption == caption &&
        other.highlightedWord == highlightedWord &&
        other.translation == translation;
  }

  @override
  int get hashCode => Object.hash(caption, highlightedWord, translation);
}
