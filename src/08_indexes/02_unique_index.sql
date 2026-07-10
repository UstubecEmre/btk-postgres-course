-- 1. UNIQUE INDEX:
/*
-- 1.1 UNIQUE INDEX Nedir?
Girilecek olan değerlerin benzersiz olmasının da kontrol edilmesini istiyorsak UNIQUE
kısıtını kullanabiliriz.
Bu sayede, indexlerimizde UNIQUE ile birlikte kullanımı hem sorgumuzu hızlandırmakta hem de
veri girişini kontrol etmemize imkan tanımaktadır.

-- 1.2. Söz Dizimi:
```sql
CREATE UNIQUE INDEX index_adimiz
ON tablo_adimiz(sutun_adi(adlari));
```

Not: Indeximizi, oluşturduğumuz sorgunun kısıtına göre oluşturmamız ve bu şekilde kullanmamız
gerekmektedir.
Aksi halde, sorgumuz istenen hızda olmayacaktır.

*/

---------------------------------------------------------------------------------------------------------------------------------
-- 2. UNIQUE INDEX EXAMPLES (UNIQUE INDEX Örnekleri):

-- 2.1. "pagila" veri tabanında yer alan customer tablosundaki "customer" tablosundaki "email" sütununa, sisteme aynı e-posta adresiyle ikinci bir kullanıcının kaydolmasını veri tabanı seviyesinde engelleyecek benzersiz bir indeks (UNIQUE INDEX) atayınız.

-- Tablomuzu hatırlayalım
SELECT
	c.customer_id AS "Müşteri ID",
	c.store_id AS "Mağaza ID",
	c.first_name || ' ' || c.last_name AS "Müşteri Adı Soyadı",
	c.email AS "Müşteri E-Mail"
FROM customer AS c;

-- Transaction başlatalım
BEGIN TRANSACTION;


-- Unique Index Oluşturalım
CREATE UNIQUE INDEX uq_idx_customer_email
ON customer(email);

-- SAVEPOINT created_email_idx
COMMIT;

-- Execution plan ile tarama yapalım, veri ekleyelim.
-- Başka bir transaction kullanalım
BEGIN;

INSERT INTO customer
(
	store_id,
	first_name,
	last_name,
	email,
	address_id,
	activebool,
	create_date,
	last_update,
	active
)
VALUES
(
	2,
	'MELISSA',
	'VARGAS',
	'MELISSA.VARGAS@sakilacustomer.org',
	105,
	true,
	'2024-10-15',
	'2026-01-01',
	1
)
RETURNING *;

-- Kaydedelim
COMMIT;

EXPLAIN
SELECT
	c.customer_id AS "Müşteri ID",
	c.store_id AS "Mağaza ID",
	c.first_name || ' ' || c.last_name AS "Müşteri Adı Soyadı",
	c.email AS "Müşteri E-Mail"
FROM customer AS c
WHERE c.email = 'MELISSA.VARGAS@sakilacustomer.com';

/*
"Index Scan using uq_idx_customer_email on customer c  (cost=0.28..8.30 rows=1 width=72)"
"  Index Cond: (email = 'MELISSA.VARGAS@sakilacustomer.com'::text)"
*/

-- 2.2. "pagila" veri tabanında "staff" (personel) tablosundaki "username" sütununa, yönetim panelinde çakışmaları önlemek amacıyla benzersizlik kısıtı getiren UNIQUE INDEX sorgusunu yazınız.

SELECT
	s.staff_id AS "Yetenek ID",
	s.first_name || ' ' || s.last_name AS "Yetenek Adı Soyadı",
	s.address_id AS "Adres",
	s.email AS "E-Mail",
	s.username AS "Kullanıcı Adı"
FROM staff AS s;

-- İstenileni yapalım
BEGIN;

-- Unique index oluşturalım
CREATE UNIQUE INDEX uq_idx_staff_username
ON staff(username);

SAVEPOINT created_uq_idx_staff_username;

-- Sorgu çekelim
EXPLAIN
SELECT
	s.staff_id,
	s.first_name || ' ' || s.last_name AS full_name,
	s.address_id,
	s.email,
	s.username
FROM staff AS s
WHERE username = 'Mike';

-- Veri de ekleyebiliriz.
INSERT INTO staff
	(
		first_name,
		last_name,
		address_id,
		email,
		store_id,
		username,
		password
	)
VALUES
	(
		'Mike',
		'Johsue',
		5,
		'Mike.Joshue@sakilastaff.com',
		2,
		'Mike',
		'8cb2237d0679ca88db6464eac60da96345513965'
	)
RETURNING *;

/*
ERROR:  duplicate key value violates unique constraint "uq_idx_staff_username"
Key (username)=(Mike) already exists. 
*/
-- Kaydedelim
COMMIT;

-- 2.3. "pagila" veri tabanında "category" tablosundaki kategori isimlerinin ("name") büyük veya küçük harf fark etmeksizin (örn: 'Action' ve 'action') benzersiz olmasını garanti altına alacak bir Fonksiyonel Benzersiz İndeks (Functional Unique Index) oluşturunuz.

-- Tablomuzu çekelim
EXPLAIN
SELECT
	c.category_id,
	c.name,
	c.last_update
FROM category AS c;

-- Transaction başlatalım
BEGIN TRANSACTION;

-- İndex oluşturalım
CREATE UNIQUE INDEX uq_idx_category_name
ON category((LOWER(name)));

SAVEPOINT created_uq_idx_category_name;

-- Veri eklemesi yapalım
INSERT INTO category
	(
		name
	)
VALUES
	('RomCom'),
	('Classics') -- Var olan eklemeyi deneyelim
RETURNING *;

/*
ERROR:  duplicate key value violates unique constraint "uq_idx_category_name"
Key (lower(name))=(classics) already exists.
*/
-- Kaydedelim
COMMIT;

EXPLAIN
SELECT
	c.*
FROM category AS c
WHERE c.name = 'RomCom'; -- Getirmeyecek, çünkü eklenmedi:)


-- 2.4. "pagila" veri tabanında iş kuralı gereği, "store" tablosundaki "manager_staff_id" (mağaza müdürü) sütununa, bir personelin birden fazla mağazaya müdür olarak atanmasını engelleyecek benzersiz bir indeks uygulayınız.

-- Tabloyu çekelim
SELECT
	s.store_id,
	s.manager_staff_id,
	s.address_id,
	s.last_update
FROM store AS s;

-- Transaction başlatalım
BEGIN;

-- UNIQUE index atayalım
CREATE UNIQUE INDEX uq_idx_store_manager
ON store(manager_staff_id);

SAVEPOINT created_uq_idx_store_manager;

-- Sorgu çekelim, ekleme yapalım
INSERT INTO store
	(	
		manager_staff_id,
		address_id		
	)
VALUES
	(
		1,
		3
	)
RETURNING *;

/*
ERROR:  duplicate key value violates unique constraint "idx_unq_manager_staff_id"
Key (manager_staff_id)=(1) already exists. 
*/

-- Sorguyu çekelim
EXPLAIN
SELECT
	s.store_id,
	s.manager_staff_id,
	s.address_id,
	s.last_update
FROM store AS s
WHERE s.manager_staff_id = 1;

-- Geriye alalım veya kaydedelim
ROLLBACK TO SAVEPOINT created_uq_idx_store_manager;
COMMIT;

-- 2.5. "pagila" veri tabanında bir veri çakışmasını engellemek adına, "city" tablosunda aynı ülke id'sine (`country_id`) sahip aynı isimde (`city`) ikinci bir şehrin eklenmesini engelleyecek Çok Sütunlu Benzersiz İndeks (Composite Unique Index) yazınız.

-- Tabloyu çekelim
SELECT
	c.city_id,
	c.city,
	c.country_id,
	c.last_update
FROM city AS c;

-- Transaction başlat
BEGIN;

-- Index oluşturalım
CREATE UNIQUE INDEX uq_idx_city_country_id_city
ON city(country_id, city);

SAVEPOINT created_uq_idx_city_country_id_city;

-- Deneyelim
EXPLAIN
SELECT
	c.city_id,
	c.city,
	c.country_id,
	c.last_update
FROM city AS c
WHERE c.country_id = 23
	AND c.city = 'Zalantum';

/*
"Index Scan using uq_idx_city_country_id_city on city c  (cost=0.28..8.29 rows=1 width=25)"
"  Index Cond: ((country_id = 23) AND (city = 'Zalantum'::text))"
*/

-- Yeni ekleme yapalım ve test edelim
INSERT INTO city
	(
		city,
		country_id
	)
VALUES
	(
		'Zanzibar',
		93
	)
RETURNING *;

/*
ERROR:  duplicate key value violates unique constraint "uq_idx_city_country_id_city"
Key (country_id, city)=(93, Zanzibar) already exists. 

*/
-- Kaydedelim
COMMIT;

-- 2.6. "pagila" veri tabanında "customer" tablosunda sadece AKTİF olan müşterilerin (`active = 1` veya `activebool = true`) e-posta adreslerinin benzersiz olmasını, pasif müşterilerde ise bu kuralın aranmamasını istiyorsunuz.

EXPLAIN
SELECT
	c.customer_id,
	c.store_id,
	c.first_name || ' ' || c.last_name AS full_name,
	c.email,
	c.address_id,
	c.active
FROM customer AS c;

-- Transaction başlatalım
BEGIN;

-- Unique Index oluşturalım
CREATE UNIQUE INDEX uq_idx_active_customer_email
ON customer(email)
WHERE active = 1;

SAVEPOINT created_uq_idx_active_customer_email;

-- Sorgu çekelim
EXPLAIN
SELECT
	c.customer_id,
	c.store_id,
	c.first_name || ' ' || c.last_name AS full_name,
	c.email,
	c.address_id,
	c.active
FROM customer AS c
WHERE active = 1;

/*
"Seq Scan on customer c  (cost=0.00..19.43 rows=585 width=80)"
"  Filter: (active = 1)"
Burada kayıtların %5 - %15 arasında olsaydı index kullanabilirdi.

*/
-- Ekleme de yapabiliriz => INSERT INTO vb. 

-- Kaydedelim
COMMIT;

-- 2.7. "pagila" veri tabanında "address" tablosundaki "phone" (telefon numarası) sütununa boş (NULL) değerler hariç olmak üzere, girilen tüm telefon numaralarının benzersiz olmasını zorunlu kılan bir UNIQUE INDEX atayınız.

-- Tabloyu çekelim
EXPLAIN
SELECT
	a.address_id,
	a.address,
	a.address2,
	a.district,
	a.city_id,
	a.postal_code,
	a.phone,
	a.last_update
FROM address AS a;


-- Transaction başlatalım.
BEGIN TRANSACTION;

-- UNIQUE INDEX Oluşturalım
CREATE UNIQUE INDEX uq_idx_address_phone_not_null
ON address(phone)
WHERE phone IS NOT NULL
	AND phone != '' ;

SAVEPOINT created_uq_idx_address_phone_not_null;

-- Sorgu çekelim
EXPLAIN
SELECT
	a.address_id,
	a.address,
	a.address2,
	a.district,
	a.city_id,
	a.postal_code,
	a.phone,
	a.last_update
FROM address AS a
WHERE 
	a.phone IS NOT NULL
	AND a.phone != '';

-- Unique test etmek istersek
UPDATE address
SET 
	phone = '6172235589' --Eski tel no: 14033335568
WHERE address_id = 3
RETURNING *;

/*
ERROR:  duplicate key value violates unique constraint "uq_idx_address_phone_not_null"
Key (phone)=(6172235589) already exists. 
*/

-- Kaydedelim
COMMIT;
