import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Time Calculation App',
      home: TimeCalculator(),
    );
  }
}

class TimeCalculator extends StatefulWidget {
  const TimeCalculator({Key? key}) : super(key: key);

  @override
  _TimeCalculatorState createState() => _TimeCalculatorState();
}

class _TimeCalculatorState extends State<TimeCalculator> {
  final TextEditingController _controller = TextEditingController();
  String _output = "";
  int _waitTime = 90;

  void calculateTime() {
    try {
      if (_controller.text.length != 4) {
        throw FormatException('正確に4桁で入力。');
      }

      int inputMinutes = int.parse(_controller.text.substring(0, 2));
      int inputSeconds = int.parse(_controller.text.substring(2, 4));

      if (inputMinutes > 59 || inputSeconds > 59) {
        throw FormatException('分または秒が範囲外。0から59の間で入力。');
      }

      int totalInputSeconds = inputMinutes * 60 + inputSeconds;
      int activationTime = totalInputSeconds - _waitTime;

      if (activationTime < 0) {
        throw FormatException('入力時間が短すぎ。');
      }

      int activationMinutes = activationTime ~/ 60;
      int activationSeconds = activationTime % 60;
      setState(() {
        _output =
            "${activationMinutes.toString().padLeft(2, '0')}分${activationSeconds.toString().padLeft(2, '0')}秒";
      });
    } catch (e) {
      setState(() {
        _output = "エラー: ${e.toString()}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('発動時間計算'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: '時間をmmss形式で入力 (例: 1123)',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                  },
                ),
              ),
              keyboardType: TextInputType.number,
              onSubmitted: (value) {
                calculateTime();
              },
            ),
            const SizedBox(height: 20),
            DropdownButton<int>(
              isExpanded: true,
              value: _waitTime,
              items: [30, 60, 90, 120].map((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text('$value seconds'),
                );
              }).toList(),
              onChanged: (int? newValue) {
                setState(() {
                  _waitTime = newValue!;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: calculateTime,
              child: const Text('計算'),
            ),
            const SizedBox(height: 20),
            const Text(
              '奥義発動時間:',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SelectableText(
              _output,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              onTap: () {
                Clipboard.setData(ClipboardData(text: _output));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("時間がクリップボードにコピーされました"),
                  duration: Duration(seconds: 2),
                ));
              },
            ),
          ],
        ),
      ),
    );
  }
}
