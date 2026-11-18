/// Admin API endpoint PATHS (relative to /api/admin baseURL).
///
/// Mirrors the web frontend's adminApi axios instance which has baseURL = '/api/admin'.
/// Used with ApiService.instance.adminGet/adminPost/adminPut/adminDelete
class AdminEndpoints {
  AdminEndpoints._();

  // ── Shared (all authenticated admins) ────────────────────────────────────
  static const String login          = '/login';
  static const String profile        = '/profile';
  static const String updateProfile  = '/profile';
  static const String changePassword = '/change-password';

  // ── Super Admin  /api/admin/super/* ──────────────────────────────────────
  static const String superDashboard = '/super/dashboard';
  static const String superSubAdmins = '/super/sub-admins';
  static String superSubAdminById(int id) => '/super/sub-admins/$id';
  static String superAssignCity(int id)   => '/super/sub-admins/$id/assign-city';
  static String superRevokeCity(int id, String city) =>
      '/super/sub-admins/$id/revoke-city/$city';
  static const String superHotels   = '/super/hotels';
  static String superHotelById(int id) => '/super/hotels/$id';
  static String superToggleHotel(int id) => '/super/hotels/$id/toggle';
  static const String superBookings = '/super/bookings';
  static const String superUsers    = '/super/users';
  static const String superBrokers  = '/super/brokers';
  static const String superManagers = '/super/managers';
  static const String superCities   = '/super/cities';
  static String superCityById(int id) => '/super/cities/$id';

  // ── Sub Admin  /api/admin/subadmin/* ─────────────────────────────────────
  static const String subDashboard   = '/subadmin/dashboard';
  static const String subHotels      = '/subadmin/hotels';
  static const String subCreateHotel = '/subadmin/hotels/create';
  static String subHotelById(int id) => '/subadmin/hotels/$id';
  static String subToggleHotel(int id) => '/subadmin/hotels/$id/toggle';
  static String subHotelPayMethods(int hid) =>
      '/subadmin/hotels/$hid/payment-methods';
  static String subPayMethodById(int id) => '/subadmin/payment-methods/$id';
  static String subRooms(int hid)        => '/subadmin/hotels/$hid/rooms';
  static String subRoomById(int hid, int rid) =>
      '/subadmin/hotels/$hid/rooms/$rid';
  static String subToggleRoom(int hid, int rid) =>
      '/subadmin/hotels/$hid/rooms/$rid/toggle';
  static const String subBookings = '/subadmin/bookings';
  static const String subBrokers  = '/subadmin/brokers';
  static const String subManagers = '/subadmin/managers';
  static String subManagerById(int id) => '/subadmin/managers/$id';

  // ── Hotel Manager  /api/admin/manager/* ──────────────────────────────────
  static const String managerDashboard = '/manager/dashboard';
  static const String managerRooms     = '/manager/rooms';
  static String managerRoomById(int rid)    => '/manager/rooms/$rid';
  static String managerToggleRoom(int rid)  => '/manager/rooms/$rid/toggle';
  static String managerRoomStatus(int rid)  => '/manager/rooms/$rid/status';
  static const String managerBookings       = '/manager/bookings';
  static String managerBookingStatus(int id) => '/manager/bookings/$id/status';
  static const String managerPayments       = '/manager/payments';
  static String managerVerifyPayment(int id) => '/manager/payments/$id/verify';
  static const String managerPayMethods     = '/manager/payment-methods';
  static String managerPayMethodById(int id) => '/manager/payment-methods/$id';
  static const String managerInbox          = '/manager/inbox';
  static String managerMessageById(int id)  => '/manager/messages/$id';
  static const String managerSendMessage    = '/manager/messages';
  static const String managerNotifications  = '/manager/notifications';
  static String managerReadNotif(int id)    => '/manager/notifications/$id/read';
  static const String managerReadAllNotifs  = '/manager/notifications/read-all';

  // ── Broker  /api/admin/broker/* ──────────────────────────────────────────
  static const String brokerDashboard   = '/broker/dashboard';
  static const String brokerBookings    = '/broker/bookings';
  static const String brokerInbox       = '/broker/inbox';
  static const String brokerSent        = '/broker/sent';
  static String brokerMessageById(int id) => '/broker/messages/$id';
  static const String brokerSendMessage = '/broker/messages';
}
