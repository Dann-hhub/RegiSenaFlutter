import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:syncfusion_flutter_charts/charts.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int totalIngresos = 0;
  List<Map<String, dynamic>> porcentajeMarcas = [];
  List<Map<String, dynamic>> porcentajeIngresos = [];
  List<Map<String, dynamic>> historicoIngresos = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:5000/dashboard/estadisticas'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Datos recibidos: $data'); // Debug: Ver los datos recibidos
        
        setState(() {
          totalIngresos = data['total_ingresos'] ?? 0;
          porcentajeMarcas = List<Map<String, dynamic>>.from(data['porcentaje_marcas'] ?? []);
          porcentajeIngresos = List<Map<String, dynamic>>.from(data['porcentaje_ingresos'] ?? []);
          
          // Procesamiento más robusto de los datos históricos
          historicoIngresos = List<Map<String, dynamic>>.from(data['historico_ingresos'] ?? [])
              .map((item) => {
                'mes': item['mes']?.toString() ?? '',
                'ingresos': (item['ingresos'] is int) ? item['ingresos'] : 
                           (item['ingresos'] is double) ? item['ingresos'].toInt() : 0
              }).toList();
              
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load dashboard data. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al cargar datos: $e'); // Debug: Ver el error
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar datos: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard', style: TextStyle(color: Color.fromARGB(223, 255, 255, 255)),),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchDashboardData,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dashboard de RegiSena',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  SizedBox(height: 20),
                  _buildTotalIngresosChart(),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(child: _buildMarcasChart()),
                      SizedBox(width: 10),
                      Expanded(child: _buildIngresosChart()),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTotalIngresosChart() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Histórico de Ingresos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Container(
              height: 250, // Aumenté la altura para mejor visualización
              child: historicoIngresos.isNotEmpty 
                  ? SfCartesianChart(
                      primaryXAxis: CategoryAxis(
                        labelRotation: -45, // Rotación para mejor legibilidad
                      ),
                      primaryYAxis: NumericAxis(
                        title: AxisTitle(text: 'Cantidad de Ingresos'),
                      ),
                      tooltipBehavior: TooltipBehavior(enable: true),
                      series: <CartesianSeries>[
                        LineSeries<Map<String, dynamic>, String>(
                          dataSource: historicoIngresos,
                          xValueMapper: (data, _) => data['mes'],
                          yValueMapper: (data, _) => data['ingresos'],
                          name: 'Ingresos',
                          color: Colors.green,
                          width: 3,
                          markerSettings: MarkerSettings(
                            isVisible: true,
                            shape: DataMarkerType.circle,
                            borderWidth: 2,
                            borderColor: Colors.green,
                            color: Colors.white,
                          ),
                          dataLabelSettings: DataLabelSettings(
                            isVisible: true,
                            textStyle: TextStyle(fontSize: 10),
                          ),
                        ),
                      ],
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.warning, color: Colors.orange, size: 40),
                          SizedBox(height: 10),
                          Text(
                            'No hay datos históricos disponibles',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
            ),
            SizedBox(height: 10),
            Center(
              child: Text(
                'Total: $totalIngresos ingresos',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Los métodos _buildMarcasChart() y _buildIngresosChart() permanecen igual
  Widget _buildMarcasChart() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Distribución de Marcas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Container(
              height: 200,
              child: SfCircularChart(
                legend: Legend(
                  isVisible: true,
                  position: LegendPosition.bottom,
                  overflowMode: LegendItemOverflowMode.wrap,
                ),
                series: <CircularSeries>[
                  PieSeries<Map<String, dynamic>, String>(
                    dataSource: porcentajeMarcas,
                    xValueMapper: (data, _) => '${data['marca']} (${data['porcentaje'].toStringAsFixed(1)}%)',
                    yValueMapper: (data, _) => data['porcentaje'],
                    dataLabelSettings: DataLabelSettings(
                      isVisible: true,
                      labelPosition: ChartDataLabelPosition.outside,
                      connectorLineSettings: ConnectorLineSettings(
                        length: '20%',
                        type: ConnectorType.curve,
                      ),
                    ),
                    enableTooltip: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIngresosChart() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Tipos de Ingreso',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Container(
              height: 200,
              child: SfCircularChart(
                legend: Legend(
                  isVisible: true,
                  position: LegendPosition.bottom,
                  overflowMode: LegendItemOverflowMode.wrap,
                ),
                series: <CircularSeries>[
                  DoughnutSeries<Map<String, dynamic>, String>(
                    dataSource: porcentajeIngresos,
                    xValueMapper: (data, _) => '${data['tipo']} (${data['porcentaje'].toStringAsFixed(1)}%)',
                    yValueMapper: (data, _) => data['porcentaje'],
                    dataLabelSettings: DataLabelSettings(
                      isVisible: true,
                      labelPosition: ChartDataLabelPosition.outside,
                      connectorLineSettings: ConnectorLineSettings(
                        length: '20%',
                        type: ConnectorType.curve,
                      ),
                    ),
                    enableTooltip: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}