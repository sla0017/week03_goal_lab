import 'package:flutter/material.dart';

void main() {
  runApp(const StudyGoalApp());
}

class StudyGoal {
  StudyGoal(this.title);

  final String title;
  bool isDone = false;

  void toggle() {
    isDone = !isDone;
  }
}

class StudyGoalApp extends StatelessWidget {
  const StudyGoalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.teal),
      home: const StudyGoalPage(),
    );
  }
}

class StudyGoalPage extends StatefulWidget {
  const StudyGoalPage({super.key});

  @override
  State<StudyGoalPage> createState() => _StudyGoalPageState();
}

class _StudyGoalPageState extends State<StudyGoalPage> {
  final _controller = TextEditingController();
  final List<StudyGoal> _goals = [];
  String? _errorText;

  void _addGoal() {
    final title = _controller.text.trim();

    if (title.isEmpty) {
      setState(() {
        _errorText = '목표를 입력하세요';
      });
      return;
    }

    setState(() {
      _goals.add(StudyGoal(title));
      _errorText = null;
      _controller.clear();
    });
  }

  void _toggleGoal(int index) {
    // TODO(AC3): 선택한 객체에 완료 전환을 요청하고 화면을 갱신한다.
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Week 03 · Study Goal')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: '오늘의 학습 목표',
                errorText: _errorText,
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (_) => _addGoal(),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _addGoal,
                child: const Text('추가'),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _goals.isEmpty
                  ? const Center(child: Text('등록된 학습 목표가 없습니다.'))
                  : ListView.builder(
                      itemCount: _goals.length,
                      itemBuilder: (context, index) {
                        final goal = _goals[index];
                        return CheckboxListTile(
                          value: goal.isDone,
                          onChanged: (_) => _toggleGoal(index),
                          title: Text(goal.title),
                          subtitle: Text(goal.isDone ? '완료' : '미완료'),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
