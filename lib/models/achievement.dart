// Owner: Edbert | FR: FR-37, FR-38, FR-39

class Achievement {
  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconAsset,
    required this.target,
    required this.progress,
    this.isUnlocked = false,
  });
  final String id;
  final String title;
  final String description;
  final String iconAsset;
  final int target;
  final int progress;
  final bool isUnlocked;

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    String? iconAsset,
    int? target,
    int? progress,
    bool? isUnlocked,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      iconAsset: iconAsset ?? this.iconAsset,
      target: target ?? this.target,
      progress: progress ?? this.progress,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }
}
