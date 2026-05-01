class PlantProfileData {
  const PlantProfileData({
    required this.recommendedLayout,
    required this.sowDepth,
    required this.sun,
    required this.water,
    required this.soil,
    required this.rotationFamily,
    required this.succession,
    required this.frost,
    required this.container,
    required this.support,
    required this.plannerUse,
    required this.warnings,
  });

  final String recommendedLayout;
  final String sowDepth;
  final String sun;
  final String water;
  final String soil;
  final String rotationFamily;
  final String succession;
  final String frost;
  final String container;
  final String support;
  final String plannerUse;
  final List<String> warnings;

  static PlantProfileData forCrop(String cropName, {String family = ''}) {
    final value = _normalize('$cropName $family');

    for (final rule in _rules) {
      if (rule.matches(value)) return rule.data;
    }

    return const PlantProfileData(
      recommendedLayout: 'General bed block',
      sowDepth: 'Check seed packet',
      sun: 'Full sun to part sun',
      water: 'Moderate, consistent moisture',
      soil: 'Fertile, free-draining garden soil',
      rotationFamily: 'General',
      succession: 'Use crop-specific timing',
      frost: 'Check local frost and temperature conditions',
      container: 'Possible if spacing and root depth are suitable',
      support: 'None unless crop habit requires it',
      plannerUse: 'Use normal spacing and season filters before planting.',
      warnings: [
        'No detailed profile rule exists for this plant yet.',
        'Use packet-specific spacing and local climate information.',
      ],
    );
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

  static const List<_PlantProfileRule> _rules = [
    _PlantProfileRule(
      keys: [
        'broccoli',
        'broccolini',
        'romanesco',
        'gai lan',
        'chinese broccoli',
        'cabbage',
        'cauliflower',
        'kale',
        'brussels',
        'brassica',
      ],
      data: PlantProfileData(
        recommendedLayout: 'Blocks or individual plants',
        sowDepth: '0.5-1cm',
        sun: 'Full sun',
        water: 'Steady moisture',
        soil: 'Rich soil with compost; avoid drying out',
        rotationFamily: 'Brassica',
        succession: 'Stagger transplants every 2-4 weeks',
        frost: 'Cool-season crop; tolerates light frost once established',
        container: 'Large containers only, 25-40L+',
        support: 'No support needed',
        plannerUse:
            'Use block planting or individual spacing. Do not overcrowd mature heads.',
        warnings: [
          'Long-season broccoli types may be sowable but not harvest-safe late in the season.',
          'Keep out of beds recently used for other brassicas where possible.',
        ],
      ),
    ),
    _PlantProfileRule(
      keys: [
        'lettuce',
        'romaine',
        'cos',
        'iceberg',
        'butterhead',
        'red lettuce',
        'leaf lettuce',
        'loose leaf',
        'salad mix',
        'mesclun',
      ],
      data: PlantProfileData(
        recommendedLayout: 'Rows or dense leaf blocks',
        sowDepth: 'Surface to 0.5cm',
        sun: 'Sun in cool weather; part shade in heat',
        water: 'Even moisture; shallow roots dry quickly',
        soil: 'Loose fertile soil, high organic matter',
        rotationFamily: 'Aster / leafy green',
        succession: 'Sow every 2-3 weeks for continuous harvest',
        frost: 'Cool-season crop; heat can cause bolting',
        container: 'Good container crop',
        support: 'No support needed',
        plannerUse:
            'Use tighter spacing for leaf lettuce and wider spacing for heading types.',
        warnings: [
          'Leaf lettuce and heading lettuce should not use the same spacing.',
          'Warm weather increases bolt risk.',
        ],
      ),
    ),
    _PlantProfileRule(
      keys: [
        'spinach',
        'silverbeet',
        'swiss chard',
        'chard',
        'rocket',
        'arugula',
        'mizuna',
        'tatsoi',
        'mustard green',
      ],
      data: PlantProfileData(
        recommendedLayout: 'Rows or leafy blocks',
        sowDepth: '0.5-1.5cm',
        sun: 'Full sun to part shade',
        water: 'Consistent moisture',
        soil: 'Fertile soil with good drainage',
        rotationFamily: 'Leafy green',
        succession: 'Sow every 2-4 weeks',
        frost: 'Cool-season; heat may reduce quality',
        container: 'Good in containers',
        support: 'No support needed',
        plannerUse:
            'Use rows or dense blocks depending on baby-leaf vs mature harvest.',
        warnings: ['Hot conditions can cause bolting or bitterness.'],
      ),
    ),
    _PlantProfileRule(
      keys: ['tomato', 'cherry tomato', 'roma tomato', 'paste tomato'],
      data: PlantProfileData(
        recommendedLayout: 'Trellis row or single plants',
        sowDepth: '0.5cm',
        sun: 'Full sun',
        water: 'Deep, regular watering; avoid wet leaves',
        soil: 'Rich, free-draining soil',
        rotationFamily: 'Nightshade',
        succession: 'Usually one main seasonal planting',
        frost: 'Frost tender; needs warm conditions',
        container: 'Good in large containers, 30L+',
        support: 'Stake, cage, or trellis',
        plannerUse:
            'Use individual plants or a supported row. Leave airflow space.',
        warnings: [
          'Sowable does not mean harvest-safe late in the season.',
          'Avoid rotating after tomatoes, potatoes, peppers, or eggplant.',
        ],
      ),
    ),
    _PlantProfileRule(
      keys: [
        'capsicum',
        'pepper',
        'bell pepper',
        'sweet pepper',
        'chilli',
        'chili',
        'eggplant',
        'aubergine',
      ],
      data: PlantProfileData(
        recommendedLayout: 'Individual plants or warm block',
        sowDepth: '0.5cm',
        sun: 'Full sun and warmth',
        water: 'Moderate, consistent moisture',
        soil: 'Warm, fertile, free-draining soil',
        rotationFamily: 'Nightshade',
        succession: 'One warm-season planting',
        frost: 'Very frost tender; needs warm soil and air',
        container: 'Good in pots, 15-30L+',
        support: 'Stake heavy plants if needed',
        plannerUse:
            'Use as individual warm-season plants with enough maturity time.',
        warnings: [
          'Often too slow if started late.',
          'Large capsicums need longer than small chillies.',
        ],
      ),
    ),
    _PlantProfileRule(
      keys: [
        'cucumber',
        'zucchini',
        'courgette',
        'pumpkin',
        'squash',
        'melon',
        'watermelon',
        'cucurbit',
      ],
      data: PlantProfileData(
        recommendedLayout: 'Single plant, hill, or trellis',
        sowDepth: '1.5-2.5cm',
        sun: 'Full sun',
        water: 'High water demand',
        soil: 'Rich soil with compost; warm soil preferred',
        rotationFamily: 'Cucurbit',
        succession: 'Usually one or two warm-season sowings',
        frost: 'Frost tender; needs warm soil',
        container: 'Only compact types in very large containers',
        support: 'Trellis for cucumber; space for vines on pumpkins/melons',
        plannerUse:
            'Use large spacing. Do not treat sprawling vines like row greens.',
        warnings: [
          'Pumpkins, melons, and squash need a long warm season.',
          'Late sowing may be possible but not harvest-safe.',
        ],
      ),
    ),
    _PlantProfileRule(
      keys: [
        'carrot',
        'radish',
        'beetroot',
        'beet',
        'turnip',
        'swede',
        'parsnip',
      ],
      data: PlantProfileData(
        recommendedLayout: 'Dense rows',
        sowDepth: '0.5-1.5cm',
        sun: 'Full sun to part sun',
        water: 'Even moisture during germination',
        soil: 'Loose, stone-free soil; avoid fresh manure for roots',
        rotationFamily: 'Root crop',
        succession: 'Sow every 2-4 weeks depending on crop',
        frost: 'Many tolerate cool weather',
        container: 'Good if container is deep enough',
        support: 'No support needed',
        plannerUse: 'Use rows and thin to final spacing.',
        warnings: [
          'Root crops need loose soil and accurate thinning.',
          'Carrots and radishes should not use the same maturity assumptions.',
        ],
      ),
    ),
    _PlantProfileRule(
      keys: [
        'onion',
        'spring onion',
        'scallion',
        'garlic',
        'leek',
        'shallot',
        'chive',
        'allium',
      ],
      data: PlantProfileData(
        recommendedLayout: 'Rows',
        sowDepth: '0.5-2cm depending on seed/clove',
        sun: 'Full sun',
        water: 'Moderate; avoid waterlogging',
        soil: 'Free-draining fertile soil',
        rotationFamily: 'Allium',
        succession:
            'Spring onions can be succession sown; garlic/onions are seasonal',
        frost: 'Generally cool tolerant once established',
        container: 'Good for spring onions and chives; larger for bulbs',
        support: 'No support needed',
        plannerUse:
            'Use rows with narrow spacing for spring onions and wider bulb spacing for onions/garlic.',
        warnings: [
          'Garlic and onions need correct seasonal timing.',
          'Avoid following alliums with alliums in the same bed.',
        ],
      ),
    ),
    _PlantProfileRule(
      keys: [
        'bean',
        'pea',
        'snow pea',
        'snap pea',
        'runner bean',
        'pole bean',
        'bush bean',
        'legume',
      ],
      data: PlantProfileData(
        recommendedLayout: 'Rows or trellis',
        sowDepth: '2-4cm',
        sun: 'Full sun',
        water: 'Moderate; consistent during flowering/pod set',
        soil: 'Free-draining soil; avoid excess nitrogen',
        rotationFamily: 'Legume',
        succession:
            'Sow every 2-3 weeks for bush beans; peas prefer cool windows',
        frost: 'Beans are frost tender; peas tolerate cool weather',
        container: 'Possible with support and depth',
        support: 'Trellis for climbing types',
        plannerUse:
            'Use trellis rows for climbing types and blocks/rows for bush types.',
        warnings: [
          'Beans and peas have different season preferences.',
          'Climbing types need support space.',
        ],
      ),
    ),
    _PlantProfileRule(
      keys: [
        'basil',
        'parsley',
        'coriander',
        'cilantro',
        'dill',
        'mint',
        'thyme',
        'rosemary',
        'sage',
        'oregano',
        'lavender',
        'herb',
      ],
      data: PlantProfileData(
        recommendedLayout: 'Borders, containers, or companion pockets',
        sowDepth: 'Usually shallow; check herb type',
        sun: 'Most prefer full sun; some tolerate part shade',
        water: 'Varies: basil/parsley need more; rosemary/lavender need less',
        soil: 'Free-draining soil; woody herbs dislike wet feet',
        rotationFamily: 'Herb',
        succession:
            'Coriander/dill succession every 2-3 weeks; woody herbs are long-term',
        frost: 'Basil is frost tender; many woody herbs tolerate mild cold',
        container: 'Excellent container group',
        support: 'No support needed',
        plannerUse:
            'Use near paths, bed edges, companion zones, or containers.',
        warnings: [
          'Do not water rosemary/lavender like basil.',
          'Mint spreads aggressively; container recommended.',
        ],
      ),
    ),
    _PlantProfileRule(
      keys: [
        'strawberry',
        'raspberry',
        'blueberry',
        'blackberry',
        'gooseberry',
        'currant',
        'berry',
      ],
      data: PlantProfileData(
        recommendedLayout: 'Permanent rows or shrub zones',
        sowDepth: 'Plant crowns/canes/shrubs, not normal seed rows',
        sun: 'Full sun to part sun',
        water: 'Consistent moisture during establishment and fruiting',
        soil: 'Species-specific; blueberries need acidic soil',
        rotationFamily: 'Berry / perennial',
        succession: 'Permanent planting; replace or renew over years',
        frost: 'Flowers may need frost protection',
        container: 'Strawberries and blueberries can work in containers',
        support: 'Trellis/support for cane berries',
        plannerUse: 'Use as permanent plantings, not short-season vegetables.',
        warnings: [
          'Blueberries need acidic soil.',
          'Cane berries need access and support.',
        ],
      ),
    ),
    _PlantProfileRule(
      keys: [
        'apple',
        'pear',
        'peach',
        'plum',
        'apricot',
        'citrus',
        'lemon',
        'orange',
        'mandarin',
        'lime',
        'fig',
        'tree',
        'fruit tree',
      ],
      data: PlantProfileData(
        recommendedLayout: 'Tree canopy zone',
        sowDepth: 'Plant nursery tree at correct graft/soil level',
        sun: 'Full sun',
        water: 'Deep watering during establishment',
        soil: 'Free-draining soil; avoid waterlogging',
        rotationFamily: 'Perennial tree',
        succession: 'Permanent multi-year planting',
        frost: 'Species-specific; blossoms can be frost damaged',
        container: 'Only dwarf or container-suitable types',
        support: 'Stake young trees if exposed',
        plannerUse: 'Use canopy/root spacing, not vegetable spacing.',
        warnings: [
          'Trees should not be placed like vegetables.',
          'Allow canopy, root spread, shade, pruning access, and permanent paths.',
        ],
      ),
    ),
  ];
}

class _PlantProfileRule {
  const _PlantProfileRule({required this.keys, required this.data});

  final List<String> keys;
  final PlantProfileData data;

  bool matches(String normalizedCropName) {
    for (final key in keys) {
      final normalizedKey = PlantProfileData._normalize(key);

      if (normalizedCropName.contains(normalizedKey)) return true;
    }

    return false;
  }
}
