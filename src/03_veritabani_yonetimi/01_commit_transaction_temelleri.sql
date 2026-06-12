-- 1. Transactions Basics (Transaction Temelleri):
/*
Veri tabanını yönetme işlemlerini yani transaction konusuna değineceğiz.
INSERT, UPDATE ve DELETE işlemleri arka planda bir transaction başlatır.
Bu işlemlerde başlatılan transaction, bu işlemin sonlanmasından sonra sonlanır.
Çok kısa süren işlemlerde de Transaction anlık başlar ve biter.

-- 1.1. Transaction Özellikleri:
- Tek bir iş birimidir (Unit of work).
- Veri tabanı tarafından arka planda Transaction numaraları verilir ve yönetilir.
- Bir veya daha fazla işlemden oluşabilir. Örneğin, içerisinde birden çok INSERT, UPDATE olabilir.
- Veri bütünlüğü ve güvenilirlik sağlar.
- Hata durumunda geri dönüş imkanı sunar.

-- 1.2. Transaction Özellikleri (ACID Prensipleri):
İlişkisel veri tabanları ACID prensibini temeline alan veri tabanlarıdır.
Transaction yapısının veri bütünlüğünü koruyabilmesi için ACID olarak adlandırılan 4 temel prensibe uyması gerekir:

- Atomicity (Bütünlük): İşlemlerin ya tamamı gerçekleşir ya da hiçbiri gerçekleşmez (Hep ya da hiç).
- Consistency (Tutarlılık): Bir transaction veri tabanını her zaman geçerli ve tutarlı bir durumdan diğerine taşır.
- Isolation (İzole Edilebilirlik): Eş zamanlı çalışan transaction'lar birbirlerinin işlemlerini göremez, etkileyemez.
- Durability (Kalıcılık): Commit edilmiş bir transaction'ın etkileri sistem çökse bile kalıcı olarak diske yazılır.


-- 1.3. Transaction Komutları:
- BEGIN: Transaction başlatmak için kullanılan komuttur.
- COMMIT: Bir verinin kalıcı olarak veri tabanına (disklere) yazılmasını sağlayan komuttur.
- ROLLBACK: Hata veya iptal durumunda, yapılan tüm değişiklikleri transaction başlangıcına geri döndürür.
	TRANSACTION içerisinde yapmış olduğumuz tüm veri değişikliklerini geri alabiliriz.
- SAVEPOINT: Kısmi bir geri dönüş noktası olarak düşünülebilir.


-- 1.3. SQL'de Komut Türleri:
Bu konu oldukça önemlidir.
Hangi tür komutun hangi kısma girdiğini bilmemiz gerekmektedir.

DQL (Data Query Language): 
    SELECT komutudur.
    Verileri seçmekte kullanılan sorgulardır.

DDL (Data Definition Language / Data Dictionary Language):
    Veri tabanı nesneleri üzerinde değişiklik yapmamızı (eklemek, silmek, güncellemek, oluşturmak vb.)
    Transaction başlar ve biter, veri tabanı yönetim sistemine bağlı olarak PostreSQL için genellikle uzun sürmezler.
	CREATE: Nesneleri oluşturmak için kullanılan komuttur.
	ALTER: Nesneleri değiştirmek için kullanılan komuttur.
	DROP: Nesneleri kaldırmak için kullanılan komuttur.
	TRUNCATE: Nesneleri başlangıç noktasına (verisiz bir şekilde) getiren komuttur.
	RENAME: Nesneleri yeniden isimlendirmek için kullanılan komuttur.

DML (Data Manipulation Language):
    Verileri değiştirme komutlarıdır.
	INSERT: Verileri eklemek için kullanılan komuttur.
	UPDATE: Verileri güncellemek için kullanılan komuttur.
	DELETE: Verileri silmek için kullanılan komuttur.

DCL (Data Control Language):
    Veri tabanı üzerinde ki nesnelere yetki verme ve yetkiyi alma görevlerinde kullanılır.
	GRANT: Yetki verirken kullanılan komuttur.
	REVOKE: Yetki alırken kullanılan komuttur.

TCL (Transaction Control Language):
	COMMIT: Yapılan transaction işlemini diske kaydetmek için kullanılan, kalıcılığı bu şekilde sağlayan komuttur.
	ROLLBACK: Yapılan değişikliği geri almak için kullanılan transaction komutudur.
	SAVEPOINT: Transaction içerisinde, hata durumunda kısmi geri dönüş yapabilmek için tanımlanan kontrol noktasıdır (Checkpoint).



Önemli Notlar:
- İyi yönetilirse, veri bütünlüğünü korur aynı zamanda verilerin kaybolma riskine karşı ciddi önlemler alınmış olur.
- Yanlış bir güncelleme veya silme işlemlerinde veri tabanına kalıcı olarak yansıtmadan geri alıp işlemlerimize kaldığımız yerden devam edebiliriz.
- ACID prensibi için mobil hesaplardan para aktarma, mobil işlemler vb.gelebilir. Burada para çekince anında hesapta görünür, başka birinin işlemi bizim işlemimizi etkilemez vb.
- PostgreSQL, AUTOCOMMIT yapıya sahiptir.
- Transaction işlemi, kendi oturumumuzda başlatılır ve yönetilir. Bu transaction işlemi COMMIT veya ROLLBACK edilmediğinde, başka oturumlarda ve kullanıcılarda görünmez. 
- Transaction işlemi başlatıldıktan sonra, başka bir kullanıcı da aynı işlemi yapmaya çalışırsa, veri tabanı yönetim sistemi, bu işlemi kilitler. Bu, veri bütünlüğünü korumak ve çakışmaları önlemek için yapılır.

*/

----------------------------------------------------------------------------------------------------------------------------------------------
-- 2. COMMIT EXAMPLES (COMMIT Örnekleri):
--2.1. "test veri" tabanında Jaguar marka bir araba ekleyip bunu transaction ile diske kaydedilmesini sağlayan sorguyu yazınız.

SELECT
	c.id AS "Araba ID",
	c.brand AS "Araba Markası",
	c.price AS "Araba Fiyatı",
	c.discount AS "İndirim Miktarı"
FROM cars AS c
ORDER BY c.id;

-- Transaction başlatalım
BEGIN;

-- Jaguar'ı ekleyelim
INSERT INTO cars AS c
	(
		brand,
		price,
		discount
	)
VALUES
	(
		'Jaguar',
		18000,
		1200
	)
RETURNING *;

-- Veri tabanına kalıcı olarak kaydedelim ve transaction'ı sonlandıralım.
COMMIT;

-- Sorgumuzu kontrol edelim.
SELECT
	c.id AS "Araba ID",
	c.brand AS "Araba Markası",
	c.price AS "Araba Fiyatı",
	c.discount AS "İndirim Miktarı"
FROM cars AS c 
ORDER BY c.id DESC
LIMIT 1;


-- 2.2. "test" veri tabanında Jack Reacher filmini John Wick olarak güncelleyen sorguyu yazınız. Veri tabanına kalıcı olarak kaydediniz.

-- Film listesini görelim
SELECT
	m.movie_id AS "Film ID",
	m.title AS "Film Başlığı"
FROM movies AS m
ORDER BY m.movie_id;

-- Transaction başlat
BEGIN TRANSACTION;

UPDATE movies AS m
SET
	title = 'Joh Wick'
WHERE 
	m.movie_id = (
		SELECT
			mov.movie_id
		FROM movies AS mov
		WHERE mov.title = 'Jack Reacher'
	)
RETURNING
	m.movie_id AS "Değiştirilen Film ID",
	m.title AS "Değiştirilen Film Başlığı";

-- Veri tabanına kalıcı şekilde kaydedelim.
COMMIT;

SELECT
	m.movie_id AS "Film ID",
	m.title AS "Film Başlığı"
FROM movies AS m
ORDER BY m.movie_id DESC;

-- 2.3. "test" veri tabanında date_demo tablosunda içerisinde MARCH geçenleri silen ve bunu kalıcı olarak kaydeden sorguyu yazınız.

-- Tablomuzu bir görelim

SELECT
	d.value_id AS "Değer ID",
	d.date_value_str AS "Tarih Değeri"
FROM date_demo AS d
ORDER BY d.value_id;

-- Transaction BAŞLAT
BEGIN;
-- BEGIN TRANSACTION;

-- İstenilen işlemi yapalım.
DELETE FROM date_demo AS d
WHERE d.date_value_str ILIKE '%MARCH%'
RETURNING *;

-- COMMIT ile kalıcı hafızaya alalım
COMMIT;

-- 2.4. "test" veri tabanında car_types Coupe olanı Limo olarak güncelleyen sorguyu yazınız ve bunu diske kaydediniz.
SELECT
	id AS "Araba Tipi ID",
	type_name AS "Araba Tipi"
FROM car_types AS ct
ORDER BY id;

-- Transaction başlatalım.
BEGIN;

-- Sorguyu yazalım.
UPDATE car_types AS ct
SET
	type_name = 'Limo'
WHERE
	ct.id = (
		SELECT
			c.id
		FROM car_types AS c
		WHERE LOWER(c.type_name) = 'coupe'
	)
RETURNING 
	ct.id AS "Güncellenen Değer ID",
	ct.type_name AS "Güncellenen Model";

-- Kaydedelim
COMMIT;

SELECT
	id AS "Araba Tipi ID",
	type_name AS "Araba Tipi"
FROM car_types AS ct
ORDER BY id;

-- 2.5. "test" veri tabanında basket_b tablosunda id'si en büyük olan kaydı silen sorguyu yazınız ve veri tabanına kalıcı olarak kaydediniz.
SELECT
	b.id_b AS "Sepet ID",
	b.fruit_b AS "Sepetteki Mevye"
FROM basket_b AS b
ORDER BY b.id_b;

-- Transaction başlatalım
BEGIN TRANSACTION;

-- Sorguyu yazalım
DELETE FROM basket_b AS b
WHERE
	b.id_b = (
		SELECT
			MAX(f.id_b)
		FROM basket_b AS f
	)
RETURNING *;

-- COMMIT edip diske yazalım
COMMIT;

-- 2.6. "test" veri tabanından yeni bir film ekleyin, ardından Oblivion isimli filmi güncelleyin. Bunları veri tabanına kalıcı olarak kaydedin.
SELECT
	m.movie_id AS "Film ID",
	m.title AS "Film Başlığı"
FROM movies AS m
ORDER BY m.movie_id;

-- Transaction başlatalım
BEGIN;

-- İstenilen sorguları yazalım

INSERT INTO movies AS m
	(
		title
	)
VALUES
	(
		'Interstellar'
	),
	(
		'The Green Mile'
	),
	(
		'The Pianist'
	),
	(
		'Spirited Away'
	)
RETURNING 
	m.movie_id AS "Eklenen Film ID",
	m.title AS "Eklenen Film Başlığı";


-- Güncellemeyi de yapalım
UPDATE movies AS m
SET
	title = 'Ballerina'
WHERE
	m.movie_id = (
		SELECT
			mov.movie_id
		FROM movies AS mov
		WHERE mov.title = 'Oblivion'
	)
RETURNING 
	m.movie_id AS "Güncellenen Film ID",
	m.title AS "Güncellenen Film Başlığı";

-- Kaydedelim
COMMIT;

-- 2.7. "test" veri tabanında kurs tablosunda published_date sütununu güncelleyin, NULL olanlar varsa slin. Bunu veri tabanına kalıcı olarak kaydedin.
SELECT
	c.course_id AS "Kurs ID",
	c.course_name AS "Kurs Adı",
	c.description AS "Kurs Açıklaması",
	c.published_date AS "Kurs Yayın Tarihi"
FROM courses AS c
ORDER BY c.course_id;

-- Transaction başlatalım
BEGIN;

-- Kursu güncelleyelim
UPDATE courses AS c
SET
	published_date = published_date + INTERVAL '2 WEEKS'
WHERE c.published_date IS NOT NULL
RETURNING c.*;

DELETE FROM courses AS c
WHERE c.published_date IS NULL
RETURNING
	c.course_id AS "Silinen Kurs ID",
	c.course_name AS "Silinen Kurs Adı",
	c.description AS "Silinen Kurs Açıklaması";

-- Kaydedelim
COMMIT;

-- 2.8. "test" veri tabanında ürünlerin indirim oranlarını 0.01 olarak artırınız, tüm ürünlerin net fiyatını güncelleyip kalıcı olarak kaydeden sorguyu yazınız.
SELECT
	ps.id AS "Ürün Segment ID",
	ps.segment AS "Ürün Segmenti",
	ps.discount AS "Ürün İndirim Oranı"
FROM product_segment AS ps;

-- Transaction başlatalım
BEGIN;

-- İstenilen sorguları yazalım
UPDATE product_segment AS ps
SET
	discount = discount + 0.01
RETURNING 
	ps.id AS "Güncellenen Ürün ID",
	ps.segment AS "Güncellenen Ürün Segmenti",
	ps.discount AS "Güncellenen İndirim Oranı";

SELECT
	p.id AS "Ürün ID",
	p.name AS "Ürün Adı",
	p.price AS "Ürün Fiyat",
	ps.segment AS "Ürün Segmenti",
	ps.discount AS "Ürün İndirim Oranı"
FROM product AS p
JOIN product_segment AS ps
	ON p.segment_id = ps.id
ORDER BY p.id;


UPDATE product AS p
SET
	net_price = price * (1 - ps.discount)
FROM product_segment AS ps
WHERE p.segment_id = ps.id
RETURNING *;

-- Kaydedelim
COMMIT;

-- 2.9. "test" veri tabanında araba fiyatlarına %15 oranında zam yapan sorguyu kalıcı olarak yapınız.
SELECT
	id AS "Araba ID",
	c.brand AS "Araba Markası",
	c.price AS "Araba Fiyatı",
	c.discount AS "İndirim Miktarı"
FROM cars AS c
ORDER BY c.id;

-- Transaction başlat
BEGIN TRANSACTION;

-- Sorguyu yazalım
UPDATE cars AS c
SET
	price = price * 1.15
RETURNING
	c.id AS "Güncellenen Araba ID",
	c.brand AS "Güncellenen Araba Markası",
	c.price AS "Güncellenen Araba Fiyatı";
	
-- Diske kalıcı olarak kaydedelim
COMMIT;


-- 2.10. "test" veri tabanında movie_rewies tablosunda filmi olmayan yorumları silen sorguyu yazınız ve kalıcı olarak kaydediniz.
SELECT
	mr.review_id AS "Film Yorum ID",
	mr.movie_id AS "Film ID",
	mr.review AS "Film Yorumu"
FROM movie_reviews AS mr
ORDER BY mr.review_id;

SELECT
	mr.review_id AS "Film Yorum ID",
	movie_id AS "Film ID",
	m.title AS "Film Başlığı",
	mr.review AS "Film Yorumu"
FROM movie_reviews AS mr
JOIN movies AS m
	USING(movie_id)
ORDER BY mr.review_id;


SELECT 
	mr.review_id AS "Film Yorum ID",
	mr.movie_id AS "Film ID",
	mr.review AS "Film Yorumu"
FROM movie_reviews AS mr
WHERE NOT EXISTS(
	SELECT
		1
	FROM movies AS m
	WHERE mr.movie_id = m.movie_id
)
ORDER BY mr.review_id;


-- Transaction başlat
BEGIN;

-- İstenen silme sorgusunu yazalım.
DELETE FROM movie_reviews AS mr
-- USING movies AS m
WHERE NOT EXISTS (
	SELECT
		1
	FROM movies AS m
	WHERE mr.movie_id = m.movie_id
)
RETURNING *;

-- Kaydedelim
COMMIT;
