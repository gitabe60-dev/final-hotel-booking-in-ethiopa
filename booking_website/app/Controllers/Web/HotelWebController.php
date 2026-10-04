<?php

namespace App\Controllers\Web;

use App\Models\HotelModel;
use App\Models\ReviewModel;
use App\Models\WishlistModel;
use App\Models\ExpertModel;
use CodeIgniter\Controller;

class HotelWebController extends Controller
{
    private HotelModel    $hotelModel;
    private ReviewModel   $reviewModel;
    private WishlistModel $wishlistModel;
    private ExpertModel   $expertModel;

    public function __construct()
    {
        $this->hotelModel    = new HotelModel();
        $this->reviewModel   = new ReviewModel();
        $this->wishlistModel = new WishlistModel();
        $this->expertModel   = new ExpertModel();
    }

    // ─── Hotel list / search ─────────────────────────────────────────────────

    public function index()
    {
        $get = $this->request->getGet();

        $params = [
            'city'       => $get['city']       ?? '',
            'hotel_name' => $get['hotel_name'] ?? '',
            'check_in'   => $get['check_in']   ?? date('Y-m-d'),
            'check_out'  => $get['check_out']  ?? date('Y-m-d', strtotime('+1 day')),
            'adults'     => $get['adults']     ?? 2,
            'children'   => $get['children']   ?? 0,
            'rooms'      => $get['rooms']      ?? 1,
            'min_price'  => $get['min_price']  ?? null,
            'max_price'  => $get['max_price']  ?? null,
            'min_rating' => $get['min_rating'] ?? null,
            'type'       => $get['type']       ?? null,
            'sort'       => $get['sort']       ?? 'rating',
            'limit'      => 12,
            'offset'     => (int)($get['page'] ?? 1) > 1 ? ((int)($get['page'] ?? 1) - 1) * 12 : 0,
        ];

        $hotels    = $this->hotelModel->search($params);
        $userId    = session()->get('user_id');
        $wishlisted = $userId ? $this->wishlistModel->getWishlistedIds($userId) : [];

        foreach ($hotels as &$h) {
            $h['is_wishlisted'] = in_array($h['id'], $wishlisted);
        }
        unset($h);

        // Price suggestion for selected city
        $priceSuggestion = !empty($params['city'])
            ? $this->expertModel->getPriceSuggestion($params['city'])
            : [];

        // Best value hotels for sidebar
        $bestValue = $this->expertModel->getBestValue($params['city'] ?? '', 3);

        return view('hotels/list', [
            'hotels'          => $hotels,
            'params'          => $params,
            'pageTitle'       => !empty($params['city']) ? 'Hotels in '.$params['city'] : 'All Hotels in Ethiopia',
            'cities'          => $this->getCities(),
            'hotelTypes'      => ['All','Hotel','Resort','Lodge','Guest House','Boutique'],
            'priceSuggestion' => $priceSuggestion,
            'bestValue'       => $bestValue,
        ]);
    }

    // ─── Hotel detail ────────────────────────────────────────────────────────

    public function detail(int $id)
    {
        // Dates MUST come first — needed for room availability check
        $checkIn  = $this->request->getGet('check_in')  ?? date('Y-m-d');
        $checkOut = $this->request->getGet('check_out') ?? date('Y-m-d', strtotime('+1 day'));
        $adults   = max(1, (int)($this->request->getGet('adults')   ?? 2));
        $children = max(0, (int)($this->request->getGet('children') ?? 0));
        $rooms    = max(1, (int)($this->request->getGet('rooms')    ?? 1));

        $hotel = $this->hotelModel->getDetail($id, $checkIn, $checkOut);
        if (!$hotel) {
            throw \CodeIgniter\Exceptions\PageNotFoundException::forPageNotFound('Hotel not found');
        }

        $userId       = session()->get('user_id');
        $isWishlisted = $userId ? $this->wishlistModel->isWishlisted($userId, $id) : false;
        $summary      = $this->reviewModel->getRatingSummary($id);
        $similar      = $this->expertModel->getSimilar($hotel, 3, $userId);

        return view('hotels/detail', [
            'hotel'       => $hotel,
            'isWishlisted'=> $isWishlisted,
            'summary'     => $summary,
            'similar'     => $similar,
            'pageTitle'   => $hotel['name'] . ' — Dallol Booking',
            'checkIn'     => $checkIn,
            'checkOut'    => $checkOut,
            'adults'      => $adults,
            'children'    => $children,
            'rooms'       => $rooms,
        ]);
    }

        // ─── Helper ──────────────────────────────────────────────────────────────

    private function getCities(): array
    {
        // Dynamic: pull from cities table
        $cityModel = new \App\Models\CityModel();
        $rows = $cityModel->getActive();
        $names = array_column($rows, 'name');
        // Ensure any hotel cities not in cities table are included
        $dbCities = \Config\Database::connect()->query(
            "SELECT DISTINCT city FROM hotels WHERE is_active=TRUE AND city IS NOT NULL ORDER BY city"
        )->getResultArray();
        foreach (array_column($dbCities, 'city') as $c) {
            if (!in_array($c, $names)) $names[] = $c;
        }
        sort($names);
        return $names;
    }
}
