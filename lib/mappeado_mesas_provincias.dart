class DataGeneralProvincia {
  String departamento;
  int electoresHabiles;
  int noVotantes;
  String provincia;
  int totalVotos;
  int votosBlancos;
  int votosImpug;
  int votosNulos;
  int votosObtenidosTotal;

  DataGeneralProvincia({
    required this.departamento,
    required this.electoresHabiles,
    required this.noVotantes,
    required this.provincia,
    required this.totalVotos,
    required this.votosBlancos,
    required this.votosImpug,
    required this.votosNulos,
    required this.votosObtenidosTotal,
  });

  factory DataGeneralProvincia.fromJson(Map<String, dynamic> json) {
    return DataGeneralProvincia(
      departamento: json['DEPARTAMENTO'],
      electoresHabiles: json['ELECTORES_HABILES'],
      noVotantes: json['NO_VOTANTES'],
      provincia: json['PROVINCIA'],
      totalVotos: json['TOTAL_VOTOS'],
      votosBlancos: json['VOTOS_BLANCOS'],
      votosImpug: json['VOTOS_IMPUG'],
      votosNulos: json['VOTOS_NULOS'],
      votosObtenidosTotal: json['VOTOS_OBTENIDOS_TOTAL'],
    );
  }
}

List<DataGeneralProvincia> parseDataGeneralProvinciaList(
    List<dynamic> jsonList) {
  return jsonList
      .map((jsonItem) => DataGeneralProvincia.fromJson(jsonItem))
      .toList();
}
