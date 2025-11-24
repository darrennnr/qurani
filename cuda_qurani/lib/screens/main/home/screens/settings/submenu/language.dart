// lib/screens/main/home/screens/settings/submenu/language.dart
import 'package:flutter/material.dart';
import 'package:cuda_qurani/core/design_system/app_design_system.dart';
import 'package:cuda_qurani/screens/main/home/screens/settings/widgets/appbar.dart';

/// ==================== LANGUAGE SETTINGS PAGE ====================
/// Halaman untuk memilih bahasa aplikasi dengan infinite scroll

class LanguagePage extends StatefulWidget {
  const LanguagePage({Key? key}) : super(key: key);

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  // Default selected language (dummy state)
  String _selectedLanguage = 'English';

  // Dummy language data for infinite scroll
  final List<String> _languages = [
    'English',
    'Indonesia',
    'العربية (Arabic)',
    'Türkçe (Turkish)',
    'اردو (Urdu)',
    'فارسی (Persian)',
    'Français (French)',
    'Deutsch (German)',
    'Español (Spanish)',
    'Português (Portuguese)',
    '中文 (Chinese)',
    '日本語 (Japanese)',
    '한국어 (Korean)',
    'Русский (Russian)',
    'Italiano (Italian)',
    'Nederlands (Dutch)',
    'Polski (Polish)',
    'Українська (Ukrainian)',
    'Bahasa Melayu (Malay)',
    'বাংলা (Bengali)',
    'हिन्दी (Hindi)',
    'ภาษาไทย (Thai)',
    'Tiếng Việt (Vietnamese)',
    'Svenska (Swedish)',
    'Norsk (Norwegian)',
    'Dansk (Danish)',
    'Suomi (Finnish)',
    'Ελληνικά (Greek)',
    'עברית (Hebrew)',
    'Català (Catalan)',
    'Čeština (Czech)',
    'Magyar (Hungarian)',
    'Română (Romanian)',
    'Български (Bulgarian)',
    'Srpski (Serbian)',
    'Hrvatski (Croatian)',
    'Slovenščina (Slovenian)',
    'Lietuvių (Lithuanian)',
    'Latviešu (Latvian)',
    'Eesti (Estonian)',
    'Shqip (Albanian)',
    'Македонски (Macedonian)',
    'Bosanski (Bosnian)',
    'Íslenska (Icelandic)',
    'Gaeilge (Irish)',
    'Cymraeg (Welsh)',
    'Euskara (Basque)',
    'Galego (Galician)',
  ];

  void _selectLanguage(String language) {
    setState(() {
      _selectedLanguage = language;
    });
    AppHaptics.selection();
    
    // TODO: Implement language change logic
    // Example: Provider.of<LanguageProvider>(context, listen: false).setLanguage(language);
  }

  Widget _buildLanguageOption({
    required String label,
    required bool isSelected,
  }) {
    final s = AppDesignSystem.getScaleFactor(context);

    return InkWell(
      onTap: () => _selectLanguage(label),
      borderRadius: BorderRadius.circular(AppDesignSystem.radiusMedium * s * 0.9),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppDesignSystem.space16 * s * 0.9,
          vertical: AppDesignSystem.space16 * s * 0.9,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDesignSystem.radiusMedium * s * 0.9),
          border: Border.all(
            color: isSelected ? Colors.black : AppColors.borderLight,
            width: isSelected ? 1.5 * s * 0.9 : 1.0 * s * 0.9,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16 * s * 0.9,
                  fontWeight: isSelected ? AppTypography.semiBold : AppTypography.regular,
                  color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                ),
              ),
            ),
            // Radio indicator
            Container(
              width: 20 * s * 0.9,
              height: 20 * s * 0.9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.black : AppColors.borderMedium,
                  width: isSelected ? 2.0 * s * 0.9 : 1.5 * s * 0.9,
                ),
                color: Colors.transparent,
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10 * s * 0.9,
                        height: 10 * s * 0.9,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppDesignSystem.getScaleFactor(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const SettingsAppBar(
        title: 'Language',
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: EdgeInsets.all(AppDesignSystem.space20 * s * 0.9),
          itemCount: _languages.length,
          separatorBuilder: (context, index) => SizedBox(
            height: AppDesignSystem.space16 * s * 0.9,
          ),
          itemBuilder: (context, index) {
            final language = _languages[index];
            return _buildLanguageOption(
              label: language,
              isSelected: _selectedLanguage == language,
            );
          },
        ),
      ),
    );
  }
}