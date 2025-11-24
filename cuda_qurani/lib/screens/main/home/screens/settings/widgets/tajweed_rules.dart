// lib/screens/main/home/screens/settings/widgets/tajweed_rules.dart
import 'package:cuda_qurani/screens/main/home/screens/settings/submenu/marking.dart';
import 'package:flutter/material.dart';
import 'package:cuda_qurani/core/design_system/app_design_system.dart';

/// ==================== TAJWEED RULES PAGE ====================
/// Halaman untuk menampilkan penjelasan aturan tajweed dengan warna

class TajweedRulesPage extends StatefulWidget {
  const TajweedRulesPage({Key? key}) : super(key: key);

  @override
  State<TajweedRulesPage> createState() => _TajweedRulesPageState();
}

class _TajweedRulesPageState extends State<TajweedRulesPage> {
  // Track expanded state for each rule
  final Map<int, bool> _expandedStates = {};

  // Tajweed rules data
  final List<TajweedRule> _rules = [
    TajweedRule(
      color: Color(0xFF8B2D2D), // Dark red
      title: 'Madd: 6',
      subtitle: 'Necessary Prolongation',
      description:
          'The dark red color indicates necessary prolongation, where the elongation is 6 vowels. This applies in cases like مد لازم (Madd Laazim). Example: "الضَّالِّينَ"',
    ),
    TajweedRule(
      color: Color(0xFFD81B60), // Pink/Magenta
      title: 'Madd: 4 or 5',
      subtitle: 'Obligatory Prolongation',
      description:
          'The pink color signifies obligatory prolongation, typically 4 or 5 vowels, depending on the context. This could include مد واجب متصل (Madd Wajib Muttasil). Example: Words like "سَمَاءٍ"',
    ),
    TajweedRule(
      color: Color(0xFFFF8C42), // Orange
      title: 'Madd: 2, 4, or 6',
      subtitle: 'Permissible Prolongation',
      description:
          'The orange color marks elongations that vary between 2, 4, or 6 vowels. This occurs in situations like مد عارض للسكون (Madd \'Aarid Li-Sukoon). Example: At the end of "الْعَالَمِينَ" when stopping.',
    ),
    TajweedRule(
      color: Color(0xFFB8860B), // Dark goldenrod/yellow-brown
      title: 'Madd: 2',
      subtitle: 'Normal Prolongation',
      description:
          'The yellow-brown color represents normal prolongation of 2 vowels, which is the standard for natural prolongation (مد طبيعي Madd Tabee\'i) Example: "عَظِيمٌ"',
    ),
    TajweedRule(
      color: Color(0xFF4CAF50), // Green
      title: 'Ghunnah',
      subtitle: 'Nasalization',
      description:
          'The green color indicates Ghunnah, a nasal sound that resonates from the nose and lasts for two vowels. Ghunnah occurs in several cases:\n\n• When ن (Noon) or م (Meem) carries shaddah (emphasis), such as in إِنَّهُمْ.\n\n• When Noon Sakinah (نْ) or Tanween (ـًـٍـٌ) is followed by Baa (ب), a small Meem (م) is added and pronounced with Ghunnah. This is known as Iqlaab (inversion).\nExamples:\nمِنْ بَعْدِ\nPronounced as "Mimba\'d", with Ghunnah on the second Meem (م).\nسَمِيعٌ بَصِيرٌ\nPronounced as "Sami\'um Basir", where the Tanween is converted into Meem with Ghunnah.\n\n• When Noon Sakinah (نْ) or Tanween (ـًـٍـٌ) is followed by one of the fifteen letters of Ikhfaa\' (ت، ث، ج، د، ذ، ز، س، ش، ص، ض، ط، ظ، ف، ق، ك). In these cases, the sound of the Noon (ن) or Tanween (ـًـٍـٌ) is hidden (the tongue does not touch the roof of the mouth) and it is pronounced instead with Ghunnah.\nExamples:\nإِنْ تَكْفُرُوا\nكَذَّبَ قَبْلُ\n\n• When the letters of Idghaam with Ghunnah (يَا يُو ي، Noon ن، Meem م، and Waw و) follow a Noon Sakinah (نْ) or Tanween (ـًـٍـٌ), they are pronounced with Ghunnah.\nExamples:\nمِنْ يَقُولُ\nPronounced as "Mayyaqool" (Noon merges into Yaa with Ghunnah).\nرَحِيمٌ وَدُودٌ\nPronounced as "Rahiimuw-waduud" (Tanween merges into Waw with Ghunnah).\n\n• When Meem Sakinah (مْ) is followed by a Baa (ب), it is pronounced with a nasalized Meem sound (م). Known as Ikhfaa\' Shafawi, an example of this is: وَاعْتَصِمُوا بِحَبْلِ',
    ),
    TajweedRule(
      color: Color(0xFF00BCD4), // Light blue/Cyan
      title: 'Qalqala',
      subtitle: 'Echoing Sound',
      description:
          'The light blue color identifies the letters of Qalqala (ق ط ب ج د) when they have سكون (e.g., "أَحَدٌ"). These letters are pronounced with a slight echo or bouncing sound, especially at the end of a verse or pause.',
    ),
    TajweedRule(
      color: Color(0xFF1976D2), // Dark blue
      title: 'Tafkhim',
      subtitle: 'Emphatic Pronunciation of Heavy Letters',
      description:
          'The dark blue color highlights ر (Ra\') when pronounced with tafkhim (a heavy, emphatic sound), as well as all other letters of isti\'laa (elevation), which include: خ، ص، ض، غ، ط، ق، ظ. These letters are pronounced with a full, resonant sound. Examples: "الْحَرَامَ", "خَالِدِينَ", "الصَّالِحَاتِ","الْمُسْتَقِيمَ".',
    ),
    TajweedRule(
      color: Color(0xFF9E9E9E), // Grey
      title: 'Silent',
      subtitle: 'Unannounced Pronunciation',
      description:
          'The grey color highlights letters that are silent and diacritics that are merged/assimilated and do not contribute any sound during recitation. Examples include the ل in الشَّمْسِ and the ن in كَانَ لَمْ pronounced as كَأْلَمْ instead.',
    ),
  ];

  void _toggleExpanded(int index) {
    setState(() {
      _expandedStates[index] = !(_expandedStates[index] ?? false);
    });
    AppHaptics.selection();
  }

  Widget _buildRuleItem(TajweedRule rule, int index) {
    final s = AppDesignSystem.getScaleFactor(context);
    final isExpanded = _expandedStates[index] ?? false;

    return Column(
      children: [
        InkWell(
          onTap: () => _toggleExpanded(index),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppDesignSystem.space16 * s * 0.9,
              vertical: AppDesignSystem.space16 * s * 0.9,
            ),
            child: Row(
              children: [
                // Color indicator circle
                Container(
                  width: 32 * s * 0.9,
                  height: 32 * s * 0.9,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: rule.color,
                  ),
                ),
                SizedBox(width: AppDesignSystem.space12 * s * 0.9),
                // Title and subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rule.title,
                        style: TextStyle(
                          fontSize: 16 * s * 0.9,
                          fontWeight: AppTypography.semiBold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2 * s * 0.9),
                      Text(
                        rule.subtitle,
                        style: TextStyle(
                          fontSize: 14 * s * 0.9,
                          fontWeight: AppTypography.regular,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Expand/collapse icon
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 24 * s * 0.9,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
        // Expanded content
        if (isExpanded) ...[
          Divider(
            height: 1,
            thickness: 1 * s * 0.9,
            color: AppColors.borderLight,
          ),
          Padding(
            padding: EdgeInsets.all(AppDesignSystem.space16 * s * 0.9),
            child: Text(
              rule.description,
              style: TextStyle(
                fontSize: 14 * s * 0.9,
                fontWeight: AppTypography.regular,
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          ),
        ],
        // Divider between items (except last item)
        if (index < _rules.length - 1)
          Divider(
            height: 1,
            thickness: 1 * s * 0.9,
            color: AppColors.borderLight,
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppDesignSystem.getScaleFactor(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.textPrimary,
            size: 24 * s * 0.9,
          ),
          onPressed: () {
            AppHaptics.light();
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const MarkingPage(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      const begin = Offset(-0.03, 0.0);
                      const end = Offset.zero;
                      const curve = Curves.easeInOut;
                      var tween = Tween(
                        begin: begin,
                        end: end,
                      ).chain(CurveTween(curve: curve));
                      var offsetAnimation = animation.drive(tween);
                      var fadeAnimation = animation.drive(
                        Tween(
                          begin: 0.0,
                          end: 1.0,
                        ).chain(CurveTween(curve: curve)),
                      );

                      return FadeTransition(
                        opacity: fadeAnimation,
                        child: SlideTransition(
                          position: offsetAnimation,
                          child: child,
                        ),
                      );
                    },
                transitionDuration: AppDesignSystem.durationNormal,
              ),
            );
          },
        ),
        title: Text(
          'Tajweed Rules',
          style: TextStyle(
            fontSize: 18 * s * 0.9,
            fontWeight: AppTypography.semiBold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(AppDesignSystem.space20 * s * 0.9),
          children: [
            // Header description
            Text(
              'Tajweed is the set of rules governing the correct pronunciation and articulation of the Quranic text during recitation.',
              style: TextStyle(
                fontSize: 14 * s * 0.9,
                fontWeight: AppTypography.regular,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            SizedBox(height: AppDesignSystem.space12 * s * 0.9),
            // "Read our blog" link
            InkWell(
              onTap: () {
                // TODO: Navigate to blog
                AppHaptics.selection();
              },
              child: Text(
                'Read our blog',
                style: TextStyle(
                  fontSize: 14 * s * 0.9,
                  fontWeight: AppTypography.regular,
                  color: AppColors.textSecondary,
                  decoration: TextDecoration.underline,
                  height: 1.5,
                ),
              ),
            ),
            SizedBox(height: AppDesignSystem.space20 * s * 0.9),
            // All rules in one container
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(
                  AppDesignSystem.radiusMedium * s * 0.9,
                ),
                border: Border.all(
                  color: AppColors.borderLight,
                  width: 1.0 * s * 0.9,
                ),
              ),
              child: Column(
                children: List.generate(_rules.length, (index) {
                  return _buildRuleItem(_rules[index], index);
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Model class for Tajweed Rule
class TajweedRule {
  final Color color;
  final String title;
  final String subtitle;
  final String description;

  TajweedRule({
    required this.color,
    required this.title,
    required this.subtitle,
    required this.description,
  });
}
