<?php

namespace App\Controllers\Web;

use App\Models\HotelModel;
use App\Models\CityModel;
use App\Models\ExpertModel;
use CodeIgniter\Controller;

class HomeController extends Controller
{
    public function index()
    {
        $hotelModel = new HotelModel();
        $cityModel  = new CityModel();
        $expert     = new ExpertModel();

        $featured    = $hotelModel->getFeatured(8);
        $cities      = $cityModel->getActive();
        $destCities  = $cityModel->getWithHotels();
        $trending    = $expert->getTrending(4);

        return view('home/index', [
            'featured'   => $featured,
            'cities'     => $cities,
            'destCities' => $destCities,
            'trending'   => $trending,
            'hotelTypes' => ['Hotel', 'Resort', 'Lodge', 'Guest House', 'Boutique'],
            'pageTitle'  => 'Dallol Booking — Find Your Perfect Stay in Ethiopia',
        ]);
    }
}
