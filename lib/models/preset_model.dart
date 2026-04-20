import 'package:hive/hive.dart';

part 'preset_model.g.dart';

@HiveType(typeId: 0)
class PresetModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String emoji;

  @HiveField(3)
  double leftFrequency;

  @HiveField(4)
  double rightFrequency;

  @HiveField(5)
  String benefit;

  @HiveField(6)
  bool isCustom;

  @HiveField(7)
  String? createdBy;

  @HiveField(8)
  String? exportedAt;

  PresetModel({
    required this.id,
    required this.name,
    required this.emoji,
    required this.leftFrequency,
    required this.rightFrequency,
    required this.benefit,
    this.isCustom = false,
    this.createdBy,
    this.exportedAt,
  });

  double get difference => (rightFrequency - leftFrequency).abs();

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'emoji': emoji,
    'leftFrequency': leftFrequency,
    'rightFrequency': rightFrequency,
    'benefit': benefit,
    'isCustom': isCustom,
    'createdBy': createdBy,
    'exportedAt': exportedAt,
  };

  factory PresetModel.fromJson(Map<String, dynamic> json) => PresetModel(
    id: json['id'] as String,
    name: json['name'] as String,
    emoji: json['emoji'] as String? ?? '🎵',
    leftFrequency: (json['leftFrequency'] as num).toDouble(),
    rightFrequency: (json['rightFrequency'] as num).toDouble(),
    benefit: json['benefit'] as String? ?? '',
    isCustom: json['isCustom'] as bool? ?? true,
    createdBy: json['createdBy'] as String?,
    exportedAt: json['exportedAt'] as String?,
  );

  PresetModel copyWith({
    String? id,
    String? name,
    String? emoji,
    double? leftFrequency,
    double? rightFrequency,
    String? benefit,
    bool? isCustom,
    String? createdBy,
    String? exportedAt,
  }) =>
      PresetModel(
        id: id ?? this.id,
        name: name ?? this.name,
        emoji: emoji ?? this.emoji,
        leftFrequency: leftFrequency ?? this.leftFrequency,
        rightFrequency: rightFrequency ?? this.rightFrequency,
        benefit: benefit ?? this.benefit,
        isCustom: isCustom ?? this.isCustom,
        createdBy: createdBy ?? this.createdBy,
        exportedAt: exportedAt ?? this.exportedAt,
      );
}
