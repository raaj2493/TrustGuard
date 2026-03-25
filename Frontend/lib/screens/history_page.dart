import 'package:flutter/material.dart';
import 'package:trust_guard/screens/detection_page.dart';
import 'package:trust_guard/widgets/custom_navbar.dart';
import 'package:trust_guard/widgets/glass_card.dart';
import 'package:trust_guard/utils/app_theme.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy History Data
    final history = [
      {
        "date": "Oct 24, 2026",
        "input": "https://secure-login-bank.com",
        "score": 12,
        "result": "Dangerous",
      },
      {
        "date": "Oct 23, 2026",
        "input": "Amazon: Your order has shipped...",
        "score": 45,
        "result": "Suspicious",
      },
      {
        "date": "Oct 22, 2026",
        "input": "https://google.com",
        "score": 98,
        "result": "Safe",
      },
      {
        "date": "Oct 21, 2026",
        "input": "Win a free iPhone now! Click here...",
        "score": 5,
        "result": "Dangerous",
      },
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CustomNavbar(
              currentIndex: 2,
              onNavigate: (index) {
                if (index == 0) {
                  Navigator.popUntil(context, (route) => route.isFirst);
                } else if (index == 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DetectionPage()),
                  );
                }
              },
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: Column(
                    children: [
                      Text(
                        "Scan History",
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 30),
                      Expanded(
                        child: GlassCard(
                          padding: const EdgeInsets.all(0),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(minWidth: 800),
                              child: DataTable(
                                headingRowColor: WidgetStateProperty.all(
                                  Colors.white.withOpacity(0.05),
                                ),
                                columns: const [
                                  DataColumn(
                                    label: Text(
                                      "Date",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      "Input",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      "Score",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      "Result",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      "Action",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                                rows: history.map((item) {
                                  final result = item['result'] as String;
                                  Color color;
                                  if (result == 'Safe')
                                    color = AppTheme.accentColor;
                                  else if (result == 'Suspicious')
                                    color = AppTheme.warningColor;
                                  else
                                    color = AppTheme.dangerColor;

                                  return DataRow(
                                    cells: [
                                      DataCell(
                                        Text(
                                          item['date'] as String,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        SizedBox(
                                          width: 300,
                                          child: Text(
                                            item['input'] as String,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          "${item['score']}",
                                          style: TextStyle(
                                            color: color,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: color.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: color.withOpacity(0.5),
                                            ),
                                          ),
                                          child: Text(
                                            result,
                                            style: TextStyle(
                                              color: color,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        IconButton(
                                          icon: const Icon(
                                            Icons.arrow_forward,
                                            color: Colors.white54,
                                          ),
                                          onPressed: () {},
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
