import 'dart:io';

void main() {
  const path = 'lib/features/planner/ui/widgets/mobile_bed_designer_strict.dart';

  final file = File(path);
  var text = file.readAsStringSync().replaceAll('\r\n', '\n');

  text = removeOrphanParameterBlocks(text);

  const methods = [
    '_candidateSlotsForPlant',
    '_slotCapacityForPlant',
    '_usedSlotCountForPlant',
    '_spacingConflictCount',
    '_addSlotsToBed',
    '_autoFillSelectedBed',
    '_fillBorderWithSelectedPlant',
    '_fillCenterRowWithSelectedPlant',
    '_clearActivePlantFromBed',
    '_openDesignStudio',
  ];

  for (final method in methods) {
    text = removeDuplicateMethods(text, method);
  }

  file.writeAsStringSync(text);
}

String removeOrphanParameterBlocks(String text) {
  final orphanBlockPattern = RegExp(r'(?m)^[ \t]*\)\s*\{\s*$');

  while (true) {
    final matches = orphanBlockPattern.allMatches(text).toList();
    var removed = false;

    for (final match in matches) {
      final blockStartLineStart = text.lastIndexOf('\n', match.start) + 1;
      final chunkStart = text.lastIndexOf('\n\n', match.start);
      final signatureStart = chunkStart == -1 ? 0 : chunkStart + 2;
      final chunk = text.substring(signatureStart, match.start);

      final hasMethodName = RegExp(
        r'(?:int|void|String|bool|double|List<[^>]+>|Future<[^>]+>)\s+[_A-Za-z][_A-Za-z0-9]*\s*\(',
      ).hasMatch(chunk);

      final looksLikeDanglingParams =
          chunk.contains('required Bed bed') ||
          chunk.contains('required String cropName') ||
          chunk.contains('required Iterable<Offset> slots');

      if (hasMethodName || !looksLikeDanglingParams) {
        continue;
      }

      final openBrace = text.indexOf('{', match.start);
      if (openBrace == -1) continue;

      final closeBrace = findMatchingBrace(text, openBrace);
      if (closeBrace == -1) continue;

      var end = closeBrace + 1;
      while (end < text.length && isWhitespace(text.codeUnitAt(end))) {
        end++;
      }

      text = text.replaceRange(signatureStart, end, '');
      removed = true;
      break;
    }

    if (!removed) return text;
  }
}

String removeDuplicateMethods(String text, String methodName) {
  while (true) {
    final starts = methodStarts(text, methodName);

    if (starts.length <= 1) {
      return text;
    }

    final duplicateStart = starts[1];
    final openBrace = text.indexOf('{', duplicateStart);
    if (openBrace == -1) return text;

    final closeBrace = findMatchingBrace(text, openBrace);
    if (closeBrace == -1) return text;

    var start = duplicateStart;
    while (start > 0 && text.codeUnitAt(start - 1) != 10) {
      start--;
    }

    var end = closeBrace + 1;
    while (end < text.length && isWhitespace(text.codeUnitAt(end))) {
      end++;
    }

    text = text.replaceRange(start, end, '');
  }
}

List<int> methodStarts(String text, String methodName) {
  final escaped = RegExp.escape(methodName);

  final regex = RegExp(
    r'(?m)^  (?:int|void|String|bool|double|List<[^>]+>|Future<[^>]+>)\s+' +
        escaped +
        r'\s*\(',
  );

  return regex.allMatches(text).map((match) => match.start).toList();
}

bool isWhitespace(int code) {
  return code == 10 || code == 13 || code == 32 || code == 9;
}

int findMatchingBrace(String text, int openBrace) {
  var depth = 0;
  var inLineComment = false;
  var inBlockComment = false;
  String? quote;
  var escaped = false;

  for (var i = openBrace; i < text.length; i++) {
    final char = text[i];
    final next = i + 1 < text.length ? text[i + 1] : '';

    if (inLineComment) {
      if (char == '\n') inLineComment = false;
      continue;
    }

    if (inBlockComment) {
      if (char == '*' && next == '/') {
        inBlockComment = false;
        i++;
      }
      continue;
    }

    if (quote != null) {
      if (escaped) {
        escaped = false;
        continue;
      }

      if (char == r'\') {
        escaped = true;
        continue;
      }

      if (char == quote) {
        quote = null;
      }

      continue;
    }

    if (char == '/' && next == '/') {
      inLineComment = true;
      i++;
      continue;
    }

    if (char == '/' && next == '*') {
      inBlockComment = true;
      i++;
      continue;
    }

    if (char == "'" || char == '"') {
      quote = char;
      continue;
    }

    if (char == '{') {
      depth++;
    } else if (char == '}') {
      depth--;

      if (depth == 0) {
        return i;
      }
    }
  }

  return -1;
}
