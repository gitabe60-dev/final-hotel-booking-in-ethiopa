/// app_images.dart
/// Centralized registry for all local asset images + network fallbacks.
///
/// Strategy (3-layer):
///   1. Local asset (bundled in APK — always works, no internet needed)
///   2. Network URL (Unsplash CDN — works when internet is available)
///   3. Generated placeholder (blue gradient with letter — always works)
///
/// All local images are 800×533px high-quality JPEGs.
library;

class AppImages {
  AppImages._();

  static const String _base = 'assets/images';

  // ───────────────────────────────────────────────────────────────────────────
  // CITY LOCAL ASSETS  (800×533px JPEGs bundled in APK)
  // ───────────────────────────────────────────────────────────────────────────
  static const _cityPaths = <String, String>{
    'Addis Ababa': '$_base/cities/addis_ababa/city.jpg',
    'Bahir Dar':   '$_base/cities/bahir_dar/city.jpg',
    'Hawassa':     '$_base/cities/hawassa/city.jpg',
    'Dire Dawa':   '$_base/cities/dire_dawa/city.jpg',
    'Mekelle':     '$_base/cities/mekelle/city.jpg',
    'Gondar':      '$_base/cities/gondar/city.jpg',
    'Adama':       '$_base/cities/adama/city.jpg',
    'Jimma':       '$_base/cities/jimma/city.jpg',
    'Harar':       '$_base/cities/harar/city.jpg',
    'Arba Minch':  '$_base/cities/arba_minch/city.jpg',
    'Dessie':      '$_base/cities/dessie/city.jpg',
    'deberberhan': '$_base/cities/deberberhan/city.jpg',
    'debermarkos': '$_base/cities/debermarkos/city.jpg',
  };

  // ───────────────────────────────────────────────────────────────────────────
  // CITY NETWORK FALLBACKS  (Unsplash CDN, matches the downloaded assets)
  // ───────────────────────────────────────────────────────────────────────────
  static const _cityUrls = <String, String>{
    'Addis Ababa': 'https://images.unsplash.com/photo-1582719508461-905c673771fd?w=800&q=80',
    'Bahir Dar':   'https://images.unsplash.com/photo-1504214208698-ea1916a2195a?w=800&q=80',
    'Hawassa':     'https://images.unsplash.com/photo-1516026672322-bc52d61a55d5?w=800&q=80',
    'Dire Dawa':   'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?w=800&q=80',
    'Mekelle':     'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&q=80',
    'Gondar':      'https://images.unsplash.com/photo-1547471080-7cc2caa01a7e?w=800&q=80',
    'Adama':       'https://images.unsplash.com/photo-1501854140801-50d01698950b?w=800&q=80',
    'Jimma':       'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=800&q=80',
    'Harar':       'https://images.unsplash.com/photo-1509316785289-025f5b846b35?w=800&q=80',
    'Arba Minch':  'https://images.unsplash.com/photo-1504701954957-2010ec3bcec1?w=800&q=80',
    'Dessie':      'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=800&q=80',
    'deberberhan': 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80',
    'debermarkos': 'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=800&q=80',
  };

  // ───────────────────────────────────────────────────────────────────────────
  // HOTEL LOCAL ASSETS  (800px JPEGs bundled in APK)
  // ───────────────────────────────────────────────────────────────────────────
  static const _hotelCovers = <String, String>{
    'Sheraton Addis':                '$_base/hotels/addis_ababa/sheraton_addis/cover.jpg',
    'Hilton Addis Ababa':            '$_base/hotels/addis_ababa/hilton_addis/cover.jpg',
    'Kuriftu Resort & Spa Bahir Dar': '$_base/hotels/bahir_dar/kuriftu_resort/cover.jpg',
    'Lewi Resort Bahir Dar':         '$_base/hotels/bahir_dar/lewi_resort/cover.jpg',
    'Haile Resort Hawassa':          '$_base/hotels/hawassa/haile_resort/cover.jpg',
    'fam hotel':                     '$_base/hotels/hawassa/fam_hotel/cover.jpg',
    'Ras Hotel Dire Dawa':           '$_base/hotels/dire_dawa/ras_hotel/cover.jpg',
    'Axum Hotel':                    '$_base/hotels/mekelle/axum_hotel/cover.jpg',
    'Goha Hotel Gondar':             '$_base/hotels/gondar/goha_hotel/cover.jpg',
    'Kuriftu Resort Adama':          '$_base/hotels/adama/kuriftu_adama/cover.jpg',
    'Harar Walled City Lodge':       '$_base/hotels/harar/harar_lodge/cover.jpg',
    'hiwot  hotel':                  '$_base/hotels/deberberhan/hiwot_hotel/cover.jpg',
    'fm htel':                       '$_base/hotels/debermarkos/fm_hotel/cover.jpg',
  };

  // ───────────────────────────────────────────────────────────────────────────
  // HOTEL NETWORK FALLBACKS  (Unsplash CDN)
  // ───────────────────────────────────────────────────────────────────────────
  static const _hotelUrls = <String, String>{
    'Sheraton Addis':                'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80',
    'Hilton Addis Ababa':            'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=800&q=80',
    'Kuriftu Resort & Spa Bahir Dar': 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=800&q=80',
    'Lewi Resort Bahir Dar':         'https://images.unsplash.com/photo-1506059612708-99d6c258160e?w=800&q=80',
    'Haile Resort Hawassa':          'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=800&q=80',
    'fam hotel':                     'https://images.unsplash.com/photo-1564501049412-61c2a3083791?w=800&q=80',
    'Ras Hotel Dire Dawa':           'https://images.unsplash.com/photo-1549294413-26f195200c16?w=800&q=80',
    'Axum Hotel':                    'https://images.unsplash.com/photo-1445019980597-93fa8acb246c?w=800&q=80',
    'Goha Hotel Gondar':             'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=800&q=80',
    'Kuriftu Resort Adama':          'https://images.unsplash.com/photo-1564501049412-61c2a3083791?w=800&q=80',
    'Harar Walled City Lodge':       'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=800&q=80',
    'hiwot  hotel':                  'https://images.unsplash.com/photo-1582719508461-905c673771fd?w=800&q=80',
    'fm htel':                       'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80',
  };

  static const String _defaultUrl =
      'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80';

  // ───────────────────────────────────────────────────────────────────────────
  // PUBLIC API
  // ───────────────────────────────────────────────────────────────────────────

  /// Local asset path for a city — always present (bundled in APK).
  static String? cityImage(String cityName) => _lookup(_cityPaths, cityName);

  /// Network URL for a city — Unsplash CDN fallback.
  static String cityNetworkUrl(String cityName) =>
      _lookup(_cityUrls, cityName) ?? _defaultUrl;

  /// Combined: returns local path first, then network URL.
  /// Pass both to LocalOrNetworkImage.
  static String onlineCityFallback(String cityName) => cityNetworkUrl(cityName);

  /// Local asset path for a hotel cover.
  static String? hotelCover(String hotelName) => _lookup(_hotelCovers, hotelName);

  /// Network URL for a hotel cover — Unsplash CDN fallback.
  static String hotelNetworkUrl(String hotelName) =>
      _lookup(_hotelUrls, hotelName) ?? _defaultUrl;

  // ───────────────────────────────────────────────────────────────────────────
  // PRIVATE HELPER — case-insensitive map lookup
  // ───────────────────────────────────────────────────────────────────────────
  static String? _lookup(Map<String, String> map, String key) {
    if (map.containsKey(key)) return map[key];
    final lower = key.toLowerCase().trim();
    for (final entry in map.entries) {
      if (entry.key.toLowerCase().trim() == lower) return entry.value;
    }
    return null;
  }
}
