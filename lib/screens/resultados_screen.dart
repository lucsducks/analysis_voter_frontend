import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:sociopolitico/mapeado_resultados.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter/material.dart';

class ResultadosScreen extends StatefulWidget {
  const ResultadosScreen({super.key});

  @override
  _ResultadosScreenState createState() => _ResultadosScreenState();
}

class _ResultadosScreenState extends State<ResultadosScreen> {
  List<DataGeneralVotos> data = [];
  Dio dio = Dio();
  bool isInitialLoad = false;
  bool noResultsFound = false;
  String year = '2022-r';
  final List<String> years = [
    '2014-r',
    '2014-v2-r',
    '2018-r',
    '2018-v2-r',
    '2022-r'
  ];

  @override
  void initState() {
    super.initState();
    _search();
  }

  Future<void> fetchData() async {
    try {
      final response = await dio
          .get('http://127.0.0.1:5000/analisis_resultados', queryParameters: {
        'datayear': year,
      });
      setState(() {
        data = parseDataGeneralVotosList(response.data);
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

  void _search() {
    setState(() {
      isInitialLoad = true;
      noResultsFound = false;
    });
    fetchData();
  }

  void _reload() {
    setState(() {
      isInitialLoad = true;
      noResultsFound = false;
    });
    fetchData();
  }

  void _onYearChange(String? newYear) {
    if (newYear != null) {
      setState(() {
        year = newYear;
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
        title: Text('Analisis de Resultados Electorales por partido político'),
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
                label: 'Personas',
                onTap: () => context.go('/person'),
              ),
              SidebarXItem(
                icon: Icons.bar_chart_outlined,
                selectable: true,
                label: 'Resultados',
                onTap: () => context.go('/resultados'),
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
                                        legend: Legend(isVisible: true),
                                        tooltipBehavior: TooltipBehavior(
                                          enable: true,
                                        ),
                                        series: <CartesianSeries<
                                            DataGeneralVotos, String>>[
                                          StackedColumnSeries<DataGeneralVotos,
                                              String>(
                                            pointColorMapper: (DataGeneralVotos
                                                    mesaDataGenero,
                                                _) {
                                              DataGeneralVotos
                                                  partidoMayorVoto =
                                                  encontrarMayorVoto(data);

                                              if (mesaDataGenero
                                                      .organizacionPolitica ==
                                                  'VOTOS EN BLANCO') {
                                                return Colors.grey;
                                              } else if (mesaDataGenero
                                                      .organizacionPolitica ==
                                                  'VOTOS NULOS') {
                                                return Colors.black54;
                                              } else if (mesaDataGenero
                                                      .organizacionPolitica ==
                                                  partidoMayorVoto
                                                      .organizacionPolitica) {
                                                return Colors
                                                    .green; // Resaltar en verde el partido con más votos
                                              } else {
                                                return Colors.blue;
                                              }
                                            },
                                            dataSource: data,
                                            isVisibleInLegend: false,
                                            xValueMapper: (DataGeneralVotos
                                                        mesaDataGenero,
                                                    _) =>
                                                mesaDataGenero.votos
                                                    .toString() +
                                                ' ' +
                                                mesaDataGenero
                                                    .organizacionPolitica +
                                                ' ' +
                                                (mesaDataGenero
                                                            .porcentajeVotos *
                                                        100)
                                                    .toStringAsFixed(2)
                                                    .toString() +
                                                '%',
                                            yValueMapper: (DataGeneralVotos
                                                        mesaDataGenero,
                                                    _) =>
                                                mesaDataGenero.votos,
                                            name: 'Votos general por partido',
                                            dataLabelSettings:
                                                DataLabelSettings(
                                                    isVisible: true),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
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
