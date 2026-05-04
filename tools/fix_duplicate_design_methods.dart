import 'dart:io';

void main() {
  const path = 'lib/features/planner/ui/widgets/mobile_bed_designer_strict.dart';

  final file = File(path);
  var text = file.readAsStringSync();

  const methods = [
    '_slotCapacityForPlant',
    '_usedSlotCountForPlant',
    '_autoFillSelectedBed',
    '_clearActivePlantFromBed',
  ];

  for (final method in methods) {
    text = removeDuplicateMethods(text, method);
  }

  file.writeAsStringSync(text);
}

String removeDuplicateMethods(String text, String methodName) {
  while (true) {
    final starts = methodStarts(text, methodName);

    if (starts.length <= 1) {
      return text;
    }

    final duplicateStart = starts[1];
    final openBrace = text.indexOf('{', duplicateStart);

    if (openBrace == -1) {
      return text;
    }

    final closeBrace = findMatchingBrace(text, openBrace);

    if (closeBrace == -1) {
      return text;
    }

    var end = closeBrace + 1;

    while (end < text.length) {
      final code = text.codeUnitAt(end);

      if (code == 10 || code == 13 || code == 32 || code == 9) {
        end++;
      } else {
        break;
      }
    }

    text = text.replaceRange(duplicateStart, end, '');
  }
}

List<int> methodStarts(String text, String methodName) {
  final escaped = RegExp.escape(methodName);

  final regex = RegExp(
    r'(?m)^  (?:int|void)\s+' + escaped + r'\s*\(',
  );

  return regex.allMatches(text).map((match) => match.start).toList();
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
      if (char == '\n') {
        inLineComment = false;
      }
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
