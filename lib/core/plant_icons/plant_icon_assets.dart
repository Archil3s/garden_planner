class PlantIconAssets {
  const PlantIconAssets._();

  static const String directory = 'assets/plant_icons';

  static const Set<String> available = <String>{
    'artichoke',
    'asparagus',
    'bamboo',
    'basil',
    'beetroot',
    'bell_pepper',
    'birch_tree',
    'bonsai',
    'broccoli',
    'cactus',
    'carrot',
    'cauliflower',
    'celery',
    'cherry_blossom',
    'chives',
    'cilantro',
    'corn',
    'cucumber',
    'dill',
    'eggplant',
    'garlic',
    'lavender',
    'leek',
    'lettuce',
    'magnolia',
    'maple_tree',
    'mint',
    'oak_tree',
    'onion',
    'oregano',
    'palm_tree',
    'parsley',
    'pine_tree',
    'potato',
    'pumpkin',
    'radish',
    'rosemary',
    'sage',
    'spinach',
    'sweet_potato',
    'thyme',
    'tomato',
    'willow',
    'zucchini',
  };

  static String normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll('&', 'and')
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
  }

  static String? assetFor(String plantName) {
    final direct = normalize(plantName);

    if (available.contains(direct)) {
      return '$directory/$direct.svg';
    }

    final aliases = <String, String>{
      'potatoes': 'potato',
      'sweet_potatoes': 'sweet_potato',
      'sweet_potato': 'sweet_potato',
      'strawberries': 'strawberry',
      'raspberries': 'raspberry',
      'blueberries': 'blueberry',
      'blackberries': 'blackberry',
      'tomatoes': 'tomato',
      'carrots': 'carrot',
      'peppers': 'bell_pepper',
      'pepper': 'bell_pepper',
      'bellpepper': 'bell_pepper',
      'bell_peppers': 'bell_pepper',
      'cucumbers': 'cucumber',
      'onions': 'onion',
      'leeks': 'leek',
      'beets': 'beetroot',
      'beet': 'beetroot',
      'aubergine': 'eggplant',
      'coriander': 'cilantro',
      'oak': 'oak_tree',
      'maple': 'maple_tree',
      'palm': 'palm_tree',
      'birch': 'birch_tree',
      'pine': 'pine_tree',
      'apple': 'apple_tree',
      'pear': 'pear_tree',
      'plum': 'plum_tree',
      'peach': 'peach_tree',
      'lemon': 'lemon_tree',
      'orange': 'orange_tree',
    };

    final alias = aliases[direct];

    if (alias != null && available.contains(alias)) {
      return '$directory/$alias.svg';
    }

    for (final key in available) {
      if (direct.contains(key) || key.contains(direct)) {
        return '$directory/$key.svg';
      }
    }

    return null;
  }
}
