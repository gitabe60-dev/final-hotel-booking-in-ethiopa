<?php

namespace App\Controllers\Web;

use App\Models\BookingModel;
use App\Models\PaymentModel;
use App\Models\HotelModel;
use CodeIgniter\Controller;

/**
 * PaymentWebController
 *
 * Full Ethiopian payment flow:
 *
 *  Step 1 — /payment/{bookingId}/method
 *           Select payment method (Telebirr, CBE Birr, Amhara Bank, etc.)
 *
 *  Step 2 — /payment/{bookingId}/summary
 *           Review booking + selected method → "Pay Now"
 *
 *  Step 3a — /payment/{bookingId}/card
 *            Test Card form (card name, number, expiry, CVV)
 *
 *  Step 3b — /payment/{bookingId}/bank
 *            Test Bank/Mobile form (phone or account number)
 *
 *  Step 4  — POST /payment/{bookingId}/process
 *            Simulate payment → mark paid → confirm booking
 *
 *  Step 5  — /payment/{bookingId}/success
 *            Success receipt page
 */
class PaymentWebController extends Controller
{
    private BookingModel $bookingModel;
    private PaymentModel $paymentModel;
    private HotelModel   $hotelModel;

    // All supported Ethiopian payment methods
    public const METHODS = [
        'telebirr'      => ['name'=>'Telebirr',         'icon'=>'📱', 'color'=>'#00B0FF', 'type'=>'mobile',  'logo'=>'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e9/Telebirr_Logo.svg/200px-Telebirr_Logo.svg.png'],
        'cbe_birr'      => ['name'=>'CBE Birr',          'icon'=>'🏦', 'color'=>'#003087', 'type'=>'mobile',  'logo'=>'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9e/CBE_logo.png/200px-CBE_logo.png'],
        'amhara_bank'   => ['name'=>'Amhara Bank',       'icon'=>'🏛️', 'color'=>'#1a56db', 'type'=>'bank',    'logo'=>''],
        'awash_bank'    => ['name'=>'Awash Bank',         'icon'=>'🏛️', 'color'=>'#c0392b', 'type'=>'bank',    'logo'=>''],
        'dashen_bank'   => ['name'=>'Dashen Bank',        'icon'=>'🏛️', 'color'=>'#27ae60', 'type'=>'bank',    'logo'=>''],
        'abyssinia_bank'=> ['name'=>'Bank of Abyssinia',  'icon'=>'🏛️', 'color'=>'#8e44ad', 'type'=>'bank',    'logo'=>''],
        'bunna_bank'    => ['name'=>'Bunna Bank',         'icon'=>'🏛️', 'color'=>'#e67e22', 'type'=>'bank',    'logo'=>''],
        'oromia_bank'   => ['name'=>'Oromia Bank',        'icon'=>'🏛️', 'color'=>'#16a085', 'type'=>'bank',    'logo'=>''],
        'card'          => ['name'=>'Credit/Debit Card',  'icon'=>'💳', 'color'=>'#2c3e50', 'type'=>'card',    'logo'=>''],
        'mobile_money'  => ['name'=>'HelloCash',          'icon'=>'📲', 'color'=>'#f39c12', 'type'=>'mobile',  'logo'=>''],
        'bank_transfer' => ['name'=>'Bank Transfer',      'icon'=>'🔄', 'color'=>'#7f8c8d', 'type'=>'bank',    'logo'=>''],
        'cash'          => ['name'=>'Pay at Hotel',       'icon'=>'💵', 'color'=>'#2ecc71', 'type'=>'cash',    'logo'=>''],
    ];

    public function __construct()
    {
        $this->bookingModel = new BookingModel();
        $this->paymentModel = new PaymentModel();
        $this->hotelModel   = new HotelModel();
    }

    private function userId(): int { return (int)session()->get('user_id'); }

    // ─── Guard: load booking or redirect ─────────────────────────────────────

    private function loadBooking(int $bookingId): ?array
    {
        if (!$this->userId()) {
            redirect()->to('/login')->send();
            return null;
        }
        $b = $this->bookingModel->getDetail($bookingId, $this->userId());
        if (!$b) {
            redirect()->to('/dashboard/bookings')->with('error', 'Booking not found.')->send();
            return null;
        }
        return $b;
    }

    // ─── Step 1: Choose payment method ───────────────────────────────────────

    public function methodPage(int $bookingId)
    {
        $booking = $this->loadBooking($bookingId);
        if (!$booking) return;

        if ($booking['status'] === 'confirmed') {
            return redirect()->to("/payment/$bookingId/success");
        }

        return view('payment/method', [
            'booking'   => $booking,
            'methods'   => self::METHODS,
            'pageTitle' => 'Choose Payment Method — Dallol Booking',
            'step'      => 1,
        ]);
    }

    public function methodPost(int $bookingId)
    {
        $booking = $this->loadBooking($bookingId);
        if (!$booking) return;

        $method = $this->request->getPost('payment_method');
        if (!array_key_exists($method, self::METHODS)) {
            return redirect()->back()->with('error', 'Please select a payment method.');
        }

        // Save method to session for this booking
        session()->set("pay_method_$bookingId", $method);

        // Update booking payment method in DB
        $this->bookingModel->update($bookingId, ['payment_method' => $method]);

        return redirect()->to("/payment/$bookingId/summary");
    }

    // ─── Step 2: Booking summary + Pay Now ───────────────────────────────────

    public function summaryPage(int $bookingId)
    {
        $booking = $this->loadBooking($bookingId);
        if (!$booking) return;

        if ($booking['status'] === 'confirmed') {
            return redirect()->to("/payment/$bookingId/success");
        }

        $method    = session()->get("pay_method_$bookingId") ?? $booking['payment_method'] ?? 'telebirr';
        $methodInfo = self::METHODS[$method] ?? self::METHODS['telebirr'];

        $payment = $this->paymentModel->getByBooking($bookingId);
        if (!$payment) {
            $this->paymentModel->createPayment($bookingId, $this->userId(), (float)$booking['total_price'], $method);
            $payment = $this->paymentModel->getByBooking($bookingId);
        }

        $nights = max(1, (strtotime($booking['check_out']) - strtotime($booking['check_in'])) / 86400);

        return view('payment/summary', [
            'booking'    => $booking,
            'method'     => $method,
            'methodInfo' => $methodInfo,
            'payment'    => $payment,
            'nights'     => (int)$nights,
            'pageTitle'  => 'Review & Pay — Dallol Booking',
            'step'       => 2,
        ]);
    }

    // ─── Step 3a: Card payment form ──────────────────────────────────────────

    public function cardPage(int $bookingId)
    {
        $booking = $this->loadBooking($bookingId);
        if (!$booking) return;

        if ($booking['status'] === 'confirmed') {
            return redirect()->to("/payment/$bookingId/success");
        }

        $method = session()->get("pay_method_$bookingId") ?? 'card';

        return view('payment/card', [
            'booking'   => $booking,
            'method'    => $method,
            'pageTitle' => 'Card Payment — Dallol Booking',
            'step'      => 3,
        ]);
    }

    // ─── Step 3b: Bank / Mobile payment form ─────────────────────────────────

    public function bankPage(int $bookingId)
    {
        $booking = $this->loadBooking($bookingId);
        if (!$booking) return;

        if ($booking['status'] === 'confirmed') {
            return redirect()->to("/payment/$bookingId/success");
        }

        $method     = session()->get("pay_method_$bookingId") ?? $booking['payment_method'] ?? 'telebirr';
        $methodInfo = self::METHODS[$method] ?? self::METHODS['telebirr'];

        return view('payment/bank', [
            'booking'    => $booking,
            'method'     => $method,
            'methodInfo' => $methodInfo,
            'pageTitle'  => $methodInfo['name'] . ' Payment — Dallol Booking',
            'step'       => 3,
        ]);
    }

    // ─── Step 4: Process payment (simulate) ──────────────────────────────────

    public function process(int $bookingId)
    {
        $booking = $this->loadBooking($bookingId);
        if (!$booking) return;

        if ($booking['status'] === 'confirmed') {
            return redirect()->to("/payment/$bookingId/success");
        }

        $method     = session()->get("pay_method_$bookingId") ?? $booking['payment_method'] ?? 'telebirr';
        $methodInfo = self::METHODS[$method] ?? self::METHODS['telebirr'];

        // Collect payment details from POST (for display on receipt)
        $payDetails = [];
        switch ($methodInfo['type']) {
            case 'card':
                $payDetails = [
                    'card_name'   => $this->request->getPost('card_name') ?? '',
                    'card_number' => '****' . substr(str_replace(' ', '', $this->request->getPost('card_number') ?? ''), -4),
                    'expiry'      => $this->request->getPost('expiry') ?? '',
                ];
                break;
            case 'mobile':
            case 'bank':
                $payDetails = [
                    'phone'   => $this->request->getPost('phone') ?? '',
                    'account' => $this->request->getPost('account_number') ?? '',
                    'bank'    => $this->request->getPost('bank_name') ?? $methodInfo['name'],
                ];
                break;
            case 'cash':
                $payDetails = ['note' => 'Pay at hotel reception on check-in'];
                break;
        }

        // Simulate payment processing (in production: call actual gateway)
        $txId       = 'DALLOL-' . strtoupper(bin2hex(random_bytes(5)));
        $gatewayRef = date('YmdHis') . '-' . $bookingId;

        // Update payment record
        $payment = $this->paymentModel->getByBooking($bookingId);
        if (!$payment) {
            $payId = $this->paymentModel->createPayment(
                $bookingId, $this->userId(), (float)$booking['total_price'], $method
            );
            $payment = $this->paymentModel->find($payId);
        }

        $this->paymentModel->markCompleted((int)$payment['id'], $txId, $gatewayRef);

        // Confirm booking
        $this->bookingModel->update($bookingId, ['status' => 'confirmed']);

        // Save receipt details to session
        session()->set("pay_receipt_$bookingId", [
            'tx_id'      => $txId,
            'method'     => $method,
            'method_name'=> $methodInfo['name'],
            'amount'     => $booking['total_price'],
            'details'    => $payDetails,
            'paid_at'    => date('d M Y, H:i'),
        ]);

        // Clean up method session
        session()->remove("pay_method_$bookingId");

        return redirect()->to("/payment/$bookingId/success")
            ->with('success', '🎉 Payment successful! Your booking is confirmed.');
    }

    // ─── Step 5: Success page ─────────────────────────────────────────────────

    public function success(int $bookingId)
    {
        if (!$this->userId()) return redirect()->to('/login');

        $booking = $this->bookingModel->getDetail($bookingId, $this->userId());
        if (!$booking) return redirect()->to('/dashboard/bookings');

        $payment = $this->paymentModel->getByBooking($bookingId);
        $receipt = session()->get("pay_receipt_$bookingId") ?? [];

        $nights = max(1, (strtotime($booking['check_out']) - strtotime($booking['check_in'])) / 86400);

        return view('payment/success', [
            'booking'   => $booking,
            'payment'   => $payment,
            'receipt'   => $receipt,
            'nights'    => (int)$nights,
            'pageTitle' => 'Payment Confirmed — Dallol Booking',
        ]);
    }
}
