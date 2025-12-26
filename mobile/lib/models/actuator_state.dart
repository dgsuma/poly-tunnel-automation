class ActuatorState {
  final bool pumpActive;
  final bool mistersActive;
  final DateTime lastUpdated;

  ActuatorState({
    required this.pumpActive,
    required this.mistersActive,
    required this.lastUpdated,
  });

  factory ActuatorState.fromJson(Map<String, dynamic> json) {
    return ActuatorState(
      pumpActive: json['pumpActive'] as bool? ?? false,
      mistersActive: json['mistersActive'] as bool? ?? false,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pumpActive': pumpActive,
      'mistersActive': mistersActive,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  ActuatorState copyWith({
    bool? pumpActive,
    bool? mistersActive,
    DateTime? lastUpdated,
  }) {
    return ActuatorState(
      pumpActive: pumpActive ?? this.pumpActive,
      mistersActive: mistersActive ?? this.mistersActive,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
