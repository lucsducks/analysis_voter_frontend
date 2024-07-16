class DataGeneroProvinciaDistrito {
  String departamento;
  String provincia;
  String distrito;
  int numeroElectores;
  int electoresVarones;
  int electoresMujeres;
  int electoresJovenes;
  int electoresAdultos;
  int electores70adultos;
  double porcentajeVarones;
  double porcentajeMujeres;
  double porcentajeJovenes;
  double porcentaje70adultos;

  DataGeneroProvinciaDistrito({
    required this.departamento,
    required this.provincia,
    required this.distrito,
    required this.numeroElectores,
    required this.electoresVarones,
    required this.electoresMujeres,
    required this.porcentajeVarones,
    required this.porcentajeMujeres,
    required this.electoresJovenes,
    required this.electores70adultos,
    required this.porcentajeJovenes,
    required this.porcentaje70adultos,
    required this.electoresAdultos,
  });

  factory DataGeneroProvinciaDistrito.fromJson(Map<String, dynamic> json) {
    return DataGeneroProvinciaDistrito(
      departamento: json['Región'] ?? 'Departamento',
      provincia: json['Provincia'] ?? 'Provincia',
      distrito: json['Distrito'] ?? 'Distrito',
      numeroElectores: json['Número de electores'] ?? 0,
      electoresVarones: json['Electores varones'] ?? 0,
      electoresMujeres: json['Electores mujeres'] ?? 0,
      porcentajeVarones: json['% Varones'] ?? 0.0,
      porcentajeMujeres: json['% Mujeres'] ?? 0.0,
      electoresAdultos: json['Electores adultos'] ?? 0,
      electoresJovenes: json['Electores jóvenes *'] ?? 0,
      electores70adultos: json['Electores mayores de 70 años'] ?? 0,
      porcentajeJovenes: json['% Electores jóvenes'] ?? 0.0,
      porcentaje70adultos: json['% Electores mayores de 70 años'] ?? 0.0,
    );
  }
}

List<DataGeneroProvinciaDistrito> parseDataGeneroProvinciaDistritoList(
    List<dynamic> jsonList) {
  return jsonList
      .map((jsonItem) => DataGeneroProvinciaDistrito.fromJson(jsonItem))
      .toList();
}
