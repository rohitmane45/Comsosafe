import 'dart:math' as math;

import 'ingredient_database.dart';

/// Result of matching a single token from OCR text to the database.
class MatchedIngredient {
  final String rawToken;
  final IngredientEntry entry;
  final double confidence; // 0.0 – 1.0

  const MatchedIngredient({
    required this.rawToken,
    required this.entry,
    required this.confidence,
  });
}

/// Matches extracted ingredient text against [IngredientDatabase].
class IngredientMatcher {
  IngredientMatcher._();

  /// Parse raw OCR text into individual ingredient tokens.
  static List<String> tokenize(String rawText) {
    // Normalize whitespace, strip junk
    var text = rawText
        .replaceAll(RegExp(r'[\r\n]+'), ', ')
        .replaceAll(RegExp(r'[•·–—]'), ',')
        .replaceAll(RegExp(r'\s{2,}'), ' ')
        .replaceAll(RegExp(r'\bingredients?\s*:?\s*', caseSensitive: false), '')
        .trim();

    // Split by comma, slash, semicolon
    final tokens = text
        .split(RegExp(r'[,;/]+'))
        .map((t) => t.trim())
        .where((t) => t.length >= 2)
        .toList();

    return tokens;
  }

  /// Match all tokens and return ingredient matches.
  static List<MatchedIngredient> matchAll(String rawText) {
    final tokens = tokenize(rawText);
    final results = <MatchedIngredient>[];
    final seen = <String>{};

    for (final token in tokens) {
      final match = _matchSingle(token);
      if (match != null && !seen.contains(match.entry.name.toLowerCase())) {
        results.add(match);
        seen.add(match.entry.name.toLowerCase());
      }
    }

    return results;
  }

  /// Try to match a single token. Returns null if no match found.
  static MatchedIngredient? _matchSingle(String token) {
    final normalized = token.toLowerCase().trim();
    if (normalized.isEmpty) return null;

    // 1) Exact match
    final exact = IngredientDatabase.findExact(normalized);
    if (exact != null) {
      return MatchedIngredient(
        rawToken: token,
        entry: exact,
        confidence: 1.0,
      );
    }

    // 2) Substring / contains match — check if any DB name is contained in token
    //    or token is contained in a DB name
    for (final entry in IngredientDatabase.all) {
      final entryLower = entry.name.toLowerCase();
      if (normalized.contains(entryLower) || entryLower.contains(normalized)) {
        final longer = math.max(normalized.length, entryLower.length);
        final shorter = math.min(normalized.length, entryLower.length);
        final conf = shorter / longer;
        if (conf >= 0.5) {
          return MatchedIngredient(
            rawToken: token,
            entry: entry,
            confidence: conf.clamp(0.6, 0.95),
          );
        }
      }

      // Also check aliases
      for (final alias in entry.aliases) {
        final aliasLower = alias.toLowerCase();
        if (normalized.contains(aliasLower) ||
            aliasLower.contains(normalized)) {
          final longer = math.max(normalized.length, aliasLower.length);
          final shorter = math.min(normalized.length, aliasLower.length);
          final conf = shorter / longer;
          if (conf >= 0.5) {
            return MatchedIngredient(
              rawToken: token,
              entry: entry,
              confidence: conf.clamp(0.6, 0.92),
            );
          }
        }
      }
    }

    // 3) Levenshtein distance for fuzzy matching
    MatchedIngredient? best;
    double bestScore = 0;

    for (final entry in IngredientDatabase.all) {
      final score = _levenshteinSimilarity(normalized, entry.name.toLowerCase());
      if (score > bestScore && score >= 0.70) {
        bestScore = score;
        best = MatchedIngredient(
          rawToken: token,
          entry: entry,
          confidence: score,
        );
      }

      // Check aliases too
      for (final alias in entry.aliases) {
        final aliasScore =
            _levenshteinSimilarity(normalized, alias.toLowerCase());
        if (aliasScore > bestScore && aliasScore >= 0.70) {
          bestScore = aliasScore;
          best = MatchedIngredient(
            rawToken: token,
            entry: entry,
            confidence: aliasScore,
          );
        }
      }
    }

    return best;
  }

  /// Returns similarity ratio based on Levenshtein distance (0.0 – 1.0).
  static double _levenshteinSimilarity(String a, String b) {
    if (a == b) return 1.0;
    if (a.isEmpty || b.isEmpty) return 0.0;

    final maxLen = math.max(a.length, b.length);
    final dist = _levenshteinDistance(a, b);
    return 1.0 - (dist / maxLen);
  }

  static int _levenshteinDistance(String a, String b) {
    final m = a.length;
    final n = b.length;
    final dp = List.generate(m + 1, (_) => List.filled(n + 1, 0));

    for (var i = 0; i <= m; i++) {
      dp[i][0] = i;
    }
    for (var j = 0; j <= n; j++) {
      dp[0][j] = j;
    }

    for (var i = 1; i <= m; i++) {
      for (var j = 1; j <= n; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        dp[i][j] = [
          dp[i - 1][j] + 1,
          dp[i][j - 1] + 1,
          dp[i - 1][j - 1] + cost,
        ].reduce(math.min);
      }
    }

    return dp[m][n];
  }
}
