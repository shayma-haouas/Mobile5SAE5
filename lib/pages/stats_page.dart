import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/goal_model.dart';
import '../services/goals_repository.dart';


class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  List<Goal> _goals = [];
  final GoalsRepository _repo = GoalsRepository();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadGoals();
    _startTimer();
  }

  Future<void> _loadGoals() async {
    final goals = await _repo.loadGoals();
    setState(() {
      _goals = goals;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_goals.isNotEmpty) {
        setState(() {}); // Refresh UI every second
      }
    });
  }



  int get totalDaysFromGoals {
    if (_goals.isEmpty) return 0;
    return _goals.map((g) => g.completedDays).fold(0, (sum, days) => sum + days);
  }

  String get timeDisplay {
    final days = totalDaysFromGoals;
    return '${days}d 0h 0m 0s';
  }

  int get cigarettesAvoided {
    if (_goals.isEmpty) return 0;
    return _goals.map((g) => (g.completedDays * g.cigarettesPerDay).floor()).fold(0, (sum, cigs) => sum + cigs);
  }

  double get moneySaved {
    if (_goals.isEmpty) return 0;
    return _goals.map((g) => g.completedDays * g.cigarettesPerDay * g.pricePerCigarette).fold(0.0, (sum, money) => sum + money);
  }

  String get lifeRegained {
    final minutesRegained = cigarettesAvoided * 11; // 11 minutes per cigarette
    final hours = minutesRegained ~/ 60;
    final minutes = minutesRegained % 60;
    return '${hours}h ${minutes}m';
  }



  List<FlSpot> get currentMoneySavedData {
    final totalDays = totalDaysFromGoals;
    if (totalDays == 0 || _goals.isEmpty) return [const FlSpot(0, 0)];
    
    final avgCigarettes = _goals.map((g) => g.cigarettesPerDay).reduce((a, b) => a + b) / _goals.length;
    final avgPrice = _goals.map((g) => g.pricePerCigarette).reduce((a, b) => a + b) / _goals.length;
    
    final maxDays = totalDays > 90 ? 90 : (totalDays < 1 ? 30 : totalDays);
    List<FlSpot> spots = [const FlSpot(0, 0)];
    
    for (int day = 1; day <= maxDays; day++) {
      final moneySaved = day * avgCigarettes * avgPrice;
      spots.add(FlSpot(day.toDouble(), moneySaved));
    }
    
    return spots;
  }
  
  List<FlSpot> get projectedMoneySavedData {
    final currentDays = totalDaysFromGoals;
    if (_goals.isEmpty) return [];
    
    final avgCigarettes = _goals.map((g) => g.cigarettesPerDay).reduce((a, b) => a + b) / _goals.length;
    final avgPrice = _goals.map((g) => g.pricePerCigarette).reduce((a, b) => a + b) / _goals.length;
    final projectionDays = currentDays > 90 ? 180 : 90;
    
    List<FlSpot> spots = [];
    
    for (int day = currentDays; day <= projectionDays; day++) {
      final moneySaved = day * avgCigarettes * avgPrice;
      spots.add(FlSpot(day.toDouble(), moneySaved));
    }
    
    return spots;
  }
  
  List<FlSpot> get currentCigarettesAvoidedData {
    final totalDays = totalDaysFromGoals;
    if (totalDays == 0 || _goals.isEmpty) return [const FlSpot(0, 0)];
    
    final avgCigarettes = _goals.map((g) => g.cigarettesPerDay).reduce((a, b) => a + b) / _goals.length;
    
    final maxDays = totalDays > 90 ? 90 : (totalDays < 1 ? 30 : totalDays);
    List<FlSpot> spots = [const FlSpot(0, 0)];
    
    for (int day = 1; day <= maxDays; day++) {
      final cigarettesAvoided = day * avgCigarettes;
      spots.add(FlSpot(day.toDouble(), cigarettesAvoided));
    }
    
    return spots;
  }
  
  List<FlSpot> get projectedCigarettesAvoidedData {
    final currentDays = totalDaysFromGoals;
    if (_goals.isEmpty) return [];
    
    final avgCigarettes = _goals.map((g) => g.cigarettesPerDay).reduce((a, b) => a + b) / _goals.length;
    final projectionDays = currentDays > 90 ? 180 : 90;
    
    List<FlSpot> spots = [];
    
    for (int day = currentDays; day <= projectionDays; day++) {
      final cigarettesAvoided = day * avgCigarettes;
      spots.add(FlSpot(day.toDouble(), cigarettesAvoided));
    }
    
    return spots;
  }
  
  double get chartMaxX {
    final currentDays = totalDaysFromGoals;
    return currentDays > 90 ? 180 : 90;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadGoals();
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
                const Text(
                  '📊 Dashboard',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
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
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      child: _buildStatCard('⏱️', 'Smoke Free', timeDisplay, Colors.white),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 600),
                      child: _buildStatCard('🚭', 'Cigarettes Avoided', '$cigarettesAvoided', Colors.white),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 700),
                      child: _buildStatCard('💰', 'Money Saved', '\$${moneySaved.toStringAsFixed(2)}', Colors.white),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 800),
                      child: _buildStatCard('❤️', 'Life Regained', lifeRegained, Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Current vs Projected Charts
                if (totalDaysFromGoals > 0) _buildMoneyProjectionChart(),
                const SizedBox(height: 20),
                if (totalDaysFromGoals > 0) _buildCigarettesProjectionChart(),
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
                        totalDaysFromGoals == 0 ? '🚀 Get Started' : '🎯 Your Progress',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4CAF50),
                        ),
                      ),
                      const SizedBox(height: 10),
                      totalDaysFromGoals == 0
                          ? const Text(
                              'Add goals and mark days complete to see your quit smoking progress!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            )
                          : const Text(
                              'Amazing! Every completed day counts. You\'re getting healthier and saving money!',
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
    final currentDays = totalDaysFromGoals;
    if (_goals.isEmpty) return const SizedBox();
    final avgCigarettes = _goals.map((g) => g.cigarettesPerDay).reduce((a, b) => a + b) / _goals.length;
    final avgPrice = _goals.map((g) => g.pricePerCigarette).reduce((a, b) => a + b) / _goals.length;
    final projectedMax = (currentDays > 90 ? 180 : 90) * avgCigarettes * avgPrice;
    
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
    final currentDays = totalDaysFromGoals;
    if (_goals.isEmpty) return const SizedBox();
    final avgCigarettes = _goals.map((g) => g.cigarettesPerDay).reduce((a, b) => a + b) / _goals.length;
    final projectedMax = (currentDays > 90 ? 180 : 90) * avgCigarettes;
    
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