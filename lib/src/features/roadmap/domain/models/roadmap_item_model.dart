class RoadmapItemModel {
  final int id;
  final String title;
  final String description;
  final bool isCompleted;
  final bool isLocked;

  const RoadmapItemModel({
    required this.id,
    required this.title,
    required this.description,
    this.isCompleted = false,
    this.isLocked = true,
  });

  // Mock data generator
  static List<RoadmapItemModel> generateHSK1Items() {
    return List.generate(60, (index) {
      // Logic to make first few unlocked/completed for demo
      final isCompleted = index < 5;
      final isLocked = index > 5;

      return RoadmapItemModel(
        id: index + 1,
        title: 'HSK 1 Lesson ${index + 1}',
        description: 'Learn basic greetings and numbers.',
        isCompleted: isCompleted,
        isLocked: isLocked,
      );
    });
  }
}
