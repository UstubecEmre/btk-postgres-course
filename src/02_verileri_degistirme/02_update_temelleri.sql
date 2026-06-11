-- 1. UPDATE Statement (Güncelleme İfadesi):
/*
Veri tabanlarında güncellemeler gerçekleştirebilmemizi sağlar.
UPDATE ile bir veya birden fazla kaydın değerini güncelleyebiliriz.

-- 1.1. Tek Satır Güncelleme Söz Dizimi:
```sql
UPDATE tablo_adi
SET
    sutun1 = deger1
WHERE kosul(lar);

	
```

-- 1.2. Çoklu Satır Güncelleme:

```sql
UPDATE tablo_adi
SET
    sutun1 = deger1,
	sutun2 = deger2
WHERE kosul(lar);

```

-- 1.3. RETURNING ile Kullanımı:
UPDATE cümlesini RETURNING ile de kullanabiliriz. 
Bu sayede SELECT ifadesine gerek kalmadan güncellenen değerin belirtilen kısmını görebiliriz.
```sql
UPDATE tablo_adi
SET
    sutun1 = deger1
	--sutun2 = deger2
WHERE kosullar
RETURNING * 
-- RETURNING dondurulmesi_istenen_sutun_adi
Önemli Notlar:
	- Burada WHERE ifadesi oldukça önemlidir. Eğer ki bir kriter/filtre vermezsek tüm tablo güncellenir.
	- UPDATE ifadesinde sadece bir tablo güncellenebilir, çoklu tablo aynı anda güncellenemez.
	- Her sorguyu çalıştırmadan önce kontrol etmek iyi olacaktır. UPDATE ifadesini geri döndürmek oldukça zordur.
	- RETURNING ifadesi ile de kullanılabilir, güncellenen değerin döndürülmesini sağlayabiliriz.
	- JOIN, Subqueries, UNION, EXISTS vb. işlemlerle beraber kullanabiliriz.
	
*/

-----------------------------------------------------------------------------------------------------------------------------------------
-- 2. UPDATE Examples (Güncelleme Örnekleri):
-- 2.1. "test" veri tabanında yer alan student tablosunda Big John isimli öğrencinin notunu güncelleyiniz.

SELECT
	s.id AS "Öğrenci ID",
	s.name AS "Öğrenci Adı",
	s.mark AS "Öğrenci Notu"
FROM student AS s
ORDER BY s.id;


UPDATE student
SET
	mark = mark + 15 
WHERE name = 'Big John';

-- İkinci yöntem

UPDATE student
SET
	mark = mark + 30
WHERE id = (
	SELECT
		stu.id
	FROM student AS stu
	WHERE stu.name = 'Big John'
	)

-- 2.2. "test" veri tabanında 'Blue' rengini 'Dark Blue' olarak değiştiren ve bunu döndüren sorguyu yazınız.
SELECT
	c.color AS "Renk"
FROM colors AS c
ORDER BY c.color;

UPDATE colors
SET
	color = 'Dark Blue'
WHERE color = 'Blue'
RETURNING color;

-- 2.3. "test" veri tabanında yer alan 1 numaralı id'ye sahip öğrenciye email adresi atayan sorguyu yazınız. (Örnek ad.soyad@gmail.com)
UPDATE student
SET
    email = LOWER
		(
 		REPLACE(name, ' ', '.')
		) || '@gmail.com'
WHERE id = 1;

-- Kontrol edelim, RETURNING ile de yapabilirdik.
SELECT
	s.id AS "Öğrenci ID",
	s.name AS "Öğrenci Adı",
	s.email AS "Öğrenci Mail Adresi"
FROM student AS s
WHERE s.id= 1;

-- 2.4. "test" veri tabanında kurs açıklamasında Bu kurs ifadesi geçen ifadeleri Kursumuz olarak güncelleyen sorguyu yazınız.
SELECT
	c.course_id AS "Kurs ID", 
	c.course_name AS "Kurs Adı",
	c.description AS "Kurs Açıklaması"
FROM courses AS C 
ORDER BY c.course_id;


UPDATE courses
SET
    description = REPLACE(description, 'Bu kurs', 'Kursumuz')
RETURNING 
	course_id AS c_id,
	description AS c_description;

-- Yanlış yazılmış bir ifade var, onu düzeltelim.
UPDATE courses
SET
	description = REPLACE(description, 'Kursumuzdaumuzda', 'Kursumuzda')
RETURNING 
	course_id AS c_id,
	description AS c_description;


-- 2.5. "test" veri tabanında fiyatı 20000'in altında olan arabalara 25000 zam yapan sorguyu yazınız.
SELECT
	c.id AS "Araba ID",
	c.brand AS "Araba Markası",
	c.price AS "Araba Fiyatı"
FROM cars AS c
ORDER BY c.id;


UPDATE cars
SET
	price = price + 25000
WHERE price < 20000
RETURNING *;

-- 2.6. "test" veri tabanında date_demo tablosunda 5 numaralı id değerini değiştiren sorguyu yazınız.
SELECT
	d.value_id AS "ID",
	d.date_value_str AS "String Formatta Tarih Değeri"
FROM date_demo AS d
ORDER BY d.value_id;


UPDATE date_demo
SET
	date_value_str = '2023-01-16'
WHERE value_id = 5
RETURNING date_value_str AS updated_value;

-- 2.7. "test" veri tabanında yer alan null olan değerlere 'white' atayan sorguyu yazınız
SELECT
	id AS "ID",
	bcolor AS "Arka Plan Rengi",
	fcolor AS "Ön Plan Rengi"
FROM distinct_demo AS d;

UPDATE distinct_demo
SET
	fcolor = 'white'
WHERE fcolor IS NULL
RETURNING *;


-- 2.8. "test" veri tabanında yer alan öğrencilerin email adresleri olmayanlara email adresi atayan sorguyu yazınız.
-- Boş olanları değiştirelim.
UPDATE student
SET
    email = LOWER
		(
 		REPLACE(name, ' ', '.')
		) || '@gmail.com'
WHERE email IS NULL;

/*
-- Uzun yöntem ile
UPDATE student
SET
	email = 
			CASE 
				WHEN POSITION(' ' IN s.name) > 0 
				THEN LOWER(SPLIT_PART(s.name, ' ',1)) 
				|| '.' 
				|| LOWER(SPLIT_PART(s.name, ' ', 2)) 
				|| '@gmail.com'
				ELSE LOWER(s.name) || '@gmail.com' 
			END
	)
WHERE student_id = 1
*/

-- 2.9. "test" veri tabanında 'Clock' ürününün 'Wall Clock', fiyatını da 580.65 olarak güncelleyen ve bu güncellemeyi döndüren sorguyu yazınız.
SELECT
	p.id AS "Ürün ID",
	p.name AS "Ürün Adı",
	p.price AS "Ürün Brüt Fiyatı"
FROM product AS p
ORDER BY p.id;

UPDATE product
SET
	name = 'Wall Clock',
	price = 580.65
WHERE id IN (
	SELECT
		p.id
	FROM product AS p
	WHERE p.name = 'Clock'
)

-- 2.10. "test" veri tabanında movie_reviews tablosunda movie_id değerleri NULL olanlara moveies tablosunda hiç kullanılmayan verileri atayan sorguyu yazınız.
SELECT
	review_id AS "Yorum ID",
	movie_id AS "Film ID",
	review AS "Film Yorumu"
FROM movie_reviews AS mr
ORDER BY review_id NULLS FIRST;

SELECT
	review_id AS "Yorum ID",
	movie_id AS "Film ID",
	review AS "Film Yorumu"	
FROM movie_reviews AS mr
WHERE movie_id IS NULL; -- 6, 11, 12


UPDATE movie_reviews 
SET movie_id = CASE review_id
		WHEN 6 THEN 15
		WHEN 11 THEN 14
		WHEN 12 THEN 12
	END 
WHERE movie_id IS NULL
RETURNING *;


-- 2.11. "test" veri tabanını kullanarak product_segmenti 2 olan ürünlerin net_price'ını hesaplayan sorguyu yazınız.
SELECT
	p.id AS "Ürün ID",
	p.name AS "Ürün Adı",
	p.price AS "Ürün Fiyatı",
	p.net_price AS "Ürünün İndirimli Fiyatı",
	ps.segment AS "Ürün Segmenti",
	ps.discount AS "İndirim Oranı"
FROM product AS p
JOIN product_segment AS ps
	ON p.segment_id = ps.id
WHERE ps.id = 2

-- Hepsini güncelleyelim, sadece segment numarası iki olanları güncellemek istersek WHERE yorum satırındaki AND kısmını açabiliriz.
UPDATE product AS p
SET
	net_price = price * (1 - ps.discount) -- Product tablosu için ALIAS kullanamayız, hata verir.
FROM product_segment AS ps
WHERE
	p.segment_id = ps.id 
	-- AND ps.id = 2
RETURNING 
	p.id AS "Ürün ID",
	p.name AS "Ürün Adı",
	p.price AS "Ürün Fiyatı",
	ps.discount AS "İndirim Oranı",
	p.net_price AS "Ürünün İndirimli Fiyatı";

-- 2.12. "test" veri tabanında yer alan employees tablosunda departmanı IT veya HR olan çalışanların maaşlarına %15, Finans ve Marketing olanlara yüzde 10 ve diğerlerine %7.5 zam yapan sorguyu yazınız.
SELECT
	e.emp_id AS "Yetenek ID",
	e.first_name || ' ' || e.last_name AS "Yetenek Adı Soyadı",
	e.department AS "Departmanı",
	e.salary AS "Çalışanın Ücreti"
FROM wf_test.employees AS e
ORDER BY e.emp_id;

UPDATE wf_test.employees AS e
SET
	salary = 
	CASE 
		WHEN e.department IN ('HR', 'IT') THEN salary * 1.15
		WHEN e.department IN ('Finance', 'Marketing') THEN salary * 1.10
		ELSE e.salary * 1.075
	END
RETURNING *;

--2.13. "test" veri tabanında courses tablosunda açıklaması boş olanları dolduran sorguyu yazınız
SELECT
	c.course_id AS "Kurs ID",
	c.course_name AS "Kurs Adı",
	c.description AS "Kurs Açıklaması"
FROM courses AS c
WHERE c.description IS NULL;

UPDATE courses AS c
SET
	description = 'PostgreSQL veri tabanı, kendini yenileyen ve önemi artan bir veri tabanı yönetim aracı ve SQL sorgulama dilidir. Burada gelin yeni bir ufuk açalım:)'
WHERE c.description IS NULL
RETURNING *;

-- 2.14. "test" veri tabanını kullanarak staff tablosunda tüm çalışanların hire_date sütunun 1 ay erkene alan, hire_date sütununu da iki hafta ileri alan sorguyu yazınız.
SELECT
	s.staff_id AS "Yetenek ID",
	s.first_name || ' ' || s.last_name AS "Yetenek Adı Soyadı",
	s.hire_date AS "İşe Girim Tarihi",
	s.departure_date AS "işten Ayrılma Tarihi"
FROM staff AS s
ORDER BY s.staff_id;

UPDATE staff AS s
SET
	hire_date = hire_date - 30,
	departure_date = departure_date + 14
RETURNING
	s.staff_id,
	s.hire_date,
	s.departure_date;
/*
-- INTERVAL ile de yapabiliriz, daha okunabilir olurdu.
UPDATE staff AS s
SET
	hire_date = hire_date - INTERVAL '1 MONTH,
	departure_date = departure_date + INTERVAL '14 DAYS' -- INTERVAL '2 WEEKS'
RETURNING
	s.staff_id,
	s.hire_date,
	s.departure_date;
*/
-- 2.15. "test" veri tabanında 16 numaralı araba tipini "Limo" yapan sorguyu yazınız.
SELECT
	ct.id AS "Araba ID",
	ct.type_name AS "Araba Tipi"
FROM car_types AS ct
ORDER BY ct.id;

UPDATE car_types AS ct
SET type_name = 'Limo'
WHERE ct.id = 16
RETURNING 
	ct.id AS "Araba ID",
	ct.type_name AS "Araba Türü";