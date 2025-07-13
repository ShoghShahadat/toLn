// lib/src/cli/assistant.dart

import 'dart:math';

/// A utility class that provides smart assistance, like detecting typos.
class Assistant {
  /// Calculates the Levenshtein distance between two strings.
  ///
  /// Levenshtein distance is a measure of the difference between two sequences.
  /// It's the minimum number of single-character edits (insertions, deletions,
  /// or substitutions) required to change one word into the other.
  static int _calculateLevenshteinDistance(String a, String b) {
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;

    final List<int> v0 = List<int>.generate(b.length + 1, (i) => i);
    List<int> v1 = List<int>.filled(b.length + 1, 0);

    for (int i = 0; i < a.length; i++) {
      v1[0] = i + 1;
      for (int j = 0; j < b.length; j++) {
        int cost = (a[i] == b[j]) ? 0 : 1;
        v1[j + 1] = min(v1[j] + 1, min(v0[j + 1] + 1, v0[j] + cost));
      }
      for (int j = 0; j <= b.length; j++) {
        v0[j] = v1[j];
      }
    }
    return v1[b.length];
  }

  /// Calculates the similarity percentage between two strings based on their
  /// Levenshtein distance. 100% means identical.
  static double calculateSimilarity(String a, String b) {
    final double maxLength = max(a.length, b.length).toDouble();
    if (maxLength == 0) return 100.0;

    final distance = _calculateLevenshteinDistance(a, b);
    return (1.0 - distance / maxLength) * 100.0;
  }

  /// Finds the most similar existing text for a new text from a map of known texts.
  ///
  /// Returns a record containing the similar text and its key if a similarity
  /// above the [threshold] is found, otherwise returns null.
  static ({String text, String key})? findSimilarText({
    required String newText,
    required Map<String, String> existingKeyMap, // normalized_text -> key
    double threshold = 80.0, // Similarity threshold in percent
  }) {
    String? bestMatchText;
    double maxSimilarity = 0.0;

    for (final existingText in existingKeyMap.keys) {
      final similarity = calculateSimilarity(newText, existingText);
      if (similarity > maxSimilarity) {
        maxSimilarity = similarity;
        bestMatchText = existingText;
      }
    }

    if (maxSimilarity >= threshold && bestMatchText != null) {
      return (text: bestMatchText, key: existingKeyMap[bestMatchText]!);
    }

    return null;
  }
}
