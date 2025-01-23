class ApiWord {
  final int externalId;
  final String? stress;
  final String translation;
  final String? redirectTo;

  ApiWord({
    required this.externalId,
    required this.translation,
    required this.redirectTo,
    this.stress,
  });
}
