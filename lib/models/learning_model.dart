class LearningModel {
  final String commandType;
  final List<String> variations;
  final int usageCount;
  final DateTime lastUsed;
  final double successRate;
  final Map<String, dynamic> metadata;
  
  LearningModel({
    required this.commandType,
    this.variations = const [],
    this.usageCount = 0,
    required this.lastUsed,
    this.successRate = 1.0,
    this.metadata = const {},
  });
  
  factory LearningModel.fromJson(Map<String, dynamic> json) {
    return LearningModel(
      commandType: json['commandType'] ?? '',
      variations: List<String>.from(json['variations'] ?? []),
      usageCount: json['usageCount'] ?? 0,
      lastUsed: DateTime.parse(json['lastUsed'] ?? DateTime.now().toIso8601String()),
      successRate: (json['successRate'] ?? 1.0).toDouble(),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'commandType': commandType,
      'variations': variations,
      'usageCount': usageCount,
      'lastUsed': lastUsed.toIso8601String(),
      'successRate': successRate,
      'metadata': metadata,
    };
  }
  
  LearningModel copyWith({
    String? commandType,
    List<String>? variations,
    int? usageCount,
    DateTime? lastUsed,
    double? successRate,
    Map<String, dynamic>? metadata,
  }) {
    return LearningModel(
      commandType: commandType ?? this.commandType,
      variations: variations ?? this.variations,
      usageCount: usageCount ?? this.usageCount,
      lastUsed: lastUsed ?? this.lastUsed,
      successRate: successRate ?? this.successRate,
      metadata: metadata ?? this.metadata,
    );
  }
  
  LearningModel incrementUsage() {
    return copyWith(
      usageCount: usageCount + 1,
      lastUsed: DateTime.now(),
    );
  }
  
  LearningModel updateSuccessRate(bool success) {
    final totalAttempts = usageCount + 1;
    final successfulAttempts = (successRate * usageCount) + (success ? 1 : 0);
    final newSuccessRate = successfulAttempts / totalAttempts;
    
    return copyWith(
      usageCount: totalAttempts,
      successRate: newSuccessRate,
      lastUsed: DateTime.now(),
    );
  }
  
  LearningModel addVariation(String variation) {
    if (variations.contains(variation)) return this;
    return copyWith(
      variations: [...variations, variation],
    );
  }
  
  @override
  String toString() => 'LearningModel(commandType: $commandType, usageCount: $usageCount)';
}

class VoiceProfileModel {
  final String id;
  final String name;
  final Map<String, dynamic> voiceCharacteristics;
  final DateTime createdAt;
  final DateTime lastUsed;
  final int usageCount;
  
  VoiceProfileModel({
    required this.id,
    required this.name,
    this.voiceCharacteristics = const {},
    required this.createdAt,
    required this.lastUsed,
    this.usageCount = 0,
  });
  
  factory VoiceProfileModel.fromJson(Map<String, dynamic> json) {
    return VoiceProfileModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      voiceCharacteristics: Map<String, dynamic>.from(json['voiceCharacteristics'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      lastUsed: DateTime.parse(json['lastUsed'] ?? DateTime.now().toIso8601String()),
      usageCount: json['usageCount'] ?? 0,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'voiceCharacteristics': voiceCharacteristics,
      'createdAt': createdAt.toIso8601String(),
      'lastUsed': lastUsed.toIso8601String(),
      'usageCount': usageCount,
    };
  }
  
  VoiceProfileModel copyWith({
    String? id,
    String? name,
    Map<String, dynamic>? voiceCharacteristics,
    DateTime? createdAt,
    DateTime? lastUsed,
    int? usageCount,
  }) {
    return VoiceProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      voiceCharacteristics: voiceCharacteristics ?? this.voiceCharacteristics,
      createdAt: createdAt ?? this.createdAt,
      lastUsed: lastUsed ?? this.lastUsed,
      usageCount: usageCount ?? this.usageCount,
    );
  }
}
