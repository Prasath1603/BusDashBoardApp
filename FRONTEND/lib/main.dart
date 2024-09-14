import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bus Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DashboardPage(),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int? personCount;
  int? rfidCount;
  bool isLoading = false;
  String errorMessage = '';

  Future<void> fetchPersonCount() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(Uri.parse('http://172.16.61.92:5000/get_person_count'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          personCount = data['person_count'];
          rfidCount = null; // Placeholder for RFID count
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to fetch person count: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bus Dashboard'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            isLoading
                ? const CircularProgressIndicator()
                : errorMessage.isNotEmpty
                    ? Text(
                        errorMessage,
                        style: const TextStyle(fontSize: 18, color: Colors.red),
                        textAlign: TextAlign.center,
                      )
                    : personCount != null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DashboardTile(
                                title: 'Person Count',
                                value: personCount.toString(),
                                icon: Icons.people,
                                color: Colors.green,
                              ),
                              const SizedBox(height: 20),
                              DashboardTile(
                                title: 'RFID Count',
                                value: rfidCount != null ? rfidCount.toString() : 'N/A',
                                icon: Icons.nfc,
                                color: Colors.orange,
                              ),
                            ],
                          )
                        : const Center(
                            child: Text(
                              'Press the button to get person count',
                              style: TextStyle(fontSize: 18),
                              textAlign: TextAlign.center,
                            ),
                          ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: fetchPersonCount,
              icon: const Icon(Icons.refresh, size: 24),
              label: const Text('Refresh', style: TextStyle(fontSize: 20)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                backgroundColor: Colors.blueAccent, // Updated button style
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const DashboardTile({super.key, 
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: color, size: 40),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: const TextStyle(fontSize: 24, color: Colors.black87),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
