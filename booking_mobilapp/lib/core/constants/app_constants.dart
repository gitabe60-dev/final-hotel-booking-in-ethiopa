// lib/core/constants/app_constants.dart
class AppConstants {
  static const String appName     = 'Hotel Booking';
  static const String appTagline  = "Ethiopia's Premier Hotel Booking";
  static const String appVersion  = '1.0.0';
  static const String currency    = 'ETB';
  static const String phonePrefix = '+251';
  static const String logoUrl =
      'https://hotelethiopia.com/wp-content/uploads/2025/10/WhatsApp-Image-2025-10-08-at-8.01.41-PM.png.webp';

  static const List<String> ethiopianCities = [
    'Addis Ababa', 'Dire Dawa', 'Hawassa',   'Bahir Dar',
    'Mekelle',     'Gondar',    'Adama',      'Jimma',
    'Harar',       'Dessie',    'Arba Minch', 'Shashamane',
  ];

  static const List<Map<String, String>> cityImages = [
    {'city': 'Addis Ababa',  'img': 'https://images.unsplash.com/photo-1580746738099-b2d4b5d4b9e7?w=400'},
    {'city': 'Dire Dawa',    'img': 'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?w=400'},
    {'city': 'Hawassa',      'img': 'https://images.unsplash.com/photo-1516026672322-bc52d61a55d5?w=400'},
    {'city': 'Bahir Dar',    'img': 'https://images.unsplash.com/photo-1504214208698-ea1916a2195a?w=400'},
    {'city': 'Mekelle',      'img': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400'},
    {'city': 'Gondar',       'img': 'https://images.unsplash.com/photo-1547471080-7cc2caa01a7e?w=400'},
    {'city': 'Adama',        'img': 'https://images.unsplash.com/photo-1501854140801-50d01698950b?w=400'},
    {'city': 'Jimma',        'img': 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=400'},
    {'city': 'Harar',        'img': 'https://images.unsplash.com/photo-1509316785289-025f5b846b35?w=400'},
    {'city': 'Dessie',       'img': 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=400'},
    {'city': 'Arba Minch',   'img': 'https://images.unsplash.com/photo-1504701954957-2010ec3bcec1?w=400'},
    {'city': 'Shashamane',   'img': 'https://images.unsplash.com/photo-1523712999610-f77fbcfc3843?w=400'},
  ];

  static String cityImageUrl(String city) {
    final match = cityImages.firstWhere(
      (m) => m['city'] == city,
      orElse: () => {'img': 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400'},
    );
    return match['img']!;
  }

  // Backend payment method keys
  static const List<Map<String, String>> paymentMethods = [
    {'key': 'telebirr',     'label': 'Telebirr',          'icon': '📱'},
    {'key': 'cbe_birr',    'label': 'CBE Birr',           'icon': '🏦'},
    {'key': 'chapa',        'label': 'Chapa',              'icon': '🔵'},
    {'key': 'awash_bank',   'label': 'Awash Bank',         'icon': '🏦'},
    {'key': 'abyssinia',    'label': 'Bank of Abyssinia',  'icon': '🏦'},
    {'key': 'dashen',       'label': 'Dashen Bank',        'icon': '🏦'},
    {'key': 'oromia_coop',  'label': 'Oromia Bank',        'icon': '🏦'},
    {'key': 'united',       'label': 'United Bank',        'icon': '🏦'},
    {'key': 'nib',          'label': 'NIB International',  'icon': '🏦'},
    {'key': 'wegagen',      'label': 'Wegagen Bank',       'icon': '🏦'},
    {'key': 'bunna',        'label': 'Bunna Bank',         'icon': '🏦'},
  ];

  static String paymentLabel(String key) {
    final m = paymentMethods.firstWhere(
      (p) => p['key'] == key,
      orElse: () => {'label': key},
    );
    return m['label']!;
  }

  static const List<String> hotelTypes = [
    'All', 'Hotel', 'Resort', 'Boutique', 'Lodge', 'Apartment', 'Guest House',
  ];

  static const List<String> sortOptions = [
    'Recommended', 'Price: Low to High', 'Price: High to Low', 'Rating',
  ];
}
