import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      icon: Icons.mic,
      title: 'تحكم بصوتك',
      description: 'تحكم في هاتفك بالكامل باستخدام الأوامر الصوتية. افتح التطبيقات، اتصل، أرسل رسائل، وغير الإعدادات بمجرد التحدث.',
      color: AppTheme.cyanAccent,
    ),
    OnboardingPage(
      icon: Icons.offline_bolt,
      title: 'يعمل بدون إنترنت',
      description: 'Maestro AI يعمل بالكامل على جهازك دون الحاجة للإنترنت. خصوصيتك محمية والاستجابة فورية.',
      color: AppTheme.successGreen,
    ),
    OnboardingPage(
      icon: Icons.psychology,
      title: 'ذكاء اصطناعي متقدم',
      description: 'يستخدم نموذج Llama 3.2 لفهم أوامرك الطبيعية وتحسين الأداء مع الاستخدام.',
      color: AppTheme.purpleAccent,
    ),
    OnboardingPage(
      icon: Icons.settings_suggest,
      title: 'تحكم كامل',
      description: 'أكثر من 50 أمراً للتحكم في كل aspect من هاتفك: التطبيقات، المكالمات، الإعدادات، الملفات، والمزيد.',
      color: AppTheme.warningOrange,
    ),
    OnboardingPage(
      icon: Icons.security,
      title: 'صلاحيات مطلوبة',
      description: 'للعمل بكفاءة، يحتاج التطبيق إلى بعض الصلاحيات. يمكنك إدارتها لاحقاً من الإعدادات.',
      color: AppTheme.errorRed,
      isLast: true,
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _finishOnboarding() async {
    final settingsBox = Hive.box(AppConstants.settingsBox);
    await settingsBox.put(AppConstants.keyFirstRun, false);

    if (!mounted) return;

    Navigator.pushReplacementNamed(context, '/download');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.deepNavy,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: _finishOnboarding,
                  child: const Text(
                    'تخطي',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),

            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),

            // Page indicators
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? AppTheme.cyanAccent
                          : Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),

            // Next/Get Started button
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.cyanAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 8,
                  ),
                  child: Text(
                    _pages[_currentPage].isLast ? 'ابدأ الآن' : 'التالي',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [page.color, page.color.withOpacity(0.5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: page.color.withOpacity(0.4),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Icon(
              page.icon,
              size: 80,
              color: Colors.white,
            ),
          )
              .animate()
              .scale(duration: 600.ms, curve: Curves.elasticOut)
              .fadeIn(),

          const SizedBox(height: 48),

          // Title
          Text(
            page.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(delay: 200.ms)
              .slideY(begin: 0.2, end: 0),

          const SizedBox(height: 24),

          // Description
          Text(
            page.description,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 18,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(delay: 400.ms)
              .slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final bool isLast;

  OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    this.isLast = false,
  });
}
