<?= $this->extend('admin/layouts/admin') ?>
<?= $this->section('content') ?>

<h4 class="fw-900 mb-4">Hotel Information</h4>

<div class="row justify-content-center">
  <div class="col-lg-8">
    <div class="admin-form-card">
      <?php
      $img = \Config\Database::connect()->query('SELECT image_url FROM hotel_images WHERE hotel_id=? AND is_primary=TRUE LIMIT 1',[$hotel['id']])->getRowArray();
      if($img??''):
      ?>
      <img src="<?= esc($img['image_url']) ?>" alt="<?= esc($hotel['name']) ?>" class="w-100 rounded-3 mb-4" style="height:220px;object-fit:cover">
      <?php endif; ?>
      <div class="row g-3 small">
        <?php
        $fields = [
          'Name'          => $hotel['name'],
          'City'          => $hotel['city'],
          'Address'       => $hotel['address'],
          'Type'          => $hotel['type'],
          'Price/Night'   => 'ETB '.number_format($hotel['price_per_night'],0),
          'Rating'        => '⭐ '.number_format($hotel['rating'],1).' ('.number_format($hotel['review_count']).' reviews)',
          'Description'   => $hotel['description']??'-',
        ];
        foreach($fields as $label=>$val):
        ?>
        <div class="col-md-6">
          <div class="p-3 rounded-3" style="background:#f8fafc">
            <div class="text-muted fw-600 mb-1" style="font-size:.75rem;text-transform:uppercase;letter-spacing:.06em"><?= $label ?></div>
            <div class="fw-700"><?= esc($val) ?></div>
          </div>
        </div>
        <?php endforeach; ?>
      </div>
    </div>
  </div>
</div>

<?= $this->endSection() ?>
