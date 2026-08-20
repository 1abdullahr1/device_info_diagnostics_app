import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class DiagnosticsScreen extends StatefulWidget {
  const DiagnosticsScreen({super.key});

  @override
  State<DiagnosticsScreen> createState() => _DiagnosticsScreenState();
}

class _DiagnosticsScreenState extends State<DiagnosticsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Text Benchmark State
  bool _isTextRunning = false;
  final List<String> _textLog = [];
  int _linesRendered = 0;
  int _charsProcessed = 0;
  double _elapsedSeconds = 0.0;
  Timer? _textTimer;
  final ScrollController _logScrollController = ScrollController();

  // Compute Benchmark State
  bool _isBenchmarking = false;
  double _benchmarkScore = 0;
  String _benchmarkStatus = 'Idle - Ready for benchmark';

  // Screen Touch Test State
  final List<Offset> _touchPoints = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _textTimer?.cancel();
    _tabController.dispose();
    _logScrollController.dispose();
    super.dispose();
  }

  void _startTextRun() {
    setState(() {
      _isTextRunning = true;
      _textLog.clear();
      _linesRendered = 0;
      _charsProcessed = 0;
      _elapsedSeconds = 0.0;
    });

    final stopwatch = Stopwatch()..start();

    _textTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (!_isTextRunning) {
        timer.cancel();
        return;
      }

      final random = Random();
      final sampleWords = [
        'Device Hardware Check',
        'Cortex-X4',
        'LPDDR5X',
        'UFS 4.0 Flash',
        'Vulkan 1.3 Pipeline',
        'ARM64-v8a ABI',
        'Display 120Hz LTPO',
        'Widevine L1 DRM Verified',
        'Thermal Sensor: 34.2°C',
        'Battery: 4200mV 98%',
        '64-bit Kernel Buffer',
        'SHA-256 Checksum: 0x9F4C2A',
      ];

      final word = sampleWords[random.nextInt(sampleWords.length)];
      final line = '[${DateTime.now().toIso8601String().substring(11, 23)}] [CPU Thread ${random.nextInt(8)}] $word (${random.nextInt(99999)} ops)';

      _textLog.add(line);
      _linesRendered++;
      _charsProcessed += line.length;
      _elapsedSeconds = stopwatch.elapsedMilliseconds / 1000.0;

      // Keep maximum 200 items in buffer for smooth UI
      if (_textLog.length > 200) {
        _textLog.removeAt(0);
      }

      if (_logScrollController.hasClients) {
        _logScrollController.jumpTo(_logScrollController.position.maxScrollExtent);
      }

      setState(() {});
    });
  }

  void _stopTextRun() {
    _textTimer?.cancel();
    setState(() {
      _isTextRunning = false;
    });
  }

  Future<void> _runComputeBenchmark() async {
    setState(() {
      _isBenchmarking = true;
      _benchmarkStatus = 'Running multi-core mathematical compute test...';
      _benchmarkScore = 0;
    });

    await Future.delayed(const Duration(milliseconds: 100));

    final stopwatch = Stopwatch()..start();
    double accumulator = 0.0;

    // Run 5 million floating point & trigonometric operations
    for (int i = 0; i < 5000000; i++) {
      accumulator += sin(i) * cos(i) + sqrt(i.toDouble());
    }

    stopwatch.stop();
    final timeMs = stopwatch.elapsedMilliseconds;

    // Calculate normalized score (Higher is better)
    final score = (5000000.0 / (timeMs > 0 ? timeMs : 1)) * 10;

    setState(() {
      _isBenchmarking = false;
      _benchmarkScore = score;
      _benchmarkStatus = 'Completed in ${timeMs}ms (Processed 5,000,000 operations)';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Diagnostics & Tests',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.terminal_rounded), text: 'Run Text Stream'),
            Tab(icon: Icon(Icons.speed_rounded), text: 'CPU Benchmark'),
            Tab(icon: Icon(Icons.touch_app_rounded), text: 'Touch & Screen'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTextStreamTab(context),
          _buildBenchmarkTab(context),
          _buildTouchScreenTab(context),
        ],
      ),
    );
  }

  Widget _buildTextStreamTab(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final opsPerSec = _elapsedSeconds > 0 ? (_linesRendered / _elapsedSeconds).toStringAsFixed(1) : '0';

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Metrics Header
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMiniStat('Lines Streamed', '$_linesRendered', Icons.format_list_numbered_rounded),
                  _buildMiniStat('Throughput', '$opsPerSec lines/s', Icons.speed_rounded),
                  _buildMiniStat('Characters', '$_charsProcessed', Icons.text_fields_rounded),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Stream Control Buttons
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _isTextRunning ? null : _startTextRun,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Start Text Run'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: Colors.green,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _isTextRunning ? _stopTextRun : null,
                  icon: const Icon(Icons.stop_rounded),
                  label: const Text('Stop Text Run'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: Colors.redAccent,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Terminal Console Window
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.cyan.withAlpha(80)),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                      const SizedBox(width: 10),
                      const Text(
                        'Live Diagnostic Text Terminal',
                        style: TextStyle(color: Colors.white70, fontSize: 11, fontFamily: 'monospace'),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white24, height: 16),
                  Expanded(
                    child: _textLog.isEmpty
                        ? const Center(
                            child: Text(
                              'Press "Start Text Run" to stream diagnostic logs and test text rendering engine throughput.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white54, fontSize: 13, fontFamily: 'monospace'),
                            ),
                          )
                        : ListView.builder(
                            controller: _logScrollController,
                            itemCount: _textLog.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2.0),
                                child: Text(
                                  _textLog[index],
                                  style: const TextStyle(
                                    color: Color(0xFF38BDF8),
                                    fontSize: 11,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenchmarkTab(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          CircleAvatar(
            radius: 40,
            backgroundColor: colorScheme.primaryContainer,
            child: Icon(Icons.bolt_rounded, size: 48, color: colorScheme.primary),
          ),
          const SizedBox(height: 16),
          Text(
            'CPU Arithmetic Compute Test',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Executes 5,000,000 trigonometric and floating point math calculations to evaluate single-thread processor throughput.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 24),

          // Score Card
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 3,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text('BENCHMARK SCORE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  const SizedBox(height: 8),
                  Text(
                    _benchmarkScore == 0 ? '---' : _benchmarkScore.toStringAsFixed(0),
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _benchmarkStatus,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          if (_isBenchmarking)
            const CircularProgressIndicator()
          else
            FilledButton.icon(
              onPressed: _runComputeBenchmark,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Run Compute Benchmark'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTouchScreenTab(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            'Draw or tap anywhere below to test multi-touch responsiveness & touch tracking (${_touchPoints.length} points logged):',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                _touchPoints.add(details.localPosition);
                if (_touchPoints.length > 500) _touchPoints.removeAt(0);
              });
            },
            onTapDown: (details) {
              setState(() {
                _touchPoints.add(details.localPosition);
              });
            },
            child: Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(10),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.withAlpha(80), width: 2),
              ),
              child: CustomPaint(
                painter: _TouchPainter(points: _touchPoints),
                child: Container(),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _touchPoints.clear();
              });
            },
            icon: const Icon(Icons.cleaning_services_rounded),
            label: const Text('Clear Canvas'),
          ),
        ),
      ],
    );
  }

  Widget _buildMiniStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.indigo),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}

class _TouchPainter extends CustomPainter {
  final List<Offset> points;
  _TouchPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blueAccent
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;

    for (int i = 0; i < points.length; i++) {
      canvas.drawCircle(points[i], 8.0, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _TouchPainter oldDelegate) => true;
}
