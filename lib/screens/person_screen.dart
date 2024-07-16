import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:sociopolitico/mapeado_genero.dart';
import 'package:sociopolitico/mapeado_genero_provincia.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter/material.dart';

class PersonScreen extends StatefulWidget {
  const PersonScreen({super.key});

  @override
  _PersonScreenState createState() => _PersonScreenState();
}

class _PersonScreenState extends State<PersonScreen> {
  List<DataGeneralGenero> data = [];
  List<DataGeneroProvinciaDistrito> distritoData = [];
  List<DataGeneroProvinciaDistrito> provinciaData = [];
  Dio dio = Dio();
  int limit = 300;
  int offset = 0;
  String provincia = '';
  String provinciaSave = '';
  bool isInitialLoad = false;
  bool noResultsFound = false;
  bool isProvince = true;
  String year = '2022-g';
  final List<int> limits = [100, 300, 500, 700, 1500];
  final List<String> years = ['2014-g', '2014-v2-g', '2018-g', '2022-g'];
  final List<String> provincias = [
    '',
    'Ambo',
    'Huanuco',
    'Huamalies',
    'Dos de mayo',
    'Lauricocha',
    'Leoncio Prado',
    'Marañon',
    'Pachitea',
    'Yarowilca',
    'Puerto inca',
  ];
  @override
  void initState() {
    super.initState();
    _search(); // Llamada inicial para cargar datos del año 2022
  }

  Future<void> fetchData() async {
    try {
      final response = await dio
          .get('http://127.0.0.1:5000/analisis_genero', queryParameters: {
        'limit': limit,
        'offset': offset,
        'datayear': year,
        if (provincia.isNotEmpty) 'provincia': provincia,
      });
      setState(() {
        data = parseDataGeneralGeneroList(response.data);
        noResultsFound = data.isEmpty;
        isInitialLoad = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        isInitialLoad = false;
      });
    }
  }

  Future<void> fetchProvinciaData() async {
    try {
      final response = await dio.get(
          'http://127.0.0.1:5000/analisis_genero_provincia',
          queryParameters: {
            'datayear': year,
          });
      setState(() {
        provinciaData = parseDataGeneroProvinciaDistritoList(response.data);
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> fetchDistritoData() async {
    try {
      final response = await dio.get(
          'http://127.0.0.1:5000/analisis_distrito_genero',
          queryParameters: {
            'datayear': year,
            if (provincia.isNotEmpty) 'provincia': provincia,
          });
      setState(() {
        distritoData = parseDataGeneroProvinciaDistritoList(response.data);
      });
    } catch (e) {
      print(e);
    }
  }

  void _loadNextPage() {
    setState(() {
      offset += limit;
      isInitialLoad = true;
      noResultsFound = false;
    });
    fetchData();
  }

  void _loadPreviousPage() {
    if (offset - limit >= 0) {
      setState(() {
        offset -= limit;
        isInitialLoad = true;
        noResultsFound = false;
      });
      fetchData();
    }
  }

  void _search() {
    setState(() {
      offset = 0;
      isInitialLoad = true;
      noResultsFound = false;
    });
    fetchData();

    if (provincia.isEmpty) {
      fetchProvinciaData();
    } else {
      fetchDistritoData();
    }
  }

  void _reload() {
    setState(() {
      isProvince = true;
      isInitialLoad = true;
      noResultsFound = false;
      provincia = '';
    });
    fetchData();
    fetchProvinciaData();
    fetchDistritoData();
  }

  void _onLimitChange(int? newLimit) {
    if (newLimit != null) {
      setState(() {
        limit = newLimit;
        offset = 0;
        isInitialLoad = false;
        noResultsFound = false;
      });
    }
  }

  void _onProvinciaChange(String? newProvincia) {
    if (newProvincia != null) {
      setState(() {
        provincia = newProvincia;
        provinciaSave = newProvincia;
        isProvince = provincia.isEmpty;
      });
    }
  }

  void _onYearChange(String? newYear) {
    if (newYear != null) {
      setState(() {
        year = newYear;
        offset = 0;
        isInitialLoad = false;
        noResultsFound = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Analisis de Resultados Electorales'),
        centerTitle: true,
      ),
      body: Row(
        children: [
          SidebarX(
            controller: SidebarXController(selectedIndex: 0),
            items: [
              SidebarXItem(
                icon: Icons.home,
                label: 'Home',
                onTap: () => context.go('/'),
              ),
              SidebarXItem(
                icon: Icons.person_3_outlined,
                label: 'Home',
                onTap: () => context.go('/person'),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: DropdownButton<String>(
                          value: year,
                          onChanged: _onYearChange,
                          items: years.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          isExpanded: true,
                          hint: Text('Seleccionar Año'),
                        ),
                      ),
                      Expanded(
                        flex: 10,
                        child: DropdownButton<String>(
                          value: provincia,
                          onChanged: _onProvinciaChange,
                          items: provincias.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          isExpanded: true,
                          hint: Text('Seleccionar Provincia'),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: DropdownButton<int>(
                          value: limit,
                          onChanged: _onLimitChange,
                          items: limits.map((int value) {
                            return DropdownMenuItem<int>(
                              value: value,
                              child: Text(
                                '$value',
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FilledButton(
                      onPressed: _search,
                      child: Text('Consultar'),
                    ),
                  ),
                  Expanded(
                    child: isInitialLoad
                        ? Center(
                            child: CircularProgressIndicator(),
                          )
                        : data.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('No se encontraron resultados'),
                                    ElevatedButton(
                                      onPressed: _reload,
                                      child: Text('Recargar'),
                                    ),
                                  ],
                                ),
                              )
                            : Column(
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: SfCartesianChart(
                                        primaryXAxis: CategoryAxis(),
                                        title: ChartTitle(
                                            text:
                                                'Resultados Electorales de las mesas de votación'),
                                        legend: Legend(isVisible: true),
                                        tooltipBehavior: TooltipBehavior(
                                          enable: true,
                                        ),
                                        series: <CartesianSeries<
                                            DataGeneralGenero, String>>[
                                          LineSeries<DataGeneralGenero, String>(
                                            dataSource: data,
                                            isVisibleInLegend: false,

                                            xValueMapper: (DataGeneralGenero
                                                        mesaDataGenero,
                                                    _) =>
                                                mesaDataGenero.numeroElectores
                                                    .toString() +
                                                ' ' +
                                                mesaDataGenero.distrito
                                                    .toString(),
                                            yValueMapper: (DataGeneralGenero
                                                        mesaDataGenero,
                                                    _) =>
                                                mesaDataGenero.numeroElectores,
                                            name: 'Electores general',
                                            // Enable data label
                                            dataLabelSettings:
                                                DataLabelSettings(
                                                    isVisible: true),
                                          ),
                                          LineSeries<DataGeneralGenero, String>(
                                            dataSource: data,
                                            initialIsVisible: false,

                                            xValueMapper: (DataGeneralGenero
                                                        mesaDataGenero,
                                                    _) =>
                                                mesaDataGenero.numeroElectores
                                                    .toString() +
                                                ' ' +
                                                mesaDataGenero.distrito
                                                    .toString(),
                                            yValueMapper: (DataGeneralGenero
                                                        mesaDataGenero,
                                                    _) =>
                                                mesaDataGenero.electoresVarones,
                                            name: 'Electores varones',
                                            // Enable data label
                                            dataLabelSettings:
                                                DataLabelSettings(
                                                    isVisible: true),
                                          ),
                                          LineSeries<DataGeneralGenero, String>(
                                            dataSource: data,
                                            initialIsVisible: false,
                                            xValueMapper: (DataGeneralGenero
                                                        mesaDataGenero,
                                                    _) =>
                                                mesaDataGenero.numeroElectores
                                                    .toString() +
                                                ' ' +
                                                mesaDataGenero.distrito
                                                    .toString(),
                                            yValueMapper: (DataGeneralGenero
                                                        mesaDataGenero,
                                                    _) =>
                                                mesaDataGenero.electoresMujeres,
                                            name: 'Electores mujeres',
                                            // Enable data label
                                            dataLabelSettings:
                                                DataLabelSettings(
                                                    isVisible: true),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  isProvince
                                      ? Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: SfCartesianChart(
                                              primaryXAxis: CategoryAxis(),
                                              title: const ChartTitle(
                                                  text:
                                                      'Resultados Electorales por edad'),
                                              legend: Legend(isVisible: true),
                                              tooltipBehavior: TooltipBehavior(
                                                enable: true,
                                              ),
                                              series: <CartesianSeries<
                                                  DataGeneroProvinciaDistrito,
                                                  String>>[
                                                LineSeries<
                                                    DataGeneroProvinciaDistrito,
                                                    String>(
                                                  dataSource: provinciaData,
                                                  isVisibleInLegend: false,

                                                  xValueMapper:
                                                      (DataGeneroProvinciaDistrito
                                                                  mesaDataGenero,
                                                              _) =>
                                                          mesaDataGenero
                                                              .numeroElectores
                                                              .toString() +
                                                          ' ' +
                                                          mesaDataGenero
                                                              .distrito
                                                              .toString(),
                                                  yValueMapper:
                                                      (DataGeneroProvinciaDistrito
                                                                  mesaDataGenero,
                                                              _) =>
                                                          mesaDataGenero
                                                              .numeroElectores,
                                                  name: 'Electores general',
                                                  // Enable data label
                                                  dataLabelSettings:
                                                      DataLabelSettings(
                                                          isVisible: true),
                                                ),
                                                LineSeries<
                                                    DataGeneroProvinciaDistrito,
                                                    String>(
                                                  dataSource: provinciaData,
                                                  initialIsVisible: false,
                                                  xValueMapper:
                                                      (DataGeneroProvinciaDistrito
                                                                  mesaDataGenero,
                                                              _) =>
                                                          mesaDataGenero
                                                              .numeroElectores
                                                              .toString() +
                                                          ' ' +
                                                          mesaDataGenero
                                                              .distrito
                                                              .toString(),
                                                  yValueMapper:
                                                      (DataGeneroProvinciaDistrito
                                                                  mesaDataGenero,
                                                              _) =>
                                                          mesaDataGenero
                                                              .electoresAdultos,
                                                  name: 'Electores adultos',
                                                  // Enable data label
                                                  dataLabelSettings:
                                                      DataLabelSettings(
                                                          isVisible: true),
                                                ),
                                                LineSeries<
                                                    DataGeneroProvinciaDistrito,
                                                    String>(
                                                  dataSource: provinciaData,
                                                  initialIsVisible: false,
                                                  xValueMapper:
                                                      (DataGeneroProvinciaDistrito
                                                                  mesaDataGenero,
                                                              _) =>
                                                          mesaDataGenero
                                                              .numeroElectores
                                                              .toString() +
                                                          ' ' +
                                                          mesaDataGenero
                                                              .distrito
                                                              .toString(),
                                                  yValueMapper:
                                                      (DataGeneroProvinciaDistrito
                                                                  mesaDataGenero,
                                                              _) =>
                                                          mesaDataGenero
                                                              .electores70adultos,
                                                  name:
                                                      'Electores mayores de 70 años',
                                                  // Enable data label
                                                  dataLabelSettings:
                                                      DataLabelSettings(
                                                          isVisible: true),
                                                ),
                                                LineSeries<
                                                    DataGeneroProvinciaDistrito,
                                                    String>(
                                                  dataSource: provinciaData,
                                                  initialIsVisible: false,
                                                  xValueMapper:
                                                      (DataGeneroProvinciaDistrito
                                                                  mesaDataGenero,
                                                              _) =>
                                                          mesaDataGenero
                                                              .numeroElectores
                                                              .toString() +
                                                          ' ' +
                                                          mesaDataGenero
                                                              .distrito
                                                              .toString(),
                                                  yValueMapper:
                                                      (DataGeneroProvinciaDistrito
                                                                  mesaDataGenero,
                                                              _) =>
                                                          mesaDataGenero
                                                              .electoresJovenes,
                                                  name: 'Electores jovenes',
                                                  // Enable data label
                                                  dataLabelSettings:
                                                      DataLabelSettings(
                                                          isVisible: true),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      : Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: SfCartesianChart(
                                              primaryXAxis: CategoryAxis(),
                                              title: const ChartTitle(
                                                  text:
                                                      'Resultados Electorales por edad'),
                                              legend: Legend(isVisible: true),
                                              tooltipBehavior: TooltipBehavior(
                                                enable: true,
                                              ),
                                              series: <CartesianSeries<
                                                  DataGeneroProvinciaDistrito,
                                                  String>>[
                                                LineSeries<
                                                    DataGeneroProvinciaDistrito,
                                                    String>(
                                                  dataSource: distritoData,
                                                  isVisibleInLegend: false,

                                                  xValueMapper:
                                                      (DataGeneroProvinciaDistrito
                                                                  mesaDataGenero,
                                                              _) =>
                                                          mesaDataGenero
                                                              .numeroElectores
                                                              .toString() +
                                                          ' ' +
                                                          mesaDataGenero
                                                              .distrito
                                                              .toString(),
                                                  yValueMapper:
                                                      (DataGeneroProvinciaDistrito
                                                                  mesaDataGenero,
                                                              _) =>
                                                          mesaDataGenero
                                                              .numeroElectores,
                                                  name: 'Electores general',
                                                  // Enable data label
                                                  dataLabelSettings:
                                                      DataLabelSettings(
                                                          isVisible: true),
                                                ),
                                                LineSeries<
                                                    DataGeneroProvinciaDistrito,
                                                    String>(
                                                  dataSource: distritoData,
                                                  initialIsVisible: false,
                                                  xValueMapper:
                                                      (DataGeneroProvinciaDistrito
                                                                  mesaDataGenero,
                                                              _) =>
                                                          mesaDataGenero
                                                              .numeroElectores
                                                              .toString() +
                                                          ' ' +
                                                          mesaDataGenero
                                                              .distrito
                                                              .toString(),
                                                  yValueMapper:
                                                      (DataGeneroProvinciaDistrito
                                                                  mesaDataGenero,
                                                              _) =>
                                                          mesaDataGenero
                                                              .electoresAdultos,
                                                  name: 'Electores adultos',
                                                  // Enable data label
                                                  dataLabelSettings:
                                                      DataLabelSettings(
                                                          isVisible: true),
                                                ),
                                                LineSeries<
                                                    DataGeneroProvinciaDistrito,
                                                    String>(
                                                  dataSource: distritoData,
                                                  initialIsVisible: false,
                                                  xValueMapper:
                                                      (DataGeneroProvinciaDistrito
                                                                  mesaDataGenero,
                                                              _) =>
                                                          mesaDataGenero
                                                              .numeroElectores
                                                              .toString() +
                                                          ' ' +
                                                          mesaDataGenero
                                                              .distrito
                                                              .toString(),
                                                  yValueMapper:
                                                      (DataGeneroProvinciaDistrito
                                                                  mesaDataGenero,
                                                              _) =>
                                                          mesaDataGenero
                                                              .electores70adultos,
                                                  name:
                                                      'Electores mayores de 70 años',
                                                  // Enable data label
                                                  dataLabelSettings:
                                                      DataLabelSettings(
                                                          isVisible: true),
                                                ),
                                                LineSeries<
                                                    DataGeneroProvinciaDistrito,
                                                    String>(
                                                  dataSource: distritoData,
                                                  initialIsVisible: false,
                                                  xValueMapper:
                                                      (DataGeneroProvinciaDistrito
                                                                  mesaDataGenero,
                                                              _) =>
                                                          mesaDataGenero
                                                              .numeroElectores
                                                              .toString() +
                                                          ' ' +
                                                          mesaDataGenero
                                                              .distrito
                                                              .toString(),
                                                  yValueMapper:
                                                      (DataGeneroProvinciaDistrito
                                                                  mesaDataGenero,
                                                              _) =>
                                                          mesaDataGenero
                                                              .electoresJovenes,
                                                  name: 'Electores jovenes',
                                                  // Enable data label
                                                  dataLabelSettings:
                                                      DataLabelSettings(
                                                          isVisible: true),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                ],
                              ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
