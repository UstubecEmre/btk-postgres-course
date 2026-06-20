-- 1. NOT NULL CONTRAINT (NOT NULL Kısıtı):
/*
-- 1.1. NOT NULL Kısıtı Nedir?
NOT NULL, boş geçilemez anlamına gelmektedir.
Bir tabloda bir veya birden fazla kolona konulabilir.

-- 1.2. Söz Dizimi:

```sql

-- Birinci Yöntem: Tablo oluştururken sütun yanına yazılması
CREATE TABLE tablo_adi
(
	sutun_adi veri_tipi NOT NULL

);

-- İkinci Yöntem: Tablo düzeyinde (Table-Level) NOT NULL tanımlanamaz!
-- Alternatif olarak alt satırda boş geçilemezlik CHECK kısıtı ile taklit edilebilir:

CREATE TABLE tablo_adi
(
	sutun_adi veri_tipi,
	CONSTRAINT chk_sutun_not_null CHECK (sutun_adi IS NOT NULL)
);

-- Üçüncü Yöntem: Sonradan eklemek (ALTER COLUMN)
ALTER TABLE tablo_adi
ALTER COLUMN kisit_konulacak_sutun 
	SET NOT NULL;

```


Hatırlatma:
- Bir tabloda birden fazla NOT NULL kısıt olabilir.
- DML işlemlerinde de veri kontrolü sağlandığından kaynaklı, veri tabanını büyük tablolar için yavaşlatabilir.
- Önemli bir kısıttır. Gerçek hayatta isim, soyisim, kullanıcı adı vb. akla gelebilir.
- PRIMARY KEY kısıtları da UNIQUE ve NOT NULL kısıtlarının özelliklerini barındırmaktadır.
*/
------------------------------------------------------------------------------------------------------------------------------------------------
-- 2. NOT NULL CONSTRAINT EXAMPLES (NOT NULL Kısıtı Örnekleri):
-- 2.1. "test" veri tabanında person tablosunda name sütununa NOT NULL kısıtı ekleyen sorguyu yazınız.

-- Person tablomuzu çekelim.

SELECT
	p.person_id AS "Kişi ID",
	p.name || ' ' || p.surname AS "Kişinin Adı Soyadı",
	p.email AS "Kişinin E-Posta Adresi",
	p.birthdate AS "Kişinin Doğum Tarihi",
	p.gender AS "Cinsiyet",
	p.birth_city_id AS "Doğduğu Şehir ID"
FROM person AS p
ORDER BY p.person_id;


-- Transaction başlatalım
BEGIN;

-- Kısıtı ekleyelim
ALTER TABLE person
ALTER COLUMN name
	SET NOT NULL;

-- Kaydedelim.
COMMIT;


-- 2.2. "test" veri tabanında tournament_year ve tournament_reward sütunlarına NOT NULL yapan kısıtı ekleyiniz.

-- Tabloyu görelim
SELECT
	t.tournament_id AS "Turnuva ID",
	t.tournament_name AS "Turnuva Adı",
	t.tournament_reward AS "Turnuva Ödülü",
	t.winning_team_id AS "Kazanan Takım ID",
	t.tournament_year AS "Turnuva Yılı",
	t.tournament_country_id AS "Turnuvanın Yapıldığı Ülke ID"
FROM tournament AS t;


-- Transaction
BEGIN TRANSACTION;

-- Kısıtı ekleyelim
ALTER TABLE tournament
ALTER COLUMN tournament_year
	SET NOT NULL,
ALTER COLUMN tournament_reward
	SET NOT NULL;

-- Kaydedelim
COMMIT;


-- 2.3. "test" veri tabanında program_type tablosunda program_type_name sütununu boş geçilemez yapacak sorguyu yazınız.

-- Tabloyu çekelim
SELECT
	pt.program_type_id AS "Program Türü ID",
	pt.program_type_name AS "Program Türü"
FROM program_type AS pt;

-- Transaction başlatalım
BEGIN TRANSACTION;

-- Değişikliği yapalım
ALTER TABLE program_type
ALTER COLUMN program_type_name
	SET NOT NULL;

-- Kaydedelim.
COMMIT;

-- 2.4. "test" veri tabanında current_season tablosunda sezon sütununu boş geçilemez yapan sorguyu yazınız.

-- Sezonların olduğu tabloyu çekelim
SELECT
	-- c.*
	c.current_season_id AS "Güncel Sezon ID",
	c.season_year AS "Sezon Yılı"
FROM current_season AS c;

-- Transaction başlatalım
BEGIN TRANSACTION;

-- NOT NULL kısıtını ekleyelim. Zaten NOT NULL kısıtı imiş, ama biz scriptimizi yazalım.
ALTER TABLE current_season
ALTER COLUMN season_year
	SET NOT NULL;

-- Kaydedelim.
COMMIT;


-- 2.5. "test" veri tabanında city tablosunda popülasyon sütununu boş geçilemez yapan sorguyu yazınız.

SELECT
	--c.*
	c.city_id AS "Şehir ID",
	c.city_name AS "Şehir",
	c.population AS "Nüfus"
FROM city AS c;

-- Transaction başlatalım
BEGIN;

-- Kısıtı ekleyelim
ALTER TABLE city
ALTER COLUMN population
	SET NOT NULL;

-- Kaydedelim
COMMIT;

-- 2.6. "test" veri tabanında courses tablosunda description sütununu boş geçilemez yapan sorguyu yazınız.

-- Tablomuza göz atalım
SELECT
	c.course_id AS "Kurs ID",
	c.course_name AS "Kurs Adı",
	c.description AS "Kurs Açıklaması",
	c.published_date AS "Yayın Tarihi"
FROM courses AS c
ORDER BY c.course_id;

-- Transaction başlatalım
BEGIN TRANSACTION;

-- NOT NULL Kısıtı ekleyelim
ALTER TABLE courses
ALTER COLUMN description
	SET NOT NULL;

-- Kaydedelim
COMMIT;

-- 2.7. "test" veri tabanında basket_a tablosunda fruit_a sütununu boş geçilemezİ geriye alan  sorguyu yazınız.

-- Tablomuza bakalım
SELECT
	id_a AS "Meyve ID",
	fruit_a AS "Meyve"
FROM basket_a;

-- Transaction başlatalım
BEGIN TRANSACTION;

-- Kısıt kaldıralım
ALTER TABLE basket_a
ALTER COLUMN fruit_a
	DROP NOT NULL;
	
-- Geriye alalım
ROLLBACK;

-- 2.8. "test" veri tabanında cars tablosunda discount sütununu NOT NULL yapan sorguyu yazınız.

SELECT
	c.id AS "Araba ID",
	c.brand AS "Marka",
	c.price AS "Fiyat",
	c.discount AS "İndirim"
FROM cars AS c;


-- Transaction başlatalım
BEGIN TRANSACTION;

-- Güncelleme yapalım ki indirimi NOT NULL yapabilelim
UPDATE cars AS c
SET discount = FLOOR(c.price / 100)
WHERE c.discount IS NULL
RETURNING *;


-- Kaydedelim veya geriye alalım
COMMIT;

-- Yeni transaction başlatalım ve NOT NULL kısıtı ekleyelim 
BEGIN;

-- Kısıtımız
ALTER TABLE cars
ALTER COLUMN discount
	SET NOT NULL;

-- Kaydedelim
COMMIT;

-- 2.9. "test" veri tabanında geçici bir tablo oluşturunuz ve buna ilk başta NOT NULL kısıtını veriniz.

-- Transaction başlatalım
BEGIN;

-- Geçici tabloyu oluşturalım
CREATE TEMP TABLE IF NOT EXISTS companies(
	company_id SMALLSERIAL,
	company_name VARCHAR(40) NOT NULL,
	founded_year DATE NOT NULL,
	scope_id SMALLINT,
	CONSTRAINT pk_company_id PRIMARY KEY(company_id),
	CONSTRAINT chk_company_name CHECK(LENGTH(company_name) >= 2)
);

-- Kaydedelim
COMMIT;

-- 2.10. "test" veri tabanında alt satıra ekleyerek NOT NULL kısıtını veren sorguyu yazınız.

-- Transaction başlatalım
BEGIN;

-- Yeni bir tablo oluşturalım
CREATE TEMP TABLE IF NOT EXISTS test_address(
	address_id SMALLSERIAL PRIMARY KEY,
	address VARCHAR(450),
	country_id SMALLINT,
	city_id SMALLINT,
	address_type_id SMALLINT,
	CONSTRAINT chk_address CHECK(address IS NOT NULL)
);

-- Kaydedelim veya geriye alalım
COMMIT;
