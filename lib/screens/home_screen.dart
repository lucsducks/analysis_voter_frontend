import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:sociopolitico/mappeado_mesas_distrito.dart';
import 'package:sociopolitico/mappeado_mesas_provincias.dart';
import 'package:sociopolitico/mappeado_partidos_politicos.dart';
import 'package:sociopolitico/mappeado_partidos_politicos_distritos.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../mappeado_mesas.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<DataMesas> data = [];
  List<DataGeneralDistrito> distritoData = [];
  List<DataGeneralProvincia> provinciaData = [];
  List<PartidoPolitico> politicosData = [];
  List<PartidoPoliticoDistrito> politicosDistritoData = [];
  Dio dio = Dio();
  int limit = 300;
  int offset = 0;
  String provincia = '';
  String provinciaSave = '';
  bool isInitialLoad = false;
  bool noResultsFound = false;
  bool isProvince = true;
  String year = '2022';
  final List<int> limits = [100, 300, 500, 700, 1500];
  final List<String> years = ['2014', '2014-v2', '2018', '2022'];
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
  bool showTable = false; // Variable to toggle between chart and table

  @override
  void initState() {
    super.initState();
    _search(); // Llamada inicial para cargar datos del año 2022
  }

  Future<void> fetchData() async {
    try {
      final response =
          await dio.get('http://127.0.0.1:5000/analisis', queryParameters: {
        'limit': limit,
        'offset': offset,
        'datayear': year,
        if (provincia.isNotEmpty) 'provincia': provincia,
      });
      setState(() {
        data = parseDataMesasList(response.data);
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
      final response = await dio
          .get('http://127.0.0.1:5000/analisis_provincia', queryParameters: {
        'datayear': year,
      });
      setState(() {
        provinciaData = parseDataGeneralProvinciaList(response.data);
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> fetchpoliticosData() async {
    try {
      final response = await dio.get(
          'http://127.0.0.1:5000/analisis_provincia-politicos',
          queryParameters: {
            'datayear': year,
          });
      setState(() {
        politicosData = parsePartidoPoliticoList(response.data);
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> fetchpoliticosDistritoData() async {
    try {
      final response = await dio.get(
          'http://127.0.0.1:5000/analisis_distrito-politicos',
          queryParameters: {
            'datayear': year,
            if (provincia.isNotEmpty) 'provincia': provincia,
          });
      setState(() {
        politicosDistritoData = parsePartidoPoliticoDistritoList(response.data);
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> fetchDistritoData() async {
    try {
      final response = await dio
          .get('http://127.0.0.1:5000/analisis_distrito', queryParameters: {
        'datayear': year,
        if (provincia.isNotEmpty) 'provincia': provincia,
      });
      setState(() {
        distritoData = parseDataGeneralDistritoList(response.data);
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
      fetchpoliticosData();
    } else {
      fetchDistritoData();
      fetchpoliticosDistritoData();
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

  void copyToClipboard(String textToCopy, BuildContext context) {
    Clipboard.setData(ClipboardData(text: textToCopy)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Texto copiado al portapapeles"),
        duration: Duration(seconds: 2),
      ));
    });
  }

  void _toggleView() {
    setState(() {
      showTable = !showTable;
    });
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
                selectable: true,
                onTap: () => context.go('/'),
              ),
              SidebarXItem(
                icon: Icons.person_3_outlined,
                label: 'Personas',
                onTap: () => context.go('/person'),
              ),
              SidebarXItem(
                icon: Icons.bar_chart_outlined,
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FilledButton(
                          onPressed: _search,
                          child: Text('Consultar'),
                        ),
                        ElevatedButton(
                          onPressed: _toggleView,
                          child: Text(showTable ? 'Gráfico' : 'Tabla'),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: isInitialLoad
                        ? Center(
                            child: CircularProgressIndicator(),
                          )
                        : noResultsFound
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
                            : showTable
                                ? PaginatedDataTable(
                                    header: Text('Resultados Electorales'),
                                    columns: [
                                      DataColumn(label: Text('Departamento')),
                                      DataColumn(label: Text('Distrito')),
                                      DataColumn(label: Text('Mesa')),
                                      DataColumn(label: Text('No Votantes')),
                                      DataColumn(label: Text('Total Votos')),
                                      DataColumn(label: Text('Votos Blancos')),
                                      DataColumn(label: Text('Votos Nulos')),
                                      DataColumn(
                                          label: Text('Votos Impugnados')),
                                      DataColumn(
                                          label: Text('Votos Obtenidos')),
                                    ],
                                    source: MesasDataTableSource(
                                        data), // Aquí pasas tu lista de datos
                                    rowsPerPage: 7,
                                    showCheckboxColumn: false,
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
                                              builder: (dynamic data,
                                                  dynamic point,
                                                  dynamic series,
                                                  int pointIndex,
                                                  int seriesIndex) {
                                                String mesaNumero = point.x
                                                    .toString()
                                                    .split(' ')[0];
                                                String distrito = point.x
                                                    .toString()
                                                    .split(' ')[1];
                                                String url =
                                                    'https://resultadoshistorico.onpe.gob.pe/ERM2022/Actas/Numero/$mesaNumero';

                                                return InkWell(
                                                  onTap: () async {
                                                    if (year == '2022') {
                                                      final Uri _url =
                                                          Uri.parse(url);

                                                      await launchUrl(_url,
                                                          webOnlyWindowName:
                                                              '_blank',
                                                          mode: LaunchMode
                                                              .externalApplication);
                                                    } else if (year == '2014') {
                                                      String urlprovicional =
                                                          'https://www.web.onpe.gob.pe/modElecciones/elecciones/elecciones2014/PRERM2014/Actas-por-numero-EM.html';
                                                      copyToClipboard(
                                                          mesaNumero, context);

                                                      final Uri _url =
                                                          Uri.parse(
                                                              urlprovicional);

                                                      await launchUrl(
                                                        _url,
                                                        mode: LaunchMode
                                                            .externalApplication,
                                                      );
                                                    } else if (year ==
                                                        '2014-v2') {
                                                      String urlprovicional =
                                                          'https://www.web.onpe.gob.pe/modElecciones/elecciones/elecciones2014/PRR2V2014/Actas-por-numero-ER.html';
                                                      copyToClipboard(
                                                          mesaNumero, context);

                                                      final Uri _url =
                                                          Uri.parse(
                                                              urlprovicional);

                                                      await launchUrl(_url,
                                                          mode: LaunchMode
                                                              .externalApplication);
                                                    }
                                                  },
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: SizedBox(
                                                      height: 50,
                                                      width: 165,
                                                      child: Column(
                                                        children: [
                                                          Text(
                                                            'Votos validos',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.007,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          Divider(),
                                                          Text(
                                                            'Mesa $mesaNumero $distrito: ${point.y}',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              fontSize: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.0053,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                            series: <CartesianSeries<DataMesas,
                                                String>>[
                                              LineSeries<DataMesas, String>(
                                                dataSource: data,
                                                initialIsVisible: false,
                                                xValueMapper:
                                                    (DataMesas mesaData, _) =>
                                                        mesaData.mesaFormatted +
                                                        ' ' +
                                                        mesaData.distrito
                                                            .toString(),
                                                yValueMapper:
                                                    (DataMesas mesaData, _) =>
                                                        mesaData.noVotantes,
                                                name: 'No votaron',
                                                // Enable data label
                                                dataLabelSettings:
                                                    DataLabelSettings(
                                                        isVisible: true),
                                              ),
                                              LineSeries<DataMesas, String>(
                                                dataSource: data,
                                                isVisibleInLegend: false,
                                                xValueMapper:
                                                    (DataMesas mesaData, _) =>
                                                        mesaData.mesaFormatted +
                                                        ' ' +
                                                        mesaData.distrito
                                                            .toString(),
                                                yValueMapper:
                                                    (DataMesas mesaData, _) =>
                                                        mesaData.votosObtenidos,
                                                name: 'Votos validos',
                                                // Enable data label
                                                dataLabelSettings:
                                                    DataLabelSettings(
                                                        isVisible: true),
                                              ),
                                              LineSeries<DataMesas, String>(
                                                dataSource: data,
                                                initialIsVisible: false,
                                                xValueMapper:
                                                    (DataMesas mesaData, _) =>
                                                        mesaData.mesaFormatted +
                                                        ' ' +
                                                        mesaData.distrito
                                                            .toString(),
                                                yValueMapper:
                                                    (DataMesas mesaData, _) =>
                                                        mesaData.votosBlancos,
                                                name: 'Votos blancos',
                                                // Enable data label
                                                dataLabelSettings:
                                                    DataLabelSettings(
                                                        isVisible: true),
                                              ),
                                              LineSeries<DataMesas, String>(
                                                initialIsVisible: false,
                                                dataSource: data,
                                                xValueMapper:
                                                    (DataMesas mesaData, _) =>
                                                        mesaData.mesaFormatted +
                                                        ' ' +
                                                        mesaData.distrito
                                                            .toString(),
                                                yValueMapper:
                                                    (DataMesas mesaData, _) =>
                                                        mesaData.votosNulos,
                                                name: 'Votos nulos',
                                                // Enable data label
                                                dataLabelSettings:
                                                    DataLabelSettings(
                                                        isVisible: true),
                                              ),
                                              LineSeries<DataMesas, String>(
                                                initialIsVisible: false,
                                                isVisibleInLegend: false,
                                                dataSource: data,
                                                xValueMapper:
                                                    (DataMesas mesaData, _) =>
                                                        mesaData.mesaFormatted +
                                                        ' ' +
                                                        mesaData.distrito
                                                            .toString(),
                                                yValueMapper:
                                                    (DataMesas mesaData, _) =>
                                                        mesaData.votosImpug,
                                                name: 'Votos impugnados',
                                                // Enable data label
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      isProvince
                                          ? Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                ElevatedButton(
                                                  onPressed: _loadPreviousPage,
                                                  child: Text('Atrás'),
                                                ),
                                                ElevatedButton(
                                                  onPressed: _loadNextPage,
                                                  child: Text('Siguiente'),
                                                ),
                                              ],
                                            )
                                          : Container(),
                                      isProvince
                                          ? Expanded(
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    flex: 2,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: SfCartesianChart(
                                                        primaryXAxis:
                                                            CategoryAxis(),
                                                        title: const ChartTitle(
                                                            text:
                                                                'Resultados Electorales por partido politico'),
                                                        legend: Legend(
                                                            isVisible: true),
                                                        tooltipBehavior:
                                                            TooltipBehavior(
                                                          enable: true,
                                                        ),
                                                        series:
                                                            _createSeriesProvincia(),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: SfCircularChart(
                                                        title: ChartTitle(
                                                            text:
                                                                'Total de personas que no emitieron su voto por Provincia '),
                                                        legend: Legend(
                                                            isVisible: true),
                                                        series: <PieSeries<
                                                            DataGeneralProvincia,
                                                            String>>[
                                                          PieSeries<
                                                              DataGeneralProvincia,
                                                              String>(
                                                            explode: true,
                                                            explodeIndex: 0,
                                                            dataSource:
                                                                provinciaData,
                                                            xValueMapper:
                                                                (DataGeneralProvincia
                                                                            mesaData,
                                                                        _) =>
                                                                    mesaData
                                                                        .provincia,
                                                            yValueMapper:
                                                                (DataGeneralProvincia
                                                                            mesaData,
                                                                        _) =>
                                                                    mesaData
                                                                        .noVotantes,
                                                            dataLabelMapper: (DataGeneralProvincia
                                                                        mesaData,
                                                                    _) =>
                                                                mesaData
                                                                    .provincia +
                                                                ' ' +
                                                                mesaData
                                                                    .noVotantes
                                                                    .toString(),
                                                            dataLabelSettings:
                                                                DataLabelSettings(
                                                                    isVisible:
                                                                        true),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : Expanded(
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    flex: 2,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: SfCartesianChart(
                                                        primaryXAxis:
                                                            CategoryAxis(),
                                                        title: ChartTitle(
                                                            text:
                                                                'Resultados Electorales por partido politico en la provincia de $provinciaSave'),
                                                        legend: Legend(
                                                            isVisible: true),
                                                        tooltipBehavior:
                                                            TooltipBehavior(
                                                          enable: true,
                                                        ),
                                                        series:
                                                            _createSeriesDistrito(),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: SfCircularChart(
                                                        title: ChartTitle(
                                                            text:
                                                                'Total de personas que no emitieron su voto por distrito de la provincia de $provincia'),
                                                        legend: Legend(
                                                            isVisible: true),
                                                        series: <PieSeries<
                                                            DataGeneralDistrito,
                                                            String>>[
                                                          PieSeries<
                                                              DataGeneralDistrito,
                                                              String>(
                                                            explode: true,
                                                            explodeIndex: 0,
                                                            dataSource:
                                                                distritoData,
                                                            xValueMapper:
                                                                (DataGeneralDistrito
                                                                            mesaData,
                                                                        _) =>
                                                                    '${mesaData.distrito} ${mesaData.totalVotos}',
                                                            yValueMapper:
                                                                (DataGeneralDistrito
                                                                            mesaData,
                                                                        _) =>
                                                                    mesaData
                                                                        .noVotantes,
                                                            dataLabelMapper:
                                                                (DataGeneralDistrito
                                                                            mesaData,
                                                                        _) =>
                                                                    '${mesaData.distrito} ${mesaData.noVotantes}',
                                                            dataLabelSettings:
                                                                DataLabelSettings(
                                                                    isVisible:
                                                                        true),
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<StackedColumnSeries<PartidoPolitico, String>> _createSeriesProvincia() {
    List<StackedColumnSeries<PartidoPolitico, String>> seriesList = [];

    // Nombres y mapeadores de las agrupaciones políticas
    Map<String, Function(PartidoPolitico)> agrupaciones = {
      'ACCION POPULAR': (PartidoPolitico p) =>
          p.agrupacionesPoliticas['ACCION POPULAR'] ?? 0,
      'ALIANZA PARA EL PROGRESO': (PartidoPolitico p) =>
          p.agrupacionesPoliticas['ALIANZA PARA EL PROGRESO'] ?? 0,
      'AUTENTICO REGIONAL': (PartidoPolitico p) =>
          p.agrupacionesPoliticas['AUTENTICO REGIONAL'] ?? 0,
      'AVANZA PAIS - PARTIDO DE INTEGRACION SOCIAL': (PartidoPolitico p) =>
          p.agrupacionesPoliticas[
              'AVANZA PAIS - PARTIDO DE INTEGRACION SOCIAL'] ??
          0,
      'AVANZADA REGIONAL INDEPENDIENTE UNIDOS POR HUANUCO':
          (PartidoPolitico p) =>
              p.agrupacionesPoliticas[
                  'AVANZADA REGIONAL INDEPENDIENTE UNIDOS POR HUANUCO'] ??
              0,
      'DEMOCRACIA DIRECTA': (PartidoPolitico p) =>
          p.agrupacionesPoliticas['DEMOCRACIA DIRECTA'] ?? 0,
      'EL FRENTE AMPLIO POR JUSTICIA, VIDA Y LIBERTAD': (PartidoPolitico p) =>
          p.agrupacionesPoliticas[
              'EL FRENTE AMPLIO POR JUSTICIA, VIDA Y LIBERTAD'] ??
          0,
      'FUERZA POPULAR': (PartidoPolitico p) =>
          p.agrupacionesPoliticas['FUERZA POPULAR'] ?? 0,
      'JUNTOS POR EL PERU': (PartidoPolitico p) =>
          p.agrupacionesPoliticas['JUNTOS POR EL PERU'] ?? 0,
      'MOVIMIENTO INDEPENDIENTE REGIONAL HUANUCO PRIMERO':
          (PartidoPolitico p) =>
              p.agrupacionesPoliticas[
                  'MOVIMIENTO INDEPENDIENTE REGIONAL HUANUCO PRIMERO'] ??
              0,
      'MOVIMIENTO INDEPENDIENTE REGIONAL LUCHEMOS POR HUANUCO':
          (PartidoPolitico p) =>
              p.agrupacionesPoliticas[
                  'MOVIMIENTO INDEPENDIENTE REGIONAL LUCHEMOS POR HUANUCO'] ??
              0,
      'MOVIMIENTO INDEPENDIENTE REGIONAL MI BUEN VECINO': (PartidoPolitico p) =>
          p.agrupacionesPoliticas[
              'MOVIMIENTO INDEPENDIENTE REGIONAL MI BUEN VECINO'] ??
          0,
      'MOVIMIENTO INTEGRACION DESCENTRALISTA': (PartidoPolitico p) =>
          p.agrupacionesPoliticas['MOVIMIENTO INTEGRACION DESCENTRALISTA'] ?? 0,
      'MOVIMIENTO POLITICO CAMBIEMOS X HCO': (PartidoPolitico p) =>
          p.agrupacionesPoliticas['MOVIMIENTO POLITICO CAMBIEMOS X HCO'] ?? 0,
      'MOVIMIENTO POLITICO FRENTE AMPLIO REGIONAL PAISANOCUNA':
          (PartidoPolitico p) =>
              p.agrupacionesPoliticas[
                  'MOVIMIENTO POLITICO FRENTE AMPLIO REGIONAL PAISANOCUNA'] ??
              0,
      'MOVIMIENTO POLITICO HECHOS Y NO PALABRAS': (PartidoPolitico p) =>
          p.agrupacionesPoliticas['MOVIMIENTO POLITICO HECHOS Y NO PALABRAS'] ??
          0,
      'PARTIDO DEMOCRATICO SOMOS PERU': (PartidoPolitico p) =>
          p.agrupacionesPoliticas['PARTIDO DEMOCRATICO SOMOS PERU'] ?? 0,
      'PARTIDO FRENTE DE LA ESPERANZA 2021': (PartidoPolitico p) =>
          p.agrupacionesPoliticas['PARTIDO FRENTE DE LA ESPERANZA 2021'] ?? 0,
      'PODEMOS POR EL PROGRESO DEL PERU': (PartidoPolitico p) =>
          p.agrupacionesPoliticas['PODEMOS POR EL PROGRESO DEL PERU'] ?? 0,
      'SOLIDARIDAD NACIONAL': (PartidoPolitico p) =>
          p.agrupacionesPoliticas['SOLIDARIDAD NACIONAL'] ?? 0,
      'UNION POR EL PERU': (PartidoPolitico p) =>
          p.agrupacionesPoliticas['UNION POR EL PERU'] ?? 0,
      'VAMOS PERU': (PartidoPolitico p) =>
          p.agrupacionesPoliticas['VAMOS PERU'] ?? 0,
      'PARTIDO MORADO': (PartidoPolitico p) =>
          p.agrupacionesPoliticas['PARTIDO MORADO'] ?? 0,
      'PARTIDO POLITICO NACIONAL PERU LIBRE': (PartidoPolitico p) =>
          p.agrupacionesPoliticas['PARTIDO POLITICO NACIONAL PERU LIBRE'] ?? 0,
      'PARTIDO POPULAR CRISTIANO - PPC': (PartidoPolitico p) =>
          p.agrupacionesPoliticas['PARTIDO POPULAR CRISTIANO - PPC'] ?? 0,
      'FRENTE DEMOCRATICO REGIONAL': (PartidoPolitico p) =>
          p.agrupacionesPoliticas['FRENTE DEMOCRATICO REGIONAL'] ?? 0,
    };

    // Iterar sobre cada agrupación para crear una serie
    agrupaciones.forEach((name, yValueMapper) {
      int totalVotes = politicosData.fold<int>(
          0, (int prev, PartidoPolitico p) => prev + (yValueMapper(p) as int));

      if (totalVotes > 0) {
        // Solo añadir si el total de votos es mayor a cero
        seriesList.add(StackedColumnSeries<PartidoPolitico, String>(
          dataSource: politicosData,
          xValueMapper: (PartidoPolitico p, _) => p.provincia,
          yValueMapper: (PartidoPolitico p, _) => yValueMapper(p),
          name: name,
          dataLabelSettings: DataLabelSettings(isVisible: true),
        ));
      }
    });

    return seriesList;
  }

  List<StackedColumnSeries<PartidoPoliticoDistrito, String>>
      _createSeriesDistrito() {
    List<StackedColumnSeries<PartidoPoliticoDistrito, String>> seriesList = [];

    // Nombres y mapeadores de las agrupaciones políticas
    Map<String, Function(PartidoPoliticoDistrito)> agrupaciones = {
      'ACCION POPULAR': (PartidoPoliticoDistrito p) =>
          p.agrupacionesPoliticas['ACCION POPULAR'] ?? 0,
      'ALIANZA PARA EL PROGRESO': (PartidoPoliticoDistrito p) =>
          p.agrupacionesPoliticas['ALIANZA PARA EL PROGRESO'] ?? 0,
      'AUTENTICO REGIONAL': (PartidoPoliticoDistrito p) =>
          p.agrupacionesPoliticas['AUTENTICO REGIONAL'] ?? 0,
      'AVANZA PAIS - PARTIDO DE INTEGRACION SOCIAL':
          (PartidoPoliticoDistrito p) =>
              p.agrupacionesPoliticas[
                  'AVANZA PAIS - PARTIDO DE INTEGRACION SOCIAL'] ??
              0,
      'AVANZADA REGIONAL INDEPENDIENTE UNIDOS POR HUANUCO':
          (PartidoPoliticoDistrito p) =>
              p.agrupacionesPoliticas[
                  'AVANZADA REGIONAL INDEPENDIENTE UNIDOS POR HUANUCO'] ??
              0,
      'DEMOCRACIA DIRECTA': (PartidoPoliticoDistrito p) =>
          p.agrupacionesPoliticas['DEMOCRACIA DIRECTA'] ?? 0,
      'EL FRENTE AMPLIO POR JUSTICIA, VIDA Y LIBERTAD':
          (PartidoPoliticoDistrito p) =>
              p.agrupacionesPoliticas[
                  'EL FRENTE AMPLIO POR JUSTICIA, VIDA Y LIBERTAD'] ??
              0,
      'FUERZA POPULAR': (PartidoPoliticoDistrito p) =>
          p.agrupacionesPoliticas['FUERZA POPULAR'] ?? 0,
      'JUNTOS POR EL PERU': (PartidoPoliticoDistrito p) =>
          p.agrupacionesPoliticas['JUNTOS POR EL PERU'] ?? 0,
      'MOVIMIENTO INDEPENDIENTE REGIONAL HUANUCO PRIMERO':
          (PartidoPoliticoDistrito p) =>
              p.agrupacionesPoliticas[
                  'MOVIMIENTO INDEPENDIENTE REGIONAL HUANUCO PRIMERO'] ??
              0,
      'MOVIMIENTO INDEPENDIENTE REGIONAL LUCHEMOS POR HUANUCO':
          (PartidoPoliticoDistrito p) =>
              p.agrupacionesPoliticas[
                  'MOVIMIENTO INDEPENDIENTE REGIONAL LUCHEMOS POR HUANUCO'] ??
              0,
      'MOVIMIENTO INDEPENDIENTE REGIONAL MI BUEN VECINO':
          (PartidoPoliticoDistrito p) =>
              p.agrupacionesPoliticas[
                  'MOVIMIENTO INDEPENDIENTE REGIONAL MI BUEN VECINO'] ??
              0,
      'MOVIMIENTO INTEGRACION DESCENTRALISTA': (PartidoPoliticoDistrito p) =>
          p.agrupacionesPoliticas['MOVIMIENTO INTEGRACION DESCENTRALISTA'] ?? 0,
      'MOVIMIENTO POLITICO CAMBIEMOS X HCO': (PartidoPoliticoDistrito p) =>
          p.agrupacionesPoliticas['MOVIMIENTO POLITICO CAMBIEMOS X HCO'] ?? 0,
      'MOVIMIENTO POLITICO FRENTE AMPLIO REGIONAL PAISANOCUNA':
          (PartidoPoliticoDistrito p) =>
              p.agrupacionesPoliticas[
                  'MOVIMIENTO POLITICO FRENTE AMPLIO REGIONAL PAISANOCUNA'] ??
              0,
      'MOVIMIENTO POLITICO HECHOS Y NO PALABRAS': (PartidoPoliticoDistrito p) =>
          p.agrupacionesPoliticas['MOVIMIENTO POLITICO HECHOS Y NO PALABRAS'] ??
          0,
      'PARTIDO DEMOCRATICO SOMOS PERU': (PartidoPoliticoDistrito p) =>
          p.agrupacionesPoliticas['PARTIDO DEMOCRATICO SOMOS PERU'] ?? 0,
      'PARTIDO FRENTE DE LA ESPERANZA 2021': (PartidoPoliticoDistrito p) =>
          p.agrupacionesPoliticas['PARTIDO FRENTE DE LA ESPERANZA 2021'] ?? 0,
      'PODEMOS POR EL PROGRESO DEL PERU': (PartidoPoliticoDistrito p) =>
          p.agrupacionesPoliticas['PODEMOS POR EL PROGRESO DEL PERU'] ?? 0,
      'SOLIDARIDAD NACIONAL': (PartidoPoliticoDistrito p) =>
          p.agrupacionesPoliticas['SOLIDARIDAD NACIONAL'] ?? 0,
      'UNION POR EL PERU': (PartidoPoliticoDistrito p) =>
          p.agrupacionesPoliticas['UNION POR EL PERU'] ?? 0,
      'VAMOS PERU': (PartidoPoliticoDistrito p) =>
          p.agrupacionesPoliticas['VAMOS PERU'] ?? 0,
      'PARTIDO MORADO': (PartidoPoliticoDistrito p) =>
          p.agrupacionesPoliticas['PARTIDO MORADO'] ?? 0,
      'PARTIDO POLITICO NACIONAL PERU LIBRE': (PartidoPoliticoDistrito p) =>
          p.agrupacionesPoliticas['PARTIDO POLITICO NACIONAL PERU LIBRE'] ?? 0,
      'PARTIDO POPULAR CRISTIANO - PPC': (PartidoPoliticoDistrito p) =>
          p.agrupacionesPoliticas['PARTIDO POPULAR CRISTIANO - PPC'] ?? 0,
      'FRENTE DEMOCRATICO REGIONAL': (PartidoPoliticoDistrito p) =>
          p.agrupacionesPoliticas['FRENTE DEMOCRATICO REGIONAL'] ?? 0,
    };

    // Iterar sobre cada agrupación para crear una serie
    agrupaciones.forEach((name, yValueMapper) {
      int totalVotes = politicosDistritoData.fold<int>(
          0,
          (int prev, PartidoPoliticoDistrito p) =>
              prev + (yValueMapper(p) as int));

      if (totalVotes > 0) {
        // Solo añadir si el total de votos es mayor a cero
        seriesList.add(StackedColumnSeries<PartidoPoliticoDistrito, String>(
          dataSource: politicosDistritoData,
          xValueMapper: (PartidoPoliticoDistrito p, _) => p.distrito,
          yValueMapper: (PartidoPoliticoDistrito p, _) => yValueMapper(p),
          name: name,
          dataLabelSettings: DataLabelSettings(isVisible: true),
        ));
      }
    });

    return seriesList;
  }
}

class MesasDataTableSource extends DataTableSource {
  final List<DataMesas> data;

  MesasDataTableSource(this.data);

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    if (index >= data.length) return null!;
    final DataMesas mesaData = data[index];
    return DataRow.byIndex(index: index, cells: [
      DataCell(Text(mesaData.departamento)),
      DataCell(Text(mesaData.distrito)),
      DataCell(Text(mesaData.mesaFormatted.toString())),
      DataCell(Text(mesaData.noVotantes.toString())),
      DataCell(Text(mesaData.totalVotos.toString())),
      DataCell(Text(mesaData.votosBlancos.toString())),
      DataCell(Text(mesaData.votosNulos.toString())),
      DataCell(Text(mesaData.votosImpug.toString())),
      DataCell(Text(mesaData.votosObtenidos.toString())),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => 0;
}
