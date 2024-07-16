class DataGeneralGenero {
  String departamento;
  String provincia;
  String distrito;
  int numeroElectores;
  int electoresVarones;
  int electoresMujeres;
  double porcentajeVarones;
  double porcentajeMujeres;

  DataGeneralGenero({
    required this.departamento,
    required this.provincia,
    required this.distrito,
    required this.numeroElectores,
    required this.electoresVarones,
    required this.electoresMujeres,
    required this.porcentajeVarones,
    required this.porcentajeMujeres,
  });

  factory DataGeneralGenero.fromJson(Map<String, dynamic> json) {
    return DataGeneralGenero(
      departamento: json['Región'] ?? 'Departamento',
      provincia: json['Provincia'] ?? 'Provincia',
      distrito: json['Distrito'] ?? 'Distrito',
      numeroElectores: json['Número de electores'] ?? 0,
      electoresVarones: json['Electores varones'] ?? 0,
      electoresMujeres: json['Electores mujeres'] ?? 0,
      porcentajeVarones: json['% Varones'] ?? 0.0,
      porcentajeMujeres: json['% Mujeres'] ?? 0.0,
    );
  }
}

List<DataGeneralGenero> parseDataGeneralGeneroList(List<dynamic> jsonList) {
  return jsonList
      .map((jsonItem) => DataGeneralGenero.fromJson(jsonItem))
      .toList();
}
