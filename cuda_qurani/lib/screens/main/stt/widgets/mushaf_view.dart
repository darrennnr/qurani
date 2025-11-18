// lib\screens\main\stt\widgets\mushaf_view.dart

import 'package:cuda_qurani/models/quran_models.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/stt_controller.dart';
import '../data/models.dart';
import '../services/quran_service.dart';
import '../utils/constants.dart';

class MushafRenderer {
  static double pageHeight(BuildContext context) {
    return MediaQuery.of(context).size.height * 0.85; // 85% screen height
  }

  static double lineHeight(BuildContext context) {
    return MediaQuery.of(context).size.height * 0.050; // ~5.5% screen height
  }

  static const double PAGE_PADDING = 0.0; // Minimal side padding
  static const double WORD_SPACING_MIN = 0.0; // Minimum gap between words
  static const double WORD_SPACING_MAX =
      0.0; // Maximum gap to prevent huge spaces

  // Render justified text for ayah lines
  static Widget renderJustifiedLine({
    required List<InlineSpan> wordSpans,
    required bool isCentered,
    required double availableWidth,
    required BuildContext context,
    bool allowOverflow = false,
  }) {
    if (wordSpans.isEmpty) return const SizedBox.shrink();

    final lineH = lineHeight(context);

    if (isCentered) {
      return SizedBox(
        height: lineH,
        width: availableWidth,
        child: Center(
          child: RichText(
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            overflow: TextOverflow.visible,
            text: TextSpan(children: wordSpans),
          ),
        ),
      );
    }

    return SizedBox(
      height: lineH,
      width: availableWidth,
      child: _buildJustifiedText(
        wordSpans: wordSpans,
        maxWidth: availableWidth,
        allowOverflow: allowOverflow,
        context: context,
      ),
    );
  }

  static Widget _buildJustifiedText({
    required List<InlineSpan> wordSpans,
    required double maxWidth,
    bool allowOverflow = false,
    required BuildContext context,
  }) {
    if (wordSpans.isEmpty) return const SizedBox.shrink();

    final lineH = lineHeight(context);

    // Single word case
    if (wordSpans.length == 1) {
      return SizedBox(
        width: maxWidth,
        child: RichText(
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.justify,
          text: wordSpans.first as TextSpan,
        ),
      );
    }

    // Calculate total text width WITHOUT spacing
    double totalTextWidth = 0;
    final List<double> wordWidths = [];

    for (final span in wordSpans) {
      final textPainter = TextPainter(
        text: span as TextSpan,
        textDirection: TextDirection.rtl,
      );
      textPainter.layout();
      final width = textPainter.width;
      wordWidths.add(width);
      totalTextWidth += width;
    }

    // Calculate spacing needed to fill the line
    final remainingSpace = maxWidth - totalTextWidth;
    final numberOfGaps = wordSpans.length - 1;

    double spacing = numberOfGaps > 0
        ? (remainingSpace / numberOfGaps).clamp(
            WORD_SPACING_MIN,
            WORD_SPACING_MAX,
          )
        : 0;

    // Build justified row
    return SizedBox(
      width: maxWidth,
      height: lineH,
      child: Row(
        textDirection: TextDirection.rtl,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (int i = 0; i < wordSpans.length; i++) ...[
            RichText(
              textDirection: TextDirection.rtl,
              overflow: TextOverflow.clip,
              maxLines: 1,
              text: wordSpans[i] as TextSpan,
            ),
            if (i < wordSpans.length - 1) SizedBox(width: spacing),
          ],
        ],
      ),
    );
  }
}

class MushafDisplay extends StatefulWidget {
  const MushafDisplay({Key? key}) : super(key: key);

  @override
  State<MushafDisplay> createState() => _MushafDisplayState();
}

class _MushafDisplayState extends State<MushafDisplay> {
  bool _isSwipeInProgress = false;
  double _dragStartPosition = 0;

  @override
  Widget build(BuildContext context) {
    final controller = context.read<SttController>();

    return GestureDetector(
      onHorizontalDragStart: (details) {
        _dragStartPosition = details.globalPosition.dx;
        _isSwipeInProgress = false;
      },
      onHorizontalDragUpdate: (details) {
        // Detect significant horizontal movement
        final dragDistance = (details.globalPosition.dx - _dragStartPosition)
            .abs();
        if (dragDistance > 50 && !_isSwipeInProgress) {
          _isSwipeInProgress = true;
        }
      },
      onHorizontalDragEnd: (details) {
        if (!_isSwipeInProgress) return;

        final velocity = details.primaryVelocity ?? 0;

        // Swipe threshold: 500 pixels per second
        if (velocity > 500) {
          // Swipe RIGHT = go to NEXT page (Arabic reading direction)
          controller.navigateToPage(controller.currentPage + 1);
        } else if (velocity < -500) {
          // Swipe LEFT = go to PREVIOUS page
          controller.navigateToPage(controller.currentPage - 1);
        }

        // Reset swipe state
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            setState(() {
              _isSwipeInProgress = false;
            });
          }
        });
      },
      child: _buildMushafPageOptimized(context),
    );
  }

  Widget _buildMushafPageOptimized(BuildContext context) {
    final controller = context.watch<SttController>();
    final pageNumber = controller.currentPage;
    final cachedLines = controller.pageCache[pageNumber];

    // âœ… FAST PATH: If page is cached, render immediately (NO LOADING)
    if (cachedLines != null && cachedLines.isNotEmpty) {
      return MushafPageContent(pageLines: cachedLines, pageNumber: pageNumber);
    }

    // âš ï¸ FALLBACK: This should RARELY happen due to aggressive preloading
    // If it does, show minimal loading and trigger emergency load
    print(
      'âš ï¸ CACHE MISS: Page $pageNumber not cached, emergency loading...',
    );

    // Trigger emergency load in controller
    Future.microtask(() async {
      try {
        final lines = await context.read<QuranService>().getMushafPageLines(
          pageNumber,
        );
        controller.updatePageCache(pageNumber, lines);
      } catch (e) {
        print('âŒ Emergency load failed: $e');
      }
    });

    // Show ultra-minimal loading (should be < 100ms)
    return SizedBox(
      height: MushafRenderer.pageHeight(context),
      child: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.03,
          height: MediaQuery.of(context).size.width * 0.03,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade400),
          ),
        ),
      ),
    );
  }
}

class MushafPageContent extends StatelessWidget {
  final List<MushafPageLine> pageLines;
  final int pageNumber;
  const MushafPageContent({
    Key? key,
    required this.pageLines,
    required this.pageNumber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appBarHeight = kToolbarHeight * 0.95; // Match QuranAppBar height

    return Padding(
      padding: EdgeInsets.only(
        top: appBarHeight,
      ), // ✅ Push content below AppBar
      child: Column(
        children: [
          const MushafPageHeader(), // Will be hidden behind AppBar
          const SizedBox(height: 0),
          ..._buildPageLines(),
        ],
      ),
    );
  }

  List<Widget> _buildPageLines() {
    return pageLines.map((line) => _buildMushafLine(line)).toList();
  }

  Widget _buildMushafLine(MushafPageLine line) {
    switch (line.lineType) {
      case 'surah_name':
        return _SurahNameLine(line: line);
      case 'basmallah':
        return _BasmallahLine();
      case 'ayah':
        return _JustifiedAyahLine(line: line, pageNumber: pageNumber);
      default:
        return const SizedBox.shrink();
    }
  }
}

class _SurahNameLine extends StatelessWidget {
  final MushafPageLine line;
  const _SurahNameLine({required this.line});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final headerSize = screenHeight * 0.060;
    final surahNameSize = screenHeight * 0.050;
    final controller = context.read<SttController>();
    final surahGlyphCode = line.surahNumber != null
        ? controller.formatSurahIdForGlyph(line.surahNumber!)
        : '';
    return Container(
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            'header',
            style: TextStyle(
              fontSize: headerSize,
              fontFamily: 'Quran-Common',
              color: Colors.black87,
              height: MediaQuery.of(context).size.height * 0.0010,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            surahGlyphCode,
            style: TextStyle(
              fontSize: surahNameSize,
              fontFamily: 'surah-name-v2',
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }
}

class _BasmallahLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final basmallahSize = screenHeight * 0.040;

    return Container(
      height: MushafRenderer.lineHeight(context),
      alignment: Alignment.center,
      child: Text(
        '﷽',
        style: TextStyle(
          fontSize: basmallahSize,
          fontFamily: 'Quran-Common',
          color: Colors.black87,
          fontWeight: FontWeight.normal,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _JustifiedAyahLine extends StatelessWidget {
  final MushafPageLine line;
  final int pageNumber; // TAMBAH ini

  const _JustifiedAyahLine({
    required this.line,
    required this.pageNumber, // TAMBAH ini
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final baseFontSize = screenWidth * 0.065;
    if (line.ayahSegments == null || line.ayahSegments!.isEmpty) {
      return SizedBox(height: MushafRenderer.lineHeight(context));
    }
    final controller = context.watch<SttController>();
    List<InlineSpan> spans = [];

    // Font family berdasarkan mode
    final fontFamily = controller.isQuranMode ? 'p$pageNumber' : 'UthmanTN';

    for (final segment in line.ayahSegments!) {
      final ayatIndex = controller.ayatList.indexWhere(
        (a) => a.surah_id == segment.surahId && a.ayah == segment.ayahNumber,
      );
      final isCurrentAyat =
          ayatIndex >= 0 && ayatIndex == controller.currentAyatIndex;

      for (int i = 0; i < segment.words.length; i++) {
        final word = segment.words[i];

        // âœ… FIX: Use wordNumber - 1 as index (wordNumber is 1-indexed, backend uses 0-indexed)
        final wordIndex = word.wordNumber - 1;

        // Get word status dari wordStatusMap
        final wordStatus =
            controller.wordStatusMap[segment.ayahNumber]?[wordIndex];

        // ðŸ”¥ DEBUG: Print word status dan warna yang akan diapply
        if (controller.isRecording &&
            segment.ayahNumber == controller.currentAyatNumber) {
          print(
            'ðŸŽ¨ UI RENDER: Ayah ${segment.ayahNumber}, Word[$wordIndex] (loop $i) = $wordStatus',
          );
          print(
            '   ðŸ“Š Full wordStatusMap[${segment.ayahNumber}] = ${controller.wordStatusMap[segment.ayahNumber]}',
          );
        }

        final wordSegments = controller.segmentText(word.text);
        final hasArabicNumber = wordSegments.any((s) => s.isArabicNumber);

        double wordOpacity = 1.0;
        Color wordBg = Colors.transparent;

        // Background color based on word status - HANYA HIJAU DAN MERAH
        if (wordStatus != null) {
          switch (wordStatus) {
            case WordStatus.matched:
              wordBg = correctColor.withOpacity(0.4); // ðŸŸ© HIJAU - BENAR
              if (controller.isRecording &&
                  segment.ayahNumber == controller.currentAyatNumber) {
                print(
                  '   âœ… SET COLOR: Hijau (matched) untuk word $wordIndex',
                );
              }
              break;
            case WordStatus.mismatched:
            case WordStatus.skipped:
              wordBg = errorColor.withOpacity(0.4); // ðŸŸ¥ MERAH - SALAH
              if (controller.isRecording &&
                  segment.ayahNumber == controller.currentAyatNumber) {
                print('   âŒ SET COLOR: Merah (salah) untuk word $wordIndex');
              }
              break;
            case WordStatus.processing:
            case WordStatus.pending:
            default:
              wordBg = Colors.transparent; // Tidak ada warna
              break;
          }
        }

if (controller.hideUnreadAyat && !isCurrentAyat) {
  final isLastWordInAyah = segment.isEndOfAyah && 
                           i == (segment.words.length - 1); // ✅ FIX: cek akhir ayat
  wordOpacity = (hasArabicNumber || isLastWordInAyah) ? 1.0 : 0.0;
}
        final segments = controller.segmentText(word.text);
        for (final textSegment in segments) {
          spans.add(
            TextSpan(
              text: textSegment.text,
              style: TextStyle(
                fontSize: baseFontSize,
                fontFamily: fontFamily,
                color: _getWordColor(isCurrentAyat).withOpacity(wordOpacity),
                backgroundColor: wordBg,
                fontWeight: FontWeight.w400,
              ),
            ),
            
          );
        }
      }
    }

    return MushafRenderer.renderJustifiedLine(
      wordSpans: spans,
      isCentered: line.isCentered,
      availableWidth: MediaQuery.of(context).size.width,
      context: context,
      allowOverflow: false,
    );
  }

  // Methods tetap sama
  Color _getWordColor(bool isCurrentWord) {
    return isCurrentWord ? listeningColor : Colors.black87;
  }
}

class MushafPageHeader extends StatelessWidget {
  const MushafPageHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final headerFontSize = screenWidth * 0.035;
    final headerHeight = screenHeight * 0.035;

    final controller = context.watch<SttController>();
    final juzNumber = controller.currentPageAyats.isNotEmpty
        ? controller.calculateJuz(
            controller.currentPageAyats.first.surah_id,
            controller.currentPageAyats.first.ayah,
          )
        : 1;

    return Container(
      height: headerHeight,
      color: Colors.white, // ✅ ADD: Background to blend when hidden
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Juz $juzNumber',
            style: TextStyle(
              fontSize: headerFontSize,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
            textDirection: TextDirection.rtl,
          ),
          // const SizedBox(width: 3),
          // Container(
          //   width: 1,
          //   height: screenHeight * 0.016,
          //   color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.3),
          // ),
          // Text(
          //   'Al-Ikhlas',
          //   style: TextStyle(
          //     fontSize: headerFontSize * 90 / 100,
          //     color: Colors.grey.shade700,
          //     fontWeight: FontWeight.w500,
          //   ),
          //   textDirection: TextDirection.rtl,
          // ),
          // Container(
          //   width: 1,
          //   height: screenHeight * 0.016,
          //   color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.3),
          // ),
          // Text(
          //   'Al-Falaq',
          //   style: TextStyle(
          //     fontSize: headerFontSize * 90 / 100,
          //     color: Colors.grey.shade700,
          //     fontWeight: FontWeight.w500,
          //   ),
          //   textDirection: TextDirection.rtl,
          // ),
          // Container(
          //   width: 1,
          //   height: screenHeight * 0.016,
          //   color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.3),
          // ),
          // Text(
          //   'An-Nas',
          //   style: TextStyle(
          //     fontSize: headerFontSize * 90 / 100,
          //     color: Colors.grey.shade700,
          //     fontWeight: FontWeight.w500,
          //   ),
          //   textDirection: TextDirection.rtl,
          // ),
          // Container(
          //   width: 1,
          //   height: screenHeight * 0.016,
          //   color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.3),
          // ),
          // const SizedBox(width: 3),
          Text(
            '${controller.currentPage}',
            style: TextStyle(
              fontSize: headerFontSize,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
