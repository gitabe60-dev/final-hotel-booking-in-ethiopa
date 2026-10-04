<?= $this->extend('admin/layouts/admin') ?>
<?= $this->section('content') ?>

<div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-3">
  <div>
    <h4 class="fw-900 mb-0">🏙️ Manage Cities</h4>
    <p class="text-muted small mb-0"><?= count($cities) ?> cities registered — cities appear in search dropdowns instantly</p>
  </div>
</div>

<!-- Add City Form -->
<div class="admin-card p-4 mb-4">
  <h6 class="fw-800 mb-3"><i class="bi bi-plus-circle-fill text-primary me-2"></i>Add New City</h6>
  <form action="/admin/super/cities/add" method="POST">
    <?= csrf_field() ?>
    <div class="row g-3 align-items-end">
      <div class="col-md-4">
        <label class="form-label fw-700 small">City Name *</label>
        <input type="text" name="city_name" class="form-control" placeholder="e.g. Debre Markos" required
               list="eth-cities-suggest" autofocus>
        <datalist id="eth-cities-suggest">
          <?php
          $suggestions = ['Debre Markos','Wukro','Shire','Alamata','Kobo','Sekota','Dejen','Bure',
            'Merawi','Bahir Dar','Dangila','Mota','Debre Sina','Hayk','Kemissie','Ataye',
            'Tibila','Jarte','Tenta','Galikoma','Robit','Mersa','Weldiya','Lalibela',
            'Nefas Mewucha','Metema','Chilga','Aykel','Maksegnit','Gorgora','Koladiba',
            'Dabat','Janamora','Tselemt','Addi Arkay'];
          foreach ($suggestions as $s): ?>
          <option value="<?= esc($s) ?>">
          <?php endforeach; ?>
        </datalist>
      </div>
      <div class="col-md-3">
        <label class="form-label fw-700 small">Region / Zone (optional)</label>
        <input type="text" name="region" class="form-control" placeholder="e.g. Amhara"
               list="regions-suggest">
        <datalist id="regions-suggest">
          <?php foreach(['Addis Ababa City Administration','Oromia','Amhara','Tigray',
            'Sidama','SNNPR','Harari','Somali','Afar','Dire Dawa','Benishangul-Gumuz',
            'Gambella','Southwest Ethiopia','Central Ethiopia'] as $r): ?>
          <option value="<?= esc($r) ?>">
          <?php endforeach; ?>
        </datalist>
      </div>
      <div class="col-auto">
        <button type="submit" class="btn btn-primary rounded-3 fw-700 px-4">
          <i class="bi bi-plus-lg me-1"></i>Add City
        </button>
      </div>
    </div>
  </form>
</div>

<!-- Cities Grid -->
<div class="admin-card p-0">
  <div class="p-3 border-bottom fw-700"><?= count($cities) ?> cities total</div>
  <div class="p-3">
    <div class="row g-2">
      <?php foreach($cities as $c): ?>
      <div class="col-6 col-md-4 col-lg-3">
        <div class="d-flex align-items-center justify-content-between p-3 rounded-3 border"
             style="background:<?= ($c['is_active']==='t'||$c['is_active']===true)?'#f8fafc':'#fee2e2' ?>">
          <div>
            <div class="fw-700 small"><?= esc($c['name']) ?></div>
            <div class="text-muted" style="font-size:.72rem">
              <?= esc($c['region'] ?? '') ?>
              <?php if((int)($c['hotel_count']??0) > 0): ?>
              · <span class="text-primary fw-600"><?= $c['hotel_count'] ?> hotel<?= $c['hotel_count']>1?'s':'' ?></span>
              <?php endif; ?>
            </div>
          </div>
          <div class="d-flex gap-1 align-items-center">
            <?php if((int)($c['hotel_count']??0) > 0): ?>
            <a href="/hotels?city=<?= urlencode($c['name']) ?>" target="_blank"
               class="btn btn-sm btn-outline-primary rounded-pill px-2" style="font-size:.7rem" title="View hotels">
              <i class="bi bi-eye"></i>
            </a>
            <?php endif; ?>
            <form action="/admin/super/cities/<?= $c['id'] ?>/delete" method="POST"
                  onsubmit="return confirm('Remove <?= esc($c['name']) ?>? Hotels in this city will remain.')">
              <?= csrf_field() ?>
              <button type="submit" class="btn btn-sm btn-outline-danger rounded-pill px-2" style="font-size:.7rem" title="Remove city">
                <i class="bi bi-trash"></i>
              </button>
            </form>
          </div>
        </div>
      </div>
      <?php endforeach; ?>
    </div>
  </div>
</div>

<?= $this->endSection() ?>
