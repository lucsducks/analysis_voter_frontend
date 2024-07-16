class DataGeneralDistrito {
  String departamento;
  String distrito;
  int electoresHabiles;
  int noVotantes;
  String provincia;
  int totalVotos;
  int votosBlancos;
  int votosImpug;
  int votosNulos;
  int votosObtenidos;

  DataGeneralDistrito({
    required this.departamento,
    required this.distrito,
    required this.electoresHabiles,
    required this.noVotantes,
    required this.provincia,
    required this.totalVotos,
    required this.votosBlancos,
    required this.votosImpug,
    required this.votosNulos,
    required this.votosObtenidos,
  });

  factory DataGeneralDistrito.fromJson(Map<String, dynamic> json) {
    return DataGeneralDistrito(
      departamento: json['DEPARTAMENTO'],
      distrito: json['DISTRITO'],
      electoresHabiles: json['ELECTORES_HABILES'],
      noVotantes: json['NO_VOTANTES'],
      provincia: json['PROVINCIA'],
      totalVotos: json['TOTAL_VOTOS'],
      votosBlancos: json['VOTOS_BLANCOS'],
      votosImpug: json['VOTOS_IMPUG'],
      votosNulos: json['VOTOS_NULOS'],
      votosObtenidos: json['VOTOS_OBTENIDOS_TOTAL'],
    );
  }
}

List<DataGeneralDistrito> parseDataGeneralDistritoList(List<dynamic> jsonList) {
  return jsonList
      .map((jsonItem) => DataGeneralDistrito.fromJson(jsonItem))
      .toList();
}
