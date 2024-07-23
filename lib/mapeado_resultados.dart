class DataGeneralVotos {
  String organizacionPolitica;
  String region;
  String tipoOrganizacionPolitica;
  int votos;
  double porcentajeVotos;

  DataGeneralVotos({
    required this.organizacionPolitica,
    required this.region,
    required this.tipoOrganizacionPolitica,
    required this.votos,
    required this.porcentajeVotos,
  });

  factory DataGeneralVotos.fromJson(Map<String, dynamic> json) {
    return DataGeneralVotos(
      organizacionPolitica:
          json['Organización Política'] ?? 'Organización Política',
      region: json['Región'] ?? 'Región',
      tipoOrganizacionPolitica:
          json['Tipo Organización Política'] ?? 'Tipo Organización Política',
      votos: json['Votos'] ?? 0,
      porcentajeVotos: (json['% Votos'] ?? 0.0).toDouble(),
    );
  }
}

DataGeneralVotos encontrarMayorVoto(List<DataGeneralVotos> data) {
  DataGeneralVotos mayorVoto = data[0];

  for (var item in data) {
    if (item.votos > mayorVoto.votos) {
      mayorVoto = item;
    }
  }

  return mayorVoto;
}

List<DataGeneralVotos> parseDataGeneralVotosList(List<dynamic> jsonList) {
  return jsonList
      .map((jsonItem) => DataGeneralVotos.fromJson(jsonItem))
      .toList();
}

List<DataGeneralVotos> adjustPorcentajeVotos(List<DataGeneralVotos> dataList) {
  return dataList.map((item) {
    item.porcentajeVotos =
        double.parse(item.porcentajeVotos.toStringAsFixed(3));
    return item;
  }).toList();
}
