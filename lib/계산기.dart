import 'dart:math' as math;

import 'package:flutter/material.dart';

void main() {
  runApp(const ScientificCalculatorApp());
}

class ScientificCalculatorApp extends StatelessWidget {
  const ScientificCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '공학용 계산기',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1E1E1E),
      ),
      home: const ScientificCalculatorScreen(),
    );
  }
}

class ScientificCalculatorScreen extends StatefulWidget {
  const ScientificCalculatorScreen({super.key});

  @override
  State<ScientificCalculatorScreen> createState() =>
      _ScientificCalculatorScreenState();
}

class _ScientificCalculatorScreenState
    extends State<ScientificCalculatorScreen> {
  String _input = '';
  String _result = '0';
  bool _isDeg = true; // Angle mode: Degree vs Radian

  // 버튼 클릭 핸들러
  void _onButtonPressed(String label) {
    setState(() {
      if (label == 'C') {
        _input = '';
        _result = '0';
      } else if (label == '⌫') {
        if (_input.isNotEmpty) {
          _input = _input.substring(0, _input.length - 1);
        }
      } else if (label == '=') {
        _calculateResult();
      } else if (label == 'DEG' || label == 'RAD') {
        _isDeg = !_isDeg;
      } else if ([
        'sin',
        'cos',
        'tan',
        'asin',
        'acos',
        'atan',
        'log',
        'ln',
        'abs',
      ].contains(label)) {
        // 공학용 함수 버튼 클릭 시 '(' 자동 입력
        _input += '$label(';
      } else {
        // 숫자 및 일반 연산자 입력
        _input += label;
      }
    });
  }

  // 수식 계산 처리
  void _calculateResult() {
    if (_input.isEmpty) return;
    try {
      double eval = _parseExpression(_input);
      setState(() {
        _result = _formatResult(eval);
      });
    } catch (e) {
      setState(() {
        _result = '오류';
      });
    }
  }

  String _formatResult(double val) {
    if (val.isNaN) return '계산 불가';
    if (val.isInfinite) return '오버플로';
    if (val == val.toInt()) {
      return val.toInt().toString();
    }
    // 소수점 유효숫자 정리
    return double.parse(val.toStringAsFixed(8)).toString();
  }

  // --- 수식 파싱 시작 ---
  double _parseExpression(String expr) {
    String formatted = expr
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll('π', '${math.pi}')
        .replaceAll('e', '${math.e}');

    List<String> tokens = _tokenize(formatted);

    // 파서 클래스 인스턴스화 및 계산 실행
    _ExpressionParser parser = _ExpressionParser(tokens, _isDeg);
    return parser.parse();
  }

  // 수식 토큰화 (Tokenizer)
  List<String> _tokenize(String input) {
    List<String> tokens = [];
    StringBuffer numberBuffer = StringBuffer();

    for (int i = 0; i < input.length; i++) {
      String char = input[i];

      if (RegExp(r'[0-9.]').hasMatch(char)) {
        numberBuffer.write(char);
      } else {
        if (numberBuffer.isNotEmpty) {
          tokens.add(numberBuffer.toString());
          numberBuffer.clear();
        }

        if (RegExp(r'[a-zA-Z가-힣]').hasMatch(char)) {
          // 함수 이름 추출 (예: sin, log)
          StringBuffer fnBuffer = StringBuffer();
          while (i < input.length && RegExp(r'[a-zA-Z]').hasMatch(input[i])) {
            fnBuffer.write(input[i]);
            i++;
          }
          i--; // 루프 인덱스 보정
          tokens.add(fnBuffer.toString());
        } else if ('+-*/^()!÷×√'.contains(char)) {
          tokens.add(char);
        }
      }
    }
    if (numberBuffer.isNotEmpty) {
      tokens.add(numberBuffer.toString());
    }
    return tokens;
  }

  // 버튼 빌더 함수
  Widget _buildButton(
    String label, {
    Color? bgColor,
    Color? textColor,
    double fontSize = 16,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(2),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: bgColor ?? const Color(0xFF2D2D2D),
            foregroundColor: textColor ?? Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            padding: EdgeInsets.zero,
          ),
          onPressed: () => _onButtonPressed(label),
          child: Text(
            label,
            style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('공학용 계산기', style: TextStyle(fontSize: 18)),
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Display Area
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                alignment: Alignment.bottomRight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      child: Text(
                        _input.isEmpty ? '0' : _input,
                        style: const TextStyle(
                          fontSize: 22,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        _result,
                        style: const TextStyle(
                          fontSize: 44,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(color: Colors.grey, height: 1),
            // Button Grid Area
            Expanded(
              flex: 7,
              child: Container(
                padding: const EdgeInsets.all(6),
                child: Column(
                  children: [
                    // Row 1
                    Expanded(
                      child: Row(
                        children: [
                          _buildButton(
                            _isDeg ? 'DEG' : 'RAD',
                            bgColor: const Color(0xFF383838),
                            textColor: Colors.amber,
                          ),
                          _buildButton('sin', bgColor: const Color(0xFF383838)),
                          _buildButton('cos', bgColor: const Color(0xFF383838)),
                          _buildButton('tan', bgColor: const Color(0xFF383838)),
                          _buildButton('C', bgColor: Colors.redAccent.shade700),
                          _buildButton('⌫', bgColor: const Color(0xFF383838)),
                        ],
                      ),
                    ),
                    // Row 2
                    Expanded(
                      child: Row(
                        children: [
                          _buildButton('^', bgColor: const Color(0xFF383838)),
                          _buildButton('log', bgColor: const Color(0xFF383838)),
                          _buildButton('ln', bgColor: const Color(0xFF383838)),
                          _buildButton('√', bgColor: const Color(0xFF383838)),
                          _buildButton('(', bgColor: const Color(0xFF383838)),
                          _buildButton(')', bgColor: const Color(0xFF383838)),
                        ],
                      ),
                    ),
                    // Row 3
                    Expanded(
                      child: Row(
                        children: [
                          _buildButton('π', bgColor: const Color(0xFF383838)),
                          _buildButton('7'),
                          _buildButton('8'),
                          _buildButton('9'),
                          _buildButton('÷', bgColor: const Color(0xFF383838)),
                          _buildButton('!', bgColor: const Color(0xFF383838)),
                        ],
                      ),
                    ),
                    // Row 4
                    Expanded(
                      child: Row(
                        children: [
                          _buildButton('e', bgColor: const Color(0xFF383838)),
                          _buildButton('4'),
                          _buildButton('5'),
                          _buildButton('6'),
                          _buildButton('×', bgColor: const Color(0xFF383838)),
                          _buildButton('-', bgColor: const Color(0xFF383838)),
                        ],
                      ),
                    ),
                    // Row 5
                    Expanded(
                      child: Row(
                        children: [
                          _buildButton('abs', bgColor: const Color(0xFF383838)),
                          _buildButton('1'),
                          _buildButton('2'),
                          _buildButton('3'),
                          _buildButton('+', bgColor: const Color(0xFF383838)),
                          _buildButton(
                            '=',
                            bgColor: Theme.of(context).colorScheme.primary,
                            textColor: Colors.black,
                          ),
                        ],
                      ),
                    ),
                    // Row 6
                    Expanded(
                      child: Row(
                        children: [
                          _buildButton(
                            'asin',
                            bgColor: const Color(0xFF383838),
                            fontSize: 13,
                          ),
                          _buildButton(
                            'acos',
                            bgColor: const Color(0xFF383838),
                            fontSize: 13,
                          ),
                          _buildButton('0'),
                          _buildButton('.'),
                          _buildButton(
                            'atan',
                            bgColor: const Color(0xFF383838),
                            fontSize: 13,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 계산기 연산을 담당하는 별도의 Parser 클래스 (함수 스코프 참조 에러 해결)
// ============================================================================
class _ExpressionParser {
  final List<String> tokens;
  final bool isDeg;
  int index = 0;

  _ExpressionParser(this.tokens, this.isDeg);

  // 파싱 시작점
  double parse() {
    double finalValue = parseExpressionTokens();
    if (index < tokens.length) {
      throw const FormatException('수식 오류');
    }
    return finalValue;
  }

  // 1단계: 덧셈 및 뺄셈 (+, -)
  double parseExpressionTokens() {
    double value = parseTerm();
    while (index < tokens.length) {
      String op = tokens[index];
      if (op == '+' || op == '-') {
        index++;
        double nextTerm = parseTerm();
        if (op == '+') value += nextTerm;
        if (op == '-') value -= nextTerm;
      } else {
        break;
      }
    }
    return value;
  }

  // 2단계: 곱셈 및 나눗셈 (*, /)
  double parseTerm() {
    double value = parsePower();
    while (index < tokens.length) {
      String op = tokens[index];
      if (op == '*' || op == '/') {
        index++;
        double nextFactor = parsePower();
        if (op == '*') value *= nextFactor;
        if (op == '/') {
          if (nextFactor == 0) return double.nan;
          value /= nextFactor;
        }
      } else {
        break;
      }
    }
    return value;
  }

  // 3단계: 거듭제곱 (^)
  double parsePower() {
    double value = parseFactor();
    if (index < tokens.length && tokens[index] == '^') {
      index++;
      double exponent = parsePower(); // 우측 우선 재귀 결합
      value = math.pow(value, exponent).toDouble();
    }
    return value;
  }

  // 4단계: 단항 연산자, 괄호, 함수 및 피연산자 처리
  double parseFactor() {
    if (index >= tokens.length) return 0;
    String token = tokens[index];

    // 단항 부호 (+ / -)
    if (token == '-') {
      index++;
      return -parseFactor();
    }
    if (token == '+') {
      index++;
      return parseFactor();
    }

    double result;

    // 괄호 처리
    if (token == '(') {
      index++; // '(' 소비
      result = parseExpressionTokens();
      if (index < tokens.length && tokens[index] == ')') {
        index++; // ')' 소비
      }
    }
    // 단항 공학용 함수 처리 (sin, cos, log, √ 등)
    else if ([
      'sin',
      'cos',
      'tan',
      'asin',
      'acos',
      'atan',
      'log',
      'ln',
      '√',
      'abs',
    ].contains(token)) {
      String fnName = token;
      index++; // 함수 이름 소비

      double arg = parseFactor();
      result = _applyFunction(fnName, arg);
    }
    // 일반 숫자
    else {
      index++;
      result = double.tryParse(token) ?? 0;
    }

    // 후위 연산자: 팩토리얼 (!) 처리
    while (index < tokens.length && tokens[index] == '!') {
      index++;
      result = _factorial(result);
    }

    return result;
  }

  // 함수 내부 로직
  double _applyFunction(String func, double arg) {
    double radArg = isDeg ? arg * (math.pi / 180.0) : arg;
    switch (func) {
      case 'sin':
        return math.sin(radArg);
      case 'cos':
        return math.cos(radArg);
      case 'tan':
        return math.tan(radArg);
      case 'asin':
        double res = math.asin(arg);
        return isDeg ? res * (180.0 / math.pi) : res;
      case 'acos':
        double res = math.acos(arg);
        return isDeg ? res * (180.0 / math.pi) : res;
      case 'atan':
        double res = math.atan(arg);
        return isDeg ? res * (180.0 / math.pi) : res;
      case 'log':
        return math.log(arg) / math.ln10; // 상용로그
      case 'ln':
        return math.log(arg); // 자연로그
      case '√':
        return math.sqrt(arg);
      case 'abs':
        return arg.abs();
      default:
        return arg;
    }
  }

  // 팩토리얼 연산
  double _factorial(double n) {
    if (n < 0) return double.nan;
    if (n == 0 || n == 1) return 1;
    double res = 1;
    for (int i = 2; i <= n.toInt(); i++) {
      res *= i;
    }
    return res;
  }
}
