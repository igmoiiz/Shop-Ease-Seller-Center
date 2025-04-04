// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:seller_center/Controller/Analytics/analytics_controller.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _cardAnimationController;
  late Animation<double> _fadeAnimation;
  final currencyFormat = NumberFormat.currency(
    symbol: 'Rs. ',
    decimalDigits: 0,
  );
  bool _showChart = true; // Toggle between pie and bar chart

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _cardAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
    _cardAnimationController.forward();

    // Fetch analytics data when the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnalyticsController>().fetchAnalytics();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _cardAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Consumer<AnalyticsController>(
        builder: (context, analytics, _) {
          if (analytics.isLoading) {
            return _buildLoadingState();
          }

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // _buildAnimatedAppBar(analytics),
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatsCards(analytics),
                        const SizedBox(height: 24),
                        _buildChartSection(analytics),
                        const SizedBox(height: 24),
                        _buildRevenueText(analytics),
                        const SizedBox(height: 24),
                        _buildRecentProductsSection(analytics),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.yellow.shade800, Colors.yellow.shade600],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 100,
              height: 100,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 8,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Loading Analytics...',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Preparing your business insights',
              style: GoogleFonts.outfit(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildAnimatedAppBar(AnalyticsController analytics) {
  //   return SliverAppBar(
  //     expandedHeight: 250,
  //     floating: true,
  //     pinned: true,
  //     elevation: 0,
  //     backgroundColor: Colors.yellow.shade800,
  //     flexibleSpace: FlexibleSpaceBar(
  //       title: Text(
  //         'Analytics Dashboard',
  //         style: GoogleFonts.outfit(
  //           color: Colors.white,
  //           fontWeight: FontWeight.bold,
  //         ),
  //       ),
  //       background: Stack(
  //         fit: StackFit.expand,
  //         children: [
  //           // Animated gradient background
  //           Container(
  //             decoration: BoxDecoration(
  //               gradient: LinearGradient(
  //                 begin: Alignment.topLeft,
  //                 end: Alignment.bottomRight,
  //                 colors: [Colors.yellow.shade800, Colors.yellow.shade600],
  //               ),
  //             ),
  //           ),
  //           // Animated circles
  //           ...List.generate(5, (index) {
  //             return Positioned(
  //               right: -30 + (index * 20),
  //               top: -20 + (index * 15),
  //               child: TweenAnimationBuilder<double>(
  //                 tween: Tween(begin: 0.0, end: 1.0),
  //                 duration: Duration(milliseconds: 1000 + (index * 200)),
  //                 builder: (context, value, child) {
  //                   return Transform.scale(
  //                     scale: value,
  //                     child: Container(
  //                       width: 100 + (index * 20),
  //                       height: 100 + (index * 20),
  //                       decoration: BoxDecoration(
  //                         shape: BoxShape.circle,
  //                         color: Colors.white.withOpacity(0.1 - (index * 0.02)),
  //                       ),
  //                     ),
  //                   );
  //                 },
  //               ),
  //             );
  //           }),
  //           // Stats summary
  //           Positioned(
  //             bottom: 70,
  //             left: 16,
  //             right: 16,
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Text(
  //                   'Business Overview',
  //                   style: GoogleFonts.outfit(
  //                     color: Colors.white70,
  //                     fontSize: 16,
  //                   ),
  //                 ),
  //                 const SizedBox(height: 8),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildStatsCards(AnalyticsController analytics) {
    // Calculate average daily sales and products
    double avgDailySales = 0;
    double avgDailyProducts = 0;
    if (analytics.dailySalesData.isNotEmpty) {
      avgDailySales =
          analytics.dailySalesData.fold(
            0.0,
            (sum, item) => sum + (item['sales'] as double),
          ) /
          analytics.dailySalesData.length;
      avgDailyProducts =
          analytics.dailySalesData.fold(
            0.0,
            (sum, item) => sum + (item['products'] as int),
          ) /
          analytics.dailySalesData.length;
    }

    // Find the category with highest revenue
    String topCategory = '';
    double maxRevenue = 0;
    analytics.categoryRevenue.forEach((category, revenue) {
      if (revenue > maxRevenue) {
        maxRevenue = revenue;
        topCategory = category;
      }
    });

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildAnimatedStatsCard(
          'Total Products',
          analytics.totalProducts.toString(),
          FontAwesomeIcons.box,
          Colors.blue,
          0,
          subtitle: 'Avg. ${avgDailyProducts.toStringAsFixed(1)}/day',
        ),
        _buildAnimatedStatsCard(
          'Total Revenue',
          currencyFormat.format(analytics.totalRevenue),
          FontAwesomeIcons.moneyBillTrendUp,
          Colors.green,
          200,
          subtitle: 'Avg. ${currencyFormat.format(avgDailySales)}/day',
        ),
        _buildAnimatedStatsCard(
          'Categories',
          analytics.categories.length.toString(),
          FontAwesomeIcons.layerGroup,
          Colors.purple,
          400,
          subtitle:
              topCategory.isNotEmpty ? 'Top: $topCategory' : 'No sales yet',
        ),
        _buildAnimatedStatsCard(
          'Avg. Price',
          analytics.totalProducts > 0
              ? currencyFormat.format(
                analytics.totalRevenue / analytics.totalProducts,
              )
              : 'Rs. 0',
          FontAwesomeIcons.tag,
          Colors.orange,
          600,
          subtitle: 'Per product',
        ),
      ],
    );
  }

  Widget _buildAnimatedStatsCard(
    String title,
    String value,
    IconData icon,
    Color color,
    int delay, {
    String? subtitle,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 30),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  "$value",
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: color.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildChartSection(AnalyticsController analytics) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _showChart ? 'Product Distribution' : 'Revenue Distribution',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _showChart = !_showChart;
                    });
                  },
                  icon: Icon(
                    _showChart
                        ? FontAwesomeIcons.chartPie
                        : FontAwesomeIcons.chartBar,
                    size: 16,
                  ),
                  label: Text(_showChart ? 'Distribution' : 'Revenue'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.yellow.shade800,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child:
              _showChart
                  ? _buildAnimatedPieChartWithLegend(analytics)
                  : _buildAnimatedBarChart(analytics),
        ),
        const SizedBox(height: 32),
        Text(
          'Sales & Products Trend (Last 30 Days)',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        _buildSalesLineChart(analytics),
      ],
    );
  }

  Widget _buildAnimatedPieChartWithLegend(AnalyticsController analytics) {
    final List<Color> colors = [
      Colors.blue.shade400,
      Colors.red.shade400,
      Colors.green.shade400,
      Colors.purple.shade400,
      Colors.orange.shade400,
      Colors.teal.shade400,
      Colors.pink.shade400,
      Colors.indigo.shade400,
      Colors.amber.shade400,
      Colors.cyan.shade400,
      Colors.brown.shade400,
      Colors.deepOrange.shade400,
    ];

    return Column(
      children: [
        SizedBox(
          height: 300,
          child: Stack(
            children: [
              PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: _generatePieChartSections(analytics),
                ),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      analytics.totalProducts.toString(),
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Products',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: List.generate(analytics.categories.length, (index) {
            final category = analytics.categories[index];
            final count = analytics.categoryProductCounts[category] ?? 0;
            final percentage = count / analytics.totalProducts * 100;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: colors[index % colors.length].withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: colors[index % colors.length].withOpacity(0.5),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: colors[index % colors.length],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    category,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '(${percentage.toStringAsFixed(1)}%)',
                    style: TextStyle(
                      fontSize: 12,
                      color: colors[index % colors.length],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildAnimatedBarChart(AnalyticsController analytics) {
    return SizedBox(
      height: 300,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY:
              analytics.categoryRevenue.values.reduce((a, b) => a > b ? a : b) *
              1.2,
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value >= 0 && value < analytics.categories.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Transform.rotate(
                        angle: -0.5,
                        child: Text(
                          analytics.categories[value.toInt()],
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    currencyFormat.format(value),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
                reservedSize: 60,
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(
            analytics.categories.length,
            (index) => BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY:
                      analytics.categoryRevenue[analytics.categories[index]] ??
                      0,
                  gradient: LinearGradient(
                    colors: [Colors.yellow.shade800, Colors.yellow.shade600],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  width: 16,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> _generatePieChartSections(
    AnalyticsController analytics,
  ) {
    final List<Color> colors = [
      Colors.blue.shade400,
      Colors.red.shade400,
      Colors.green.shade400,
      Colors.purple.shade400,
      Colors.orange.shade400,
      Colors.teal.shade400,
      Colors.pink.shade400,
      Colors.indigo.shade400,
      Colors.amber.shade400,
      Colors.cyan.shade400,
      Colors.brown.shade400,
      Colors.deepOrange.shade400,
    ];

    return List.generate(analytics.categories.length, (index) {
      final category = analytics.categories[index];
      final count = analytics.categoryProductCounts[category] ?? 0;
      final percentage = count / analytics.totalProducts * 100;

      return PieChartSectionData(
        color: colors[index % colors.length],
        value: count.toDouble(),
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    });
  }

  Widget _buildSalesLineChart(AnalyticsController analytics) {
    if (analytics.dailySalesData.isEmpty) {
      return const SizedBox.shrink();
    }

    // Calculate max values for scaling
    double maxSales = 0;
    int maxProducts = 0;
    for (var data in analytics.dailySalesData) {
      if (data['sales'] > maxSales) maxSales = data['sales'];
      if (data['products'] > maxProducts) maxProducts = data['products'];
    }

    return Container(
      height: 300,
      padding: const EdgeInsets.only(right: 16, left: 0, top: 16, bottom: 16),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxSales / 5,
            getDrawingHorizontalLine: (value) {
              return FlLine(color: Colors.grey.shade200, strokeWidth: 1);
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value >= 0 && value < analytics.dailySalesData.length) {
                    DateTime date =
                        analytics.dailySalesData[value.toInt()]['date'];
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Transform.rotate(
                        angle: -0.5,
                        child: Text(
                          '${date.day}/${date.month}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: AxisTitles(
              axisNameWidget: const Text('Sales (Rs.)'),
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    currencyFormat.format(value),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
                reservedSize: 60,
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade300, width: 1),
              left: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
          ),
          minX: 0,
          maxX: analytics.dailySalesData.length.toDouble() - 1,
          minY: 0,
          maxY: maxSales * 1.2,
          lineBarsData: [
            // Sales Line
            LineChartBarData(
              spots: List.generate(
                analytics.dailySalesData.length,
                (index) => FlSpot(
                  index.toDouble(),
                  analytics.dailySalesData[index]['sales'],
                ),
              ),
              isCurved: true,
              color: Colors.yellow.shade800,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.yellow.shade800.withOpacity(0.1),
              ),
            ),
            // Products Line
            LineChartBarData(
              spots: List.generate(
                analytics.dailySalesData.length,
                (index) => FlSpot(
                  index.toDouble(),
                  (analytics.dailySalesData[index]['products'] *
                      maxSales /
                      maxProducts),
                ),
              ),
              isCurved: true,
              color: Colors.blue.shade400,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blue.shade400.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentProductsSection(AnalyticsController analytics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Products',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: analytics.recentProducts.length,
          itemBuilder: (context, index) {
            return _buildAnimatedProductCard(
              analytics.recentProducts[index],
              index,
            );
          },
        ),
      ],
    );
  }

  Widget _buildAnimatedProductCard(Map<String, dynamic> product, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 500 + (index * 100)),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: Hero(
                tag: 'product_${product['id']}',
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      product['image'] ?? '',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.image_not_supported),
                        );
                      },
                    ),
                  ),
                ),
              ),
              title: Text(
                product['title'] ?? 'Untitled Product',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.yellow.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      product['category'] ?? 'Uncategorized',
                      style: TextStyle(
                        color: Colors.yellow.shade800,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currencyFormat.format(product['price'] ?? 0),
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRevenueText(AnalyticsController analytics) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 15,
      children: [
        Text(
          'Total Revenue',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.yellow.shade600,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.sizeOf(context).width * 0.025,
              vertical: MediaQuery.sizeOf(context).height * 0.01,
            ),
            child: Row(
              children: [
                Icon(FontAwesomeIcons.chartLine, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  currencyFormat.format(analytics.totalRevenue),
                  style: GoogleFonts.playfairDisplay(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
