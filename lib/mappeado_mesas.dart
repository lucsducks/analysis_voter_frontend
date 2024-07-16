class DataMesas {
  String departamento;
  String distrito;
  int electoresHabiles;
  int mesa;
  int noVotantes;
  String provincia;
  int totalVotos;
  int ubigeo;
  bool verificacion;
  int votosBlancos;
  int votosImpug;
  int votosNulos;
  int votosObtenidos;

  DataMesas({
    required this.departamento,
    required this.distrito,
    required this.electoresHabiles,
    required this.mesa,
    required this.noVotantes,
    required this.provincia,
    required this.totalVotos,
    required this.ubigeo,
    required this.verificacion,
    required this.votosBlancos,
    required this.votosImpug,
    required this.votosNulos,
    required this.votosObtenidos,
  });
  String get mesaFormatted {
    String mesaStr = mesa.toString();
    if (mesaStr.length == 5) {
      return '0$mesaStr';
    } else {
      return mesaStr;
    }
  }

  factory DataMesas.fromJson(Map<String, dynamic> json) {
    return DataMesas(
      departamento: json['DEPARTAMENTO'],
      distrito: json['DISTRITO'],
      electoresHabiles: json['ELECTORES_HABILES'],
      mesa: json['MESA'],
      noVotantes: json['NO_VOTANTES'],
      provincia: json['PROVINCIA'],
      totalVotos: json['TOTAL_VOTOS'],
      ubigeo: json['UBIGEO'],
      verificacion: json['VERIFICACION'],
      votosBlancos: json['VOTOS_BLANCOS'],
      votosImpug: json['VOTOS_IMPUG'],
      votosNulos: json['VOTOS_NULOS'],
      votosObtenidos: json['VOTOS_OBTENIDOS'],
    );
  }
}

List<DataMesas> parseDataMesasList(List<dynamic> jsonList) {
  return jsonList.map((jsonItem) => DataMesas.fromJson(jsonItem)).toList();
}
