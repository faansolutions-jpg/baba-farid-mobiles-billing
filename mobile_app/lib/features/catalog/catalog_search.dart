// Accessories Master Catalog — fuzzy + Roman-Urdu search helper.
//
// Pure Dart (no Flutter imports). Shopkeepers type fast Roman Urdu, so
// search must tolerate the usual misspellings: "type c cabel" must find
// a Type-C cable, "carger" must find chargers, "glas" must find glass.
//
// How it works:
//  1. [normalizeQuery] lowercases the query, splits it into tokens and
//     rewrites each token through [romanUrduSynonyms], then strips every
//     space / hyphen / underscore so "type-c" and "type c" compare equal.
//  2. [searchCatalog] scores every item: an exact token match scores
//     highest, a substring match lower, a prefix match lower still.
//     Exact-token matches come first; ties keep catalogue order.
//  3. Matching runs over name_en, name_ur, brand, category, sku and
//     model_compatibility. Urdu names are matched on the raw (unnormalised)
//     text as well, so an Urdu query still works.
import 'catalog_models.dart';

/// Common Roman-Urdu / phonetic misspellings -> correct English word.
const Map<String, String> romanUrduSynonyms = {
  'cabel': 'cable',
  'cablee': 'cable',
  'carger': 'charger',
  'chargr': 'charger',
  'charger': 'charger',
  'glas': 'glass',
  'glaas': 'glass',
  'kover': 'cover',
  'covar': 'cover',
  'hansfree': 'handsfree',
  'handfree': 'handsfree',
  'hansfri': 'handsfree',
  'airbuds': 'earbuds',
  'airbud': 'earbud',
  'earbud': 'earbuds',
  'pawar': 'power',
  'powar': 'power',
  'bank': 'bank',
  'battry': 'battery',
  'batry': 'battery',
  'btry': 'battery',
  'watch': 'watch',
  'ghari': 'watch',
  'gharri': 'watch',
  'spekar': 'speaker',
  'speker': 'speaker',
  'wirles': 'wireless',
  'wireles': 'wireless',
  'blutooth': 'bluetooth',
  'bluetooth': 'bluetooth',
  'temprd': 'tempered',
  'temprad': 'tempered',
  'protactor': 'protector',
  'protecter': 'protector',
  'selicone': 'silicone',
  'silicon': 'silicone',
  'lether': 'leather',
  'back': 'back',
  'bak': 'back',
  'hedphone': 'headphone',
  'hedphones': 'headphones',
  'hedfone': 'headphone',
  'nekband': 'neckband',
  'neckbend': 'neckband',
  'holder': 'holder',
  'holdar': 'holder',
  'tripod': 'tripod',
  'selfi': 'selfie',
  'selfee': 'selfie',
  'stik': 'stick',
  'ringlite': 'ringlight',
  'memry': 'memory',
  'memori': 'memory',
  'card': 'card',
  'adaptor': 'adapter',
  'adpter': 'adapter',
  'otg': 'otg',
  'carcharger': 'carcharger',
  'car': 'car',
  'fast': 'fast',
  'faster': 'faster',
};

/// Normalise one token: lowercase, apply the synonym map, then strip
/// every character that is not a letter or digit.
String _normalizeToken(String token) {
  var t = token.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  return romanUrduSynonyms[t] ?? t;
}

/// Normalise a whole query to space-separated normalised tokens.
/// "Type C Cabel" -> "type c cable". Returns '' for an empty query.
String normalizeQuery(String query) {
  return query
      .split(RegExp(r'\s+'))
      .map(_normalizeToken)
      .where((t) => t.isNotEmpty)
      .join(' ');
}

/// Tokens of a piece of text, normalised the same way as the query.
List<String> _textTokens(String text) {
  return text
      .split(RegExp(r'[\s\-_]+'))
      .map(_normalizeToken)
      .where((t) => t.isNotEmpty)
      .toList();
}

/// The searchable text of an item, with spaces/hyphens stripped so a
/// query token can match across them ("typec" matches "Type-C").
String _compactHaystack(CatalogItem item) {
  final parts = [
    item.nameEn,
    item.brand,
    item.category,
    item.sku,
    item.modelCompatibility ?? '',
    ...item.variants,
    ...item.colors,
  ];
  return parts
      .join(' ')
      .toLowerCase()
      .replaceAll(RegExp(r'[\s\-_]+'), '');
}

/// Raw (unnormalised) searchable text, for Urdu substring matching.
String _rawHaystack(CatalogItem item) {
  return [
    item.nameEn,
    item.nameUr,
    item.brand,
    item.category,
    item.sku,
    item.modelCompatibility ?? '',
  ].join(' ').toLowerCase();
}

int _scoreItem(CatalogItem item, List<String> queryTokens, String rawQuery) {
  final tokens = _textTokens([
    item.nameEn,
    item.brand,
    item.category,
    item.sku,
    item.modelCompatibility ?? '',
    ...item.variants,
  ].join(' '));
  final tokenSet = tokens.toSet();
  final compact = _compactHaystack(item);
  var score = 0;
  for (final q in queryTokens) {
    if (tokenSet.contains(q)) {
      score += 10; // exact token match
    } else if (compact.contains(q)) {
      score += 5; // substring match (covers "type c" -> "type-c")
    } else if (tokens.any((t) => t.startsWith(q))) {
      score += 2; // prefix match (user typed a partial word)
      // NOTE: do NOT match `q.startsWith(t)` (query starts with an item
      // token). That made an exact SKU query like
      // 'ACC-CAB-ANK-TC10-002' match every item whose tokens include a
      // short prefix ('acc', 'cab', 'ank'), returning 5 rows for 1 SKU.
    } else {
      return 0; // every query token must match something (AND semantics)
    }
  }
  // Bonus: the whole query as one phrase in the compact text.
  final compactQuery = queryTokens.join('');
  if (compactQuery.isNotEmpty && compact.contains(compactQuery)) score += 3;
  // Bonus: exact phrase in the raw text (Urdu queries).
  if (rawQuery.isNotEmpty && _rawHaystack(item).contains(rawQuery)) score += 4;
  return score;
}

/// Fuzzy + Roman-Urdu search over a list of catalog items.
///
/// Returns matching items ranked best-first (exact token matches first).
/// An empty query returns the input list unchanged. Matching is AND over
/// query tokens: every token must match the item somewhere.
List<CatalogItem> searchCatalog(List<CatalogItem> items, String query) {
  final trimmed = query.trim();
  if (trimmed.isEmpty) return List<CatalogItem>.from(items);
  final normalized = normalizeQuery(trimmed);
  if (normalized.isEmpty) return List<CatalogItem>.from(items);
  final queryTokens = normalized.split(' ');
  final rawQuery = trimmed.toLowerCase();
  final scored = <_ScoredItem>[];
  for (var i = 0; i < items.length; i++) {
    final score = _scoreItem(items[i], queryTokens, rawQuery);
    if (score > 0) scored.add(_ScoredItem(items[i], score, i));
  }
  scored.sort((a, b) {
    final byScore = b.score.compareTo(a.score);
    if (byScore != 0) return byScore;
    return a.index.compareTo(b.index);
  });
  return scored.map((s) => s.item).toList();
}

class _ScoredItem {
  final CatalogItem item;
  final int score;
  final int index;

  _ScoredItem(this.item, this.score, this.index);
}
