-- 1. TEMPORARY TABLES (Geçici Tablolar):
/*
Tabloları oluşturma yöntemlerini detaylı bir şekilde inceledik ve pratikler gerçekleştirdik.
Temporary Table veya Temp Table, geçici tablolardır. 
Oturum boyunca çalışmaktadırlar.
Etkisini daha iyi gözlemleyebilmek amacıyla PostgreSQL'in oturum boyunca devam eden AUTOCOMMIT özelliğini devre dışı bırakmamız gerekmektedir.

-- 1.1. Söz Dizimi:

 ```sql
CREATE TEMP TABLE table_name
(
    column_name_1 data_type,
    column_name_2 data_type,
    …
) [ON COMMIT {PRESERVE ROW | DELETE ROWS | DROP}];

```

-- 1.2. Argümanların Açıklamaları:

-- PRESERVE ROWS: Bir transaction commit edildikten sonra verileri korur (varsayılan)
Veriler, oturum sona erene kadar tabloda kalır.

-- DELETE ROWS: Tabloyu korur ancak commit sonrasında tüm verileri siler. Veriler transaction sonunda silinir, fakat tablo yapısı oturum boyunca varlığını sürdürür.

-- DROP: Commit sonrasında tabloyu tamamen siler. Transaction sonunda tablo bütünüyle kaldırılır.

Dikkat Edilmesi Gerekenler:
- Varsayılan argümanımız PRESERVE ROWS'tur.
- Oturum boyunca çalışma söz konusudur. 

Not: Transaction konusunda bunlara detaylı bir şekilde yer vermiştik.

*/
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 2. TEMP TABLE EXAMPLES (Geçici Tablo Örnekleri):
-- 2.1. "test" veri tabanını kullanarak Mercedes ve Honda marka araçları geçici tabloya aktaran sorguyu yazınız.

-- Sorgumuzu yazalım
-- Tüm araçları çekelim
SELECT
	c.id AS "Araba ID",
	c.brand AS "Araba Marka",
	c.price AS "Araba Fiyatı"
FROM cars AS c
ORDER BY c.id;


-- Sadece Honda ve Mercedes'leri çekelim
SELECT
	c.id AS "Araba ID",
	c.brand AS "Marka",
	c.price AS "Fiyat"
FROM cars AS c
WHERE c.id IN (
	SELECT
		ca.id
	FROM cars AS ca
	WHERE 
		ca.brand ILIKE '%Mercedes%'
		OR LOWER(ca.brand) = 'honda'
	)
ORDER BY c.id;

-- Transaction başlatalım
BEGIN;

-- CREATE TEMP TABLE oluşturalım
CREATE TEMP TABLE mercedes_honda_cars
(
     car_id,
	 brand,
	 price
) 
ON COMMIT PRESERVE ROWS
AS 
SELECT
	c.id,
	c.brand,
	c.price
FROM cars AS c
WHERE c.id IN (
	SELECT
		ca.id
	FROM cars AS ca
	WHERE 
		ca.brand ILIKE '%Mercedes%'
		OR LOWER(ca.brand) = 'honda'
	)


-- Kaydedelim => COMMIT
COMMIT;

SELECT
	mh.car_id,
	mh.brand,
	mh.price
FROM mercedes_honda_cars AS mh;

-- 2.2. "test" veri tabanında yorumu 15 karakterden uzun olan filmleri geçici tabloya aktaran sorguyu yazınız.

-- Tüm tabloyu çekelim
SELECT
	m.movie_id AS "Film ID",
	m.title AS "Film Başlığı"
FROM movies AS m
ORDER BY m.movie_id;

-- Sorgumuzu yazalım.
SELECT
	m.movie_id AS "Film ID",
	m.title AS "Film Başlığı",
	LENGTH(m.title) AS "Başlık Uzunluğu"
FROM movies AS m
WHERE LENGTH(m.title) > 15
ORDER BY m.movie_id;

-- Transaction başlatalım
BEGIN;

-- SELECT INTO ile yapalım
SELECT
    m.movie_id,
	m.title,
	LENGTH(m.title)
INTO TEMP TABLE long_title_films
FROM movies AS m
WHERE LENGTH(m.title) > 15
ORDER BY m.movie_id;
 -- Varsayılan yazmaya gerek yok ON COMMIT PRESERVE ROWS;

-- Transaction'ı kaydedelim. COMMIT
COMMIT;

-- Çekelim
SELECT
	l.movie_id,
	l.title
FROM long_title_films AS l;


-- 2.3. "test" veri tabanında colors tablosunda rengi 6 karakterden az olanları geçici tabloya aktaran ve sorgu sonucunda tabloyu silen sorguyu yazınız.

-- Tüm tabloyu inceleyelim
SELECT
	c.color AS "Renk"
FROM colors AS c;

-- Şarta uygun olanları çekelim
SELECT
	c.color AS "Renk",
	LENGTH(c.color) AS "Renk Uzunluğu"
FROM colors AS c
WHERE LENGTH(c.color) < 6
ORDER BY c.color;

-- Transaction başlat
BEGIN;


CREATE TEMP TABLE short_color_names
(
	color,
	length_of_color
)
ON COMMIT DROP
AS
SELECT
	c.color,
	LENGTH(c.color)
FROM colors AS c
WHERE LENGTH(c.color) < 6
;

-- Kaydedelim
COMMIT;

-- Sorguyu çekelim ve ne olduğunu görelim => ERROR:  relation "short_color_names" does not exist
SELECT
	s.color,
	s.length_of_color
FROM short_color_names AS s;


-- 2.4. "test" veri tabanında kurs adında Postgre geçenleri geçici tabloya aktaran sorguyu seçiniz, sorgu sonrasında verilerin silinmesini sağlayınız.

SELECT
	c.course_id AS "Kurs ID",
	c.course_name AS "Kurs",
	c.description AS "Kurs Açıklaması"
FROM courses AS c
WHERE c.course_name ILIKE '%Postgre%'
ORDER BY c.course_id;

-- Transaction başlat
BEGIN TRANSACTION;


CREATE TEMP TABLE postgres_courses
(	
	course_id,
	course_name,
	description
)
ON COMMIT DELETE ROWS
AS
SELECT
	c.course_id,
	c.course_name,
	c.description
FROM courses AS c
WHERE c.course_id IN (
	SELECT
		co.course_id
	FROM courses AS co
	WHERE co.course_name ILIKE '%Postgres%'
)
ORDER BY c.course_id;

-- kaydedelim
COMMIT;


-- Sorgu sonucunu görelim => Tablonun sütun isimlerini göreceksiniz ama içerisinde veri olmayacak.
SELECT
	pc.course_id,
	pc.course_name,
	pc.description
FROM postgres_courses AS pc;

-- 2.5. "test" veri tabanında araç tipi içerisinde Truck geçenleri bulup geçici tabloda gözlemeleyiniz.Sorgu sonucunda tabloyu da uçurunuz.
SELECT
	ct.id AS "Araba Tipi ID",
	ct.type_name AS "Araba Tipi"
FROM car_types AS ct
WHERE ct.type_name LIKE '%Truck%';

-- Transaction başlat
BEGIN;

CREATE TEMP TABLE truck_types
(
	car_type_id,
	car_type
) 
ON COMMIT DROP
AS
SELECT
	ct.id,
	ct.type_name
FROM car_types AS ct
WHERE ct.type_name ILIKE '%Truck%';

-- Kaydedelim
COMMIT;


-- Sorguyu çekelim => ERROR:  relation "truck_types" does not exist
SELECT
	t.car_type_id,
	t.car_type
FROM truck_types AS t;

-- 2.6. "test" veri tabanında high_salaries tablosunda ismi 'Mi' ile başlayanlar veya soyismi 'er' ile bitenleri geçici tabloya kaydeden sorguyu yazınız.

-- Tabloyu inceleyelim.
SELECT
	hs.emp_id AS "Yetenek ID",
	hs.first_name || ' ' || hs.last_name AS "Yetenek Adı Soyadı",
	hs.department AS "Departman",
	hs.salary AS "Ücret"
FROM high_salaries AS hs
ORDER BY hs.emp_id;

-- Sorguyu deneyelim

SELECT
	hs.emp_id AS "Yetenek ID",
	hs.first_name || ' ' || hs.last_name AS "Yetenek Adı Soyadı",
	hs.department AS "Departman",
	hs.salary AS "Ücret"
FROM high_salaries AS hs
WHERE 
	hs.first_name LIKE 'Mi%'
	OR hs.last_name LIKE '%er'
ORDER BY hs.emp_id;

--Transaction başlatalım
BEGIN TRANSACTION;

CREATE TEMP TABLE selected_names
(
	emp_id,
	full_name,
	department,
	salary
)
ON COMMIT PRESERVE ROWS
AS
SELECT
	hs.emp_id,
	hs.first_name || ' ' || hs.last_name,
	hs.department,
	hs.salary
FROM high_salaries AS hs
WHERE 
	hs.first_name LIKE 'Mi%'
	OR hs.last_name LIKE '%er';

-- Kaydedelim
COMMIT;

-- Sorguyu çekelim ve sonucunu görelim
SELECT
	s.emp_id,
	s.full_name,
	s.department,
	s.salary
FROM selected_names AS s;


-- 2.7. "test" veri tabanında product_segmenti 3 olan ürünleri geçici tabloya aktarınız, sorgu sonucunda ki verileri işlem sonrasında siliniz.

-- Sorgumuzu gerçekleştirelim ve gözlemleyelim.
SELECT
	ps.id AS "Ürün Segment ID",
	p.id AS "Ürün ID",
	p.name AS "Ürün Adı",
	p.price AS "Ürün Fiyatı",
	ps.segment AS "Ürün Segmenti",
	ps.discount AS "Ürün İndirim Oranı"
FROM product_segment AS ps
LEFT JOIN product AS p
	ON ps.id = p.segment_id
WHERE ps.id = 3
ORDER BY p.id;


-- Transaction başlatalım
BEGIN TRANSACTION;
/*
-- SELECT INTO kullanalım
SELECT 
	-- ps.id,
	p.id,
	p.name,
	p.price,
	ps.segment,
	ps.discount
INTO TEMP TABLE segment3_products
FROM product_segment AS ps
LEFT JOIN product p
	ON ps.id = p.segment_id
WHERE ps.id = 3
ORDER BY p.id
*/

-- Geçici tabloyu kullanalım.
CREATE TEMP TABLE segment3_products
ON COMMIT DELETE ROWS -- ON COMMIT ifadesi AS'ten hemen önce olmalı
AS
SELECT 
    p.id,
    p.name,
    p.price,
    ps.segment,
    ps.discount
FROM product_segment AS ps
LEFT JOIN product p
    ON ps.id = p.segment_id
WHERE ps.id = 3
ORDER BY p.id;

COMMIT;

-- Sorguyu çekip görelim
SELECT
	s.id,
	s.name,
	s.price,
	s.segment,
	s.discount
FROM segment3_products AS s;


-- 2.8. "test" veri tabanında araba fiyatı 145000'den fazla olanları geçici tabloya aktaran sorguyu yazınız. Sorgu sonucunda tüm tabloyu da uçurunuz.

-- Sorgumuzu deneyelim.
SELECT
	c.id AS "Araba ID",
	c.brand AS "Marka",
	c.price AS "Fiyat"
FROM cars AS c
WHERE c.price > 145000
ORDER BY c.id;

-- Transaction başlayalım
BEGIN;

-- Yanlışı düzeltelim.
UPDATE cars AS c
SET
	brand = 'Ferrari'
WHERE
	c.id IN (
		SELECT
			ca.id
		FROM cars AS ca
		WHERE ca.brand = 'Ferrai'
	)
RETURNING
	c.id AS "Güncellenen Araba ID",
	c.brand AS "Güncellenen Araba Markası";


-- Veri tabanına kaydedelim.
COMMIT;

-- Tabloyu geçici olarak oluşturalım
BEGIN;

CREATE TEMP TABLE luxury_cars
(
	car_id,
	brand,
	price
)
ON COMMIT DROP
AS
SELECT
	c.id, 
	c.brand,
	c.price
FROM cars AS c
WHERE c.price > 145000
ORDER BY c.id;

-- Kaydedelim
COMMIT;

-- Sorgumuzun sonucunu commit sonrası görelim => ERROR:  relation "luxury_cars" does not exist
SELECT
	l.car_id,
	l.brand,
	l.price
FROM luxury_cars AS l
ORDER BY l.car_id;
