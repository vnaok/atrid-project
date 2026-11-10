class VisitorState {
  final int misionesCompletadas;
  final int puntos;

  const VisitorState({
    required this.misionesCompletadas,
    required this.puntos,
  });

  VisitorState copyWith({
    int? misionesCompletadas,
    int? puntos,
  }) {
    return VisitorState(
      misionesCompletadas:
      misionesCompletadas ?? this.misionesCompletadas,
      puntos: puntos ?? this.puntos,
    );
  }

  factory VisitorState.inicial() {
    return const VisitorState(
      misionesCompletadas: 0,
      puntos: 0,
    );
  }
}