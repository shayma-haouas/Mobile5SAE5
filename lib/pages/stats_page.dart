import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';


class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  DateTime? quitDate;
  double cigarettesPerDay = 20;
  double pricePerCigarette = 0.5;
  Timer? _timer;
  Duration? _timeSinceQuit;

  @override
  void initState() {
    super.initState();
    _loadData();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (quitDate != null) {
        setState(() {
          _timeSinceQuit = DateTime.now().difference(quitDate!);
        });
      }
    });
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final quitDateString = prefs.getString('quit_date');
    if (quitDateString != null) {
      quitDate = DateTime.parse(quitDateString);
      _timeSinceQuit = DateTime.now().difference(quitDate!);
    }
    cigarettesPerDay = prefs.getDouble('cigarettes_per_day') ?? 20;
    pricePerCigarette = prefs.getDouble('price_per_cigarette') ?? 0.5;
    setState(() {});
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    if (quitDate != null) {
      await prefs.setString('quit_date', quitDate!.toIso8601String());
    }
    await prefs.setDouble('cigarettes_per_day', cigarettesPerDay);
    await prefs.setDouble('price_per_cigarette', pricePerCigarette);
  }

  String get timeDisplay {
    if (_timeSinceQuit == null) return '0d 0h 0m 0s';
    final days = _timeSinceQuit!.inDays;
    final hours = _timeSinceQuit!.inHours % 24;
    final minutes = _timeSinceQuit!.inMinutes % 60;
    final seconds = _timeSinceQuit!.inSeconds % 60;
    return '${days}d ${hours}h ${minutes}m ${seconds}s';
  }

  int get cigarettesAvoided {
    if (_timeSinceQuit == null) return 0;
    final totalMinutes = _timeSinceQuit!.inMinutes;
    final dailyMinutes = 24 * 60;
    return ((totalMinutes / dailyMinutes) * cigarettesPerDay).floor();
  }

  double get moneySaved {
    return cigarettesAvoided * pricePerCigarette;
  }

  String get lifeRegained {
    final minutesRegained = cigarettesAvoided * 11; // 11 minutes per cigarette
    final hours = minutesRegained ~/ 60;
    final minutes = minutesRegained % 60;
    return '${hours}h ${minutes}m';
  }



  List<FlSpot> get currentMoneySavedData {
    if (_timeSinceQuit == null) {
      return [const FlSpot(0, 0)];
    }
    
    final totalDays = _timeSinceQuit!.inDays;
    final maxDays = totalDays > 90 ? 90 : (totalDays < 1 ? 30 : totalDays);
    List<FlSpot> spots = [const FlSpot(0, 0)];
    
    for (int day = 1; day <= maxDays; day++) {
      final moneySaved = day * cigarettesPerDay * pricePerCigarette;
      spots.add(FlSpot(day.toDouble(), moneySaved));
    }
    
    return spots;
  }
  
  List<FlSpot> get projectedMoneySavedData {
    final currentDays = _timeSinceQuit?.inDays ?? 0;
    final projectionDays = currentDays > 90 ? 180 : 90;
    
    List<FlSpot> spots = [];
    
    for (int day = currentDays; day <= projectionDays; day++) {
      final moneySaved = day * cigarettesPerDay * pricePerCigarette;
      spots.add(FlSpot(day.toDouble(), moneySaved));
    }
    
    return spots;
  }
  
  List<FlSpot> get currentCigarettesAvoidedData {
    if (_timeSinceQuit == null) {
      return [const FlSpot(0, 0)];
    }
    
    final totalDays = _timeSinceQuit!.inDays;
    final maxDays = totalDays > 90 ? 90 : (totalDays < 1 ? 30 : totalDays);
    List<FlSpot> spots = [const FlSpot(0, 0)];
    
    for (int day = 1; day <= maxDays; day++) {
      final cigarettesAvoided = day * cigarettesPerDay;
      spots.add(FlSpot(day.toDouble(), cigarettesAvoided));
    }
    
    return spots;
  }
  
  List<FlSpot> get projectedCigarettesAvoidedData {
    final currentDays = _timeSinceQuit?.inDays ?? 0;
    final projectionDays = currentDays > 90 ? 180 : 90;
    
    List<FlSpot> spots = [];
    
    for (int day = currentDays; day <= projectionDays; day++) {
      final cigarettesAvoided = day * cigarettesPerDay;
      spots.add(FlSpot(day.toDouble(), cigarettesAvoided));
    }
    
    return spots;
  }
  
  double get chartMaxX {
    final currentDays = _timeSinceQuit?.inDays ?? 0;
    return currentDays > 90 ? 180 : 90;
  }

  void _showSetupDialog() {
    if (quitDate == null) {
      _showInitialSetup();
    } else {
      _showSettingsDialog();
    }
  }

  void _showInitialSetup() {
    final cigarettesController = TextEditingController(text: cigarettesPerDay.toString());
    final priceController = TextEditingController(text: pricePerCigarette.toString());
    DateTime? tempQuitDate;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('🚭 Start Your Journey'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('When did you quit smoking?', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (time != null) {
                      tempQuitDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                    } else {
                      tempQuitDate = date;
                    }
                    setDialogState(() {}); // Update dialog state
                  }
                },
                child: Text(tempQuitDate?.toString().split('.')[0] ?? 'Select Date & Time'),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: cigarettesController,
                decoration: const InputDecoration(labelText: 'Cigarettes per day'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Price per cigarette (\$)'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: tempQuitDate == null ? null : () {
                quitDate = tempQuitDate;
                cigarettesPerDay = double.tryParse(cigarettesController.text) ?? 20;
                pricePerCigarette = double.tryParse(priceController.text) ?? 0.5;
                _saveData();
                Navigator.pop(context);
                setState(() {
                  _timeSinceQuit = DateTime.now().difference(quitDate!);
                });
              },
              child: const Text('Start Tracking'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Quit Date'),
              subtitle: Text(quitDate?.toString().split('.')[0] ?? 'Not set'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: quitDate ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(quitDate ?? DateTime.now()),
                  );
                  if (time != null) {
                    setState(() => quitDate = DateTime(date.year, date.month, date.day, time.hour, time.minute));
                  } else {
                    setState(() => quitDate = date);
                  }
                  _saveData();
                }
              },
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Cigarettes per day'),
              keyboardType: TextInputType.number,
              controller: TextEditingController(text: cigarettesPerDay.toString()),
              onChanged: (value) {
                cigarettesPerDay = double.tryParse(value) ?? 20;
                _saveData();
              },
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Price per cigarette (\$)'),
              keyboardType: TextInputType.number,
              controller: TextEditingController(text: pricePerCigarette.toString()),
              onChanged: (value) {
                pricePerCigarette = double.tryParse(value) ?? 0.5;
                _saveData();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {});
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '📊 Dashboard',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: _showSetupDialog,
                      icon: const Icon(Icons.settings, color: Colors.white, size: 28),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                // Stats Cards
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildStatCard('⏱️', 'Smoke Free', timeDisplay, Colors.white),
                    _buildStatCard('🚭', 'Cigarettes Avoided', '$cigarettesAvoided', Colors.white),
                    _buildStatCard('💰', 'Money Saved', '\$${moneySaved.toStringAsFixed(2)}', Colors.white),
                    _buildStatCard('❤️', 'Life Regained', lifeRegained, Colors.white),
                  ],
                ),
                const SizedBox(height: 20),
                // Current vs Projected Charts
                if (quitDate != null) _buildMoneyProjectionChart(),
                const SizedBox(height: 20),
                if (quitDate != null) _buildCigarettesProjectionChart(),
                const SizedBox(height: 20),
                // Bottom Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        quitDate == null ? '🚀 Get Started' : '🎯 Your Progress',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4CAF50),
                        ),
                      ),
                      const SizedBox(height: 10),
                      quitDate == null
                          ? Column(
                              children: [
                                const Text(
                                  'Ready to start tracking your smoke-free journey?',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 15),
                                ElevatedButton(
                                  onPressed: _showInitialSetup,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF4CAF50),
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                                  ),
                                  child: const Text('Start Tracking'),
                                ),
                              ],
                            )
                          : const Text(
                              'Amazing! Every second counts. You\'re getting healthier and saving money!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                    ],
                  ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }



  Widget _buildMoneyProjectionChart() {
    final currentDays = _timeSinceQuit?.inDays ?? 0;
    final projectedMax = (currentDays > 90 ? 180 : 90) * cigarettesPerDay * pricePerCigarette;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '💰 Money Saved: Current vs Future Potential',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4CAF50),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(width: 12, height: 12, color: Colors.green),
              const SizedBox(width: 8),
              const Text('Current Savings', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 20),
              Container(width: 12, height: 12, color: Colors.blue.shade300),
              const SizedBox(width: 8),
              const Text('Future Projection', style: TextStyle(fontSize: 12)),
            ],
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: projectedMax / 5,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.shade300,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) => Text(
                        '\$${value.toInt()}',
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 25,
                      getTitlesWidget: (value, meta) => Text(
                        '${value.toInt()}d',
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    left: BorderSide(color: Colors.grey.shade300),
                    bottom: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                minX: 0,
                maxX: chartMaxX,
                minY: 0,
                maxY: projectedMax * 1.1,
                lineBarsData: [
                  // Current Savings (Green - solid)
                  LineChartBarData(
                    spots: currentMoneySavedData,
                    isCurved: true,
                    color: Colors.green,
                    barWidth: 4,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.green.withOpacity(0.3),
                    ),
                  ),
                  // Future Projection (Blue - dashed)
                  LineChartBarData(
                    spots: projectedMoneySavedData,
                    isCurved: true,
                    color: Colors.blue.shade300,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    dashArray: [8, 4],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCigarettesProjectionChart() {
    final currentDays = _timeSinceQuit?.inDays ?? 0;
    final projectedMax = (currentDays > 90 ? 180 : 90) * cigarettesPerDay;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🚭 Cigarettes Avoided: Current vs Future Potential',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4CAF50),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(width: 12, height: 12, color: Colors.orange),
              const SizedBox(width: 8),
              const Text('Current Avoided', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 20),
              Container(width: 12, height: 12, color: Colors.purple.shade300),
              const SizedBox(width: 8),
              const Text('Future Projection', style: TextStyle(fontSize: 12)),
            ],
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: projectedMax / 5,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.shade300,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) => Text(
                        '${value.toInt()}',
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 25,
                      getTitlesWidget: (value, meta) => Text(
                        '${value.toInt()}d',
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    left: BorderSide(color: Colors.grey.shade300),
                    bottom: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                minX: 0,
                maxX: chartMaxX,
                minY: 0,
                maxY: projectedMax * 1.1,
                lineBarsData: [
                  // Current Avoided (Orange - solid)
                  LineChartBarData(
                    spots: currentCigarettesAvoidedData,
                    isCurved: true,
                    color: Colors.orange,
                    barWidth: 4,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.orange.withOpacity(0.3),
                    ),
                  ),
                  // Future Projection (Purple - dashed)
                  LineChartBarData(
                    spots: projectedCigarettesAvoidedData,
                    isCurved: true,
                    color: Colors.purple.shade300,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    dashArray: [8, 4],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String emoji, String title, String value, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4CAF50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}