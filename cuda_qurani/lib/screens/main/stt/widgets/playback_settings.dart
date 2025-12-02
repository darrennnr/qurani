// lib/screens/main/stt/widgets/playback_settings.dart
import 'package:cuda_qurani/core/design_system/app_design_system.dart';
import 'package:cuda_qurani/models/playback_settings_model.dart';
import 'package:cuda_qurani/screens/main/home/screens/settings/submenu/reciters_download.dart';
import 'package:cuda_qurani/services/reciter_manager_services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../services/local_database_service.dart';

class PlaybackSettingsPage extends StatefulWidget {
  const PlaybackSettingsPage({Key? key}) : super(key: key);

  @override
  State<PlaybackSettingsPage> createState() => _PlaybackSettingsPageState();
}

class _PlaybackSettingsPageState extends State<PlaybackSettingsPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _surahs = [];

  int _parseRepeatValue(String value) {
    if (value == 'Loop') return -1;
    // Extract number from "1 time", "2 times", etc.
    final match = RegExp(r'\d+').firstMatch(value);
    return match != null ? int.parse(match.group(0)!) : 1;
  }

  double _parseSpeedValue(String value) {
    // Extract number from "0.5x", "1x", "1.5x", etc.
    return double.parse(value.replaceAll('x', ''));
  }

  // --- Selection State ---
  int _startSurahId = 1;
  int _startVerse = 1;
  int _endSurahId = 1;
  int _endVerse = 7;

  List<ReciterInfo> _reciters = [];
  String _selectedReciter = '';
  String _selectedReciterId = '';

  bool _isReciterExpanded = false;

  // --- Playback Options ---
  final List<String> _speeds = [
    '0.5x',
    '0.75x',
    '1x',
    '1.25x',
    '1.5x',
    '1.75x',
  ];
  String _selectedSpeed = '1x';
  final List<String> _repetitions = ['1 time', '2 times', '3 times', 'Loop'];
  String _eachVerseRepeat = '1 time';
  String _rangeRepeat = '1 time';

  @override
  void initState() {
    super.initState();
    _loadDatabaseData();
    _loadReciters();
  }

Future<void> _loadReciters() async {
  print('🔍 Loading reciters...'); // ✅ Debug
  final reciters = await ReciterManagerService.getAllReciters();
  print('📊 Loaded ${reciters.length} reciters'); // ✅ Debug
  
  if (reciters.isEmpty) {
    print('❌ No reciters loaded!'); // ✅ Debug
  }
  
  setState(() {
    _reciters = reciters;
    if (_reciters.isNotEmpty) {
      _selectedReciter = _reciters.first.name;
      _selectedReciterId = _reciters.first.identifier;
      print('✅ Selected: $_selectedReciter'); // ✅ Debug
    } else {
      print('⚠️ Reciters list is empty!'); // ✅ Debug
    }
  });
}
  /// Loads Surah data from SQLite using your LocalDatabaseService
  Future<void> _loadDatabaseData() async {
    try {
      await LocalDatabaseService.preInitialize();
      final surahs = await LocalDatabaseService.getSurahs();
      if (mounted) {
        setState(() {
          _surahs = surahs;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading surahs: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _surahs = [
            {'id': 1, 'name_simple': 'Al-Fatihah', 'verses_count': 7},
            {'id': 2, 'name_simple': 'Al-Baqarah', 'verses_count': 286},
          ];
        });
      }
    }
  }

  String _getSurahName(int id) {
    final surah = _surahs.firstWhere(
      (s) => s['id'] == id,
      orElse: () => {'name_simple': 'Unknown'},
    );
    return surah['name_simple'];
  }

  int _getVerseCount(int id) {
    final surah = _surahs.firstWhere(
      (s) => s['id'] == id,
      orElse: () => {'verses_count': 1},
    );
    return surah['verses_count'] ?? 0;
  }

  void _showVersePicker({required bool isStart}) {
    int tempSurahId = isStart ? _startSurahId : _endSurahId;
    int tempVerse = isStart ? _startVerse : _endVerse;
    int maxVerses = _getVerseCount(tempSurahId);

    FixedExtentScrollController surahController = FixedExtentScrollController(
      initialItem: tempSurahId - 1,
    );
    FixedExtentScrollController verseController = FixedExtentScrollController(
      initialItem: tempVerse - 1,
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDesignSystem.radiusXLarge),
        ),
      ),
      builder: (BuildContext context) {
        final s = AppDesignSystem.getScaleFactor(context);
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: 350 * s,
              padding: EdgeInsets.only(top: AppDesignSystem.space16 * s),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDesignSystem.space16 * s,
                      vertical: AppDesignSystem.space8 * s,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Cancel',
                            style: AppTypography.label(
                              context,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        Text(
                          isStart ? 'Starting Verse' : 'Ending Verse',
                          style: AppTypography.titleLarge(context),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              if (isStart) {
                                _startSurahId = tempSurahId;
                                _startVerse = tempVerse;
                                if (_startSurahId > _endSurahId ||
                                    (_startSurahId == _endSurahId &&
                                        _startVerse > _endVerse)) {
                                  _endSurahId = _startSurahId;
                                  _endVerse = _startVerse;
                                }
                              } else {
                                _endSurahId = tempSurahId;
                                _endVerse = tempVerse;
                              }
                            });
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Done',
                            style: AppTypography.label(
                              context,
                              color: AppColors.textPrimary,
                              weight: AppTypography.semiBold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: CupertinoPicker.builder(
                            scrollController: surahController,
                            itemExtent: 40 * s,
                            onSelectedItemChanged: (index) {
                              setModalState(() {
                                tempSurahId = index + 1;
                                maxVerses = _getVerseCount(tempSurahId);
                                if (tempVerse > maxVerses) {
                                  tempVerse = 1;
                                  verseController.jumpToItem(0);
                                }
                              });
                            },
                            childCount: _surahs.length,
                            itemBuilder: (context, index) {
                              final surah = _surahs[index];
                              return Center(
                                child: Text(
                                  "${surah['id']} - ${surah['name_simple']}",
                                  style: AppTypography.body(context),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            },
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: CupertinoPicker.builder(
                            scrollController: verseController,
                            itemExtent: 40 * s,
                            onSelectedItemChanged: (index) {
                              setModalState(() {
                                tempVerse = index + 1;
                              });
                            },
                            childCount: maxVerses,
                            itemBuilder: (context, index) {
                              return Center(
                                child: Text(
                                  "${index + 1}",
                                  style: AppTypography.body(context),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDropdownTrigger({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    final s = AppDesignSystem.getScaleFactor(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDesignSystem.radiusMedium * s),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppDesignSystem.space16 * s,
              vertical: AppDesignSystem.space12 * s,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(
                AppDesignSystem.radiusMedium * s,
              ),
              border: Border.all(color: AppColors.borderMedium),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: AppTypography.body(context)),
                Row(
                  children: [
                    Text(
                      value,
                      style: AppTypography.body(
                        context,
                        weight: AppTypography.semiBold,
                      ),
                    ),
                    SizedBox(width: AppDesignSystem.space8 * s),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.textSecondary,
                      size: AppDesignSystem.iconMedium * s,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReciterSection() {
    final s = AppDesignSystem.getScaleFactor(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Reciter",
          style: AppTypography.caption(context, weight: AppTypography.semiBold),
        ),
        SizedBox(height: AppDesignSystem.space10 * s),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(
              AppDesignSystem.radiusMedium * s,
            ),
            border: Border.all(color: AppColors.borderMedium),
          ),
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    _isReciterExpanded = !_isReciterExpanded;
                  });
                },
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppDesignSystem.radiusMedium * s),
                  bottom: Radius.circular(
                    _isReciterExpanded ? 0 : AppDesignSystem.radiusMedium * s,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDesignSystem.space16 * s,
                    vertical: AppDesignSystem.space16 * s,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _selectedReciter,
                          style: AppTypography.body(context),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        _isReciterExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: AppColors.textPrimary,
                        size: AppDesignSystem.iconLarge * s,
                      ),
                    ],
                  ),
                ),
              ),
              if (_isReciterExpanded) ...[
                const Divider(height: 1, color: AppColors.borderMedium),
                SizedBox(
                  height: 200 * s,
                  child: ListView.builder(
                    itemCount: _reciters.length,
                    itemBuilder: (context, index) {
                      final reciter = _reciters[index];
                      final isSelected =
                          reciter.identifier == _selectedReciterId;
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedReciter = reciter.name;
                            _selectedReciterId = reciter.identifier;
                            _isReciterExpanded = false;
                          });
                          AppHaptics.light();
                        },
                        child: Container(
                          color: isSelected
                              ? AppColors.primaryWithOpacity(0.1)
                              : null,
                          padding: EdgeInsets.symmetric(
                            horizontal: AppDesignSystem.space16 * s,
                            vertical: AppDesignSystem.space12 * s,
                          ),
                          child: Text(
                            reciter.name,
                            style: AppTypography.body(
                              context,
                              weight: isSelected
                                  ? AppTypography.semiBold
                                  : AppTypography.regular,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
              if (!_isReciterExpanded) ...[
                const Divider(height: 1, color: AppColors.borderMedium),
                InkWell(
                  onTap: () {
                    AppHaptics.light();
                     Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            RecitersDownloadPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.03, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          var fadeAnimation = animation.drive(
            Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve)),
          );

          return FadeTransition(
            opacity: fadeAnimation,
            child: SlideTransition(position: offsetAnimation, child: child),
          );
        },
        transitionDuration: AppDesignSystem.durationNormal,
      ),
    );
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            RecitersDownloadPage(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                              const begin = Offset(0.03, 0.0);
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
                    // Add download management logic here
                  },
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(AppDesignSystem.radiusMedium * s),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDesignSystem.space16 * s,
                      vertical: AppDesignSystem.space12 * s,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Manage downloads",
                          style: AppTypography.body(context),
                        ),
                        Container(
                          padding: EdgeInsets.all(AppDesignSystem.space4 * s),
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.arrow_downward,
                            color: Colors.white,
                            size: AppDesignSystem.iconSmall * s,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSelectionRow(
    String title,
    List<String> options,
    String selectedValue,
    Function(String) onSelect,
  ) {
    final s = AppDesignSystem.getScaleFactor(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.caption(context, weight: AppTypography.semiBold),
        ),
        SizedBox(height: AppDesignSystem.space10 * s),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: options.map((option) {
              final isSelected = option == selectedValue;
              return Padding(
                padding: EdgeInsets.only(right: AppDesignSystem.space8 * s),
                child: GestureDetector(
                  onTap: () {
                    onSelect(option);
                    AppHaptics.light();
                  },
                  child: AnimatedContainer(
                    duration: AppDesignSystem.durationFast,
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDesignSystem.space20 * s + 180 / 100,
                      vertical: AppDesignSystem.space10 * s,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.textPrimary
                          : AppColors.surface,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.textPrimary
                            : AppColors.borderMedium,
                      ),
                      borderRadius: BorderRadius.circular(
                        AppDesignSystem.radiusSmall * s,
                      ),
                    ),
                    child: Text(
                      option,
                      style: AppTypography.labelSmall(
                        context,
                        color: isSelected
                            ? Colors.white
                            : AppColors.textPrimary,
                        weight: isSelected
                            ? AppTypography.semiBold
                            : AppTypography.regular,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppDesignSystem.getScaleFactor(context);
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.textPrimary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppDesignSystem.space16 * s,
                vertical: AppDesignSystem.space12 * s,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Playback Settings",
                    style: AppTypography.h2(
                      context,
                      weight: AppTypography.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      AppHaptics.light();
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.close, color: AppColors.textSecondary),
                    splashRadius: 20 * s,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDesignSystem.space20 * s,
                ),
                physics: const BouncingScrollPhysics(),
                children: [
                  Text(
                    "Select Range",
                    style: AppTypography.caption(
                      context,
                      weight: AppTypography.semiBold,
                    ),
                  ),
                  SizedBox(height: AppDesignSystem.space12 * s),
                  _buildDropdownTrigger(
                    label: "Starting Verse",
                    value:
                        "${_getSurahName(_startSurahId)} - $_startSurahId:$_startVerse",
                    onTap: () => _showVersePicker(isStart: true),
                  ),
                  SizedBox(height: AppDesignSystem.space12 * s),
                  _buildDropdownTrigger(
                    label: "Ending Verse",
                    value:
                        "${_getSurahName(_endSurahId)} - $_endSurahId:$_endVerse",
                    onTap: () => _showVersePicker(isStart: false),
                  ),
                  SizedBox(height: AppDesignSystem.space24 * s),
                  _buildReciterSection(),
                  SizedBox(height: AppDesignSystem.space24 * s),
                  _buildSelectionRow(
                    "Play speed",
                    _speeds,
                    _selectedSpeed,
                    (val) => setState(() => _selectedSpeed = val),
                  ),
                  SizedBox(height: AppDesignSystem.space24 * s),
                  _buildSelectionRow(
                    "Play each verse",
                    _repetitions,
                    _eachVerseRepeat,
                    (val) => setState(() => _eachVerseRepeat = val),
                  ),
                  SizedBox(height: AppDesignSystem.space24 * s),
                  _buildSelectionRow(
                    "Play the range",
                    _repetitions,
                    _rangeRepeat,
                    (val) => setState(() => _rangeRepeat = val),
                  ),
                  SizedBox(height: AppDesignSystem.space96 * s),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: AppColors.background,
        padding: EdgeInsets.fromLTRB(
          AppDesignSystem.space20 * s,
          0,
          AppDesignSystem.space20 * s,
          AppDesignSystem.space20 * s,
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: AppDesignSystem.buttonHeightXLarge * s,
            child: ElevatedButton.icon(
              onPressed: () {
                AppHaptics.medium();

                // Create PlaybackSettings object
                final settings = PlaybackSettings(
                  startSurahId: _startSurahId,
                  startVerse: _startVerse,
                  endSurahId: _endSurahId,
                  endVerse: _endVerse,
                  reciter: _selectedReciterId,
                  speed: _parseSpeedValue(_selectedSpeed),
                  eachVerseRepeat: _parseRepeatValue(_eachVerseRepeat),
                  rangeRepeat: _parseRepeatValue(_rangeRepeat),
                );

                // Return settings to parent
                Navigator.pop(context, settings);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.textPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30 * s),
                ),
                elevation: 0,
              ),
              icon: Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: AppDesignSystem.iconMedium * s,
              ),
              label: Text(
                "Play Audio",
                style: AppTypography.label(
                  context,
                  color: Colors.white,
                  weight: AppTypography.semiBold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
