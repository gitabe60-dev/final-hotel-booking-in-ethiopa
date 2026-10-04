<?php

use CodeIgniter\Router\RouteCollection;

/**
 * @var RouteCollection $routes
 */

// ─────────────────────────────────────────────────────────────────────────────
//  API v1  —  consumed by Flutter mobile app
// ─────────────────────────────────────────────────────────────────────────────
$routes->group('api/v1', ['namespace' => 'App\Controllers\Api'], function ($r) {

    // ── Auth (public) ──────────────────────────────────────────────────────
    $r->post('auth/guest/register',        'AuthController::register');
    $r->post('auth/guest/login',           'AuthController::login');
    $r->post('auth/otp/send',              'AuthController::sendOtp');
    $r->post('auth/otp/verify',            'AuthController::verifyOtp');
    $r->post('auth/refresh',               'AuthController::refresh');
    $r->post('auth/guest/forgot-password', 'AuthController::forgotPassword');
    $r->post('auth/guest/reset-password',  'AuthController::resetPassword');
    $r->post('auth/logout',                'AuthController::logout',  ['filter' => 'jwt']);

    // ── Hotels ─────────────────────────────────────────────────────────────
    $r->get('hotels/featured',             'HotelController::featured');
    $r->get('hotels/search',               'HotelController::search');
    $r->get('hotels/(:num)',               'HotelController::show/$1');
    $r->get('hotels/(:num)/reviews',       'HotelController::reviews/$1');
    $r->post('hotels/(:num)/reviews',      'HotelController::postReview/$1', ['filter' => 'jwt']);

    // ── Bookings (JWT) ──────────────────────────────────────────────────────
    $r->get('bookings',                    'BookingController::index',     ['filter' => 'jwt']);
    $r->post('bookings',                   'BookingController::create',    ['filter' => 'jwt']);
    $r->get('bookings/(:num)',             'BookingController::show/$1',   ['filter' => 'jwt']);
    $r->post('bookings/(:num)/cancel',     'BookingController::cancel/$1', ['filter' => 'jwt']);

    // ── Guest Profile (JWT) ─────────────────────────────────────────────────
    $r->get('guest/profile',               'GuestController::profile',        ['filter' => 'jwt']);
    $r->put('guest/profile',               'GuestController::updateProfile',   ['filter' => 'jwt']);
    $r->post('guest/change-password',      'GuestController::changePassword',  ['filter' => 'jwt']);

    // ── Wishlist (JWT) ──────────────────────────────────────────────────────
    $r->get('wishlist',                    'WishlistController::index',    ['filter' => 'jwt']);
    $r->post('wishlist',                   'WishlistController::toggle',   ['filter' => 'jwt']);
    $r->delete('wishlist/(:num)',          'WishlistController::remove/$1',['filter' => 'jwt']);

    // ── Payments (JWT) ──────────────────────────────────────────────────────
    $r->post('payments/initiate',          'PaymentController::initiate',  ['filter' => 'jwt']);
    $r->get('payments/(:num)/status',      'PaymentController::status/$1', ['filter' => 'jwt']);
    $r->post('payments/retry/(:num)',      'PaymentController::retry/$1',  ['filter' => 'jwt']);
    $r->post('payments/webhook',           'PaymentController::webhook');
});

// ─────────────────────────────────────────────────────────────────────────────
//  Web Routes
// ─────────────────────────────────────────────────────────────────────────────
$routes->group('', ['namespace' => 'App\Controllers\Web'], function ($r) {

    // Public pages
    $r->get('/',             'HomeController::index');
    $r->get('hotels',        'HotelWebController::index');
    $r->get('hotels/(:num)', 'HotelWebController::detail/$1');

    // Auth pages
    $r->get('login',             'AuthWebController::loginPage');
    $r->post('login',            'AuthWebController::loginPost');
    $r->get('register',          'AuthWebController::registerPage');
    $r->post('register',         'AuthWebController::registerPost');
    $r->get('otp',               'AuthWebController::otpPage');
    $r->post('otp/send',         'AuthWebController::otpSend');
    $r->post('otp/verify',       'AuthWebController::otpVerify');
    $r->get('logout',            'AuthWebController::logout');
    $r->get('forgot-password',   'AuthWebController::forgotPage');
    $r->post('forgot-password',  'AuthWebController::forgotPost');

    // Dashboard (session protected)
    $r->get('dashboard',                          'DashboardController::index',         ['filter' => 'session']);
    $r->get('dashboard/bookings',                 'DashboardController::bookings',      ['filter' => 'session']);
    $r->get('dashboard/bookings/(:num)',           'DashboardController::bookingDetail/$1', ['filter' => 'session']);
    $r->post('dashboard/bookings/(:num)/cancel',  'DashboardController::cancelBooking/$1', ['filter' => 'session']);
    $r->get('dashboard/wishlist',                 'DashboardController::wishlist',      ['filter' => 'session']);
    $r->post('dashboard/wishlist/toggle',         'DashboardController::toggleWishlist',['filter' => 'session']);
    $r->get('dashboard/profile',                  'DashboardController::profile',       ['filter' => 'session']);
    $r->post('dashboard/profile',                 'DashboardController::updateProfile', ['filter' => 'session']);

    // Booking flow (session protected)
    $r->get('booking/(:num)',              'BookingWebController::form/$1',          ['filter' => 'session']);
    $r->post('booking/(:num)',             'BookingWebController::submit/$1',        ['filter' => 'session']);
    $r->get('booking/confirm/(:num)',      'BookingWebController::confirm/$1',       ['filter' => 'session']);
    $r->get('booking/payment/(:num)',      'BookingWebController::payment/$1',       ['filter' => 'session']);
    $r->post('booking/payment/(:num)',     'BookingWebController::processPayment/$1',['filter' => 'session']);

    // ── NEW: Full Ethiopian Payment Flow ──────────────────────────────────────
    $r->get('payment/(:num)/method',       'PaymentWebController::methodPage/$1',   ['filter' => 'session']);
    $r->post('payment/(:num)/method',      'PaymentWebController::methodPost/$1',   ['filter' => 'session']);
    $r->get('payment/(:num)/summary',      'PaymentWebController::summaryPage/$1',  ['filter' => 'session']);
    $r->get('payment/(:num)/card',         'PaymentWebController::cardPage/$1',     ['filter' => 'session']);
    $r->post('payment/(:num)/card',        'PaymentWebController::process/$1',      ['filter' => 'session']);
    $r->get('payment/(:num)/bank',         'PaymentWebController::bankPage/$1',     ['filter' => 'session']);
    $r->post('payment/(:num)/bank',        'PaymentWebController::process/$1',      ['filter' => 'session']);
    $r->post('payment/(:num)/process',     'PaymentWebController::process/$1',      ['filter' => 'session']);
    $r->get('payment/(:num)/success',      'PaymentWebController::success/$1',      ['filter' => 'session']);
});

// ─────────────────────────────────────────────────────────────────────────────
//  ADMIN PANEL ROUTES  — /admin/*
// ─────────────────────────────────────────────────────────────────────────────
$routes->group('admin', ['namespace' => 'App\Controllers\Admin'], function($r) {

    // ── Auth (no filter needed) ────────────────────────────────────────────
    $r->get('login',           'AdminAuthController::loginPage');
    $r->post('login',          'AdminAuthController::loginPost');
    $r->get('logout',          'AdminAuthController::logout');
    $r->get('dashboard',       'AdminAuthController::dashboard');
    $r->get('profile',         'AdminAuthController::updateProfile',   ['filter'=>'admin']);
    $r->post('profile',        'AdminAuthController::updateProfile',   ['filter'=>'admin']);
    $r->get('change-password', 'AdminAuthController::changePassword',  ['filter'=>'admin']);
    $r->post('change-password','AdminAuthController::changePassword',  ['filter'=>'admin']);

    // ── Super Admin ──────────────────────────────────────────────────────
    $r->group('super', ['filter'=>'admin:super_admin'], function($r) {
        $r->get('dashboard',                            'SuperAdminController::dashboard');
        $r->get('sub-admins',                           'SuperAdminController::subAdmins');
        $r->get('sub-admins/create',                    'SuperAdminController::createSubAdmin');
        $r->post('sub-admins/create',                   'SuperAdminController::createSubAdmin');
        $r->get('sub-admins/(:num)/edit',               'SuperAdminController::editSubAdmin/$1');
        $r->post('sub-admins/(:num)/edit',              'SuperAdminController::editSubAdmin/$1');
        $r->post('sub-admins/(:num)/delete',            'SuperAdminController::deleteSubAdmin/$1');
        $r->post('sub-admins/(:num)/assign-city',       'SuperAdminController::assignCity/$1');
        $r->get('sub-admins/(:num)/revoke-city/(:any)', 'SuperAdminController::revokeCity/$1/$2');
        $r->get('hotels',                               'SuperAdminController::hotels');
        $r->get('hotels/add',                           'SuperAdminController::addHotel');
        $r->post('hotels/add',                          'SuperAdminController::addHotel');
        $r->get('hotels/(:num)/edit',                   'SuperAdminController::editHotel/$1');
        $r->post('hotels/(:num)/edit',                  'SuperAdminController::editHotel/$1');
        $r->post('hotels/(:num)/toggle',                'SuperAdminController::toggleHotel/$1');
        $r->get('bookings',                             'SuperAdminController::bookings');
        $r->get('users',                                'SuperAdminController::users');
        $r->get('brokers',                              'SuperAdminController::brokers');
        $r->get('managers',                             'SuperAdminController::managers');
        $r->get('cities',                               'SuperAdminController::citiesPage');
        $r->post('cities/add',                          'SuperAdminController::addCity');
        $r->post('cities/(:num)/delete',                'SuperAdminController::deleteCity/$1');
    });

    // ── Sub Admin ────────────────────────────────────────────────────────
    $r->group('subadmin', ['filter'=>'admin:sub_admin'], function($r) {
        $r->get('dashboard',                                    'SubAdminController::dashboard');
        $r->get('hotels',                                       'SubAdminController::hotels');
        $r->get('hotels/add',                                   'SubAdminController::addHotel');
        $r->post('hotels/add',                                  'SubAdminController::addHotel');
        $r->get('hotels/(:num)/edit',                           'SubAdminController::editHotel/$1');
        $r->post('hotels/(:num)/edit',                          'SubAdminController::editHotel/$1');
        $r->post('hotels/(:num)/delete',                        'SubAdminController::deleteHotel/$1');
        $r->get('hotels/(:num)/rooms',                          'SubAdminController::rooms/$1');
        $r->get('hotels/(:num)/rooms/add',                      'SubAdminController::addRoom/$1');
        $r->post('hotels/(:num)/rooms/add',                     'SubAdminController::addRoom/$1');
        $r->get('hotels/(:num)/rooms/(:num)/edit',              'SubAdminController::editRoom/$1/$2');
        $r->post('hotels/(:num)/rooms/(:num)/edit',             'SubAdminController::editRoom/$1/$2');
        $r->post('hotels/(:num)/rooms/(:num)/delete',           'SubAdminController::deleteRoom/$1/$2');
        $r->post('hotels/(:num)/rooms/(:num)/toggle',           'SubAdminController::toggleRoom/$1/$2');
        $r->get('hotels/(:num)/assign-manager',                 'SubAdminController::assignManager/$1');
        $r->post('hotels/(:num)/assign-manager',                'SubAdminController::assignManager/$1');
        $r->get('bookings',                                     'SubAdminController::bookings');
        $r->get('brokers',                                      'SubAdminController::brokers');
        $r->get('brokers/create',                               'SubAdminController::createBroker');
        $r->post('brokers/create',                              'SubAdminController::createBroker');
        $r->get('brokers/(:num)/edit',                          'SubAdminController::editBroker/$1');
        $r->post('brokers/(:num)/edit',                         'SubAdminController::editBroker/$1');
        $r->post('brokers/(:num)/delete',                       'SubAdminController::deleteBroker/$1');
    });

    // ── Broker ───────────────────────────────────────────────────────────
    $r->group('broker', ['filter'=>'admin:broker'], function($r) {
        $r->get('dashboard',              'BrokerController::dashboard');
        $r->get('hotels',                 'BrokerController::hotels');
        $r->get('hotels/(:num)/rooms',    'BrokerController::rooms/$1');
        $r->get('bookings',               'BrokerController::bookings');
        $r->get('inbox',                  'BrokerController::inbox');
        $r->get('messages/(:num)',        'BrokerController::viewMessage/$1');
        $r->get('compose',                'BrokerController::sendMessage');
        $r->post('compose',               'BrokerController::sendMessage');
        $r->get('sent',                   'BrokerController::sent');
    });

    // ── Hotel Manager ─────────────────────────────────────────────────────
    $r->group('manager', ['filter'=>'admin:hotel_manager'], function($r) {
        $r->get('dashboard',                'HotelManagerController::dashboard');
        $r->get('hotel-info',               'HotelManagerController::hotelInfo');
        $r->get('rooms',                    'HotelManagerController::rooms');
        $r->get('rooms/add',                'HotelManagerController::addRoom');
        $r->post('rooms/add',               'HotelManagerController::addRoom');
        $r->get('rooms/(:num)/edit',        'HotelManagerController::editRoom/$1');
        $r->post('rooms/(:num)/edit',       'HotelManagerController::editRoom/$1');
        $r->post('rooms/(:num)/delete',     'HotelManagerController::deleteRoom/$1');
        $r->post('rooms/(:num)/toggle',     'HotelManagerController::toggleRoom/$1');
        $r->get('bookings',                 'HotelManagerController::bookings');
        $r->post('bookings/(:num)/status',  'HotelManagerController::updateBookingStatus/$1');
        $r->get('inbox',                    'HotelManagerController::inbox');
        $r->get('messages/(:num)',          'HotelManagerController::viewMessage/$1');
        $r->get('reply',                    'HotelManagerController::reply');
        $r->post('reply',                   'HotelManagerController::reply');
    });
});
