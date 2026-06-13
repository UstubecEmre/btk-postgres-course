-- 1. SAVEPOINT Statement (SAVEPOINT İfadesi):
/*
Transaction komutlarından COMMIT ve ROLLBACK ifadesinden sonra SAVEPOINT konusuna da değinelim.
SAVEPOINT, bizim için güvenli bir liman, işaretleme noktası olarak düşünülebilir.
SAVEPOINT öncesinde yapılan işlemlerde herhangi bir değişiklik olmazken, SAVEPOINT'den sonra
yapılan işlemleri SAVEPOINT geri_alacagimiz_nokta_ismi ile geri alabiliriz.

Bütün işlemleri geri almak istersek zaten ROLLBACK ifadesini kullanıyorduk.
Önemli bir komuttur, adım adım ilerleyebilmemize ve geri alabilmemize imkan tanır.

-- 1.1. SAVEPOINT Söz Dizimi:
```sql

-- Transaction başlatalım
BEGIN TRANSACTION;

-- Real Madrid'i ekleyelim

INSERT INTO teams
    (
        team_name,
        championships_won
    )
VALUES
    (
        'Real Madrid',
        34
	)
RETURNING *;

SAVEPOINT ınserted_realmadrid;

-- Can kurtarma noktamız gibi düşünebiliriz, değişiklikleri burada kaydediyoruz.

-- Bayern Munich ile Manchester City Ekleyelim
INSERT INTO teams
    (
        team_name,
        championships_won
    )
VALUES
    (
        'FC Bayern Munich',
        19
	)
RETURNING *;

INSERT INTO teams
    (
        team_name,
        championships_won
    )
VALUES
    (
        'Manchester City',
        12
	)
RETURNING *;

ROLLBACK TO SAVEPOINT inserted_realmadrid;

```
Bu işlemde belirtmiş olduğumuz SAVEPOINT'e kadar olan işlemlerimizi geri alacaktır.
Sonuç olarak:
	- Real Madrid eklenmiş olacak.
	- Diğer iki takım hiç eklenmemiş gibi olacaktır.

Önemli Not:
- BEGIN ile başlayan transaction işlemimiz ROLLBACKT TO SAVEPOINT savepoint_adi ile bitmez.
- SAVEPOINT sadece o noktaya dönmemizi sağlar. Bu transaction işlemini bitirebilmek için mutlaka COMMIT veya ROLLBACK kullanmamız gerekmektedir.
*/
---------------------------------------------------------------------------------------------------------------------
-- 2. SAVEPOINT EXAMPLES (SAVEPOINT Örnekleri):

-- 2.1. "test" veri tabanında yer alan "cars" tablosuna 'BMW i20', 'Mercedes E200' ve 'Ford Mustang' araçlarını ekleyiniz ve burada "inserted_three_cars" adında bir SAVEPOINT oluşturunuz.
-- Ardından yanlışlıkla 'Porsche Cayman' ve 'Chevrolet Camaro' araçlarını da ekleyen sorguyu yazınız. Son iki aracın eklenmesini SAVEPOINT ile geri alıp, ilk 3 aracın kaydını veri tabanına kalıcı olarak kaydediniz.

-- Tablomuzu inceleyelim
SELECT
	c.id AS "Araba ID",
	c.brand AS "Araba Marka",
	c.price AS "Araba Fiyatı",
	c.discount AS "İndirim Miktarı"
FROM cars AS c
ORDER BY c.id;

-- Transaction başlatalım
BEGIN TRANSACTION;

-- Ekleme işlemi yapalım
INSERT INTO cars AS c
	(
		brand,
		price,
		discount
	)
VALUES
	(
		'BMW i20',
		1800000,
		1800
	),
	(
		'Mercedes E200',
		2500000,
		30000
	),
	(
		'Ford Mustang',
		420000,
		2500
	)
RETURNING *;

-- SAVEPOINT Ekleyelim
SAVEPOINT inserted_three_cars;

-- Ekleme yapalım
INSERT INTO cars AS c
	(
		brand,
		price,
		discount
	)
VALUES
	(
		'Porsche Cayman',
		9000000,
		5000
	),
	(
		'Chevrolet Camaro',
		4850000,
		3750
	)
RETURNING *;

-- Değişikliği geri alalım
ROLLBACK TO SAVEPOINT inserted_three_cars;

-- Kalıcı olarka kaydedelim
COMMIT;

-- 2.2. "test" veri tabanında yer alan "basket_b" tablosunda 4 numaralı ID'ye sahip meyvenin değerini güncelleyiniz ve "guncelleme_ok" adında bir SAVEPOINT koyunuz.
-- Sonrasında tablodaki en yüksek (MAX) ID değerine sahip kaydı bir SUBQUERY kullanarak siliniz. Bu silme işleminden vazgeçip SAVEPOINT'e geri dönen ve transaction'ı kapatan kodu yazınız.

-- Tablomuzu inceleyelim
SELECT
	b.id_b AS "Meyve ID",
	b.fruit_b AS "Meyve"
FROM basket_b AS b
ORDER BY b.id_b;

-- Transaction başlatalım
BEGIN;

-- Güncelleme yapalım
UPDATE basket_b AS b
SET
	fruit_b = 'Cherry'
WHERE b.id_b = 4
RETURNING
	b.id_b AS "Güncellenen Ürün ID",
	b.fruit_b AS "Güncellenen Meyve";

SAVEPOINT updated_mango;

DELETE FROM basket_b AS b
WHERE
	b.id_b = (
		SELECT
			MAX(ba.id_b)
		FROM basket_b AS ba
	)
RETURNING
	b.id_b AS "Silinen Ürün ID",
	b.fruit_b AS "Silinen Meyve";

-- İşlemi geri alalım
ROLLBACK TO SAVEPOINT updated_mango;

-- Kalıcı olarka kaydedelim
COMMIT;

-- 2.3. "test" veri tabanında yer alan courses tablosunda içinde RUST geçen kursu bulup siliniz, SQL geçenleri (Strutcture Query Language) olarak güncelleyiniz ve bunu geriye alınız.

-- Tablomuzu inceleyelim
SELECT
	c.course_id AS "Kurs ID",
	c.course_name AS "Kurs Adı",
	c.description AS "Kurs Açıklama",
	c.published_date AS "Kurs Yayınlanma Tarihi"
FROM courses AS c
ORDER BY c.course_id;

-- RUST geçeni bulan sorguyu da deneyelim.
SELECT
	c.course_id AS "Kurs ID",
	c.course_name AS "Kurs Adı",
	c.description AS "Kurs Açıklama",
	c.published_date AS "Kurs Yayınlanma Tarihi"
FROM courses AS c
WHERE EXISTS (
	SELECT
		1
	FROM courses AS co
	WHERE 
		c.course_id = co.course_id
		AND POSITION('RUST' IN co.description) > 0
)

-- Transaction başlatalım
BEGIN TRANSACTION;

-- Silme işlemini yapalım
DELETE FROM courses AS c
WHERE EXISTS(
	SELECT
		1
	FROM courses AS co
	WHERE 
		c.course_id = co.course_id
		AND POSITION('RUST' IN co.description) > 0
)
RETURNING *;

SAVEPOINT updated_rust;

UPDATE courses AS c
SET
	description = REPLACE(c.description, 'SQL','Structured Query Language')
RETURNING *;

-- Geriye alalım
ROLLBACK TO SAVEPOINT updated_rust;

-- Tamamını geriye alalım.
ROLLBACK;

-- 2.4. "test" veri tabanında date_demo tablosuna yeni iki kayıt ekleyiniz ancak en son eklenen kaydı geri alınız.

-- Tablomuzu inceleyelim
SELECT
	d.value_id AS "Tarih Değeri ID",
	d.date_value_str AS "Metinsel Tarih Değeri"
FROM date_demo AS d
ORDER BY d.value_id;

-- Transaction başlatalım
BEGIN TRANSACTION;

-- Ekleme yapalım
INSERT INTO date_demo AS d
(
	date_value_str
)
VALUES
	(
		'2026-08-14'
	)
RETURNING *;

SAVEPOINT inserted_date1;

INSERT INTO date_demo AS d
(
	date_value_str
)
VALUES
	(
		'21.10.1989'
	)
RETURNING *;

-- Geriye alalım
ROLLBACK TO SAVEPOINT inserted_date1;

-- Veri tabanına kaydedelim
COMMIT;

-- 2.5. "test" veri tabanında movie_reviews tablosunda film yorumu Awesome olan kayıtları siliniz, Horrible olan varsa bunu Really Bad olarak güncelleyip bu işlemi veya silme işlemini geri alınız.

-- Tablomuzu inceleyelim

SELECT
	mr.review_id AS "Film Yorumu ID",
	mr.movie_id AS "Yorum Yapılan Film ID",
	mr.review AS "Film Yorumu"
FROM movie_reviews AS mr
ORDER BY mr.review_id;

SELECT
	mr.review_id AS "Film Yorumu ID",
	mr.movie_id AS "Yorum Yapılan Film ID",
	mr.review AS "Film Yorumu"
FROM movie_reviews AS mr
WHERE 
	mr.review = 'Awesome';

-- Horrible olan film varsa bilgilerini getirelim
SELECT
	mr.review_id AS "Film Yorum ID",
	mr.movie_id AS "Film ID",
	mr.review AS "Film Yorumu"
FROM movie_reviews AS mr
WHERE EXISTS (
	SELECT
		1
	FROM movie_reviews AS mov
	WHERE 
		mr.review_id = mov.review_id
		AND mov.review = 'Horrible'
);

-- Transaction Başlatalım.
BEGIN;

DELETE FROM movie_reviews AS mr
WHERE
	mr.review = 'Awesome'
RETURNING 
	mr.review_id AS "Silinen Yorum ID",
	mr.movie_id AS "Silinen Film ID",
	mr.review AS "Silinen Film Yorumu";

-- Bu kısmı güvenceye alalım
SAVEPOINT deleted_awesome_reviews;


-- Diğer yöntemi uygulayalım. (EXISTS yerine IN ile de çözelim)

UPDATE movie_reviews AS mr
SET
	review = 'Really Bad'
WHERE mr.review_id IN (
	SELECT
		mov.review_id
	FROM movie_reviews AS mov
	WHERE mov.review = 'Horrible'
)
RETURNING *;

-- Geriye alalım
ROLLBACK TO SAVEPOINT deleted_awesome_reviews;

-- Geriye alalım
ROLLBACK;

-- 2.6. "test" veri tabanında colors tablosunda son iki kaydı güncelleyiniz, ardından olmayan bir renk ekleyip bu işlemi geriye alınız.

SELECT
	c.color AS "Renk"
FROM colors AS c
ORDER BY c.color;

SELECT
	c.color AS "Renk"
FROM colors AS c
ORDER BY c.color DESC
LIMIT 2;


-- Transaction başlat
BEGIN;

-- Güncelleme yapalım
UPDATE colors AS c
SET
	color = CONCAT('Dark', ' ', c.color)
WHERE
	color IN (
		SELECT
			color
		FROM colors
		ORDER BY color DESC
		LIMIT 2
	)
RETURNING c.color AS "Güncellenen Renk";

-- SAVEPOINT ekleyelim
SAVEPOINT updated_colors;


-- Ekleme yapalım
INSERT INTO colors AS c
	(
		color
	)
VALUES
	(
		'Gray'
	)
RETURNING 
	c.color AS "Eklenen Renk";

-- İşlemi geriye alalım
ROLLBACK TO SAVEPOINT updated_colors;

-- Kaydedelim.
COMMIT;

-- 2.7. "test" veri tabanında product_segmenti 3 olanların indirim oranını güncelleyiniz, net_price sütununu yeniden hesaplayınız. İşlemi sonrasında geri alınız.

-- Tabloyu inceleyelim.
SELECT
	ps.id AS "Ürün Segment ID",
	ps.segment AS "Ürün Segmenti",
	p.name AS "Ürün İsmi",
	p.price AS "Ürün Fiyatı",
	p.net_price AS "Ürün Net Fiyatı"
FROM product_segment AS ps
JOIN product AS p
	ON ps.id = p.segment_id
ORDER BY ps.id;

SELECT
	ps.id AS "Ürün Segment ID",
	ps.segment AS "Ürün Segmenti"
FROM product_segment AS ps
WHERE ps.id = 2
ORDER BY ps.id;

-- Transaction başlatalım
BEGIN;

-- Güncelleme işlemi yapalım
UPDATE product_segment AS ps
SET 
	discount = ps.discount - 0.02
WHERE ps.id = 2
RETURNING *;

-- Savepoint atalım
SAVEPOINT updated_discount;

-- Ürün fiyatlarını güncelleyelim
UPDATE product AS p
SET
     net_price = price - price * ps.discount
FROM product_segment AS ps
WHERE p.segment_id = ps.id;

-- İşlemi geri alalım
ROLLBACK TO SAVEPOINT updated_discount;

-- Geriye alalım
ROLLBACK;


-- 2.8. "test" veri tabanında yer alan budgets tablosunda null olan değer varsa güncelleyin, son kaydı siliniz, bunu geriye alınız.

-- Tablomuzu hatıryalım.
SELECT
	b.salesman_id AS "Yetenek ID",
	b.current_year AS "Bu Yıl ki Satış Miktarı",
	b.previous_year AS "Geçen Yıl ki Satış Miktarı"
FROM budgets AS b
ORDER BY b.salesman_id;

-- Transaction başlat
BEGIN TRANSACTION;

UPDATE budgets AS b
SET
	current_year = (
		SELECT
			bud.previous_year - 1000
		FROM budgets AS bud
		WHERE bud.salesman_id IN (
			SELECT
				budg.salesman_id
			FROM budgets AS budg
			WHERE budg.current_year IS NULL
		)
	)
WHERE b.current_year IS NULL
RETURNING *;

-- SAVEPOINT ile 
SAVEPOINT updated_current_year;

-- Silme işlemini yapalım
DELETE FROM budgets AS b
WHERE b.salesman_id = (
	SELECT
		MAX(bud.salesman_id)
	FROM budgets AS bud
)
RETURNING
	b.salesman_id AS "Silinen Yetenek ID",
	b.current_year AS "Silinen Güncel Satış Miktarı",
	b.previous_year AS "Silinen Geçen Yıl ki Satış Miktarı";

-- İşlemi geriye alalım.
ROLLBACK TO SAVEPOINT updated_current_year;

-- Kaydedelim
COMMIT;

-- Komple geri almak istersek:
-- ROLLBACK;
	
-- 2.9. "test" veri tabanında ortalamanın altında olan öğrencilere 15 puan ekleyiniz, ortalamanın üstünde olanlardan 5 puan kıran sonra bunu geri alan sorguyu yazınız.

-- Öğrenci tablomuza yakından bakalım.
SELECT
	s.id AS "Öğrenci ID",
	s.name AS "Öğrenci Adı Soyadı",
	s.class AS "Öğrenci Sınıfı",
	s.mark AS "Öğrenci Notu",
	s.gender AS "Öğrenci Cinsiyeti",
	s.course_name AS "Öğrencinin Bölümü",
	s.email AS "Öğrencinin E-Posta Adresi"
FROM student AS s
ORDER BY s.id;

-- Ortalama puanı hata almayalım diye önceden hesaplayalım.
SELECT
	ROUND(AVG(s.mark)) AS "Ortalama Puan" -- 74
FROM student AS s;

-- Transaction başlatalım
BEGIN;

-- Güncelleme yapalım
UPDATE student AS s
SET
	mark = s.mark + 15
WHERE s.mark < (
	SELECT
		ROUND(AVG(stu.mark))
	FROM student AS stu
)
RETURNING 
	s.id AS "Not EKlenen Öğrenci ID",
	s.name AS "Not Eklenen Öğrenci",
	s.class AS "Not Eklenen Sınıf",
	s.mark AS "Güncellenmiş Notu";

SAVEPOINT added_marks;

-- Ortalamadan yüksek olanlardan da puan silelim
UPDATE student AS s
SET
	mark = s.mark - 5
WHERE s.mark > (
	SELECT
		ROUND(AVG(stu.mark))
	FROM student AS stu
)
RETURNING 
	s.id AS "Not EKlenen Öğrenci ID",
	s.name AS "Not Eklenen Öğrenci",
	s.class AS "Not Eklenen Sınıf",
	s.mark AS "Güncellenmiş Notu";

-- İşlemi geriye alalım
ROLLBACK TO SAVEPOINT added_marks;

-- Diske yazalım
COMMIT;

-- 2.10. "test" veri tabanında car_types tablosunda iki adet güncelleme gerçekleştiriniz, ardından ekleme yapınız ve yapılan son iki işlemi geriye alınız.

-- Araba türleri tablomuzun kayıtlarına bakalım.
SELECT
	ct.id AS "Araba Türü ID",
	ct.type_name AS "Araba Türü"
FROM car_types AS ct
ORDER BY ct.id;


-- Transaction başlatalım
BEGIN;

-- Ekleme yapalım

INSERT INTO car_types AS ct
(
	type_name
)
VALUES
	(
		'Shooting Brake'
	)
RETURNING
	ct.id AS "Eklenen Araba ID",
	ct.type_name AS "Eklenen Araba Türü";

SAVEPOINT added_shooting_brake;

-- Yeni tür ekleyelim
INSERT INTO car_types AS ct
(
	type_name
)
VALUES
	(
		'Targa'
	)
RETURNING
	ct.id AS "Eklenen Araba ID",
	ct.type_name AS "Eklenen Araba Türü";

SAVEPOINT added_targa;


-- Yeni bir tür daha ekleyelim
INSERT INTO car_types AS ct
(
	type_name
)
VALUES
	(
		'Campervan'
	)
RETURNING
	ct.id AS "Eklenen Araba ID",
	ct.type_name AS "Eklenen Araba Türü";


-- Geriye alalım, istediğinizi yorum satırından çıkartıp veya yorum satırına alarak deneyebilirsiniz.

-- ROLLBACK TO SAVEPOINT added_targa;
ROLLBACK TO SAVEPOINT added_shooting_brake;

-- Veri tabanına kalıcı olarak kaydedelim.
COMMIT;
