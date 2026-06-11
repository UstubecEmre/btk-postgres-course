-- 1. DELETE Statement (DELETE İfadesi):
/*
DELETE ifadesi, tablodan bir veya birden fazla kayıt silmemizi sağlayan önemli bir komuttur.

-- 1.1. Tek Satır Silme Syntaxi:
```sql
DELETE FROM tablo_adi
WHERE kosul(lar) -- genelde primary key verilir, tek satır olmasını garantilemek için.
```

Örnek olarak:
```sql
DELETE FROM teams
WHERE team_id = 1;
```

-- 1.2. Çoklu Satır Silme:
Çoklu satır silmek için, verilen şarta uygun olan kayıtlar silinmelidir.
Burada şart oldukça önemlidir.

-- İçerisinde FC geçenleri silen sorgu örneğinden ilerleyelim.
```sql
DELETE FROM teams
WHERE team_name LIKE '%FC%';
```

-- 1.3. RETURNING İfadesi ile Kullanımı:
Silinen değerlerin yani etkilenen kayıtları görmek için RETURNING ifadesini kullanabiliriz.
RETURNING * ile etkilenen sorgunun tüm sütunlarını, sütun adı (column_name) ile de belirttiğimiz sütunun
dönmesini sağlayabiliriz.

```sql
DELETE FROM members
WHERE member_name IN ('Emre', 'İsmail', 'Berkan', 'Burak')
RETURNING *
-- RETURNING member_id AS "Üye ID", member_name AS "Üye Adı";

Önemli Notlar:
- DELETE ifadesi, JOIN, HAVING, GROUP BY, SUBQUERY vb. sql komutlarıyla ve konularıyla beraber kullanılabilir.
- Sorguyu çalıştırmadan önce ve çalıştırdıktan sonra kontrollü bir şekilde ilerlememiz gerekmektedir.
- Silinen sorgunun ID numarası varsa, yeni kayıt eklenirse son id numarasından sonra devam eder, eski ID numaralarını almaz.
*/

------------------------------------------------------------------------------------------------------------------------------------------------------

-- 2. TRUNCATE Statement (TRUNCATE İfadesi):
/*
TRUNCATE ifadesi, DELETE komutunun aksine bir DML değil DDL komutudur.
DELETE ifadesine göre daha hızlı çalışır ve geri döndürülemez.
Bir tablodaki tüm verileri silmeye yarayan ifadedir.

-- 2.1. TRUNCATE Söz Dizimi:

```sql
-- Tekli tabloyu silerken
TRUNCATE tablo_adi;
```

```sql
-- Çoklu tablo silerken
TRUNCATE
	tablo1_adi,
	tablo2_adi,
	...;
```




-- 2.2. TRUNCATE Argümanları:
TRUNCATE ile kullanabileceğimiz argümanlar bulunamaktadır. 
Bunlar:
	- RESTART IDENTITY: Tablonun tamamını sildikten sonra eğer tablonun üzerinde bir identity sütun varsa (serial gibi) bunun değerini sıfırlar yani en başa getirir.
	Yeni eklenen kayıtlar 1 numaradan başlayacak şekilde eklenir.

	- CASCADE: Silinecek tablomuzun sayısı birden fazla ise ve bu tablolar birbirlerine yabancı anahtar 
	(FOREIGN KEY) ile bağımlıysa, bu bağımlılığı dikkate alarak kayıtların tamamını silen argümandır.

-- 2.3. TRUNCATE ile Argümanların Kullanımı:
```sql
-- RESTART IDENTITY argümanını görelim.
TRUNCATE teams
RESTART IDENTITY;
```

```sql
-- CASCADE argümanını görelim.
TRUNCATE 
	movies,
	movie_reviews
CASCADE;
```

Dikkat Edilmesi Gerekenler:
- Eğer ki foreign bağımlılığı varsa ve CASCADE argümanını kullanmazsak, ilgili tabloları silerken veri tabanımız bizlere hata verecektir.
- TRUNCATE işlemi geri döndürülemez bir işlemdir. Çok daha dikkatli kullanmamız tavsiye edilir.


*/
------------------------------------------------------------------------------------------------------------------------------------------------------

-- 3. DELETE EXAMPLES (DELETE Örnekleri):
-- 3.1. "test" veri tabanında yer alan suggested_movies tablosunda id numarası 3 olan kaydı silen sorguyu yazınız.
SELECT
	sm.movie_id AS "Film ID",
	sm.title AS "Film Başlığı"
FROM suggested_movies AS sm
ORDER BY sm.movie_id;

DELETE FROM suggested_movies AS sm
WHERE sm.movie_id = 3;

-- 3.2. "test" veri tabanında sonu 't' veya 'y' ile biten ürünleri silen sorguyu yazınız.
SELECT
	p.id AS "Ürün ID",
	p.name AS "Ürün Adı",
	p.price AS "Ürün Fiyatı"
FROM product AS p
ORDER BY p.id;

DELETE FROM product AS p
WHERE
	p.name LIKE '%t'
	OR p.name LIKE '%y';
	

-- 3.3. "test" veri tabanında yer alan high_salaries tablosundan en düşük maaşı alan yeteneği silen sorguyu yazınız ve bu değeri döndürürüz.
SELECT
	hs.emp_id AS "Yetenek ID",
	hs.first_name || ' ' || hs.last_name AS "Yetenek Adı Soyadı",
	hs.department AS "Departman",
	hs.salary AS "Yetenek Maaşı"
FROM high_salaries AS hs
ORDER BY hs.emp_id;


DELETE FROM high_salaries AS hs
WHERE hs.emp_id = (
	SELECT
		h.emp_id
	FROM high_salaries AS h
	WHERE h.salary = (
		SELECT
			MIN(salary)
		FROM high_salaries
	)
)
RETURNING *;

-- 3.4. "test" veri tabanında date_demo tablosunda içerisinde Feb geçenleri silen sorguyu yazınız.
SELECT
	d.value_id AS "Değer ID",
	d.date_value_str AS "Zaman Değeri"
FROM date_demo AS d
ORDER BY d.value_id;

-- Silelim
DELETE FROM date_demo AS d
WHERE d.date_value_str ILIKE '%Feb%'
RETURNING 
	d.value_id AS "Silinen Değer ID",
	d.date_value_str AS "Silinen Zaman Değeri";

-- 3.5. "test" veri tabanından fiyatı en düşük 3 arabayı silen sorguyu yazınız.
SELECT
	c.id AS "Araba ID",
	c.brand AS "Araba Markası",
	c.price AS "Araba Fiyatı"
FROM cars AS c
ORDER BY c.price 
LIMIT 3;

DELETE FROM cars AS c
WHERE c.id IN (
	SELECT
		ca.id
	FROM cars AS ca
	ORDER BY ca.price
	LIMIT 3
)
RETURNING 
	c.id AS "Silinen Araba ID",
	c.brand AS "Silinen Araba Markası",
	c.price AS "Silinen Araba Fiyatı";


-- 3.6. "test" veri tabanından geçen yılla bu yıl arasında ki satışları arasında çok fark olmayan yetenekleri işten çıkartan sorguyu yazınız.
SELECT
	b.salesman_id AS "Yetenek ID",
	b.current_year AS "Güncel Satış",
	b.previous_year AS "Geçen Yıl ki Satış"
FROM budgets AS b
ORDER BY b.salesman_id;

-- Silelim => Satışı geçen seneden az olanları sileceğiz.
DELETE FROM budgets AS b
WHERE 
	previous_year > current_year
RETURNING 
	b.salesman_id AS "Silinen Yetenek ID",
	b.current_year AS "Bu Sene ki Satış Miktarı",
	b.previous_year AS "Önceki Sene ki Satış Miktarı";

-- 3.7. "test" veri tabanında araba tipi limo olanları silen sorguyu yazınız ve bunu döndürünüz.
SELECT
	ct.id AS "Araba Tipi ID",
	ct.type_name AS "Araba Tipi"
FROM car_types AS ct
ORDER BY ct.id;

DELETE FROM car_types AS ct
WHERE ct.id = (
	SELECT
		c.id 
	FROM car_types AS c
	WHERE LOWER(c.type_name) = 'limo'
)
--RETURNING *;
RETURNING 
	ct.id AS "Silinen Araba Türü ID",
	ct.type_name AS "Silinen Araba Türü";
	
-- 3.8. "test" veri tabanında film başlığında "Armage" geçenleri silen sorguyu yazınız.
SELECT	
	m.movie_id AS "Film ID",
	m.title AS "Film Başlığı"
FROM movies AS m
ORDER BY m.movie_id;

-- Silelim
DELETE FROM movies AS m
WHERE m.title ILIKE '%Armage%'
RETURNING 
	m.movie_id AS "Silinen Film ID",
	m.title AS "Silinen Film Başlığı";

-- 3.9. "test" veri tabanında film yorumu en uzun kelimeye sahip yorumu silen sorguyu yazınz.
SELECT
	mr.review_id AS "Yorum ID",
	mr.movie_id AS "Film ID",
	mr.review AS "Film Yorumu"
FROM movie_reviews AS mr
ORDER BY mr.review_id;

SELECT
	m.movie_id AS "Film ID",
	m.title AS "Film Başlığı"
FROM movies AS m
ORDER BY m.movie_id;

-- Çok uzun bir yorum ekleyelim.
INSERT INTO movie_reviews
	(
		movie_id,
		review
	)
VALUES
	(
		9,
		'This film had a mind-blowing ending'
	),
	(
		10,
		'Interesting'
	),
	(
		11,
		'Fantastic and unbeliaveble'
	),
	(
		12,
		'Includes dark concepts'
	),
	(
		13,
		'Will Ferrell has created an iconic character. This film is absolutely funny'
	),
	(
		14,
		'This film is a masterpiece and unique'
	),
	(
		15,
		'This film has rules:) '
	)
RETURNING *;

SELECT
	mr.review_id AS "Yorum ID",
	MAX(LENGTH(mr.review)) AS "Yorum Uzunluğu"
FROM movie_reviews AS mr
GROUP BY mr.review_id
ORDER BY mr.review_id;


DELETE FROM movie_reviews
WHERE review_id = (
	SELECT
		mr.review_id
	FROM movie_reviews AS mr
	ORDER BY LENGTH(mr.review) DESC
	LIMIT 1
)
RETURNING *;


-- 3.10. "test" veri tabanında yorumu olmayan filmleri silen sorguyu yazınız.
SELECT
	mr.review_id AS "Yorum ID",
	movie_id AS "Film ID",
	m.title AS "Film Başlığı",
	mr.review AS "Film Yorumu"
FROM movie_reviews AS mr
LEFT JOIN movies AS m
	USING(movie_id)
ORDER BY mr.review_id;

-- Eşleşmesi olmayanları getirelim
SELECT
	mr.review_id,
	mr.movie_id,
	mr.review
FROM movie_reviews AS mr
WHERE
	NOT EXISTS(
		SELECT
			1
		FROM movies AS m
		WHERE mr.movie_id = m.movie_id
	)

-- Bunları silelim
DELETE FROM movies AS m
WHERE NOT EXISTS(
		SELECT
			1
		FROM movie_reviews AS mr
		WHERE m.movie_id = mr.movie_id
	)
RETURNING *;


-- 3.11. "test" veri tabanında distinct_demo tablosunu boşaltan sorguyu yazınız.
SELECT
	d.id AS "ID",
	d.bcolor AS "Arka Plan Rengi",
	d.fcolor AS "Ön Plan Rengi"
FROM distinct_demo AS d
ORDER BY d.id;

-- İçindeki verileri silelim.
TRUNCATE distinct_demo
RESTART IDENTITY;

INSERT INTO distinct_demo AS d
	(
		bcolor,
		fcolor
	)
VALUES
	(
		'Red',
		'White'
	),
	(
		'Yellow',
		'Dark Blue'
	),
	(
		'Purple',
		'Magenta'
	),
	(
		'Beige',
		'Forest Green'
	),
	(
		'Orange',
		'Teal'
	)
RETURNING *;

-- 3.12. "test" veri tabanında colors tablosunu boşaltan sorguyu yazınız.
TRUNCATE colors;

