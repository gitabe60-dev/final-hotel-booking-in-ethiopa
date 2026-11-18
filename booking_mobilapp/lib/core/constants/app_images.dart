/// app_images.dart  
/// Centralized registry for all local asset images.
/// Every city and hotel that has a local image returns its path.
/// When no local image is found, the app falls back to Unsplash.
library;

class AppImages {
  AppImages._();

  static const String _base = 'assets/images';

  // ─────────────────────────────────────────────────────────────────────────
  // CITY IMAGES  — all 13 cities present
  // ─────────────────────────────────────────────────────────────────────────
  static const _cityPaths = <String, String>{
    'Addis Ababa':  '$_base/cities/addis_ababa/city.jpg',
    'Bahir Dar':    '$_base/cities/bahir_dar/city.jpg',
    'Hawassa':      '$_base/cities/hawassa/city.jpg',
    'Dire Dawa':    '$_base/cities/dire_dawa/city.jpg',
    'Mekelle':      '$_base/cities/mekelle/city.jpg',
    'Gondar':       '$_base/cities/gondar/city.jpg',
    'Adama':        '$_base/cities/adama/city.jpg',
    'Jimma':        '$_base/cities/jimma/city.jpg',
    'Harar':        '$_base/cities/harar/city.jpg',
    'Arba Minch':   '$_base/cities/arba_minch/city.jpg',
    'Dessie':       '$_base/cities/dessie/city.jpg',
    'deberberhan':  '$_base/cities/deberberhan/city.jpg',
    'debermarkos':  '$_base/cities/debermarkos/city.jpg',
  };

  /// Returns local asset path for a city image. Case-insensitive.
  static String? cityImage(String cityName) {
    if (_cityPaths.containsKey(cityName)) return _cityPaths[cityName];
    final lower = cityName.toLowerCase();
    for (final entry in _cityPaths.entries) {
      if (entry.key.toLowerCase() == lower) return entry.value;
    }
    return null;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // HOTEL COVER IMAGES — all 13 hotels present
  // ─────────────────────────────────────────────────────────────────────────
  static const _hotelCovers = <String, String>{
    'Sheraton Addis':              '$_base/hotels/addis_ababa/sheraton_addis/cover.jpg',
    'Hilton Addis Ababa':          '$_base/hotels/addis_ababa/hilton_addis/cover.jpg',
    'Kuriftu Resort & Spa Bahir Dar': '$_base/hotels/bahir_dar/kuriftu_resort/cover.jpg',
    'Lewi Resort Bahir Dar':       '$_base/hotels/bahir_dar/lewi_resort/cover.jpg',
    'Haile Resort Hawassa':        '$_base/hotels/hawassa/haile_resort/cover.jpg',
    'fam hotel':                   '$_base/hotels/hawassa/fam_hotel/cover.jpg',
    'Ras Hotel Dire Dawa':         '$_base/hotels/dire_dawa/ras_hotel/cover.jpg',
    'Axum Hotel':                  '$_base/hotels/mekelle/axum_hotel/cover.jpg',
    'Goha Hotel Gondar':           '$_base/hotels/gondar/goha_hotel/cover.jpg',
    'Kuriftu Resort Adama':        '$_base/hotels/adama/kuriftu_adama/cover.jpg',
    'Harar Walled City Lodge':     '$_base/hotels/harar/harar_lodge/cover.jpg',
    'hiwot  hotel':                '$_base/hotels/deberberhan/hiwot_hotel/cover.jpg',
    'fm htel':                     '$_base/hotels/debermarkos/fm_hotel/cover.jpg',
  };

  /// Returns local cover image path for a hotel by name. Case-insensitive.
  static String? hotelCover(String hotelName) {
    if (_hotelCovers.containsKey(hotelName)) return _hotelCovers[hotelName];
    final lower = hotelName.toLowerCase().trim();
    for (final entry in _hotelCovers.entries) {
      if (entry.key.toLowerCase().trim() == lower) return entry.value;
    }
    return null;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ONLINE FALLBACKS — for future hotels with no local image
  // ─────────────────────────────────────────────────────────────────────────
  static const _onlineCities = <String, String>{
    'Addis Ababa':  'https://images.unsplash.com/photo-1580746738099-b2d4b5d4b9e7?w=800&q=80',
    'Bahir Dar':    'https://images.unsplash.com/photo-1504214208698-ea1916a2195a?w=800&q=80',
    'Hawassa':      'https://images.unsplash.com/photo-1516026672322-bc52d61a55d5?w=800&q=80',
    'Dire Dawa':    'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?w=800&q=80',
    'Mekelle':      'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&q=80',
    'Gondar':       'https://images.unsplash.com/photo-1547471080-7cc2caa01a7e?w=800&q=80',
    'Adama':        'https://images.unsplash.com/photo-1501854140801-50d01698950b?w=800&q=80',
    'Jimma':        'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=800&q=80',
    'Harar':        'https://images.unsplash.com/photo-1509316785289-025f5b846b35?w=800&q=80',
    'Arba Minch':   'https://images.unsplash.com/photo-1504701954957-2010ec3bcec1?w=800&q=80',
    'Dessie':       'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=800&q=80',
    'deberberhan':  'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80',
    'debermarkos':  'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80',
  };

  static const String defaultOnline =
      'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80';

  static String onlineCityFallback(String cityName) {
    if (_onlineCities.containsKey(cityName)) return _onlineCities[cityName]!;
    final lower = cityName.toLowerCase();
    for (final entry in _onlineCities.entries) {
      if (entry.key.toLowerCase() == lower) return entry.value;
    }
    return defaultOnline;
  }
}
