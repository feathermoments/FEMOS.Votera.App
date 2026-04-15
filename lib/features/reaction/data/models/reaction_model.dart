import 'package:votera_app/features/reaction/domain/entities/reaction_entity.dart';

class ReactionModel extends ReactionEntity {
  const ReactionModel({
    required super.code,
    required super.emoji,
    required super.count,
  });

  factory ReactionModel.fromJson(Map<String, dynamic> json) {
    return ReactionModel(
      code: json['code'] as String? ?? '',
      emoji: json['emoji'] as String? ?? '',
      count: (json['count'] as num? ?? 0).toInt(),
    );
  }
}
