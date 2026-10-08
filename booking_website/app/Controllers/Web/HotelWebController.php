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

        $page   = max(1, (int)($get['page'] ?? 1));
        $limit  = 12;

        $params = [
            'city'       => trim($get['city']       ?? ''),
            'hotel_name' => trim($get['hotel_name'] ?? ''),
            'check_in'   => $get['check_in']   ?? date('Y-m-d'),
            'check_out'  => $get['check_out']  ?? date('Y-m-d', strtotime('+1 day')),
            'adults'     => max(1, (int)($get['adults']   ?? 2)),
            'children'   => max(0, (int)($get['children'] ?? 0)),
            'rooms'      => max(1, (int)($get['rooms']    ?? 1)),
            'min_price'  => $get['min_price']  ?? null,
            'max_price'  => $get['max_price']  ?? null,
            'min_rating' => $get['min_rating'] ?? null,
            'type'       => $get['type']       ?? null,
            'sort'       => $get['sort']       ?? 'rating',
            'limit'      => $limit,
            'offset'     => ($page - 1) * $limit,
        ];

        // Validate dates
        if ($params['check_in'] < date('Y-m-d')) {
            $params['check_in'] = date('Y-m-d');
        }
        if ($params['check_out'] <= $params['check_in']) {
            $params['check_out'] = date('Y-m-d', strtotime($params['check_in'] . ' +1 day'));
        }

        $total     = $this->hotelModel->countSearch($params);
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

        $pageTitle = !empty($params['city'])
            ? "Hotels in {$params['city']} ({$total} found)"
            : "All Hotels in Ethiopia ({$total} found)";

        return view('hotels/list', [
            'hotels'          => $hotels,
            'params'          => $params,
            'total'           => $total,
            'page'            => $page,
            'totalPages'      => max(1, (int)ceil($total / $limit)),
            'pageTitle'       => $pageTitle,
            'cities'          => $this->getCities(),
            'hotelTypes'      => ['All','Hotel','Resort','Lodge','Guest House','Boutique'],
            'priceSuggestion' => $priceSuggestion,
            'bestValue'       => $bestValue,
        ]);
    }

    // ─── Hotel detail ────────────────────────────────────────────────────────

    public function detail(int $id)
    {
        $today    = date('Y-m-d');
        $tomorrow = date('Y-m-d', strtotime('+1 day'));

        // Dates MUST come first — needed for room availability check
        $checkIn  = $this->request->getGet('check_in')  ?? $today;
        $checkOut = $this->request->getGet('check_out') ?? $tomorrow;
        $adults   = max(1, (int)($this->request->getGet('adults')   ?? 2));
        $children = max(0, (int)($this->request->getGet('children') ?? 0));
        $rooms    = max(1, (int)($this->request->getGet('rooms')    ?? 1));

        // Sanitize dates
        if ($checkIn < $today)             $checkIn  = $today;
        if ($checkOut <= $checkIn)         $checkOut = date('Y-m-d', strtotime($checkIn . ' +1 day'));

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

    // ─── Helper: cities for dropdowns ────────────────────────────────────────

    private function getCities(): array
    {
        $cityModel = new \App\Models\CityModel();
        // Get all active cities with hotel counts
        $rows = $cityModel->getAll();

        // Also union any hotels whose city isn't in cities table yet
        $knownNames = array_map('strtolower', array_column($rows, 'name'));
        $dbCities   = \Config\Database::connect()->query(
            "SELECT DISTINCT city AS name FROM hotels WHERE is_active=TRUE AND city IS NOT NULL ORDER BY city"
        )->getResultArray();

        foreach ($dbCities as $c) {
            if (!in_array(strtolower($c['name']), $knownNames)) {
                $rows[] = ['id' => 0, 'name' => $c['name'], 'region' => '', 'hotel_count' => 1];
            }
        }

        usort($rows, fn($a,$b) => strcmp($a['name'], $b['name']));
        return $rows;
    }
}
