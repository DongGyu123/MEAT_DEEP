import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class BarData {
  final String category;
  final int percentage;
  final charts.Color color;

  BarData(this.category, this.percentage, Color color)
      : color = charts.Color(
            r: color.red, g: color.green, b: color.blue, a: color.alpha);
}

class PercentageBarGraph extends StatelessWidget {
  final int cookedPercentage;
  final bool animate;

  const PercentageBarGraph({
    Key? key,
    required this.cookedPercentage,
    this.animate = false,
  }) : super(key: key);

  List<charts.Series<BarData, String>> _createData() {
    final data = [
      BarData('Cooked', cookedPercentage, Color.fromARGB(255, 116, 205, 83)),
      BarData('Uncooked', 100 - cookedPercentage,
          Color.fromARGB(255, 239, 169, 122)),
    ];

    return [
      charts.Series<BarData, String>(
        id: 'Cooked vs Uncooked',
        domainFn: (BarData bars, _) => bars.category,
        measureFn: (BarData bars, _) => bars.percentage,
        colorFn: (BarData bars, _) => bars.color,
        data: data,
        labelAccessorFn: (BarData row, _) =>
            '${row.category}: ${row.percentage}%',
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return charts.BarChart(
      _createData(),
      animate: animate,
      vertical: false,
      barRendererDecorator: charts.BarLabelDecorator<String>(),
      domainAxis:
          const charts.OrdinalAxisSpec(renderSpec: charts.NoneRenderSpec()),
      primaryMeasureAxis: const charts.NumericAxisSpec(
        viewport: charts.NumericExtents(0, 100),
      ),
    );
  }
}
