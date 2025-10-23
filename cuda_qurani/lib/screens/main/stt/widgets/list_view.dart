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

    // Estimate: ~600px per page (adjusted for vertical mode)
    final offset = (pageNumber - 1) * 600.0;
    _scrollController.jumpTo(
      offset.clamp(0.0, _scrollController.position.maxScrollExtent),
    );
  }

  void _onScroll() {
    if (!mounted || !_scrollController.hasClients) return;

    final offset = _scrollController.offset;
    final pageNumber = (offset / 600.0).round() + 1;

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
          return const SizedBox(
            height: 600,
            child: Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return SizedBox(
            height: 600,
            child: Center(
              child: Text(
                'Error loading page $pageNumber',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
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

    return Container(
      constraints: const BoxConstraints(minHeight: 600),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Page header
          _PageHeader(pageNumber: pageNumber, juzNumber: juz),

          // Render lines in DATABASE ORDER
          ..._buildLinesInOrder(controller),

          const SizedBox(height: 20),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Juz $juzNumber',
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black,
            fontWeight: FontWeight.w100,
          ),
        ),
        Text(
          '$pageNumber',
          style: const TextStyle(
            fontSize: 12,
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

    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Text(
            'header',
            style: TextStyle(
              fontSize: 48,
              fontFamily: 'Quran-Common',
              color: Colors.black87,
            ),
          ),
          Text(
            surahGlyphCode,
            style: const TextStyle(
              fontSize: 38,
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
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: const Text(
        '﷽',
        style: TextStyle(
          fontSize: 32,
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

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE0E0E0), width: 0.5),
        ),
      ),
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Ayah number badge (left side)
          if (segment.isStartOfAyah)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
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
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ),

          // Complete ayah text with natural wrapping (NO forced line breaks)
          Directionality(
            textDirection: TextDirection.rtl,
            child: Wrap(
              alignment: WrapAlignment.start, // RTL: start = right
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 2,
                    vertical: 1,
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
                        fontSize: 25,
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
