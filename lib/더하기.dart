import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '두 수 더하기 앱',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: '두 수 더하기 계산기'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // 텍스트 필드의 입력값을 가져오기 위한 컨트롤러 생성
  final TextEditingController _num1Controller = TextEditingController();
  final TextEditingController _num2Controller = TextEditingController();

  // 계산 결과를 저장할 변수
  String _result = '숫자를 입력하고 더하기 버튼을 누르세요';

  // 덧셈 연산 함수
  void _calculateSum() {
    setState(() {
      // 입력값을 double(실수) 타입으로 변환 (숫자가 아니거나 빈 값이면 null 반환)
      double? num1 = double.tryParse(_num1Controller.text);
      double? num2 = double.tryParse(_num2Controller.text);

      if (num1 != null && num2 != null) {
        double sum = num1 + num2;

        // 정수로 딱 떨어질 경우 소수점(.0) 제거 후 출력
        if (sum == sum.toInt()) {
          _result = '결과: ${sum.toInt()}';
        } else {
          _result = '결과: $sum';
        }
      } else {
        _result = '올바른 숫자를 입력해주세요.';
      }
    });
  }

  // 메모리 누수를 방지하기 위한 controller 해제
  @override
  void dispose() {
    _num1Controller.dispose();
    _num2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 첫 번째 입력 필드
            TextField(
              controller: _num1Controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '첫 번째 숫자',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.looks_one),
              ),
            ),
            const SizedBox(height: 16), // 위젯 간 간격
            // 두 번째 입력 필드
            TextField(
              controller: _num2Controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '두 번째 숫자',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.looks_two),
              ),
            ),
            const SizedBox(height: 24),

            // 더하기 버튼
            ElevatedButton.icon(
              onPressed: _calculateSum,
              icon: const Icon(Icons.add),
              label: const Text('더하기', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 32),

            // 결과 출력 영역
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _result,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
