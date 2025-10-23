// lib\screens\main\stt\widgets\mushaf_view.dart

import 'package:cuda_qurani/models/quran_models.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/stt_controller.dart';
import '../data/models.dart';
import '../services/quran_service.dart';
import '../utils/constants.dart';

class MushafRenderer {
  static const double PAGE_HEIGHT = 750.0; // Total page height
  static const double PAGE_PADDING = 0.0; // Minimal side padding
  static const double WORD_SPACING_MIN = 0.0; // Minimum gap between words
  static const double WORD_SPACING_MAX =
      0.0; // Maximum gap to prevent huge spaces
  static const double LINE_HEIGHT = 46.0; // Line height

  // Render justified text for ayah lines
  static Widget renderJustifiedLine({
    required List<InlineSpan> wordSpans,
    required bool isCentered,
    required double availableWidth,
    required BuildContext context,
    bool allowOverflow = false,
  }) {
    if (wordSpans.isEmpty) return const SizedBox.shrink();

    // For centered lines (surah names, basmallah)
    if (isCentered) {
      return SizedBox(
        height: LINE_HEIGHT,
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

    // For justified ayah lines
    return SizedBox(
      height: LINE_HEIGHT,
      width: availableWidth,
      child: _buildJustifiedText(
        wordSpans: wordSpans,
        maxWidth: availableWidth,
        allowOverflow: allowOverflow,
      ),
    );
  }

  static Widget _buildJustifiedText({
    required List<InlineSpan> wordSpans,
    required double maxWidth,
    bool allowOverflow = false,
  }) {
    if (wordSpans.isEmpty) return const SizedBox.shrink();

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
      height: LINE_HEIGHT,
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

    // FAST PATH: If page is cached, render immediately
    if (cachedLines != null && cachedLines.isNotEmpty) {
      return MushafPageContent(pageLines: cachedLines, pageNumber: pageNumber);
    }

    // SLOW PATH: Load from database with minimal loading indicator
    return FutureBuilder<List<MushafPageLine>>(
      key: ValueKey('page_$pageNumber'), // Force rebuild on page change
      future: context.read<QuranService>().getMushafPageLines(pageNumber),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Ultra-minimal loading indicator
          return SizedBox(
            height: MushafRenderer.PAGE_HEIGHT,
            child: Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.grey.shade300,
                  ),
                ),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return SizedBox(
            height: MushafRenderer.PAGE_HEIGHT,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.grey.shade400,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Error loading page $pageNumber',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return SizedBox(
            height: MushafRenderer.PAGE_HEIGHT,
            child: Center(
              child: Text(
                'No data for page $pageNumber',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ),
          );
        }

        final pageLines = snapshot.data!;

        // Update cache asynchronously after frame renders
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            controller.updatePageCache(pageNumber, pageLines);
          }
        });

        return MushafPageContent(pageLines: pageLines, pageNumber: pageNumber);
      },
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
    return Container(
      height: MushafRenderer.PAGE_HEIGHT,
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Column(
        children: [
          const MushafPageHeader(),
          const SizedBox(height: 0),
          Expanded(child: Column(children: _buildPageLines())),
        ],
      ),
    );
  }

  List<Widget> _buildPageLines() {
    List<Widget> widgets = pageLines
        .map((line) => _buildMushafLine(line))
        .toList();
    while (widgets.length < 15) {
      widgets.add(const SizedBox(height: MushafRenderer.LINE_HEIGHT));
    }
    return widgets;
  }

  Widget _buildMushafLine(MushafPageLine line) {
    switch (line.lineType) {
      case 'surah_name':
        return _SurahNameLine(line: line);
      case 'basmallah':
        return _BasmallahLine();
      case 'ayah':
        return _JustifiedAyahLine(
          line: line,
          pageNumber: pageNumber,
        ); // TAMBAH pageNumber
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
    final controller = context.read<SttController>();
    final surahGlyphCode = line.surahNumber != null
        ? controller.formatSurahIdForGlyph(line.surahNumber!)
        : '';
    return Container(
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Text(
            'header',
            style: TextStyle(
              fontSize: 52,
              fontFamily: 'Quran-Common',
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            surahGlyphCode,
            style: const TextStyle(
              fontSize: 42,
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
    return Container(
      height: MushafRenderer.LINE_HEIGHT,
      alignment: Alignment.center,
      child: const Text(
        '﷽',
        style: TextStyle(
          fontSize: 34,
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
    if (line.ayahSegments == null || line.ayahSegments!.isEmpty) {
      return const SizedBox(height: MushafRenderer.LINE_HEIGHT);
    }
    final controller = context.watch<SttController>();
    List<InlineSpan> spans = [];

    // Font family berdasarkan mode
    final fontFamily = controller.isQuranMode ? 'p$pageNumber' : 'UthmanTN';

for (final segment in line.ayahSegments!) {
  final ayatIndex = controller.ayatList.indexWhere(
    (a) => a.surah_id == segment.surahId && a.ayah == segment.ayahNumber,
  );
  final isCurrentAyat = ayatIndex >= 0 && ayatIndex == controller.currentAyatIndex;
  
  for (int i = 0; i < segment.words.length; i++) {
    final word = segment.words[i];
    
    // ✅ FIX: Use wordNumber - 1 as index (wordNumber is 1-indexed, backend uses 0-indexed)
    final wordIndex = word.wordNumber - 1;
    
    // Get word status dari wordStatusMap
    final wordStatus = controller.wordStatusMap[segment.ayahNumber]?[wordIndex];
    
    // 🔥 DEBUG: Print word status dan warna yang akan diapply
    if (controller.isRecording && segment.ayahNumber == controller.currentAyatNumber) {
      print('🎨 UI RENDER: Ayah ${segment.ayahNumber}, Word[$wordIndex] (loop $i) = $wordStatus');
      print('   📊 Full wordStatusMap[${segment.ayahNumber}] = ${controller.wordStatusMap[segment.ayahNumber]}');
    }
    
    final wordSegments = controller.segmentText(word.text);
    final hasArabicNumber = wordSegments.any((s) => s.isArabicNumber);

    double wordOpacity = 1.0;
    Color wordBg = Colors.transparent;
    
    // Background color based on word status - HANYA HIJAU DAN MERAH
    if (wordStatus != null) {
      switch (wordStatus) {
        case WordStatus.matched:
          wordBg = correctColor.withOpacity(0.4);  // 🟩 HIJAU - BENAR
          if (controller.isRecording && segment.ayahNumber == controller.currentAyatNumber) {
            print('   ✅ SET COLOR: Hijau (matched) untuk word $wordIndex');
          }
          break;
        case WordStatus.mismatched:
        case WordStatus.skipped:
          wordBg = errorColor.withOpacity(0.4);  // 🟥 MERAH - SALAH
          if (controller.isRecording && segment.ayahNumber == controller.currentAyatNumber) {
            print('   ❌ SET COLOR: Merah (salah) untuk word $wordIndex');
          }
          break;
        case WordStatus.processing:
        case WordStatus.pending:
        default:
          wordBg = Colors.transparent;  // Tidak ada warna
          break;
      }
    }
    
    if (controller.hideUnreadAyat && !isCurrentAyat) {
      wordOpacity = hasArabicNumber ? 1.0 : 0.0;
    }

    final segments = controller.segmentText(word.text);
    for (final textSegment in segments) {
      spans.add(
        TextSpan(
          text: textSegment.text,
          style: TextStyle(
            fontSize: 26.0,
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
    final controller = context.watch<SttController>();
    final juzNumber = controller.currentPageAyats.isNotEmpty
        ? controller.calculateJuz(
            controller.currentPageAyats.first.surah_id,
            controller.currentPageAyats.first.ayah,
          )
        : 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Juz $juzNumber',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
          textDirection: TextDirection.rtl,
        ),
        Text(
          '${controller.currentPage}',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
