// lib\screens\main\stt\widgets\list_view.dart

import 'package:cuda_qurani/models/quran_models.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/stt_controller.dart';
import '../data/models.dart';
import '../services/quran_service.dart';
import '../utils/constants.dart';

/// Optimized vertical Quran reading mode
/// Uses same data source as mushaf mode for consistency
class QuranListView extends StatefulWidget {
  const QuranListView({Key? key}) : super(key: key);

  @override
  State<QuranListView> createState() => _QuranListViewState();
}

class _QuranListViewState extends State<QuranListView> {
  final ScrollController _scrollController = ScrollController();
  int _currentVisiblePage = 1;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Jump to current page after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final controller = context.read<SttController>();
      _jumpToPage(controller.currentPage);
    });
  }

  void _jumpToPage(int pageNumber) {
    if (!mounted || !_scrollController.hasClients) return;

    // ✅ GANTI estimasi dengan persentase screen height
    final screenHeight = MediaQuery.of(context).size.height;
    final estimatedPageHeight = screenHeight * 0.75; // ~600px pada 800px height
    final offset = (pageNumber - 1) * estimatedPageHeight;

    _scrollController.jumpTo(
      offset.clamp(0.0, _scrollController.position.maxScrollExtent),
    );
  }

  void _onScroll() {
    if (!mounted || !_scrollController.hasClients) return;

    final offset = _scrollController.offset;
    final screenHeight = MediaQuery.of(context).size.height;
    final estimatedPageHeight = screenHeight * 0.75; // ✅ TAMBAH ini
    final pageNumber = (offset / estimatedPageHeight).round() + 1; // ✅ GANTI

    if (pageNumber != _currentVisiblePage &&
        pageNumber >= 1 &&
        pageNumber <= 604) {
      setState(() => _currentVisiblePage = pageNumber);
      context.read<SttController>().updateVisiblePage(pageNumber);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: 604,
      cacheExtent: 2048, // Cache 3 pages ahead/behind
      addAutomaticKeepAlives: true,
      addRepaintBoundaries: true,
      itemBuilder: (context, index) {
        final pageNumber = index + 1;
        return RepaintBoundary(
          key: ValueKey('vertical_page_$pageNumber'),
          child: _VerticalPageWidget(pageNumber: pageNumber),
        );
      },
    );
  }
}

/// Single vertical page widget - uses cached mushaf data
class _VerticalPageWidget extends StatelessWidget {
  final int pageNumber;

  const _VerticalPageWidget({required this.pageNumber});

  @override
  Widget build(BuildContext context) {
    final controller = context.read<SttController>();
    final service = context.read<QuranService>();

    // Check cache first for instant load
    final cachedLines = controller.pageCache[pageNumber];

    if (cachedLines != null && cachedLines.isNotEmpty) {
      return _VerticalPageContent(
        pageNumber: pageNumber,
        pageLines: cachedLines,
      );
    }

    // Load from database
    return FutureBuilder<List<MushafPageLine>>(
      key: ValueKey('page_data_$pageNumber'),
      future: service.getMushafPageLines(pageNumber),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height:
                MediaQuery.of(context).size.height * 0.75, // ✅ GANTI dari 600
            child: Center(
              child: SizedBox(
                width:
                    MediaQuery.of(context).size.width *
                    0.045, // ✅ GANTI dari 18
                height: MediaQuery.of(context).size.width * 0.045,
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return SizedBox(
            height:
                MediaQuery.of(context).size.height * 0.75, // ✅ GANTI dari 600
            child: Center(
              child: Text(
                'Error loading page $pageNumber',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize:
                      MediaQuery.of(context).size.width *
                      0.03, // ✅ GANTI dari 12
                ),
              ),
            ),
          );
        }
        final pageLines = snapshot.data!;

        // Update cache asynchronously
        WidgetsBinding.instance.addPostFrameCallback((_) {
          controller.updatePageCache(pageNumber, pageLines);
        });

        return _VerticalPageContent(
          pageNumber: pageNumber,
          pageLines: pageLines,
        );
      },
    );
  }
}

/// Renders page content with optimized vertical layout
class _VerticalPageContent extends StatelessWidget {
  final int pageNumber;
  final List<MushafPageLine> pageLines;

  const _VerticalPageContent({
    required this.pageNumber,
    required this.pageLines,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SttController>();
    final juz = _calculateJuzForPage();
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      constraints: BoxConstraints(
        minHeight: screenHeight * 0.75, // ✅ GANTI dari 600
      ),
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04, // ✅ GANTI dari 16
        vertical: screenHeight * 0.015, // ✅ GANTI dari 12
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PageHeader(pageNumber: pageNumber, juzNumber: juz),
          ..._buildLinesInOrder(controller),
          SizedBox(height: screenHeight * 0.025), // ✅ GANTI dari 20
        ],
      ),
    );
  }

  /// Render lines in exact database order
  List<Widget> _buildLinesInOrder(SttController controller) {
    final widgets = <Widget>[];
    final renderedAyahs = <String>{}; // Track "surahId:ayahNumber"

    // Pre-aggregate complete ayahs
    final Map<String, List<WordData>> completeAyahs = {};
    final Map<String, AyahSegment> ayahMetadata = {};

    for (final line in pageLines) {
      if (line.lineType == 'ayah' && line.ayahSegments != null) {
        for (final segment in line.ayahSegments!) {
          final key = '${segment.surahId}:${segment.ayahNumber}';
          completeAyahs.putIfAbsent(key, () => []).addAll(segment.words);
          if (!ayahMetadata.containsKey(key)) {
            ayahMetadata[key] = segment;
          }
        }
      }
    }

    // Sort words in each ayah
    for (final words in completeAyahs.values) {
      words.sort((a, b) => a.wordNumber.compareTo(b.wordNumber));
    }

    // Render in database order
    for (final line in pageLines) {
      switch (line.lineType) {
        case 'surah_name':
          widgets.add(_SurahHeader(line: line));
          break;

        case 'basmallah':
          widgets.add(const _Basmallah());
          break;

        case 'ayah':
          if (line.ayahSegments != null) {
            for (final segment in line.ayahSegments!) {
              final key = '${segment.surahId}:${segment.ayahNumber}';

              // Render complete ayah only once
              if (!renderedAyahs.contains(key)) {
                renderedAyahs.add(key);

                final allWords = completeAyahs[key]!;
                final metadata = ayahMetadata[key]!;

                final completeSegment = AyahSegment(
                  surahId: metadata.surahId,
                  ayahNumber: metadata.ayahNumber,
                  words: allWords,
                  isStartOfAyah: true,
                  isEndOfAyah: true,
                );

                widgets.add(
                  _CompleteAyahWidget(
                    segment: completeSegment,
                    fontFamily: 'p$pageNumber',
                    controller: controller,
                  ),
                );
              }
            }
          }
          break;
      }
    }

    return widgets;
  }

  int _calculateJuzForPage() {
    if (pageLines.isEmpty) return 1;

    for (final line in pageLines) {
      if (line.ayahSegments != null && line.ayahSegments!.isNotEmpty) {
        final segment = line.ayahSegments!.first;
        return QuranService().calculateJuzAccurate(
          segment.surahId,
          segment.ayahNumber,
        );
      }
    }
    return 1;
  }
}

/// Page header with juz and page number
class _PageHeader extends StatelessWidget {
  final int pageNumber;
  final int juzNumber;

  const _PageHeader({required this.pageNumber, required this.juzNumber});

  @override
  Widget build(BuildContext context) {
    final fontSize =
        MediaQuery.of(context).size.width * 0.03; // ✅ ~12px pada 400px

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Juz $juzNumber',
          style: TextStyle(
            fontSize: fontSize, // ✅ GANTI dari 12
            color: Colors.black,
            fontWeight: FontWeight.w100,
          ),
        ),
        Text(
          '$pageNumber',
          style: TextStyle(
            fontSize: fontSize, // ✅ GANTI dari 12
            color: Colors.black,
            fontWeight: FontWeight.w100,
          ),
        ),
      ],
    );
  }
}

/// Surah header with decorative background
class _SurahHeader extends StatelessWidget {
  final MushafPageLine line;

  const _SurahHeader({required this.line});

  @override
  Widget build(BuildContext context) {
    final surahId = line.surahNumber ?? 1;
    final surahGlyphCode = _formatSurahGlyph(surahId);
    final screenHeight = MediaQuery.of(context).size.height;

    final headerSize = screenHeight * 0.056; // ✅ ~48px pada 800px
    final surahNameSize = screenHeight * 0.0475; // ✅ ~38px pada 800px
    final verticalMargin = screenHeight * 0.015; // ✅ ~12px pada 800px

    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.symmetric(vertical: verticalMargin), // ✅ GANTI
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            'header',
            style: TextStyle(
              fontSize: headerSize, // ✅ GANTI dari 48
              fontFamily: 'Quran-Common',
              color: Colors.black87,
            ),
          ),
          Text(
            surahGlyphCode,
            style: TextStyle(
              fontSize: surahNameSize, // ✅ GANTI dari 38
              fontFamily: 'surah-name-v2',
              color: Colors.black,
            ),
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }

  String _formatSurahGlyph(int surahId) {
    if (surahId <= 9) return 'surah00$surahId';
    if (surahId <= 99) return 'surah0$surahId';
    return 'surah$surahId';
  }
}

/// Basmallah text
class _Basmallah extends StatelessWidget {
  const _Basmallah();

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final basmallahSize = screenHeight * 0.04; // ✅ ~32px pada 800px
    final verticalPadding = screenHeight * 0.01; // ✅ ~8px pada 800px

    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(vertical: verticalPadding), // ✅ GANTI
      child: Text(
        '﷽',
        style: TextStyle(
          fontSize: basmallahSize, // ✅ GANTI dari 32
          fontFamily: 'Quran-Common',
          color: Colors.black87,
        ),
      ),
    );
  }
}

/// Renders ONE COMPLETE AYAH with badge and underline
class _CompleteAyahWidget extends StatelessWidget {
  final AyahSegment segment;
  final String fontFamily;
  final SttController controller;

  const _CompleteAyahWidget({
    required this.segment,
    required this.fontFamily,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final ayatIndex = controller.ayatList.indexWhere(
      (a) => a.surah_id == segment.surahId && a.ayah == segment.ayahNumber,
    );
    final isCurrentAyat =
        ayatIndex >= 0 && ayatIndex == controller.currentAyatIndex;

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final badgeFontSize = screenWidth * 0.0275; // ✅ ~11px pada 400px
    final badgePaddingH = screenWidth * 0.02; // ✅ ~8px
    final badgePaddingV = screenHeight * 0.005; // ✅ ~4px
    final badgeBottomMargin = screenHeight * 0.01; // ✅ ~8px
    final containerBottomPadding = screenHeight * 0.015; // ✅ ~12px
    final containerTopPadding = screenHeight * 0.005; // ✅ ~4px
    final wordFontSize = screenWidth * 0.0625; // ✅ ~25px pada 400px

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE0E0E0), width: 0.5),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: containerBottomPadding, // ✅ GANTI
        top: containerTopPadding, // ✅ GANTI
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Ayah number badge
          if (segment.isStartOfAyah)
            Padding(
              padding: EdgeInsets.only(bottom: badgeBottomMargin), // ✅ GANTI
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: badgePaddingH, // ✅ GANTI
                    vertical: badgePaddingV, // ✅ GANTI
                  ),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(
                      color: isCurrentAyat ? primaryColor : Colors.black54,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${segment.surahId}:${segment.ayahNumber}',
                    style: TextStyle(
                      color: isCurrentAyat ? primaryColor : Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: badgeFontSize, // ✅ GANTI dari 11
                    ),
                  ),
                ),
              ),
            ),

          // Complete ayah text
          Directionality(
            textDirection: TextDirection.rtl,
            child: Wrap(
              alignment: WrapAlignment.start,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 1,
              runSpacing: 4,
              children: segment.words.asMap().entries.map((entry) {
                final wordIndex = entry.value.wordNumber - 1;
                final word = entry.value;

                final wordStatus =
                    controller.wordStatusMap[segment.ayahNumber]?[wordIndex];

                Color wordBg = Colors.transparent;
                if (wordStatus != null && controller.isRecording) {
                  switch (wordStatus) {
                    case WordStatus.matched:
                      wordBg = correctColor.withOpacity(0.4);
                      break;
                    case WordStatus.mismatched:
                    case WordStatus.skipped:
                      wordBg = errorColor.withOpacity(0.4);
                      break;
                    case WordStatus.processing:
                      wordBg = listeningColor.withOpacity(0.3);
                      break;
                    default:
                      break;
                  }
                }

                double opacity = 1.0;
                if (controller.hideUnreadAyat && !isCurrentAyat) {
                  final hasNumber = RegExp(r'[٠-٩0-9]').hasMatch(word.text);
                  opacity = hasNumber ? 1.0 : 0.0;
                }

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.005, // ✅ GANTI dari 2
                    vertical: screenHeight * 0.00125, // ✅ GANTI dari 1
                  ),
                  decoration: BoxDecoration(
                    color: wordBg,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: opacity,
                    child: Text(
                      word.text,
                      style: TextStyle(
                        fontSize: wordFontSize, // ✅ GANTI dari 25
                        fontFamily: fontFamily,
                        color: isCurrentAyat ? listeningColor : Colors.black87,
                        fontWeight: FontWeight.w400,
                        height: 1.7,
                        letterSpacing: -5,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
