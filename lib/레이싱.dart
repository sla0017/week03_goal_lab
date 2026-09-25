import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MotoRacingApp());
}

class MotoRacingApp extends StatelessWidget {
  const MotoRacingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '오토바이 레이싱',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.grey),
        useMaterial3: true,
      ),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // 게임 상태 변수
  bool _isPlaying = false;
  bool _isGameOver = false;
  int _score = 0;

  // 차선은 0(왼쪽), 1(가운데), 2(오른쪽) 3개로 구성
  int _playerLane = 1;

  // 장애물 리스트 (lane: 차선, y: 수직 위치 0.0 ~ 1.0)
  List<Obstacle> _obstacles = [];

  Timer? _gameTimer;
  final Random _random = Random();

  // 다음 장애물이 생성될 거리 (Y좌표 기준)
  double _nextSpawnDistance = 0.5;

  // 게임 시작
  void _startGame() {
    setState(() {
      _isPlaying = true;
      _isGameOver = false;
      _score = 0;
      _playerLane = 1;
      _obstacles.clear();
      _nextSpawnDistance = 0.5;
    });

    _gameTimer?.cancel();
    // 부드러운 모션을 위해 16ms(약 60FPS) 주기로 화면 갱신
    _gameTimer = Timer.periodic(const Duration(milliseconds: 16), _updateGame);
  }

  // 게임 루프 업데이트
  void _updateGame(Timer timer) {
    if (_isGameOver) return;

    setState(() {
      // 1. 100점 단위로 레벨을 계산하여 속도 증가
      int level = _score ~/ 100;
      // 기본 속도 0.01에, 레벨당 0.0015씩 추가 (너무 빠르지 않게 최대 0.08 제한)
      double speed = min(0.01 + (level * 0.0015), 0.08);

      // 장애물 아래로 이동
      for (var obs in _obstacles) {
        obs.y += speed;
      }

      // 충돌 검사 (오토바이의 y위치는 0.85 부근)
      for (var obs in _obstacles) {
        if (obs.lane == _playerLane && obs.y > 0.75 && obs.y < 0.9) {
          _gameOver();
          return;
        }
      }

      // 화면을 벗어난 장애물 제거 및 점수 증가
      _obstacles.removeWhere((obs) {
        if (obs.y > 1.0) {
          _score += 10;
          return true;
        }
        return false;
      });

      // 새 장애물 생성 (마지막 장애물과의 Y좌표 간격이 목표치를 넘었을 때)
      if (_obstacles.isEmpty || _obstacles.last.y > _nextSpawnDistance) {
        int lane = _random.nextInt(3);
        _obstacles.add(Obstacle(lane: lane, y: -0.1));

        // 다음 장애물이 생성될 간격을 랜덤하게 설정 (0.35 ~ 0.65 사이)
        _nextSpawnDistance = 0.35 + _random.nextDouble() * 0.3;
      }
    });
  }

  // 게임 오버 처리
  void _gameOver() {
    setState(() {
      _isGameOver = true;
      _isPlaying = false;
    });
    _gameTimer?.cancel();
  }

  // 왼쪽으로 한 칸 이동
  void _moveLeft() {
    if (_isPlaying && !_isGameOver && _playerLane > 0) {
      setState(() {
        _playerLane--;
      });
    }
  }

  // 오른쪽으로 한 칸 이동
  void _moveRight() {
    if (_isPlaying && !_isGameOver && _playerLane < 2) {
      setState(() {
        _playerLane++;
      });
    }
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[800], // 도로 주변 배경색
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400), // 모바일 화면 비율 유지
          child: Focus(
            autofocus: true,
            onKeyEvent: (node, event) {
              if (event is KeyDownEvent) {
                if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
                  _moveLeft();
                  return KeyEventResult.handled;
                } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
                  _moveRight();
                  return KeyEventResult.handled;
                }
              }
              return KeyEventResult.ignored;
            },
            child: ClipRect(
              child: Stack(
                children: [
                  // 1. 도로 배경
                  Container(
                    color: Colors.grey[850],
                    width: double.infinity,
                    height: double.infinity,
                  ),

                  // 차선 그리기
                  Row(
                    children: [
                      Expanded(child: _buildLaneDivider()),
                      Expanded(child: _buildLaneDivider()),
                      Expanded(child: Container()), // 마지막 차선은 오른쪽 선 필요 없음
                    ],
                  ),

                  // 2. 모바일용 터치 영역 (화면 반반)
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: _moveLeft,
                          behavior: HitTestBehavior.translucent,
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: _moveRight,
                          behavior: HitTestBehavior.translucent,
                        ),
                      ),
                    ],
                  ),

                  // 3. 장애물 그리기
                  ..._obstacles.map((obs) {
                    return Align(
                      alignment: FractionalOffset(
                        (obs.lane * 0.5), // 0.0(좌), 0.5(중앙), 1.0(우)
                        obs.y,
                      ),
                      child: const Text(
                        '🚗', // 장애물 이모지
                        style: TextStyle(fontSize: 48),
                      ),
                    );
                  }),

                  // 4. 플레이어 (오토바이) 그리기 - AnimatedAlign으로 부드러운 차선 이동 구현
                  AnimatedAlign(
                    duration: const Duration(milliseconds: 150), // 이동 애니메이션 시간
                    curve: Curves.easeOutQuad, // 자연스러운 감속 커브
                    alignment: FractionalOffset(
                      (_playerLane * 0.5), // 0.0(좌), 0.5(중앙), 1.0(우)
                      0.85, // 화면 하단에 고정
                    ),
                    child: const Text(
                      '🏍️', // 오토바이 이모지
                      style: TextStyle(fontSize: 48),
                    ),
                  ),

                  // 5. 점수 표시
                  Positioned(
                    top: 50,
                    left: 20,
                    child: Text(
                      '점수: $_score',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // 6. 시작 전 / 게임 오버 화면 오버레이
                  if (!_isPlaying)
                    Container(
                      color: Colors.black.withOpacity(0.7),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _isGameOver ? 'GAME OVER' : '오토바이 레이싱',
                              style: TextStyle(
                                color: _isGameOver ? Colors.red : Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (_isGameOver)
                              Text(
                                '최종 점수: $_score',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                ),
                              ),
                            const SizedBox(height: 32),
                            ElevatedButton(
                              onPressed: _startGame,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 40,
                                  vertical: 16,
                                ),
                                textStyle: const TextStyle(fontSize: 20),
                              ),
                              child: Text(_isGameOver ? '다시 시작' : '게임 시작'),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              '키보드 좌/우 방향키\n또는 화면 좌/우 터치로 조작',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
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

  // 차선 점선 효과를 위한 위젯
  Widget _buildLaneDivider() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: Colors.white.withOpacity(0.3),
            width: 4,
            style: BorderStyle.solid,
          ),
        ),
      ),
    );
  }
}

// 장애물 데이터 클래스
class Obstacle {
  int lane; // 0, 1, 2
  double y; // 0.0 (top) to 1.0 (bottom)

  Obstacle({required this.lane, required this.y});
}
