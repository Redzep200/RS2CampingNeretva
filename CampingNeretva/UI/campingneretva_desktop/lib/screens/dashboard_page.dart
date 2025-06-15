import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/navbar.dart';
import '../services/reservation_service.dart';
import '../services/review_service.dart';
import '../services/image_service.dart';
import '../models/image_model.dart';
import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../services/auth_service.dart';
import 'login_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int yearRevenue = DateTime.now().year;
  int? monthRevenue;

  int yearParcel = DateTime.now().year;
  int? monthParcel;

  int yearActivity = DateTime.now().year;
  int? monthActivity;

  int yearReview = DateTime.now().year;
  int? monthReview;

  double totalRevenue = 0;
  int mostPopularParcel = 0;

  List<MapEntry<String, int>> topActivities = [];
  List<MapEntry<String, int>> topWorkers = [];

  final months = List.generate(
    12,
    (i) => DateFormat.MMMM().format(DateTime(0, i + 1)),
  );

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    await Future.wait([
      _loadRevenueStats(),
      _loadParcelStats(),
      _loadActivityStats(),
      _loadReviewStats(),
    ]);
  }

  DateTimeRange _getDateRange(int year, int? month) {
    final from = month != null ? DateTime(year, month, 1) : DateTime(year, 1);
    final to =
        month != null
            ? DateTime(year, month + 1).subtract(const Duration(days: 1))
            : DateTime(year, 12, 31);
    return DateTimeRange(start: from, end: to);
  }

  Future<void> _loadRevenueStats() async {
    final range = _getDateRange(yearRevenue, monthRevenue);
    final reservations = await ReservationService.fetchAll(
      from: range.start,
      to: range.end,
      page: 0,
      pageSize: 10000,
    );
    setState(() {
      totalRevenue = reservations.fold(0.0, (sum, r) => sum + r.totalPrice);
    });
  }

  Future<void> _loadParcelStats() async {
    final range = _getDateRange(yearParcel, monthParcel);
    final reservations = await ReservationService.fetchAll(
      from: range.start,
      to: range.end,
      page: 0,
      pageSize: 10000,
    );
    final parcelCounts = <int, int>{};

    for (var res in reservations) {
      parcelCounts[res.parcel.number] =
          (parcelCounts[res.parcel.number] ?? 0) + 1;
    }

    setState(() {
      mostPopularParcel =
          parcelCounts.isNotEmpty
              ? parcelCounts.entries
                  .reduce((a, b) => a.value > b.value ? a : b)
                  .key
              : 0;
    });
  }

  Future<void> _loadActivityStats() async {
    final range = _getDateRange(yearActivity, monthActivity);
    final reservations = await ReservationService.fetchAll(
      from: range.start,
      to: range.end,
      page: 0,
      pageSize: 10000,
    );
    final activityCounts = <String, int>{};
    for (var res in reservations) {
      for (var act in res.activities ?? []) {
        activityCounts[act.name] = (activityCounts[act.name] ?? 0) + 1;
      }
    }

    final sorted =
        activityCounts.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    setState(() {
      topActivities = sorted.take(3).toList();
    });
  }

  Future<void> _loadReviewStats() async {
    final range = _getDateRange(yearReview, monthReview);
    final reviews = await ReviewService.getAll();

    final filtered = reviews.where((r) {
      final date = DateTime.parse(r.datePosted);
      return date.isAfter(range.start.subtract(const Duration(seconds: 1))) &&
          date.isBefore(range.end.add(const Duration(days: 1)));
    });

    final workerCounts = <String, int>{};
    for (var r in filtered) {
      final name = r.worker.fullName;
      workerCounts[name] = (workerCounts[name] ?? 0) + 1;
    }

    final sorted =
        workerCounts.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    setState(() {
      topWorkers = sorted.take(3).toList();
    });
  }

  Future<Uint8List> _generatePdf(String title, String content) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(title, style: const pw.TextStyle(fontSize: 24)),
              pw.SizedBox(height: 20),
              pw.Text(content, style: const pw.TextStyle(fontSize: 16)),
            ],
          );
        },
      ),
    );
    return pdf.save();
  }

  Future<void> _downloadPdf(String fileName, Uint8List pdfBytes) async {
    try {
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Save PDF',
        fileName: fileName,
        allowedExtensions: ['pdf'],
        type: FileType.custom,
      );

      if (result != null) {
        final file = File(result);
        await file.writeAsBytes(pdfBytes);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF saved to: $result'),
            duration: const Duration(seconds: 5),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF save canceled'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving PDF: $e')));
    }
  }

  Future<void> _generateRevenueReport() async {
    final period =
        monthRevenue != null
            ? '${months[monthRevenue! - 1]} $yearRevenue'
            : 'Cijela godina $yearRevenue';
    final content =
        'Ukupna zarada za $period: € ${totalRevenue.toStringAsFixed(2)}';
    final pdfBytes = await _generatePdf('Izvještaj o zaradi', content);
    await _downloadPdf(
      'revenue_report_$yearRevenue${monthRevenue != null ? '_${monthRevenue}' : ''}.pdf',
      pdfBytes,
    );
  }

  Future<void> _generateParcelReport() async {
    final period =
        monthParcel != null
            ? '${months[monthParcel! - 1]} $yearParcel'
            : 'Cijela godina $yearParcel';
    final content =
        mostPopularParcel > 0
            ? 'Najpopularnija parcela za $period: Parcela #$mostPopularParcel'
            : 'Nema podataka o parcelama za $period';
    final pdfBytes = await _generatePdf('Izvještaj o parcelama', content);
    await _downloadPdf(
      'parcel_report_$yearParcel${monthParcel != null ? '_${monthParcel}' : ''}.pdf',
      pdfBytes,
    );
  }

  Future<void> _generateActivityReport() async {
    final period =
        monthActivity != null
            ? '${months[monthActivity! - 1]} $yearActivity'
            : 'Cijela godina $yearActivity';
    final content =
        topActivities.isNotEmpty
            ? 'Top 3 aktivnosti za $period:\n' +
                topActivities
                    .asMap()
                    .entries
                    .map(
                      (e) =>
                          '${e.key + 1}. ${e.value.key}: ${e.value.value} puta',
                    )
                    .join('\n')
            : 'Nema podataka o aktivnostima za $period';
    final pdfBytes = await _generatePdf('Izvještaj o aktivnostima', content);
    await _downloadPdf(
      'activity_report_$yearActivity${monthActivity != null ? '_${monthActivity}' : ''}.pdf',
      pdfBytes,
    );
  }

  Future<void> _generateReviewReport() async {
    final period =
        monthReview != null
            ? '${months[monthReview! - 1]} $yearReview'
            : 'Cijela godina $yearReview';
    final content =
        topWorkers.isNotEmpty
            ? 'Top 3 radnika po recenzijama za $period:\n' +
                topWorkers
                    .asMap()
                    .entries
                    .map(
                      (e) =>
                          '${e.key + 1}. ${e.value.key}: ${e.value.value} recenzija',
                    )
                    .join('\n')
            : 'Nema podataka o recenzijama za $period';
    final pdfBytes = await _generatePdf('Izvještaj o recenzijama', content);
    await _downloadPdf(
      'review_report_$yearReview${monthReview != null ? '_${monthReview}' : ''}.pdf',
      pdfBytes,
    );
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (mounted) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (context) => LoginPage()));
    }
  }

  void _showImagesDialog() async {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: FutureBuilder<List<ImageModel>>(
            future: ImageService.fetchAll(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: CircularProgressIndicator()),
                );
              } else if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text('Greška pri dohvaćanju slika: ${snapshot.error}'),
                );
              }

              final images = snapshot.data ?? [];

              return Container(
                width: 600,
                height: 500,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sve slike',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: GridView.builder(
                        itemCount: images.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                        itemBuilder: (context, index) {
                          final img = images[index];
                          return Stack(
                            children: [
                              Positioned.fill(
                                child: Image.network(
                                  'http://localhost:5205/${img.path}',
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (context, _, __) =>
                                          const Icon(Icons.broken_image),
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () async {
                                    try {
                                      await ImageService.delete(img.imageId);
                                      Navigator.of(context).pop();
                                      _showImagesDialog();
                                    } catch (e) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Greška pri brisanju slike: $e',
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        child: const Text('Zatvori'),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _yearMonthPicker({
    required int year,
    required int? month,
    required ValueChanged<int?> onYearChanged,
    required ValueChanged<int?> onMonthChanged,
  }) {
    return Row(
      children: [
        DropdownButton<int>(
          value: year,
          items:
              [2023, 2024, 2025]
                  .map((y) => DropdownMenuItem(value: y, child: Text('$y')))
                  .toList(),
          onChanged: onYearChanged,
        ),
        const SizedBox(width: 8),
        DropdownButton<int?>(
          value: month,
          hint: const Text("Cijela godina"),
          items: [
            const DropdownMenuItem<int?>(
              value: null,
              child: Text("Cijela godina"),
            ),
            ...List.generate(12, (i) {
              return DropdownMenuItem(value: i + 1, child: Text(months[i]));
            }),
          ],
          onChanged: onMonthChanged,
        ),
      ],
    );
  }

  Widget _buildBarChart() {
    if (topActivities.isEmpty) {
      return const Center(
        child: Text(
          'Nema podataka o aktivnostima',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top 3 Aktivnosti',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceEvenly,
                  maxY:
                      (topActivities
                                  .map((e) => e.value)
                                  .reduce((a, b) => a > b ? a : b) *
                              1.2)
                          .toDouble(),
                  barGroups:
                      topActivities.asMap().entries.map((entry) {
                        final i = entry.key;
                        final data = entry.value;
                        return BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: data.value.toDouble(),
                              width: 30, // Thicker bars
                              color:
                                  [Colors.blue, Colors.green, Colors.orange][i %
                                      3], // Distinct colors
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                          ],
                          showingTooltipIndicators: [0],
                        );
                      }).toList(),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 12),
                          );
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 60,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < topActivities.length) {
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              angle: 0.5, // Rotate labels slightly for fit
                              child: Text(
                                topActivities[index].key,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval:
                        topActivities.isNotEmpty
                            ? topActivities
                                    .map((e) => e.value)
                                    .reduce((a, b) => a > b ? a : b)
                                    .toDouble() /
                                5
                            : 1,
                  ),
                  borderData: FlBorderData(show: false),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${topActivities[groupIndex].key}\n${rod.toY.toInt()} puta',
                          const TextStyle(color: Colors.white),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart() {
    return PieChart(
      PieChartData(
        sections:
            topWorkers.asMap().entries.map((entry) {
              final i = entry.key;
              final e = entry.value;
              final colors = [Colors.green, Colors.lightGreen, Colors.teal];
              return PieChartSectionData(
                color: colors[i % colors.length],
                value: e.value.toDouble(),
                title: e.key,
                titleStyle: const TextStyle(fontSize: 12),
              );
            }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomNavbar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton.icon(
                    onPressed: _showImagesDialog,
                    icon: const Icon(Icons.image),
                    label: const Text('Prikaži slike'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout),
                    label: const Text('Odjava'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Ukupna zarada:", style: TextStyle(fontSize: 18)),
                Row(
                  children: [
                    _yearMonthPicker(
                      year: yearRevenue,
                      month: monthRevenue,
                      onYearChanged:
                          (v) => setState(() {
                            yearRevenue = v ?? DateTime.now().year;
                            _loadRevenueStats();
                          }),
                      onMonthChanged:
                          (v) => setState(() {
                            monthRevenue = v;
                            _loadRevenueStats();
                          }),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _generateRevenueReport,
                      child: const Text('Izvještaj'),
                    ),
                  ],
                ),
              ],
            ),
            Card(
              margin: const EdgeInsets.only(top: 8),
              child: ListTile(
                title: Text(
                  "€ ${totalRevenue.toStringAsFixed(2)}",
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Najpopularnija parcela:",
                  style: TextStyle(fontSize: 18),
                ),
                Row(
                  children: [
                    _yearMonthPicker(
                      year: yearParcel,
                      month: monthParcel,
                      onYearChanged:
                          (v) => setState(() {
                            yearParcel = v ?? DateTime.now().year;
                            _loadParcelStats();
                          }),
                      onMonthChanged:
                          (v) => setState(() {
                            monthParcel = v;
                            _loadParcelStats();
                          }),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _generateParcelReport,
                      child: const Text('Izvještaj'),
                    ),
                  ],
                ),
              ],
            ),
            Card(
              margin: const EdgeInsets.only(top: 8),
              child: ListTile(
                title: Text(
                  mostPopularParcel > 0
                      ? "Parcela #$mostPopularParcel"
                      : "Nema podataka",
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Top 3 aktivnosti:", style: TextStyle(fontSize: 18)),
                Row(
                  children: [
                    _yearMonthPicker(
                      year: yearActivity,
                      month: monthActivity,
                      onYearChanged:
                          (v) => setState(() {
                            yearActivity = v ?? DateTime.now().year;
                            _loadActivityStats();
                          }),
                      onMonthChanged:
                          (v) => setState(() {
                            monthActivity = v;
                            _loadActivityStats();
                          }),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _generateActivityReport,
                      child: const Text('Izvještaj'),
                    ),
                  ],
                ),
              ],
            ),
            _buildBarChart(),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Top 3 radnika (recenzije):",
                  style: TextStyle(fontSize: 18),
                ),
                Row(
                  children: [
                    _yearMonthPicker(
                      year: yearReview,
                      month: monthReview,
                      onYearChanged:
                          (v) => setState(() {
                            yearReview = v ?? DateTime.now().year;
                            _loadReviewStats();
                          }),
                      onMonthChanged:
                          (v) => setState(() {
                            monthReview = v;
                            _loadReviewStats();
                          }),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _generateReviewReport,
                      child: const Text('Izvještaj'),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 200, child: _buildPieChart()),
          ],
        ),
      ),
    );
  }
}
