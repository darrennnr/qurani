// lib\screens\main\stt\widgets\list_view.dart

import 'package:cuda_qurani/models/quran_models.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/stt_controller.dart';
import '../data/models.dart';
import '../utils/constants.dart';

class QuranListView extends StatelessWidget {
  const QuranListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SttController>();

    return ListView.builder(
      controller: controller.scrollController,
      itemCount:
          controller.ayatList.length + 2, // +2 untuk header dan basmallah
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: true,
      cacheExtent: 500,
      itemBuilder: (context, index) {
        // Header
        if (index == 0) {
          return _buildVerticalModeHeader(context, controller);
        }

        // Basmallah
        if (index == 1) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(0, 3, 0, 0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              child: const Text(
                '﷽',
                style: TextStyle(
                  fontSize: 43,
                  fontFamily: 'Quran-Common',
                  fontWeight: FontWeight.normal,
                  height: 0.8,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        // Ayat items
        final ayatIndex = index - 2;
        return _OptimizedAyatItem(
          ayatIndex: ayatIndex,
          key: ValueKey('ayat_$ayatIndex'),
        );
      },
    );
  }

  Widget _buildVerticalModeHeader(
    BuildContext context,
    SttController controller,
  ) {
    if (controller.suratId <= 0) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            'header',
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width * 0.12,
              fontFamily: 'Quran-Common',
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            controller.formatSurahIdForGlyph(controller.suratId),
            style: const TextStyle(
              fontSize: 40,
              fontFamily: 'surah-name-v2',
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _OptimizedAyatItem extends StatelessWidget {
  final int ayatIndex;

  const _OptimizedAyatItem({required this.ayatIndex, Key? key})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Selector<SttController, _AyatData>(
        selector: (_, controller) => _AyatData(
          ayat: controller.ayatList[ayatIndex],
          isCurrentAyat: controller.currentAyatIndex == ayatIndex,
          hideUnread: controller.hideUnreadAyat,
        ),
        shouldRebuild: (prev, next) =>
            prev.isCurrentAyat != next.isCurrentAyat ||
            prev.hideUnread != next.hideUnread,
        builder: (context, data, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _AyatHeader(
                ayatIndex: ayatIndex,
                isCurrentAyat: data.isCurrentAyat,
              ),
              _ColoredAyatText(
                ayat: data.ayat,
                ayatIndex: ayatIndex,
                isCurrentAyat: data.isCurrentAyat,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AyatData {
  final dynamic ayat;
  final bool isCurrentAyat;
  final bool hideUnread;

  _AyatData({
    required this.ayat,
    required this.isCurrentAyat,
    required this.hideUnread,
  });
}

class _AyatHeader extends StatelessWidget {
  final int ayatIndex;
  final bool isCurrentAyat;

  const _AyatHeader({
    Key? key,
    required this.ayatIndex,
    required this.isCurrentAyat,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = context.read<SttController>();
    final progress = controller.ayatProgress[ayatIndex];
    final completionPercentage = progress?.completionPercentage ?? 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: completionPercentage / 100,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isCurrentAyat ? primaryColor : correctColor,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isCurrentAyat ? primaryColor : Colors.grey.shade400,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${controller.ayatList[ayatIndex].ayah}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ColoredAyatText extends StatelessWidget {
  final AyatData ayat;
  final int ayatIndex;
  final bool isCurrentAyat;

  const _ColoredAyatText({
    Key? key,
    required this.ayat,
    required this.ayatIndex,
    required this.isCurrentAyat,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.start,
      textDirection: TextDirection.rtl,
      spacing: 0,
      runSpacing: 8,
      children: ayat.words.asMap().entries.map((entry) {
        final wordData = entry.value;

        return _WordWidget(word: wordData.text, isCurrentAyat: isCurrentAyat);
      }).toList(),
    );
  }
}

class _WordWidget extends StatelessWidget {
  final String word;
  final bool isCurrentAyat;

  const _WordWidget({required this.word, required this.isCurrentAyat});

  @override
  Widget build(BuildContext context) {
    final controller = context.read<SttController>();
    final segments = controller.segmentText(word);

    double wordOpacity = 1.0;
    if (controller.hideUnreadAyat && !isCurrentAyat) {
      final hasArabicNumber = segments.any((s) => s.isArabicNumber);
      wordOpacity = hasArabicNumber ? 1.0 : 0.0;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: isCurrentAyat
            ? listeningColor.withOpacity(0.15)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: wordOpacity,
        child: _buildSegmentedText(word, isCurrentAyat, controller),
      ),
    );
  }

Widget _buildSegmentedText(
  String text,
  bool isCurrentAyat,
  SttController controller,
) {
  final segments = controller.segmentText(text);
  
  // Get word index dari ayat list
  final ayatIndex = controller.ayatList.indexWhere((a) => 
    a.ayah == controller.ayatList[controller.currentAyatIndex].ayah
  );
  
  if (ayatIndex < 0) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 30,
        fontFamily: 'UthmanTN',
        color: isCurrentAyat ? listeningColor : Colors.black87,
      ),
      textDirection: TextDirection.rtl,
    );
  }
  
  final ayat = controller.ayatList[ayatIndex];
  final wordIndex = ayat.words.indexWhere((w) => w.text == text);
  
  // Get word status dari wordStatusMap
  final wordStatus = controller.wordStatusMap[ayat.ayah]?[wordIndex];
  
  Color wordBg = Colors.transparent;
  if (wordStatus != null) {
    switch (wordStatus) {
      case WordStatus.matched:
        wordBg = correctColor.withOpacity(0.4);
        break;
      case WordStatus.mismatched:
        wordBg = errorColor.withOpacity(0.4);
        break;
      case WordStatus.processing:
        wordBg = listeningColor.withOpacity(0.5);
        break;
      case WordStatus.skipped:
        wordBg = errorColor.withOpacity(0.5);
        break;
      default:
        break;
    }
  }

  if (segments.length == 1 && !segments.first.isArabicNumber) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 30,
        fontFamily: 'UthmanTN',
        color: isCurrentAyat ? listeningColor : Colors.black87,
        backgroundColor: wordBg,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      textDirection: TextDirection.rtl,
    );
  }

  List<TextSpan> spans = [];
  for (final segment in segments) {
    spans.add(
      TextSpan(
        text: segment.text,
        style: TextStyle(
          fontSize: 26,
          fontFamily: segment.isArabicNumber
              ? 'KFGQPCUthmanicScriptHAFSRegular'
              : 'UthmanTN',
          color: isCurrentAyat ? listeningColor : Colors.black87,
          backgroundColor: wordBg,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
      ),
    );
    if (segment != segments.last) {
      spans.add(TextSpan(text: ' ', style: TextStyle(fontSize: 26)));
    }
  }

  return RichText(
    text: TextSpan(children: spans),
    textDirection: TextDirection.rtl,
  );
}
}
