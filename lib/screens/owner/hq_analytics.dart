import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/data_provider.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_badge.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_button.dart';
import '../../utils/ui_utils.dart';

class HqAnalytics extends StatefulWidget {
  const HqAnalytics({Key? key}) : super(key: key);

  @override
  State<HqAnalytics> createState() => _HqAnalyticsState();
}

class _HqAnalyticsState extends State<HqAnalytics> {
  String _branch = 'All Branches';
  String _service = 'All Services';
  String _time = 'Last 7 Days';

  List<double> _generateMockData() {
    final random = Random(_branch.hashCode ^ _service.hashCode ^ _time.hashCode);
    int multiplier = 1000;
    if (_time == 'This Month') multiplier = 5000;
    if (_time == 'Year to Date') multiplier = 20000;

    return List.generate(7, (index) => (random.nextDouble() * 10 + 5) * multiplier);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('HQ Analytics', style: Theme.of(context).textTheme.headlineMedium),
            ],
          ),
          const SizedBox(height: 16),
          Row(
             children: [
                Expanded(
                  child: CustomCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _branch,
                        isExpanded: true,
                        items: ['All Branches', 'North', 'West', 'South Main'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _branch = val);
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomCard(
                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _service,
                        isExpanded: true,
                        items: ['All Services', 'Maintenance', 'Repairs', 'Towing'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _service = val);
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomCard(
                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _time,
                        isExpanded: true,
                        items: ['Last 7 Days', 'This Month', 'Year to Date'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _time = val);
                        },
                      ),
                    ),
                  ),
                ),
             ],
          ),
          const SizedBox(height: 24),
          Text('Revenue Overview', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          CustomCard(
            child: SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 20000,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => Theme.of(context).colorScheme.surface,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '\$${rod.toY.round()}',
                          TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          const style = TextStyle(fontWeight: FontWeight.bold, fontSize: 12);
                          late String text;
                          switch (value.toInt()) {
                            case 0: text = 'Mon'; break;
                            case 1: text = 'Tue'; break;
                            case 2: text = 'Wed'; break;
                            case 3: text = 'Thu'; break;
                            case 4: text = 'Fri'; break;
                            case 5: text = 'Sat'; break;
                            case 6: text = 'Sun'; break;
                            default: text = ''; break;
                          }
                          return SideTitleWidget(meta: meta, child: Text(text, style: style));
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          return Text('${(value / 1000).toInt()}k', style: const TextStyle(fontSize: 10));
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: _generateMockData().asMap().entries.map((e) {
                    return BarChartGroupData(
                      x: e.key,
                      barRods: [BarChartRodData(toY: e.value, color: Theme.of(context).colorScheme.primary, width: 16, borderRadius: BorderRadius.circular(4))],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          Text('Store Settings', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          _StoreSettingsCard(),
        ],
      ),
    );
  }
}

class _StoreSettingsCard extends StatefulWidget {
  @override
  __StoreSettingsCardState createState() => __StoreSettingsCardState();
}

class __StoreSettingsCardState extends State<_StoreSettingsCard> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: Provider.of<DataProvider>(context, listen: false).storeName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Update Global Business Name', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                     labelText: 'Business Name',
                     border: OutlineInputBorder(),
                  ),
                )
              ),
              const SizedBox(width: 16),
              CustomButton(
                text: 'Save',
                onPressed: () {
                   if (_controller.text.isNotEmpty) {
                     Provider.of<DataProvider>(context, listen: false).updateStoreName(_controller.text);
                     UiUtils.showToast(context, 'Global Store Name updated to: ${_controller.text}');
                   }
                }
              )
            ],
          )
        ],
      )
    );
  }
}
