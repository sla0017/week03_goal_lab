import 'package:flutter/material.dart';

// 1. 앱 실행을 위한 메인 함수 (필수)
void main() {
  runApp(const MyApp());
}

// 2. 앱의 뼈대 설정 (MaterialApp)
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '3주차 과제',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: GoalScreen(), // 처음에 띄울 화면
    );
  }
}

// 3. 목표 데이터 모델 (반드시 다른 클래스 바깥에 독립적으로 있어야 합니다)
class StudyGoal {
  String title;
  bool isCompleted;

  StudyGoal({required this.title, this.isCompleted = false});
}

// 4. 화면 UI 및 동작 로직
class GoalScreen extends StatefulWidget {
  @override
  _GoalScreenState createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  // 상태 변수 설정
  final List<StudyGoal> _goals = [];
  final TextEditingController _controller = TextEditingController();
  String? _errorMessage;

  // _addGoal 구현
  void _addGoal() {
    final text = _controller.text.trim();

    if (text.isEmpty) {
      setState(() {
        _errorMessage = "목표를 입력해주세요.";
      });
      return;
    }

    setState(() {
      _goals.add(StudyGoal(title: text));
      _errorMessage = null;
      _controller.clear();
    });
  }

  // _toggleGoal 구현
  void _toggleGoal(int index) {
    setState(() {
      _goals[index].isCompleted = !_goals[index].isCompleted;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('3주차 StudyGoal')),
      body: Column(
        children: [
          // 입력 영역
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: '오늘의 목표를 입력하세요',
                      errorText: _errorMessage,
                    ),
                  ),
                ),
                IconButton(icon: const Icon(Icons.add), onPressed: _addGoal),
              ],
            ),
          ),

          // 리스트 출력 영역
          Expanded(
            child: ListView.builder(
              itemCount: _goals.length,
              itemBuilder: (context, index) {
                final goal = _goals[index];
                return ListTile(
                  leading: Checkbox(
                    value: goal.isCompleted,
                    onChanged: (value) => _toggleGoal(index),
                  ),
                  title: Text(
                    goal.title,
                    style: TextStyle(
                      decoration: goal.isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: goal.isCompleted ? Colors.grey : Colors.black,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
