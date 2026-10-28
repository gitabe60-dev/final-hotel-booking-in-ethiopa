-- database/seed.sql
-- Idempotent seed data for DallolBook.
-- Safe to run multiple times — uses ON CONFLICT DO NOTHING.

-- ─── Cities ──────────────────────────────────────────────────────────────────
INSERT INTO cities (name, region, is_active) VALUES
  ('Addis Ababa', 'Addis Ababa City Administration', true),
  ('Dire Dawa',   'Dire Dawa City Administration',   true),
  ('Hawassa',     'Sidama Region',                   true),
  ('Bahir Dar',   'Amhara Region',                   true),
  ('Gondar',      'Amhara Region',                   true),
  ('Mekelle',     'Tigray Region',                   true),
  ('Jimma',       'Oromia Region',                   true),
  ('Adama',       'Oromia Region',                   true),
  ('Harar',       'Harari Region',                   true),
  ('Arba Minch',  'SNNPR',                           true)
ON CONFLICT (name) DO NOTHING;

-- ─── Hotels ──────────────────────────────────────────────────────────────────
INSERT INTO hotels (name,city,address,description,type,rating,review_count,price_per_night,latitude,longitude,is_featured,is_active)
VALUES
  ('Sheraton Addis','Addis Ababa','Taitu Street, Addis Ababa',
   'Iconic 5-star luxury hotel in the heart of Addis Ababa with world-class amenities, multiple restaurants, and a stunning outdoor pool.',
   'hotel',4.8,412,250.00,9.0192,38.7525,true,true),
  ('Hilton Addis Ababa','Addis Ababa','Menelik II Avenue, Addis Ababa',
   'Premier business hotel offering elegant rooms, conference facilities, and fine dining overlooking the city.',
   'hotel',4.6,318,190.00,9.0227,38.7468,true,true),
  ('Kuriftu Resort & Spa Bahir Dar','Bahir Dar','Lake Tana Shore, Bahir Dar',
   'Serene lakeside resort featuring traditional Ethiopian architecture, a full-service spa, and stunning Lake Tana views.',
   'resort',4.7,205,180.00,11.5936,37.3876,true,true),
  ('Haile Resort Hawassa','Hawassa','Lake Hawassa Road, Hawassa',
   'Sprawling lakefront resort with spacious bungalows, water sports, and multiple dining options on Lake Hawassa.',
   'resort',4.5,287,150.00,7.0504,38.4955,true,true),
  ('Goha Hotel Gondar','Gondar','Goha Hill, Gondar',
   'Hilltop hotel offering breathtaking panoramic views of the Royal Enclosure and surrounding highlands.',
   'hotel',4.3,176,120.00,12.609,37.4675,false,true),
  ('Axum Hotel','Mekelle','Airport Road, Mekelle',
   'Comfortable hotel close to Tigray historical sites with modern amenities and authentic local cuisine.',
   'hotel',4.0,98,90.00,13.4967,39.4753,false,true),
  ('Kuriftu Resort Adama','Adama','Main Resort Road, Adama',
   'Modern resort outside Addis Ababa with a large pool, spa, gardens, and easy highway access.',
   'resort',4.4,221,160.00,8.54,39.27,true,true),
  ('Ras Hotel Dire Dawa','Dire Dawa','Kezira District, Dire Dawa',
   'Historic colonial-era hotel in eastern Ethiopia, known for its classic architecture and warm hospitality.',
   'hotel',3.9,134,80.00,9.5931,41.8661,false,true),
  ('Lewi Resort Bahir Dar','Bahir Dar','Lake Tana Promenade, Bahir Dar',
   'Boutique resort with private pier access to Lake Tana, lush gardens, and a rooftop bar.',
   'resort',4.6,163,200.00,11.601,37.382,true,true),
  ('Harar Walled City Lodge','Harar','Inside the Jugol, Harar',
   'Unique heritage lodge set within the ancient walled city of Harar, offering cultural immersion and traditional design.',
   'boutique',4.5,89,110.00,9.312,42.125,true,true)
ON CONFLICT DO NOTHING;

-- ─── Hotel Images ─────────────────────────────────────────────────────────────
DO $$
DECLARE r RECORD;
BEGIN
  FOR r IN (SELECT * FROM (VALUES
    ('Sheraton Addis',              0,true, 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800'),
    ('Sheraton Addis',              1,false,'https://images.unsplash.com/photo-1582719508461-905c673771fd?w=800'),
    ('Hilton Addis Ababa',          0,true, 'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=800'),
    ('Hilton Addis Ababa',          1,false,'https://images.unsplash.com/photo-1564501049412-61c2a3083791?w=800'),
    ('Kuriftu Resort & Spa Bahir Dar',0,true,'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=800'),
    ('Kuriftu Resort & Spa Bahir Dar',1,false,'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=800'),
    ('Haile Resort Hawassa',        0,true, 'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=800'),
    ('Haile Resort Hawassa',        1,false,'https://images.unsplash.com/photo-1564501049412-61c2a3083791?w=800'),
    ('Goha Hotel Gondar',           0,true, 'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=800'),
    ('Axum Hotel',                  0,true, 'https://images.unsplash.com/photo-1445019980597-93fa8acb246c?w=800'),
    ('Kuriftu Resort Adama',        0,true, 'https://images.unsplash.com/photo-1564501049412-61c2a3083791?w=800'),
    ('Kuriftu Resort Adama',        1,false,'https://images.unsplash.com/photo-1549294413-26f195200c16?w=800'),
    ('Ras Hotel Dire Dawa',         0,true, 'https://images.unsplash.com/photo-1549294413-26f195200c16?w=800'),
    ('Lewi Resort Bahir Dar',       0,true, 'https://images.unsplash.com/photo-1506059612708-99d6c258160e?w=800'),
    ('Lewi Resort Bahir Dar',       1,false,'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=800'),
    ('Harar Walled City Lodge',     0,true, 'https://images.unsplash.com/photo-1590447306561-90a2b4c3dcda?w=800')
  ) AS t(hname,sorder,isprimary,imgurl)) LOOP
    INSERT INTO hotel_images(hotel_id,image_url,sort_order,is_primary)
    SELECT h.id, r.imgurl, r.sorder, r.isprimary
    FROM hotels h WHERE h.name=r.hname
    ON CONFLICT DO NOTHING;
  END LOOP;
END $$;

-- ─── Hotel Amenities ──────────────────────────────────────────────────────────
DO $$
DECLARE h_id INT;
BEGIN
  SELECT id INTO h_id FROM hotels WHERE name='Sheraton Addis';
  IF NOT EXISTS(SELECT 1 FROM hotel_amenities WHERE hotel_id=h_id) THEN
    INSERT INTO hotel_amenities(hotel_id,amenity) VALUES
      (h_id,'Free WiFi'),(h_id,'Swimming Pool'),(h_id,'Spa'),(h_id,'Gym'),
      (h_id,'Restaurant'),(h_id,'Bar'),(h_id,'Room Service'),(h_id,'Airport Shuttle'),
      (h_id,'Business Center'),(h_id,'Parking');
  END IF;

  SELECT id INTO h_id FROM hotels WHERE name='Hilton Addis Ababa';
  IF NOT EXISTS(SELECT 1 FROM hotel_amenities WHERE hotel_id=h_id) THEN
    INSERT INTO hotel_amenities(hotel_id,amenity) VALUES
      (h_id,'Free WiFi'),(h_id,'Swimming Pool'),(h_id,'Gym'),
      (h_id,'Restaurant'),(h_id,'Bar'),(h_id,'Room Service'),
      (h_id,'Conference Room'),(h_id,'Parking');
  END IF;

  SELECT id INTO h_id FROM hotels WHERE name='Kuriftu Resort & Spa Bahir Dar';
  IF NOT EXISTS(SELECT 1 FROM hotel_amenities WHERE hotel_id=h_id) THEN
    INSERT INTO hotel_amenities(hotel_id,amenity) VALUES
      (h_id,'Free WiFi'),(h_id,'Swimming Pool'),(h_id,'Spa'),(h_id,'Gym'),
      (h_id,'Restaurant'),(h_id,'Lake View'),(h_id,'Boat Tours'),(h_id,'Parking');
  END IF;

  SELECT id INTO h_id FROM hotels WHERE name='Haile Resort Hawassa';
  IF NOT EXISTS(SELECT 1 FROM hotel_amenities WHERE hotel_id=h_id) THEN
    INSERT INTO hotel_amenities(hotel_id,amenity) VALUES
      (h_id,'Free WiFi'),(h_id,'Swimming Pool'),(h_id,'Gym'),(h_id,'Restaurant'),
      (h_id,'Bar'),(h_id,'Water Sports'),(h_id,'Lake View'),(h_id,'Parking');
  END IF;

  SELECT id INTO h_id FROM hotels WHERE name='Goha Hotel Gondar';
  IF NOT EXISTS(SELECT 1 FROM hotel_amenities WHERE hotel_id=h_id) THEN
    INSERT INTO hotel_amenities(hotel_id,amenity) VALUES
      (h_id,'Free WiFi'),(h_id,'Swimming Pool'),(h_id,'Restaurant'),
      (h_id,'Bar'),(h_id,'Panoramic View'),(h_id,'Parking');
  END IF;

  SELECT id INTO h_id FROM hotels WHERE name='Axum Hotel';
  IF NOT EXISTS(SELECT 1 FROM hotel_amenities WHERE hotel_id=h_id) THEN
    INSERT INTO hotel_amenities(hotel_id,amenity) VALUES
      (h_id,'Free WiFi'),(h_id,'Restaurant'),(h_id,'Parking'),(h_id,'Air Conditioning');
  END IF;

  SELECT id INTO h_id FROM hotels WHERE name='Kuriftu Resort Adama';
  IF NOT EXISTS(SELECT 1 FROM hotel_amenities WHERE hotel_id=h_id) THEN
    INSERT INTO hotel_amenities(hotel_id,amenity) VALUES
      (h_id,'Free WiFi'),(h_id,'Swimming Pool'),(h_id,'Spa'),(h_id,'Gym'),
      (h_id,'Restaurant'),(h_id,'Bar'),(h_id,'Parking'),(h_id,'Garden');
  END IF;

  SELECT id INTO h_id FROM hotels WHERE name='Ras Hotel Dire Dawa';
  IF NOT EXISTS(SELECT 1 FROM hotel_amenities WHERE hotel_id=h_id) THEN
    INSERT INTO hotel_amenities(hotel_id,amenity) VALUES
      (h_id,'Free WiFi'),(h_id,'Restaurant'),(h_id,'Bar'),(h_id,'Parking');
  END IF;

  SELECT id INTO h_id FROM hotels WHERE name='Lewi Resort Bahir Dar';
  IF NOT EXISTS(SELECT 1 FROM hotel_amenities WHERE hotel_id=h_id) THEN
    INSERT INTO hotel_amenities(hotel_id,amenity) VALUES
      (h_id,'Free WiFi'),(h_id,'Swimming Pool'),(h_id,'Restaurant'),
      (h_id,'Bar'),(h_id,'Lake View'),(h_id,'Private Pier'),(h_id,'Parking');
  END IF;

  SELECT id INTO h_id FROM hotels WHERE name='Harar Walled City Lodge';
  IF NOT EXISTS(SELECT 1 FROM hotel_amenities WHERE hotel_id=h_id) THEN
    INSERT INTO hotel_amenities(hotel_id,amenity) VALUES
      (h_id,'Free WiFi'),(h_id,'Restaurant'),(h_id,'Cultural Tours'),
      (h_id,'Rooftop Terrace'),(h_id,'Air Conditioning');
  END IF;
END $$;

-- ─── Room Types (with images) ─────────────────────────────────────────────────
DO $$
DECLARE h_id INT;
BEGIN
  SELECT id INTO h_id FROM hotels WHERE name='Sheraton Addis';
  IF NOT EXISTS(SELECT 1 FROM room_types WHERE hotel_id=h_id) THEN
    INSERT INTO room_types(hotel_id,name,bed_type,price_per_night,size_sqm,max_guests,is_available,image_url) VALUES
      (h_id,'Deluxe Room',    'King', 250,45,2,true,'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800'),
      (h_id,'Executive Suite','King', 450,85,3,true,'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=800'),
      (h_id,'Twin Room',      'Twin', 230,42,2,true,'https://images.unsplash.com/photo-1595526114035-0d45ed16cfbf?w=800');
  END IF;

  SELECT id INTO h_id FROM hotels WHERE name='Hilton Addis Ababa';
  IF NOT EXISTS(SELECT 1 FROM room_types WHERE hotel_id=h_id) THEN
    INSERT INTO room_types(hotel_id,name,bed_type,price_per_night,size_sqm,max_guests,is_available,image_url) VALUES
      (h_id,'Standard Room','Queen',190,38,2,true,'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800'),
      (h_id,'Junior Suite', 'King', 320,65,3,true,'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=800');
  END IF;

  SELECT id INTO h_id FROM hotels WHERE name='Kuriftu Resort & Spa Bahir Dar';
  IF NOT EXISTS(SELECT 1 FROM room_types WHERE hotel_id=h_id) THEN
    INSERT INTO room_types(hotel_id,name,bed_type,price_per_night,size_sqm,max_guests,is_available,image_url) VALUES
      (h_id,'Lake View Bungalow','King',180,50,2,true,'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=800'),
      (h_id,'Garden Villa',     'King',250,80,4,true,'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=800');
  END IF;

  SELECT id INTO h_id FROM hotels WHERE name='Haile Resort Hawassa';
  IF NOT EXISTS(SELECT 1 FROM room_types WHERE hotel_id=h_id) THEN
    INSERT INTO room_types(hotel_id,name,bed_type,price_per_night,size_sqm,max_guests,is_available,image_url) VALUES
      (h_id,'Standard Bungalow','Double',150,40,2,true,'https://images.unsplash.com/photo-1595526114035-0d45ed16cfbf?w=800'),
      (h_id,'Family Bungalow',  'Twin',  220,70,4,true,'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800');
  END IF;

  SELECT id INTO h_id FROM hotels WHERE name='Goha Hotel Gondar';
  IF NOT EXISTS(SELECT 1 FROM room_types WHERE hotel_id=h_id) THEN
    INSERT INTO room_types(hotel_id,name,bed_type,price_per_night,size_sqm,max_guests,is_available,image_url) VALUES
      (h_id,'Standard Room','Double',120,35,2,true,'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=800'),
      (h_id,'Superior Room','King',  160,45,2,true,'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800');
  END IF;

  SELECT id INTO h_id FROM hotels WHERE name='Axum Hotel';
  IF NOT EXISTS(SELECT 1 FROM room_types WHERE hotel_id=h_id) THEN
    INSERT INTO room_types(hotel_id,name,bed_type,price_per_night,size_sqm,max_guests,is_available,image_url) VALUES
      (h_id,'Standard Room','Double',90, 32,2,true,'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800'),
      (h_id,'Deluxe Room',  'King',  120,40,2,true,'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=800');
  END IF;

  SELECT id INTO h_id FROM hotels WHERE name='Kuriftu Resort Adama';
  IF NOT EXISTS(SELECT 1 FROM room_types WHERE hotel_id=h_id) THEN
    INSERT INTO room_types(hotel_id,name,bed_type,price_per_night,size_sqm,max_guests,is_available,image_url) VALUES
      (h_id,'Pool View Room','King',160,42,2,true,'https://images.unsplash.com/photo-1564501049412-61c2a3083791?w=800'),
      (h_id,'Family Suite',  'King',280,90,5,true,'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=800');
  END IF;

  SELECT id INTO h_id FROM hotels WHERE name='Ras Hotel Dire Dawa';
  IF NOT EXISTS(SELECT 1 FROM room_types WHERE hotel_id=h_id) THEN
    INSERT INTO room_types(hotel_id,name,bed_type,price_per_night,size_sqm,max_guests,is_available,image_url) VALUES
      (h_id,'Classic Room', 'Double',80, 30,2,true,'https://images.unsplash.com/photo-1595526114035-0d45ed16cfbf?w=800'),
      (h_id,'Superior Room','King',  100,38,2,true,'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800');
  END IF;

  SELECT id INTO h_id FROM hotels WHERE name='Lewi Resort Bahir Dar';
  IF NOT EXISTS(SELECT 1 FROM room_types WHERE hotel_id=h_id) THEN
    INSERT INTO room_types(hotel_id,name,bed_type,price_per_night,size_sqm,max_guests,is_available,image_url) VALUES
      (h_id,'Lake View Room','King',200,48,2,true,'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=800'),
      (h_id,'Premium Suite', 'King',350,95,3,true,'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=800');
  END IF;

  SELECT id INTO h_id FROM hotels WHERE name='Harar Walled City Lodge';
  IF NOT EXISTS(SELECT 1 FROM room_types WHERE hotel_id=h_id) THEN
    INSERT INTO room_types(hotel_id,name,bed_type,price_per_night,size_sqm,max_guests,is_available,image_url) VALUES
      (h_id,'Heritage Room', 'Double',110,35,2,true,'https://images.unsplash.com/photo-1590447306561-90a2b4c3dcda?w=800'),
      (h_id,'Cultural Suite','King',  160,55,3,true,'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=800');
  END IF;
END $$;

-- ─── Payment Methods per Hotel ────────────────────────────────────────────────
DO $$
DECLARE h_id INT;
BEGIN
  -- Helper: insert payment method only if not already there
  FOR h_id IN SELECT id FROM hotels WHERE name IN (
    'Sheraton Addis','Hilton Addis Ababa','Kuriftu Resort & Spa Bahir Dar',
    'Haile Resort Hawassa','Goha Hotel Gondar','Axum Hotel',
    'Kuriftu Resort Adama','Ras Hotel Dire Dawa','Lewi Resort Bahir Dar',
    'Harar Walled City Lodge'
  ) LOOP
    IF NOT EXISTS(SELECT 1 FROM hotel_payment_methods WHERE hotel_id=h_id) THEN
      INSERT INTO hotel_payment_methods(hotel_id,method,account_name,account_number,phone_number,instructions,is_active)
      VALUES
        (h_id,'telebirr',     'Hotel Telebirr','09XXXXXXXX','09XXXXXXXX','Send to the Telebirr number and include Booking ID',true),
        (h_id,'cbe_birr',     'Hotel CBE Birr','1000XXXXXXXX','09XXXXXXXX','CBE Birr — include Booking ID in note',             true),
        (h_id,'chapa',        'Chapa Gateway','','',           'Secure online payment via Chapa gateway',                    true),
        (h_id,'bank_transfer','Hotel Bank','1000XXXXXXXX','',  'Commercial Bank of Ethiopia — include Booking ID',           true),
        (h_id,'cash',         'Reception','','',               'Pay cash at hotel reception on arrival',                     true);
    END IF;
  END LOOP;
END $$;

-- ─── Super Admin ──────────────────────────────────────────────────────────────
-- Credentials: admin@dallolbook.com / Admin@1234
INSERT INTO admin_users(full_name,email,phone,password_hash,role,status)
VALUES(
  'Super Admin',
  'admin@dallolbook.com',
  '+251911000000',
  '$2a$12$FPQdYzTtLvfPw0GFRiIJIOP.mmKXefixHgC3pu2d2hkqq6nJAT6Qq',
  'super_admin','active'
) ON CONFLICT (email) DO NOTHING;
