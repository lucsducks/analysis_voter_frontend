class PartidoPoliticoDistrito {
  Map<String, int> agrupacionesPoliticas;
  String departamento;
  String provincia;
  String distrito;

  PartidoPoliticoDistrito({
    required this.agrupacionesPoliticas,
    required this.departamento,
    required this.provincia,
    required this.distrito,
  });

  factory PartidoPoliticoDistrito.fromJson(Map<String, dynamic> json) {
    Map<String, int> agrupaciones = {};
    json['AGRUPACIONES_POLITICAS'].forEach((key, value) {
      agrupaciones[key] = value ?? 0;
    });

    return PartidoPoliticoDistrito(
      agrupacionesPoliticas: agrupaciones,
      departamento: json['DEPARTAMENTO'],
      provincia: json['PROVINCIA'],
      distrito: json['DISTRITO'],
    );
  }
}

List<PartidoPoliticoDistrito> parsePartidoPoliticoDistritoList(
    List<dynamic> jsonList) {
  return jsonList
      .map((jsonItem) => PartidoPoliticoDistrito.fromJson(jsonItem))
      .toList();
}
