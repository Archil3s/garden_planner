import 'crop_spacing.dart';
import 'seed_catalog.dart';
import '../plant_icons/generated_plant_svgs.dart';

class PlantVarietyCatalog {
  const PlantVarietyCatalog._();

  static List<PlantTypeGroup> groupsForCrop(String cropName) {
    final name = _normalize(cropName);

    final curated = _curatedGroups
        .where((group) => group.matches(name))
        .toList();

    if (curated.isNotEmpty) {
      return curated;
    }

    final dynamic = _dynamicGroupForCrop(cropName);
    if (dynamic == null) return const <PlantTypeGroup>[];

    return [dynamic];
  }

  static PlantTypeGroup? bestGroupForCrop(String cropName) {
    final groups = groupsForCrop(cropName);
    if (groups.isEmpty) return null;

    return groups.first;
  }

  static List<PlantVariety> varietiesForCrop(String cropName) {
    final groups = groupsForCrop(cropName);

    return [for (final group in groups) ...group.varieties];
  }

  static String varietySummaryForCrop(String cropName) {
    final group = bestGroupForCrop(cropName);
    if (group == null) return 'No subtype notes yet.';

    return '${group.title}: ${group.varieties.length} subtype${group.varieties.length == 1 ? '' : 's'} · ${group.summary}';
  }

  static PlantTypeGroup? _dynamicGroupForCrop(String cropName) {
    final normalized = _normalize(cropName);
    final base = _baseFor(normalized);

    if (base.isEmpty) return null;

    final matchingKeys = generatedPlantSvgs.keys.where((key) {
      return _baseFor(_normalize(key)) == base;
    }).toList()..sort();

    final keys = matchingKeys.isEmpty ? [cropName] : matchingKeys;
    final displayBase = _displayName(base);

    final varieties = keys.map((key) => _varietyFromIconKey(key, base)).toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    return PlantTypeGroup(
      keys: keys,
      title: '$displayBase subtypes',
      summary: varieties.length == 1
          ? 'One subtype is currently listed for $displayBase. Add more icon keys or curated entries to expand this group.'
          : 'Related $displayBase entries from the SVG plant library. Use spacing and maturity notes to choose the correct subtype.',
      defaultSpacingCm: _averageSpacingCm(varieties),
      notes: [
        'Subtype names come from the SVG icon library and curated crop rules.',
        'Spacing is estimated from the app-wide CropSpacing table.',
        'Click the card for full sowing, harvest, spacing, and subtype details.',
      ],
      varieties: varieties,
    );
  }

  static PlantVariety _varietyFromIconKey(String key, String base) {
    final displayName = _displayNameForKey(key);
    final spacingCm = (CropSpacing.spacingMetersForCrop(displayName) * 100)
        .round();
    final catalog = _catalogFor(displayName);

    return PlantVariety(
      name: displayName,
      alsoKnownAs: _aliasesFor(displayName, base),
      spacingCm: spacingCm,
      daysToMaturity: _maturityFor(displayName, catalog),
      bestUse: _bestUseFor(displayName, base),
      sowingNote: _sowingNoteFor(displayName, base),
      harvestNote: _harvestNoteFor(displayName, base),
      difficulty: _difficultyFor(displayName, base),
    );
  }

  static SeedCatalogItem? _catalogFor(String cropName) {
    final normalized = _normalize(cropName);

    for (final item in SeedCatalog.items) {
      final key = _normalize(item.key);
      final name = _normalize(item.cropName);

      if (key == normalized ||
          name == normalized ||
          normalized.contains(key) ||
          key.contains(normalized) ||
          normalized.contains(name) ||
          name.contains(normalized)) {
        return item;
      }
    }

    return null;
  }

  static String _maturityFor(String displayName, SeedCatalogItem? catalog) {
    if (catalog == null) {
      return _fallbackMaturity(displayName);
    }

    final directDays =
        catalog.germinationMaxDays + catalog.harvestDaysFromTransplant;
    final trayDays =
        catalog.germinationMaxDays +
        catalog.transplantMaxDays +
        catalog.harvestDaysFromTransplant;

    if (catalog.transplantMaxDays <= 0) {
      return 'About $directDays days from sowing';
    }

    return 'About $directDays-$trayDays days';
  }

  static String _fallbackMaturity(String displayName) {
    final name = _normalize(displayName);

    if (name.contains('tree') ||
        name.contains('apple') ||
        name.contains('pear') ||
        name.contains('peach') ||
        name.contains('plum') ||
        name.contains('citrus') ||
        name.contains('fig')) {
      return 'Multi-year crop';
    }

    if (name.contains('radish') || name.contains('rocket')) return '30-45 days';
    if (name.contains('lettuce') || name.contains('spinach'))
      return '30-70 days';
    if (name.contains('broccoli') || name.contains('cabbage'))
      return '60-120 days';
    if (name.contains('tomato') ||
        name.contains('pepper') ||
        name.contains('chilli')) {
      return '70-120 days';
    }

    return 'Varies by subtype';
  }

  static String _bestUseFor(String displayName, String base) {
    final name = _normalize(displayName);

    if (base == 'broccoli') {
      if (name.contains('chinese'))
        return 'Stems, leaves, and tender flower buds.';
      if (name.contains('broccolini')) return 'Tender stems and small florets.';
      if (name.contains('romanesco'))
        return 'Large spiral head, similar to cauliflower.';
      if (name.contains('sprouting')) return 'Repeated side-shoot harvests.';
      return 'Main head plus smaller side shoots.';
    }

    if (base == 'lettuce') {
      if (name.contains('red') || name.contains('leaf')) {
        return 'Cut-and-come-again leaves or loose heads.';
      }

      if (name.contains('romaine') || name.contains('cos')) {
        return 'Upright heads and crunchy leaves.';
      }

      return 'Salad leaves or heads depending on subtype.';
    }

    if (base == 'tree' || name.contains('tree')) {
      return 'Permanent long-term planting.';
    }

    if (base == 'tomato')
      return 'Fresh eating, sauces, preserving, or long harvest.';
    if (base == 'pepper')
      return 'Sweet peppers or chillies depending on subtype.';
    if (base == 'bean' || base == 'pea') return 'Rows or trellis harvest.';
    if (base == 'herb')
      return 'Culinary herb, companion planting, or pollinator support.';

    return 'Use according to the subtype, spacing, and season window.';
  }

  static String _sowingNoteFor(String displayName, String base) {
    final name = _normalize(displayName);

    if (name.contains('tree') ||
        name.contains('apple') ||
        name.contains('pear') ||
        name.contains('peach') ||
        name.contains('plum') ||
        name.contains('citrus')) {
      return 'Plant as nursery stock or established tree, not as a normal vegetable sowing.';
    }

    if (base == 'broccoli') {
      return 'Use the specific subtype for spacing and season timing; long-season types need more planning.';
    }

    if (base == 'lettuce') {
      return 'Leaf types can be tighter; heading types need more space and steady moisture.';
    }

    if (base == 'tomato' || base == 'pepper') {
      return 'Warm-season crop. Check that there is enough time to mature before season close.';
    }

    return 'Check the month filter and harvest-safe status before planting.';
  }

  static String _harvestNoteFor(String displayName, String base) {
    final name = _normalize(displayName);

    if (base == 'broccoli') {
      if (name.contains('sprouting'))
        return 'Pick shoots repeatedly while tight and tender.';
      if (name.contains('chinese'))
        return 'Harvest stems when buds form but before flowers open.';
      return 'Harvest before buds loosen or flowers open.';
    }

    if (base == 'lettuce') {
      return 'Pick outer leaves or harvest whole heads before bolting.';
    }

    if (base == 'tomato' || base == 'pepper') {
      return 'Harvest when fruit reaches the preferred colour and size.';
    }

    if (name.contains('tree')) {
      return 'Harvest timing depends on species, cultivar, and tree maturity.';
    }

    return 'Harvest timing depends on subtype and local growing conditions.';
  }

  static String _difficultyFor(String displayName, String base) {
    final name = _normalize(displayName);

    if (name.contains('romanesco') || name.contains('cauliflower'))
      return 'Moderate';
    if (name.contains('tree') || name.contains('fruit tree'))
      return 'Long-term';
    if (base == 'lettuce' || name.contains('radish')) return 'Easy';
    if (base == 'tomato' || base == 'pepper' || base == 'broccoli')
      return 'Moderate';

    return 'Varies';
  }

  static List<String> _aliasesFor(String displayName, String base) {
    final name = _normalize(displayName);

    if (name.contains('chinese broccoli')) return ['Gai lan', 'Kai lan'];
    if (name.contains('broccolini'))
      return ['Tenderstem broccoli', 'Baby broccoli'];
    if (name.contains('romanesco'))
      return ['Romanesco broccoli', 'Romanesco cauliflower'];
    if (name.contains('cos')) return ['Romaine'];
    if (name.contains('capsicum')) return ['Bell pepper', 'Sweet pepper'];
    if (name.contains('coriander')) return ['Cilantro'];

    return const <String>[];
  }

  static int _averageSpacingCm(List<PlantVariety> varieties) {
    if (varieties.isEmpty) return 30;

    final total = varieties.fold<int>(0, (sum, item) => sum + item.spacingCm);

    return (total / varieties.length).round();
  }

  static String _baseFor(String normalized) {
    final name = normalized
        .replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    for (final entry in _baseAliases.entries) {
      for (final alias in entry.value) {
        if (name == alias || name.contains(alias)) {
          return entry.key;
        }
      }
    }

    final tokens = name
        .split(' ')
        .where((token) => token.isNotEmpty)
        .where((token) => !_modifierWords.contains(token))
        .toList();

    if (tokens.isEmpty) return name;

    return tokens.last;
  }

  static String _displayNameForKey(String key) {
    return key
        .replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .split(' ')
        .where((part) => part.trim().isNotEmpty)
        .map((part) => part[0].toUpperCase() + part.substring(1))
        .join(' ');
  }

  static String _displayName(String value) {
    return value
        .split(' ')
        .where((part) => part.trim().isNotEmpty)
        .map((part) => part[0].toUpperCase() + part.substring(1))
        .join(' ');
  }

  static String _normalize(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll('&', 'and')
        .replaceAll('-', ' ')
        .replaceAll('_', ' ')
        .replaceAll(RegExp(r'[^a-z0-9\s]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static const Map<String, List<String>> _baseAliases = {
    'broccoli': [
      'broccoli',
      'broccolini',
      'sprouting broccoli',
      'purple broccoli',
      'chinese broccoli',
      'gai lan',
      'kai lan',
      'romanesco broccoli',
      'romanesco',
    ],
    'lettuce': [
      'lettuce',
      'red lettuce',
      'red leaf lettuce',
      'loose leaf lettuce',
      'romaine',
      'cos lettuce',
      'cos',
      'butterhead',
      'iceberg',
      'crisphead',
    ],
    'tomato': [
      'tomato',
      'cherry tomato',
      'roma tomato',
      'paste tomato',
      'bush tomato',
    ],
    'pepper': [
      'pepper',
      'capsicum',
      'bell pepper',
      'sweet pepper',
      'chilli',
      'chili',
    ],
    'cucumber': ['cucumber'],
    'pumpkin': ['pumpkin'],
    'squash': ['squash', 'zucchini', 'courgette'],
    'melon': ['melon', 'watermelon', 'rockmelon', 'cantaloupe', 'honeydew'],
    'carrot': ['carrot'],
    'beetroot': ['beetroot', 'beet'],
    'radish': ['radish'],
    'potato': ['potato'],
    'sweet potato': ['sweet potato', 'kumara'],
    'onion': ['onion', 'spring onion', 'scallion'],
    'garlic': ['garlic'],
    'leek': ['leek'],
    'corn': ['corn', 'maize', 'sweetcorn'],
    'bean': ['bean', 'bush bean', 'pole bean', 'runner bean'],
    'pea': ['pea', 'snow pea', 'snap pea'],
    'cabbage': ['cabbage', 'savoy'],
    'cauliflower': ['cauliflower'],
    'kale': ['kale'],
    'spinach': ['spinach'],
    'basil': ['basil'],
    'mint': ['mint'],
    'parsley': ['parsley'],
    'thyme': ['thyme'],
    'rosemary': ['rosemary'],
    'sage': ['sage'],
    'lavender': ['lavender'],
    'oregano': ['oregano', 'marjoram'],
    'dill': ['dill'],
    'coriander': ['coriander', 'cilantro'],
    'fennel': ['fennel'],
    'chives': ['chives'],
    'strawberry': ['strawberry'],
    'raspberry': ['raspberry'],
    'blueberry': ['blueberry'],
    'blackberry': ['blackberry'],
    'apple': ['apple', 'apple tree', 'dwarf apple'],
    'pear': ['pear', 'pear tree', 'dwarf pear'],
    'peach': ['peach', 'peach tree', 'dwarf peach'],
    'plum': ['plum', 'plum tree', 'dwarf plum'],
    'apricot': ['apricot', 'apricot tree'],
    'citrus': ['citrus', 'lemon', 'orange', 'lime', 'mandarin', 'grapefruit'],
    'fig': ['fig', 'fig tree'],
    'tree': ['tree', 'oak', 'maple', 'birch', 'magnolia', 'palm'],
  };

  static const Set<String> _modifierWords = {
    'red',
    'green',
    'yellow',
    'white',
    'black',
    'purple',
    'orange',
    'golden',
    'dwarf',
    'giant',
    'baby',
    'sweet',
    'hot',
    'chinese',
    'japanese',
    'italian',
    'thai',
    'common',
    'wild',
    'bush',
    'pole',
    'climbing',
    'curly',
    'flat',
    'loose',
    'leaf',
    'heading',
    'main',
    'head',
    'sprouting',
    'tenderstem',
  };

  static const List<PlantTypeGroup> _curatedGroups = [
    PlantTypeGroup(
      keys: [
        'broccoli',
        'purple broccoli',
        'sprouting broccoli',
        'chinese broccoli',
        'gai lan',
        'broccolini',
        'romanesco broccoli',
        'romanesco',
      ],
      title: 'Broccoli types',
      summary:
          'Broccoli includes main-head, sprouting, tenderstem, Chinese broccoli, and romanesco-style crops. They need different spacing and maturity windows.',
      defaultSpacingCm: 45,
      notes: [
        'Main-head broccoli needs more room than broccolini or Chinese broccoli.',
        'Sprouting broccoli is usually a longer-season crop.',
        'Romanesco behaves closer to cauliflower and needs steady growth.',
      ],
      varieties: [
        PlantVariety(
          name: 'Calabrese / main-head broccoli',
          alsoKnownAs: ['Green broccoli', 'Heading broccoli'],
          spacingCm: 45,
          daysToMaturity: '65-90 days from transplant',
          bestUse: 'One main head, then smaller side shoots.',
          sowingNote: 'Good general broccoli type for beds and blocks.',
          harvestNote: 'Harvest the central head before flower buds open.',
          difficulty: 'Moderate',
        ),
        PlantVariety(
          name: 'Sprouting broccoli',
          alsoKnownAs: [
            'Purple sprouting broccoli',
            'White sprouting broccoli',
          ],
          spacingCm: 60,
          daysToMaturity: '120-220 days depending on type',
          bestUse: 'Many small side shoots over a longer harvest window.',
          sowingNote: 'Often a long-season crop.',
          harvestNote: 'Pick shoots repeatedly while tight and tender.',
          difficulty: 'Moderate to slow',
        ),
        PlantVariety(
          name: 'Purple broccoli',
          alsoKnownAs: ['Purple sprouting', 'Purple heading broccoli'],
          spacingCm: 50,
          daysToMaturity: '80-180 days depending on cultivar',
          bestUse: 'Purple heads or shoots.',
          sowingNote:
              'Treat as long-season unless the packet says fast heading.',
          harvestNote: 'Harvest before buds loosen.',
          difficulty: 'Moderate',
        ),
        PlantVariety(
          name: 'Broccolini',
          alsoKnownAs: ['Tenderstem broccoli', 'Baby broccoli'],
          spacingCm: 30,
          daysToMaturity: '50-70 days from transplant',
          bestUse: 'Tender stems and small florets.',
          sowingNote: 'Can be planted closer than main-head broccoli.',
          harvestNote: 'Cut stems regularly to encourage more shoots.',
          difficulty: 'Easy to moderate',
        ),
        PlantVariety(
          name: 'Chinese broccoli',
          alsoKnownAs: ['Gai lan', 'Kai lan', 'Chinese kale'],
          spacingCm: 25,
          daysToMaturity: '40-60 days',
          bestUse: 'Stems, leaves, and flower buds.',
          sowingNote: 'Faster than heading broccoli.',
          harvestNote: 'Harvest stems when buds form before flowers open.',
          difficulty: 'Easy',
        ),
        PlantVariety(
          name: 'Romanesco',
          alsoKnownAs: ['Romanesco broccoli', 'Romanesco cauliflower'],
          spacingCm: 55,
          daysToMaturity: '75-110 days from transplant',
          bestUse: 'Large spiral head.',
          sowingNote: 'Needs consistent growth and more room.',
          harvestNote: 'Harvest when the spiral head is firm.',
          difficulty: 'Moderate',
        ),
      ],
    ),
    PlantTypeGroup(
      keys: [
        'lettuce',
        'red lettuce',
        'loose leaf lettuce',
        'red leaf lettuce',
        'romaine',
        'cos lettuce',
        'butterhead',
        'iceberg',
      ],
      title: 'Lettuce types',
      summary:
          'Leaf lettuce can be much tighter than heading lettuce. Red and loose-leaf types are usually grown closer than romaine, butterhead, or iceberg.',
      defaultSpacingCm: 15,
      notes: [
        'Loose-leaf lettuce works well for cut-and-come-again harvest.',
        'Heading lettuce needs more room and more even moisture.',
      ],
      varieties: [
        PlantVariety(
          name: 'Red loose-leaf lettuce',
          alsoKnownAs: ['Red leaf lettuce', 'Oakleaf', 'Lollo rossa'],
          spacingCm: 15,
          daysToMaturity: '30-55 days',
          bestUse: 'Cut-and-come-again leaves or small heads.',
          sowingNote: 'Good for tighter planting.',
          harvestNote: 'Pick outer leaves or cut whole plant young.',
          difficulty: 'Easy',
        ),
        PlantVariety(
          name: 'Romaine / cos lettuce',
          alsoKnownAs: ['Cos'],
          spacingCm: 30,
          daysToMaturity: '55-75 days',
          bestUse: 'Upright heads and crunchy leaves.',
          sowingNote: 'Needs more room than leaf lettuce.',
          harvestNote: 'Harvest whole head when firm but before bolting.',
          difficulty: 'Easy to moderate',
        ),
        PlantVariety(
          name: 'Butterhead lettuce',
          alsoKnownAs: ['Bibb', 'Boston'],
          spacingCm: 25,
          daysToMaturity: '50-70 days',
          bestUse: 'Soft heads.',
          sowingNote: 'Moderate spacing.',
          harvestNote: 'Harvest whole head or outer leaves.',
          difficulty: 'Easy',
        ),
        PlantVariety(
          name: 'Iceberg / crisphead lettuce',
          alsoKnownAs: ['Crisphead'],
          spacingCm: 35,
          daysToMaturity: '70-90 days',
          bestUse: 'Dense crisp heads.',
          sowingNote: 'Needs the most room and consistent cool growth.',
          harvestNote: 'Harvest once head is firm.',
          difficulty: 'Moderate',
        ),
      ],
    ),
  ];
}

class PlantTypeGroup {
  const PlantTypeGroup({
    required this.keys,
    required this.title,
    required this.summary,
    required this.defaultSpacingCm,
    required this.notes,
    required this.varieties,
  });

  final List<String> keys;
  final String title;
  final String summary;
  final int defaultSpacingCm;
  final List<String> notes;
  final List<PlantVariety> varieties;

  bool matches(String normalizedCropName) {
    for (final key in keys) {
      final normalizedKey = PlantVarietyCatalog._normalize(key);

      if (normalizedCropName == normalizedKey ||
          normalizedCropName.contains(normalizedKey) ||
          normalizedKey.contains(normalizedCropName)) {
        return true;
      }
    }

    return false;
  }
}

class PlantVariety {
  const PlantVariety({
    required this.name,
    required this.alsoKnownAs,
    required this.spacingCm,
    required this.daysToMaturity,
    required this.bestUse,
    required this.sowingNote,
    required this.harvestNote,
    required this.difficulty,
  });

  final String name;
  final List<String> alsoKnownAs;
  final int spacingCm;
  final String daysToMaturity;
  final String bestUse;
  final String sowingNote;
  final String harvestNote;
  final String difficulty;
}
