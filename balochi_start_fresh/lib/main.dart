import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb; // Required for Web check
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

// --- CONFIGURATION ---
const String groqApiKey =
    "PASTE_YOUR_API_KEY_HERE";

// --- THEME COLORS ---
const Color kPrimaryColor = Color(0xFF2C3E50);
const Color kAccentColor = Color(0xFFC0392B);
const Color kGreenColor = Color(0xFF6A8D73);
const Color kTanColor = Color(0xFFD4AC7D);
const Color kLightBg = Color(0xFFF8F9FA);
const Color kDarkBg = Color(0xFF121212);
const Color kWhite = Colors.white;
const Color kGreyText = Color(0xFF7F8C8D);

// --- GLOBAL STATE ---
class AppState extends ChangeNotifier {
  static final AppState _instance = AppState._internal();
  factory AppState() => _instance;
  AppState._internal();

  ThemeMode _themeMode = ThemeMode.light;
  String _userName = "Ghazen Khalid";
  String _userBio = "Balochi Learner";

  // Profile Image Handling
  File? _profileImageFile; // For Mobile
  Uint8List? _profileImageBytes; // For Web

  ThemeMode get themeMode => _themeMode;
  String get userName => _userName;
  String get userBio => _userBio;

  // Helper to get the correct image provider
  ImageProvider? get profileImageProvider {
    if (kIsWeb && _profileImageBytes != null) {
      return MemoryImage(_profileImageBytes!);
    } else if (!kIsWeb && _profileImageFile != null) {
      return FileImage(_profileImageFile!);
    }
    return null;
  }

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> updateProfile({
    String? name,
    String? bio,
    XFile? pickedFile,
  }) async {
    if (name != null) _userName = name;
    if (bio != null) _userBio = bio;

    if (pickedFile != null) {
      if (kIsWeb) {
        // Web: Read bytes directly
        _profileImageBytes = await pickedFile.readAsBytes();
      } else {
        // Mobile: Save to file system
        final directory = await getApplicationDocumentsDirectory();
        final path = directory.path;
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
        final newImage = await File(pickedFile.path).copy('$path/$fileName');
        _profileImageFile = newImage;
      }
    }
    notifyListeners();
  }
}

final appState = AppState();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Balochi Tutor',
          themeMode: appState.themeMode,
          // LIGHT THEME
          theme: ThemeData(
            useMaterial3: true,
            primaryColor: kPrimaryColor,
            scaffoldBackgroundColor: kLightBg,
            cardColor: kWhite,
            colorScheme: ColorScheme.fromSeed(
              seedColor: kPrimaryColor,
              primary: kPrimaryColor,
              secondary: kAccentColor,
              background: kLightBg,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: kWhite,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              iconTheme: IconThemeData(color: kPrimaryColor),
              titleTextStyle: TextStyle(
                color: kPrimaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            textTheme: const TextTheme(
              bodyMedium: TextStyle(color: kPrimaryColor),
            ),
          ),
          // DARK THEME
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            primaryColor: kPrimaryColor,
            scaffoldBackgroundColor: kDarkBg,
            cardColor: const Color(0xFF1E1E1E),
            colorScheme: ColorScheme.dark(
              primary: kPrimaryColor,
              secondary: kAccentColor,
              background: kDarkBg,
              surface: const Color(0xFF1E1E1E),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: kDarkBg,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              iconTheme: IconThemeData(color: kWhite),
              titleTextStyle: TextStyle(
                color: kWhite,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            textTheme: const TextTheme(bodyMedium: TextStyle(color: kWhite)),
          ),
          home: const AnimatedSplashScreen(),
        );
      },
    );
  }
}

// ==========================================
// 1. LOGIC ENGINE
// ==========================================
class BalochiLogic {
  static const String shadda = '\u0651';

  static final Map<String, String> latToArMap = {
    'b': 'ب',
    'ch': 'چ',
    'd': 'د',
    'dh': 'ڈ',
    'g': 'گ',
    'h': 'ه',
    'j': 'ج',
    'k': 'ک',
    'l': 'ل',
    'm': 'م',
    'n': 'ن',
    'p': 'پ',
    'f': 'پ',
    'r': 'ر',
    's': 'س',
    'sh': 'ش',
    't': 'ت',
    'th': 'ٹ',
    'w': 'و',
    'y': 'ی',
    'z': 'ز',
    'zh': 'ژ',
    "'": 'ء',
    'kh': 'خ',
    'gh': 'غ',
    'a': 'َ',
    'e': 'ِ',
    'o': 'ُ',
    'á': 'ا',
    'é': 'ی',
    'i': 'ی',
    'ó': 'و',
    'u': 'و',
    'aw': 'َوْ',
    'ay': 'َی',
    '?': '؟',
    ',': '،',
    '.': '۔',
  };

  static final Map<String, String> startMap = {
    'a': 'اَ',
    'e': 'اِ',
    'o': 'اُ',
    'á': 'آ',
    'é': 'ای',
    'i': 'ای',
    'ó': 'او',
    'u': 'عُو',
    'aw': 'اَو',
    'ay': 'اَی',
    'dh': 'ڈ',
  };

  static final Map<String, String> endMap = {'é': 'ے', 'ay': 'ے', 'dh': 'ڑ'};

  static final Map<String, String> arToLatMap = {
    'ب': 'b',
    'پ': 'p',
    'ت': 't',
    'ٹ': 'th',
    'ث': 's',
    'ج': 'j',
    'چ': 'ch',
    'ح': 'h',
    'خ': 'kh',
    'd': 'd',
    'ڈ': 'dh',
    'ذ': 'z',
    'ر': 'r',
    'ڑ': 'dh',
    'ز': 'z',
    'ژ': 'zh',
    'س': 's',
    'ش': 'sh',
    'ص': 's',
    'ض': 'z',
    'ط': 't',
    'ظ': 'z',
    'ع': '',
    'غ': 'gh',
    'ف': 'p',
    'ق': 'k',
    'ک': 'k',
    'گ': 'g',
    'ل': 'l',
    'm': 'm',
    'ن': 'n',
    'ں': 'n',
    'و': 'w',
    'ہ': 'h',
    'ه': 'h',
    'ء': "'",
    'ی': 'y',
    'ے': 'é',
    'آ': 'á',
    'ؤ': 'w',
    'ئ': 'y',
    'ۃ': 'h',
    'َ': 'a',
    'ِ': 'e',
    'ُ': 'o',
    'ا': 'á',
    '۔': '.',
    '،': ',',
    '؟': '?',
  };

  String toArabic(String text) {
    if (text.isEmpty) return "";
    return text.split(' ').map((w) => _wordToArabic(w)).join(' ');
  }

  String _wordToArabic(String word) {
    if (word.isEmpty) return "";
    String clean = word.toLowerCase().trim();
    if (!RegExp(r'[a-zA-Záéó]').hasMatch(clean[0]) && clean[0] != "'")
      return word;

    StringBuffer buffer = StringBuffer();
    int i = 0;
    while (i < clean.length) {
      String char = clean[i];
      String next = (i + 1 < clean.length) ? clean[i + 1] : "";
      String bigram = char + next;
      String token = char;
      int tokenLen = 1;

      if (latToArMap.containsKey(bigram) || startMap.containsKey(bigram)) {
        token = bigram;
        tokenLen = 2;
      }

      bool isDoubled = false;
      int nextIdx = i + tokenLen;
      if (nextIdx < clean.length) {
        String nextChar = clean[nextIdx];
        String nextNext = (nextIdx + 1 < clean.length)
            ? clean[nextIdx + 1]
            : "";
        String nextBigram = nextChar + nextNext;
        String nextToken = nextChar;
        if (latToArMap.containsKey(nextBigram)) nextToken = nextBigram;
        if (token == nextToken &&
            ![
              'a',
              'e',
              'o',
              'á',
              'é',
              'i',
              'ó',
              'u',
              'aw',
              'ay',
            ].contains(token))
          isDoubled = true;
      }

      String mapped = token;
      if (i == 0 && startMap.containsKey(token))
        mapped = startMap[token]!;
      else if (i + tokenLen == clean.length && endMap.containsKey(token))
        mapped = endMap[token]!;
      else if (latToArMap.containsKey(token))
        mapped = latToArMap[token]!;

      buffer.write(mapped);
      if (isDoubled) {
        buffer.write(shadda);
        i += tokenLen;
      }
      i += tokenLen;
    }
    return buffer.toString();
  }

  String toLatin(String text) {
    if (text.isEmpty) return "";
    return text.split(' ').map((w) => _wordToLatin(w)).join(' ');
  }

  String _wordToLatin(String word) {
    if (word.isEmpty) return "";
    if (word == "و") return "o";
    String p = word
        .replaceAll('َا', 'á')
        .replaceAll('آ', 'á')
        .replaceAll('َوْ', 'aw')
        .replaceAll('َی', 'ay');
    StringBuffer b = StringBuffer();
    for (int i = 0; i < p.length; i++) {
      String c = p[i];
      if (c == 'ی' && i == p.length - 1) {
        b.write('i');
        continue;
      }
      b.write(arToLatMap[c] ?? c);
    }
    return b.toString().replaceAll('áa', 'á');
  }
}

// ==========================================
// 2. DATA
// ==========================================
class ScriptData {
  static final List<Map<String, String>> alphabet = [
    {'lat': 'A', 'ar': 'اَ', 'name': 'Zabar', 'arName': 'زَبر'},
    {'lat': 'Á', 'ar': 'آ', 'name': 'Á', 'arName': 'آ'},
    {'lat': 'B', 'ar': 'ب', 'name': 'Bé', 'arName': 'بے'},
    {'lat': 'Ch', 'ar': 'چ', 'name': 'Ché', 'arName': 'چے'},
    {'lat': 'D', 'ar': 'د', 'name': 'Dé', 'arName': 'دے'},
    {'lat': 'Dh', 'ar': 'ڈ / ڑ', 'name': 'Dhé', 'arName': 'ڈے'},
    {'lat': 'E', 'ar': 'ِ', 'name': 'Zér', 'arName': 'زِیر'},
    {'lat': 'É', 'ar': 'اے', 'name': 'É', 'arName': 'اے'},
    {'lat': 'G', 'ar': 'گ', 'name': 'Gé', 'arName': 'گے'},
    {'lat': 'H', 'ar': 'ه', 'name': 'Hé', 'arName': 'ھے'},
    {'lat': 'I', 'ar': 'ای', 'name': 'I', 'arName': 'ای'},
    {'lat': 'J', 'ar': 'ج', 'name': 'Jé', 'arName': 'جے'},
    {'lat': 'K', 'ar': 'ک', 'name': 'Ké', 'arName': 'کے'},
    {'lat': 'L', 'ar': 'ل', 'name': 'Lé', 'arName': 'لے'},
    {'lat': 'M', 'ar': 'م', 'name': 'Mé', 'arName': 'مے'},
    {'lat': 'N', 'ar': 'ن', 'name': 'Né', 'arName': 'نے'},
    {'lat': 'O', 'ar': 'ُ', 'name': 'Pésh', 'arName': 'پیش'},
    {'lat': 'Ó', 'ar': 'او', 'name': 'Ó', 'arName': 'او'},
    {'lat': 'P', 'ar': 'پ', 'name': 'Pé', 'arName': 'پے'},
    {'lat': 'R', 'ar': 'ر', 'name': 'Ré', 'arName': 'رے'},
    {'lat': 'S', 'ar': 'س', 'name': 'Sé', 'arName': 'سے'},
    {'lat': 'Sh', 'ar': 'ش', 'name': 'Shé', 'arName': 'شے'},
    {'lat': 'T', 'ar': 'ت', 'name': 'Té', 'arName': 'تے'},
    {'lat': 'Th', 'ar': 'ٹ', 'name': 'Thé', 'arName': 'ٹے'},
    {'lat': 'U', 'ar': 'اُو', 'name': 'U', 'arName': 'اُو'},
    {'lat': 'W', 'ar': 'و', 'name': 'Wá', 'arName': 'وا'},
    {'lat': 'Y', 'ar': 'ی', 'name': 'Yá', 'arName': 'یا'},
    {'lat': 'Z', 'ar': 'ز', 'name': 'Zé', 'arName': 'زے'},
    {'lat': 'Zh', 'ar': 'ژ', 'name': 'Zhé', 'arName': 'ژے'},
  ];

  static final List<Map<String, String>> rules = [
    {
      'title': 'Double Letters',
      'desc': 'Double consonants get Shadda (e.g. Mann -> مَنّ).',
    },
    {'title': 'Start Vowels', 'desc': 'U -> عُو, A -> اَ, Á -> آ.'},
    {'title': 'Dh Digraph', 'desc': 'Start: Dal (ڈ), Middle/End: Re (ڑ).'},
    {'title': 'No F', 'desc': 'F is always P (پ).'},
  ];

  static final List<Map<String, Object>> quizQuestions = [
    {
      'question': 'Which letter is "چ"?',
      'options': ['C', 'Ch', 'K', 'Sh'],
      'answerIndex': 1,
    },
    {
      'question': 'Arabic script for "Mann"?',
      'options': ['مَن', 'مَنّ', 'مان', 'مُن'],
      'answerIndex': 1,
    },
    {
      'question': 'How is "F" written?',
      'options': ['F', 'Ph', 'P', 'V'],
      'answerIndex': 2,
    },
    {
      'question': 'Start "ڈ" is:',
      'options': ['D', 'Dd', 'Dh', 'R'],
      'answerIndex': 2,
    },
    {
      'question': 'Vowel "ِ" is:',
      'options': ['A', 'E', 'I', 'O'],
      'answerIndex': 1,
    },
  ];
}

// ==========================================
// 3. SPLASH SCREEN
// ==========================================
class AnimatedSplashScreen extends StatefulWidget {
  const AnimatedSplashScreen({super.key});
  @override
  State<AnimatedSplashScreen> createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _fade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
    _ctrl.forward();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted)
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const MainLayout(),
            transitionsBuilder: (_, a, __, c) =>
                FadeTransition(opacity: a, child: c),
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? kDarkBg : kWhite,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _scale,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? const Color(0xFF1E1E1E) : kWhite,
                  boxShadow: [
                    BoxShadow(
                      color: kPrimaryColor.withOpacity(0.15),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/logo.png',
                  width: 140,
                  height: 140,
                  errorBuilder: (c, e, s) => const Icon(
                    Icons.language,
                    size: 100,
                    color: kPrimaryColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            FadeTransition(
              opacity: _fade,
              child: Column(
                children: [
                  Text(
                    "Balochi Tutor",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: isDark ? kWhite : kPrimaryColor,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Master the Script",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? kGreyText
                          : kPrimaryColor.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 4. MAIN LAYOUT
// ==========================================
class MainLayout extends StatefulWidget {
  const MainLayout({super.key});
  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _idx = 0;
  final List<Widget> _pages = [
    const HomeScreen(),
    const GroqChatScreen(),
    const ReferenceScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: _pages[_idx],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              indicatorColor: kPrimaryColor.withOpacity(0.1),
              labelTextStyle: WidgetStateProperty.all(
                const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              iconTheme: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.selected)
                    ? const IconThemeData(color: kPrimaryColor)
                    : IconThemeData(color: isDark ? Colors.grey : kGreyText),
              ),
            ),
            child: NavigationBar(
              selectedIndex: _idx,
              onDestinationSelected: (i) => setState(() => _idx = i),
              backgroundColor: Colors.transparent,
              elevation: 0,
              height: 75,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_rounded),
                  selectedIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.chat_bubble_outline_rounded),
                  selectedIcon: Icon(Icons.chat_bubble_rounded),
                  label: 'Chat',
                ),
                NavigationDestination(
                  icon: Icon(Icons.menu_book_rounded),
                  selectedIcon: Icon(Icons.menu_book),
                  label: 'Reference',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings_rounded),
                  selectedIcon: Icon(Icons.settings),
                  label: 'Settings',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 5. HOME SCREEN
// ==========================================
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: ListenableBuilder(
            listenable: appState,
            builder: (context, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Salam,",
                            style: TextStyle(
                              fontSize: 18,
                              color: isDark
                                  ? kGreyText
                                  : kPrimaryColor.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            appState.userName.split(' ')[0],
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: isDark ? kWhite : kPrimaryColor,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: kAccentColor, width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 28,
                          backgroundImage: appState.profileImageProvider,
                          backgroundColor: kAccentColor.withOpacity(0.1),
                          child: appState.profileImageProvider == null
                              ? const Icon(
                                  Icons.person,
                                  color: kAccentColor,
                                  size: 30,
                                )
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BalochiTranslatorScreen(),
                      ),
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [kPrimaryColor, Color(0xFF34495E)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: kPrimaryColor.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: kWhite.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    "INSTANT CONVERTER",
                                    style: TextStyle(
                                      color: kWhite,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  "Translate\nBalochi Script",
                                  style: TextStyle(
                                    color: kWhite,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    height: 1.1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Opacity(
                            opacity: 0.2,
                            child: Image.asset(
                              'assets/logo.png',
                              width: 100,
                              height: 100,
                              color: kWhite,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    "Quick Tools",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? kWhite : kPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.05,
                    children: [
                      _card(
                        context,
                        "AI Tutor",
                        "Chat & Learn",
                        Icons.chat_bubble_rounded,
                        kGreenColor,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const GroqChatScreen(),
                          ),
                        ),
                      ),
                      _card(
                        context,
                        "Translator",
                        "Convert Text",
                        Icons.translate_rounded,
                        kAccentColor,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const BalochiTranslatorScreen(),
                          ),
                        ),
                      ),
                      _card(
                        context,
                        "Reference",
                        "Alphabet & Rules",
                        Icons.menu_book_rounded,
                        kTanColor,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ReferenceScreen(),
                          ),
                        ),
                      ),
                      _card(
                        context,
                        "Quiz",
                        "Test Yourself",
                        Icons.quiz_rounded,
                        kPrimaryColor,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const QuizScreen()),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _card(
    BuildContext c,
    String t,
    String s,
    IconData i,
    Color co,
    VoidCallback cb,
  ) {
    final isDark = Theme.of(c).brightness == Brightness.dark;
    return GestureDetector(
      onTap: cb,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(c).cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: co.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(i, color: co, size: 26),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: isDark ? kWhite : kPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    s,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? kGreyText
                          : kPrimaryColor.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 6. TRANSLATOR SCREEN
// ==========================================
class BalochiTranslatorScreen extends StatefulWidget {
  const BalochiTranslatorScreen({super.key});
  @override
  State<BalochiTranslatorScreen> createState() =>
      _BalochiTranslatorScreenState();
}

class _BalochiTranslatorScreenState extends State<BalochiTranslatorScreen> {
  final TextEditingController _c = TextEditingController();
  String _res = "";
  final BalochiLogic _logic = BalochiLogic();
  bool _latToAr = true;

  void _translate() => setState(
    () => _res = _c.text.isEmpty
        ? ""
        : (_latToAr ? _logic.toArabic(_c.text) : _logic.toLatin(_c.text)),
  );

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Translator"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: "Clear",
            onPressed: () {
              _c.clear();
              setState(() => _res = "");
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isDark ? Colors.transparent : Colors.grey.shade200,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _toggleBtn("Arabic", !_latToAr),
                  _toggleBtn("Latin", _latToAr),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _latToAr ? "LATIN INPUT" : "ARABIC INPUT",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: kPrimaryColor.withOpacity(0.6),
                        fontSize: 12,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _c,
                      maxLines: 5,
                      onChanged: (v) => _translate(),
                      textDirection: _latToAr
                          ? TextDirection.ltr
                          : TextDirection.rtl,
                      style: const TextStyle(fontSize: 18),
                      decoration: InputDecoration(
                        hintText: _latToAr
                            ? "Type Latin text here..."
                            : "Type Arabic text here...",
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          color: isDark ? kGreyText : Colors.grey.shade400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _res.isNotEmpty
                  ? Card(
                      color: kAccentColor,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _latToAr ? "ARABIC OUTPUT" : "LATIN OUTPUT",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white70,
                                    fontSize: 12,
                                    letterSpacing: 1,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Clipboard.setData(
                                      ClipboardData(text: _res),
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Copied to clipboard!"),
                                      ),
                                    );
                                  },
                                  child: const Icon(
                                    Icons.copy_rounded,
                                    color: kWhite,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SelectableText(
                              _res,
                              style: const TextStyle(
                                color: kWhite,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                height: 1.4,
                              ),
                              textAlign: _latToAr
                                  ? TextAlign.right
                                  : TextAlign.left,
                              textDirection: _latToAr
                                  ? TextDirection.rtl
                                  : TextDirection.ltr,
                            ),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toggleBtn(String t, bool active) {
    return GestureDetector(
      onTap: () => setState(() {
        _latToAr = t == "Latin";
        _c.clear();
        _res = "";
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: active ? kPrimaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(
          t,
          style: TextStyle(
            color: active
                ? kWhite
                : (Theme.of(context).brightness == Brightness.dark
                      ? kWhite
                      : kPrimaryColor),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 7. CHAT SCREEN
// ==========================================
class GroqChatScreen extends StatefulWidget {
  const GroqChatScreen({super.key});
  @override
  State<GroqChatScreen> createState() => _GroqChatScreenState();
}

class _GroqChatScreenState extends State<GroqChatScreen> {
  final TextEditingController _c = TextEditingController();
  final ScrollController _s = ScrollController();
  final List<Map<String, String>> _msgs = [];
  bool _loading = false;
  final BalochiLogic _logic = BalochiLogic();

  Future<void> _send() async {
    final t = _c.text.trim();
    if (t.isEmpty) return;
    FocusScope.of(context).unfocus();

    bool isConv =
        t.toLowerCase().startsWith("convert") ||
        t.toLowerCase().startsWith("write");
    String prompt = t;
    if (isConv) {
      String raw = t.replaceAll(
        RegExp(r'^(convert|write)\s*', caseSensitive: false),
        "",
      );
      prompt =
          "User: '$t'\n[SYSTEM DATA]\nArabic: '${_logic.toArabic(raw)}'\nLatin: '${_logic.toLatin(raw)}'\nUse this data to answer.";
    }

    setState(() {
      _msgs.add({"role": "user", "text": t});
      _loading = true;
    });
    _c.clear();
    _scroll();

    try {
      final r = await http.post(
        Uri.parse("https://api.groq.com/openai/v1/chat/completions"),
        headers: {
          "Authorization": "Bearer $groqApiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "model": "llama-3.3-70b-versatile",
          "messages": [
            {
              "role": "system",
              "content":
                  "You are a Balochi Script Assistant. If user asks to convert, use [SYSTEM DATA]. Otherwise, chat normally, and still in construction by Ghazen Khalid. ",
            },
            {"role": "user", "content": prompt},
          ],
        }),
      );
      final d = jsonDecode(r.body);
      setState(() {
        _msgs.add({
          "role": "ai",
          "text": d["choices"][0]["message"]["content"],
        });
        _loading = false;
      });
      _scroll();
    } catch (e) {
      setState(() {
        _msgs.add({"role": "ai", "text": "Error connecting."});
        _loading = false;
      });
    }
  }

  void _scroll() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (_s.hasClients)
      _s.animateTo(
        _s.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Tutor"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt_rounded),
            tooltip: "Restart Chat",
            onPressed: () => setState(() => _msgs.clear()),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            decoration: BoxDecoration(
              color: kPrimaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline_rounded,
                  color: kPrimaryColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Tip: Start with 'Convert' to switch scripts (e.g., 'Convert Salam').",
                    style: TextStyle(
                      color: kPrimaryColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _msgs.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 60,
                            color: kPrimaryColor.withOpacity(0.3),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "Ask me anything!\nTo convert, say:\n'Convert [word]'",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isDark
                                  ? kGreyText
                                  : kPrimaryColor.withOpacity(0.6),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _s,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                    itemCount: _msgs.length,
                    itemBuilder: (c, i) {
                      final isUser = _msgs[i]["role"] == "user";
                      return Align(
                        alignment: isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 14,
                          ),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.8,
                          ),
                          decoration: BoxDecoration(
                            color: isUser
                                ? kAccentColor
                                : Theme.of(context).cardColor,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(20),
                              topRight: const Radius.circular(20),
                              bottomLeft: isUser
                                  ? const Radius.circular(20)
                                  : Radius.zero,
                              bottomRight: isUser
                                  ? Radius.zero
                                  : const Radius.circular(20),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            _msgs[i]["text"]!,
                            style: TextStyle(
                              color: isUser
                                  ? kWhite
                                  : (isDark ? kWhite : kPrimaryColor),
                              height: 1.4,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (_loading)
            const LinearProgressIndicator(color: kAccentColor, minHeight: 2),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _c,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      filled: true,
                      fillColor: isDark ? const Color(0xFF2C2C2C) : kLightBg,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      hintStyle: TextStyle(
                        color: isDark ? kGreyText : Colors.grey.shade400,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                CircleAvatar(
                  backgroundColor: kPrimaryColor,
                  radius: 26,
                  child: IconButton(
                    icon: const Icon(
                      Icons.send_rounded,
                      color: kWhite,
                      size: 22,
                    ),
                    onPressed: _send,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 8. REFERENCE SCREEN
// ==========================================
class ReferenceScreen extends StatelessWidget {
  const ReferenceScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Reference"),
          centerTitle: true,
          bottom: TabBar(
            labelColor: kPrimaryColor,
            unselectedLabelColor: kGreyText,
            indicatorColor: kAccentColor,
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: "Alphabet"),
              Tab(text: "Rules"),
            ],
          ),
        ),
        body: const TabBarView(children: [AlphabetTab(), RulesTab()]),
      ),
    );
  }
}

class AlphabetTab extends StatelessWidget {
  const AlphabetTab({super.key});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.85,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: ScriptData.alphabet.length,
      itemBuilder: (c, i) {
        final x = ScriptData.alphabet[i];
        return Card(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                x['lat']!,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: isDark ? kWhite : kPrimaryColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                x['ar']!,
                style: TextStyle(fontSize: 24, color: kAccentColor),
              ),
              const SizedBox(height: 12),
              Text(
                x['name']!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class RulesTab extends StatelessWidget {
  const RulesTab({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: ScriptData.rules.length,
      itemBuilder: (c, i) {
        final r = ScriptData.rules[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.rule_rounded, color: kAccentColor, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      r['title']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  r['desc']!,
                  style: TextStyle(
                    fontSize: 15,
                    color: kPrimaryColor.withOpacity(0.8),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ==========================================
// 9. SETTINGS SCREEN
// ==========================================
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        await appState.updateProfile(
          pickedFile: pickedFile,
        ); // Pass XFile directly
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Error picking image. Check permissions."),
          ),
        );
    }
  }

  void _editProfile() {
    final n = TextEditingController(text: appState.userName);
    final b = TextEditingController(text: appState.userBio);
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text(
          "Edit Profile",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: n,
              decoration: const InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: b,
              decoration: const InputDecoration(
                labelText: "Bio",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              appState.updateProfile(name: n.text, bio: b.text);
              Navigator.pop(c);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              foregroundColor: kWhite,
            ),
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text("Settings"), centerTitle: true),
      body: ListenableBuilder(
        listenable: appState,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: kAccentColor, width: 3),
                      ),
                      child: CircleAvatar(
                        radius: 64,
                        backgroundColor: kPrimaryColor.withOpacity(0.1),
                        backgroundImage: appState.profileImageProvider,
                        child: appState.profileImageProvider == null
                            ? Icon(
                                Icons.person_rounded,
                                size: 64,
                                color: kPrimaryColor,
                              )
                            : null,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => _showImageSourceSheet(context),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: kAccentColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              width: 3,
                            ),
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            color: kWhite,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  appState.userName,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  appState.userBio,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? kGreyText : kPrimaryColor.withOpacity(0.7),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: OutlinedButton.icon(
                  onPressed: _editProfile,
                  icon: const Icon(Icons.edit_rounded, size: 18),
                  label: const Text("Edit Profile"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kPrimaryColor,
                    side: const BorderSide(color: kPrimaryColor),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Text(
                "Preferences",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryColor,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      secondary: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: kPrimaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.dark_mode_rounded,
                          color: kPrimaryColor,
                        ),
                      ),
                      title: const Text(
                        "Dark Mode",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      value: appState.themeMode == ThemeMode.dark,
                      onChanged: (v) => appState.toggleTheme(v),
                      activeColor: kAccentColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "About",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryColor,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: kTanColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.info_outline_rounded, color: kTanColor),
                  ),
                  title: const Text(
                    "About App",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text("Version 1.1.0 • Balochi Standard 2026"),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showImageSourceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (c) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text("Gallery"),
              onTap: () {
                Navigator.pop(c);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: const Text("Camera"),
              onTap: () {
                Navigator.pop(c);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 10. NEW QUIZ SCREEN
// ==========================================
class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  int? _selectedAnswerIndex;
  bool _isAnswered = false;

  void _answerQuestion(int index) {
    setState(() {
      _selectedAnswerIndex = index;
      _isAnswered = true;
      if (index ==
          ScriptData.quizQuestions[_currentQuestionIndex]['answerIndex']) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    setState(() {
      _currentQuestionIndex++;
      _selectedAnswerIndex = null;
      _isAnswered = false;
    });
  }

  void _resetQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _score = 0;
      _selectedAnswerIndex = null;
      _isAnswered = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_currentQuestionIndex >= ScriptData.quizQuestions.length) {
      return _buildResultScreen(isDark);
    }

    final question = ScriptData.quizQuestions[_currentQuestionIndex];
    final options = question['options'] as List<String>;
    final correctAnswerIndex = question['answerIndex'] as int;
    final isLastQuestion =
        _currentQuestionIndex == ScriptData.quizQuestions.length - 1;

    return Scaffold(
      appBar: AppBar(title: const Text("Quiz"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearProgressIndicator(
              value:
                  (_currentQuestionIndex + 1) / ScriptData.quizQuestions.length,
              backgroundColor: kPrimaryColor.withOpacity(0.1),
              color: kAccentColor,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 20),
            Text(
              "Question ${_currentQuestionIndex + 1}/${ScriptData.quizQuestions.length}",
              style: TextStyle(
                color: kPrimaryColor.withOpacity(0.6),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              question['question'] as String,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? kWhite : kPrimaryColor,
              ),
            ),
            const SizedBox(height: 30),
            ...options.asMap().entries.map((entry) {
              final index = entry.key;
              final text = entry.value;
              Color? backgroundColor;
              Color textColor = isDark ? kWhite : kPrimaryColor;

              if (_isAnswered) {
                if (index == correctAnswerIndex) {
                  backgroundColor = kGreenColor.withOpacity(0.2);
                  textColor = kGreenColor;
                } else if (index == _selectedAnswerIndex) {
                  backgroundColor = kAccentColor.withOpacity(0.2);
                  textColor = kAccentColor;
                }
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: InkWell(
                  onTap: _isAnswered ? null : () => _answerQuestion(index),
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: backgroundColor ?? Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color:
                            _isAnswered &&
                                (index == correctAnswerIndex ||
                                    index == _selectedAnswerIndex)
                            ? textColor
                            : (isDark
                                  ? Colors.transparent
                                  : Colors.grey.shade200),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          String.fromCharCode(65 + index) + '.',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            text,
                            style: TextStyle(fontSize: 18, color: textColor),
                          ),
                        ),
                        if (_isAnswered && index == correctAnswerIndex)
                          Icon(Icons.check_circle_rounded, color: kGreenColor)
                        else if (_isAnswered && index == _selectedAnswerIndex)
                          Icon(Icons.cancel_rounded, color: kAccentColor),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
            const Spacer(),
            if (_isAnswered)
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _nextQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    foregroundColor: kWhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: Text(isLastQuestion ? "See Results" : "Next Question"),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultScreen(bool isDark) {
    final scorePercentage = _score / ScriptData.quizQuestions.length;
    String message;
    IconData icon;
    Color color;

    if (scorePercentage >= 0.8) {
      message = "Excellent Job!";
      icon = Icons.emoji_events_rounded;
      color = kGreenColor;
    } else if (scorePercentage >= 0.5) {
      message = "Good Effort!";
      icon = Icons.thumb_up_alt_rounded;
      color = kTanColor;
    } else {
      message = "Keep Practicing!";
      icon = Icons.school_rounded;
      color = kAccentColor;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Result"),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(icon, size: 100, color: color),
            const SizedBox(height: 24),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "You scored $_score out of ${ScriptData.quizQuestions.length}",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                color: isDark ? kWhite : kPrimaryColor,
              ),
            ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              onPressed: _resetQuiz,
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: kWhite,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.restart_alt_rounded),
              label: const Text(
                "Restart Quiz",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: kPrimaryColor,
                side: const BorderSide(color: kPrimaryColor),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.home_rounded),
              label: const Text(
                "Back to Home",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
