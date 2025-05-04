import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/category.dart';

class PieChartWidget extends StatelessWidget {
  final Map<String, double> data;
  final List<Category> categories;
  final String title;

  const PieChartWidget({
    Key? key,
    required this.data,
    required this.categories,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: data.isEmpty
                  ? const Center(child: Text('Aucune donnée disponible'))
                  : PieChart(
                      PieChartData(
                        sections: _getSections(),
                        centerSpaceRadius: 40,
                        sectionsSpace: 2,
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _getSections() {
    List<PieChartSectionData> sections = [];
    double total = data.values.fold(0, (sum, value) => sum + value);
    
    if (total == 0) return sections;
    
    data.forEach((categoryId, value) {
      if (value > 0) {
        Category? category = categories.firstWhere(
            (cat) => cat.id == categoryId,
            orElse: () => Category(
                id: categoryId,
                name: 'Inconnu',
                icon: '?',
                colorValue: Colors.grey.value));
        
        sections.add(
          PieChartSectionData(
            color: Color(category.colorValue),
            value: value,
            title: '${((value / total) * 100).toStringAsFixed(1)}%',
            radius: 80,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
      }
    });
    
    return sections;
  }

  Widget _buildLegend() {
    List<Widget> legendItems = [];
    
    data.forEach((categoryId, value) {
      if (value > 0) {
        Category? category = categories.firstWhere(
            (cat) => cat.id == categoryId,
            orElse: () => Category(
                id: categoryId,
                name: 'Inconnu',
                icon: '?',
                colorValue: Colors.grey.value));
        
        legendItems.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  color: Color(category.colorValue),
                ),
                const SizedBox(width: 8),
                Text(category.name),
                const Spacer(),
                Text('${value.toStringAsFixed(2)} €'),
              ],
            ),
          ),
        );
      }
    });
    
    return Column(children: legendItems);
  }
}

class LineChartWidget extends StatelessWidget {
  final Map<String, double> data;
  final String title;
  final Color lineColor;

  const LineChartWidget({
    Key? key,
    required this.data,
    required this.title,
    required this.lineColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> sortedKeys = data.keys.toList()..sort();
    
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: data.isEmpty
                  ? const Center(child: Text('Aucune donnée disponible'))
                  : LineChart(
                      LineChartData(
                        gridData: FlGridData(show: true),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: true),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() >= 0 && 
                                    value.toInt() < sortedKeys.length) {
                                  return Text(
                                    sortedKeys[value.toInt()],
                                    style: const TextStyle(fontSize: 10),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(color: const Color(0xff37434d)),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: _getSpots(sortedKeys),
                            isCurved: true,
                            barWidth: 3,
                            color: lineColor,
                            dotData: FlDotData(show: true),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _getSpots(List<String> sortedKeys) {
    List<FlSpot> spots = [];
    for (int i = 0; i < sortedKeys.length; i++) {
      spots.add(FlSpot(i.toDouble(), data[sortedKeys[i]] ?? 0));
    }
    return spots;
  }
}