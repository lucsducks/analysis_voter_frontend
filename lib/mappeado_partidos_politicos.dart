class PartidoPolitico {
  Map<String, int> agrupacionesPoliticas;
  String departamento;
  String provincia;

  PartidoPolitico({
    required this.agrupacionesPoliticas,
    required this.departamento,
    required this.provincia,
  });

  factory PartidoPolitico.fromJson(Map<String, dynamic> json) {
    Map<String, int> agrupaciones = {};
    json['AGRUPACIONES_POLITICAS'].forEach((key, value) {
      agrupaciones[key] = value ?? 0;
    });

    return PartidoPolitico(
      agrupacionesPoliticas: agrupaciones,
      departamento: json['DEPARTAMENTO'],
      provincia: json['PROVINCIA'],
    );
  }
}

List<PartidoPolitico> parsePartidoPoliticoList(List<dynamic> jsonList) {
  return jsonList
      .map((jsonItem) => PartidoPolitico.fromJson(jsonItem))
      .toList();
}
