import 'package:flutter/material.dart';

void main() {
  runApp(const ChemicalDictionaryApp());
}

class ChemicalDictionaryApp extends StatelessWidget {
  const ChemicalDictionaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '물질 기호 검색기',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const ChemicalSearchScreen(),
    );
  }
}

class ChemicalSearchScreen extends StatefulWidget {
  const ChemicalSearchScreen({super.key});

  @override
  State<ChemicalSearchScreen> createState() => _ChemicalSearchScreenState();
}

class _ChemicalSearchScreenState extends State<ChemicalSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchResult = '물질 이름을 입력하고 검색을 눌러주세요.\n(예: 철, 물, 산소, 베이킹소다)';
  String _resultSymbol = '';

  // 방대한 물질 데이터베이스 (118개 전 원소, 주요 화합물 및 동의어 포함)
  final Map<String, String> _chemicalDatabase = {
    // --- 1~18족 주요 원소 및 동의어 ---
    '수소': 'H', '헬륨': 'He', '리튬': 'Li', '베릴륨': 'Be', '붕소': 'B',
    '탄소': 'C', '질소': 'N', '산소': 'O', '플루오린': 'F', '불소': 'F',
    '네온': 'Ne', '나트륨': 'Na', '소듐': 'Na', '마그네슘': 'Mg', '알루미늄': 'Al',
    '규소': 'Si', '실리콘': 'Si', '인': 'P', '황': 'S', '염소': 'Cl',
    '아르곤': 'Ar', '칼륨': 'K', '포타슘': 'K', '칼슘': 'Ca',

    // --- 나머지 주요 및 전이 원소 (원자번호 21~118) ---
    '스칸듐': 'Sc', '티타늄': 'Ti', '타이타늄': 'Ti', '바나듐': 'V', '크로뮴': 'Cr',
    '망가니즈': 'Mn', '망간': 'Mn', '철': 'Fe', '코발트': 'Co', '니켈': 'Ni',
    '구리': 'Cu', '아연': 'Zn', '갈륨': 'Ga', '저마늄': 'Ge', '게르마늄': 'Ge',
    '비소': 'As', '셀레늄': 'Se', '브로민': 'Br', '브롬': 'Br', '크립톤': 'Kr',
    '루비듐': 'Rb', '스트론튬': 'Sr', '이트륨': 'Y', '지르코늄': 'Zr', '나이오븀': 'Nb',
    '몰리브데넘': 'Mo', '테크네튬': 'Tc', '루테늄': 'Ru', '로듐': 'Rh', '팔라듐': 'Pd',
    '은': 'Ag', '카드뮴': 'Cd', '인듐': 'In', '주석': 'Sn', '안티모니': 'Sb',
    '텔루륨': 'Te', '아이오딘': 'I', '요오드': 'I', '제논': 'Xe', '크세논': 'Xe',
    '세슘': 'Cs', '바륨': 'Ba', '란타넘': 'La', '세륨': 'Ce', '프라세오디뮴': 'Pr',
    '네오디뮴': 'Nd', '프로메튬': 'Pm', '사마륨': 'Sm', '유로퓸': 'Eu', '가돌리늄': 'Gd',
    '터븀': 'Tb', '디스프로슘': 'Dy', '홀뮴': 'Ho', '어븀': 'Er', '툴륨': 'Tm',
    '이터븀': 'Yb', '루테튬': 'Lu', '하프늄': 'Hf', '탄탈럼': 'Ta', '텅스텐': 'W',
    '레늄': 'Re', '오스뮴': 'Os', '이리듐': 'Ir', '백금': 'Pt', '금': 'Au',
    '수은': 'Hg', '탈륨': 'Tl', '납': 'Pb', '비스무트': 'Bi', '폴로늄': 'Po',
    '아스타틴': 'At', '라돈': 'Rn', '프랑슘': 'Fr', '라듐': 'Ra', '악티늄': 'Ac',
    '토륨': 'Th', '프로트악티늄': 'Pa', '우라늄': 'U', '넵투늄': 'Np', '플루토늄': 'Pu',
    '아메리슘': 'Am', '퀴륨': 'Cm', '버클륨': 'Bk', '캘리포늄': 'Cf', '아인슈타이늄': 'Es',
    '페르뮴': 'Fm', '멘델레븀': 'Md', '노벨륨': 'No', '로렌슘': 'Lr', '러더포듐': 'Rf',
    '더브늄': 'Db', '시보귬': 'Sg', '보륨': 'Bh', '하슘': 'Hs', '마이트너륨': 'Mt',
    '다름슈타튬': 'Ds', '뢴트게늄': 'Rg', '코페르니슘': 'Cn', '니호늄': 'Nh', '플레로븀': 'Fl',
    '모스코븀': 'Mc', '리버모륨': 'Lv', '테네신': 'Ts', '오가네손': 'Og',

    // --- 주요 화합물 및 혼합물 동의어 ---
    '물': 'H₂O',
    '얼음': 'H₂O',
    '수증기': 'H₂O',
    '이산화탄소': 'CO₂',
    '드라이아이스': 'CO₂',
    '일산화탄소': 'CO',
    '과산화수소': 'H₂O₂',
    '오존': 'O₃',

    // 산과 염기
    '염산': 'HCl',
    '황산': 'H₂SO₄',
    '질산': 'HNO₃',
    '인산': 'H₃PO₄',
    '아세트산': 'CH₃COOH',
    '식초': 'CH₃COOH',
    '수산화나트륨': 'NaOH',
    '양잿물': 'NaOH',
    '수산화칼륨': 'KOH',
    '수산화칼슘': 'Ca(OH)₂',
    '소석회': 'Ca(OH)₂',
    '수산화마그네슘': 'Mg(OH)₂',

    // 염 (Salts)
    '염화나트륨': 'NaCl',
    '소금': 'NaCl',
    '탄산나트륨': 'Na₂CO₃',
    '탄산수소나트륨': 'NaHCO₃',
    '베이킹소다': 'NaHCO₃',
    '탄산칼슘': 'CaCO₃',
    '석회석': 'CaCO₃',
    '대리석': 'CaCO₃',
    '황산구리': 'CuSO₄',
    '질산은': 'AgNO₃',
    '염화칼슘': 'CaCl₂',
    '제설제': 'CaCl₂',

    // 유기 화합물
    '메탄': 'CH₄',
    '메테인': 'CH₄',
    '에탄': 'C₂H₆',
    '에테인': 'C₂H₆',
    '프로판': 'C₃H₈',
    '프로페인': 'C₃H₈',
    '부탄': 'C₄H₁₀',
    '뷰테인': 'C₄H₁₀',
    '메탄올': 'CH₃OH',
    '에탄올': 'C₂H₅OH',
    '알코올': 'C₂H₅OH',
    '벤젠': 'C₆H₆',
    '포도당': 'C₆H₁₂O₆',
    '글루코스': 'C₆H₁₂O₆',
    '설탕': 'C₁₂H₂₂O₁₁',
    '자당': 'C₁₂H₂₂O₁₁',
    '아세톤': 'C₃H₆O',
    '요소': 'CO(NH₂)₂',

    // 기타 주요 화합물
    '암모니아': 'NH₃',
    '이산화황': 'SO₂',
    '이산화질소': 'NO₂',
    '일산화질소': 'NO',
    '아산화질소': 'N₂O',
    '웃음가스': 'N₂O',
    '산화철': 'Fe₂O₃',
    '녹': 'Fe₂O₃',
  };

  void _performSearch() {
    // 띄어쓰기를 무시하도록 공백 제거 및 소문자 처리 (유연한 검색)
    String rawQuery = _searchController.text.trim();
    String query = rawQuery.replaceAll(' ', '');

    if (query.isEmpty) {
      setState(() {
        _searchResult = '검색어를 입력해주세요.';
        _resultSymbol = '';
      });
      return;
    }

    setState(() {
      if (_chemicalDatabase.containsKey(query)) {
        _searchResult = '$rawQuery의 화학식(기호)은 다음과 같습니다.';
        _resultSymbol = _chemicalDatabase[query]!;
      } else {
        _searchResult =
            '데이터베이스에서 "$rawQuery"을(를) 찾을 수 없습니다.\n정확한 명칭을 입력했는지 확인해주세요.';
        _resultSymbol = '?';
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        title: const Text(
          '화학 물질 기호 검색기',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.science, size: 80, color: Colors.teal),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: '물질 이름 입력 (예: 은, 암모니아, 포타슘)',
                      labelText: '물질 이름',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchResult = '물질 이름을 입력하고 검색을 눌러주세요.';
                            _resultSymbol = '';
                          });
                        },
                      ),
                    ),
                    onSubmitted: (_) => _performSearch(),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _performSearch,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .primaryContainer,
                      foregroundColor: Theme.of(context)
                          .colorScheme
                          .onPrimaryContainer,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      '검색',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _searchResult,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                        if (_resultSymbol.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Text(
                            _resultSymbol,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 64,
                              fontWeight: FontWeight.bold,
                              color: _resultSymbol == '?'
                                  ? Theme.of(context).colorScheme.error
                                  : Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ],
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
}
