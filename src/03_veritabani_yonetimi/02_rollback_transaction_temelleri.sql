-- 1. ROLLBACK Statement (ROLLBACK İfadesi):
/*
ROLLBACK ifadesi, bir transaction sırasında yapılan tüm değişiklieri geri alan komuttur. 

1.1. ROLLBACK Özellikleri:
    - Veri değişiklikleri geri alınır.
    - Veriler, bir önceki statüsüne geri döner.
    - SAVEPOINT noktaları silinir.
    - Kilitler kaldırılır.

1.2. ROLLBACK Kullanımı: 

```sql
-- Takımlar isminde bir tablomuz olduğunu varsayalım.
SELECT
    t.team_id AS "Takım ID",
    t.team_name AS "Takım Adı",
    t.championships_won AS "Kazanılan Şampiyonluk Sayısı"
FROM teams AS t
ORDER BY t.team_id;

# Transaction başlatalım

BEGIN;

-- İstenilen işlemi yapalım.
INSERT INTO teams
    (
        team_name,
        championships_won
    )
VALUES
    (
        'FC Barcelona',
        24)
RETURNING *;

ROLLBACK; -- Şampiyonluk sayısının 26 olması gereksin. 


Önemli Notlar:
- ROLLBACK sonrasında olanlar da COMMIT’e oldukça benzer.
*/

------------------------------------------------------------------------------------------------------
-- 2. ROLLBACK EXAMPLES (ROLLBACK Örnekleri):
-- 2.1 "test" veri tabanında araçların id'si 11 olan aracın fiyatını 500 azaltacakken, tüm araçların fiyatını azaltan ve bu yanlışı geri alan sorguyu yazınız.

--Tablomuzu gözlemleyelim
SELECT
	c.id AS "Araba ID",
	c.brand AS "Araba Markası",
	c.price AS "Araba Fiyatı",
	c.discount AS "İndirim Miktarı"
FROM cars AS c
ORDER BY c.id;


-- Transaction başlatalım
BEGIN;

-- Yanlış güncelleme işlemi yapalım.
UPDATE cars AS c
SET 
	price = price - 5000
-- WHERE c.id = 11 --unutmuş olalım.
RETURNING 
	c.id AS "Güncellenen Araba ID",
	c.brand AS "Güncellenen Araba Modeli",
	c.price AS "Güncellenen Araba Fiyatı";

-- Değişikliği geri alalım.
ROLLBACK;


-- 2.2. "test" veri tabanında yer alan date_demo tablosunda içerisinde APR olanları silen sorguyu geri alan sorguyu yazınız.

-- Tablomuzu yakından inceleyelim.
SELECT
	d.value_id AS "Değer ID",
	d.date_value_str AS "Değerin Metinsel Karşılığı"
FROM date_demo AS d
ORDER BY d.value_id;

-- Transaction başlatalım
BEGIN TRANSACTION;

-- Silme işlemini yapalım.
DELETE FROM date_demo AS d
WHERE
	d.date_value_str ILIKE '%APR%'
RETURNING 
	d.value_id AS "Silinen Nesnenin ID Değeri",
	d.date_value_str AS "Silinen Değer";

-- Değişikliği geriye alalım
ROLLBACK;



-- 2.3. "test" veri tabanında yer alan colors tablosunda yeni eklemeler yapan ancak eklemelerin yazım yanlışı nedeniyle geri alan sorguyu yazınız.
SELECT
	c.color AS "Renk"
FROM colors AS c
ORDER BY c.color;

-- Transaction başlat
BEGIN;

-- Ekleme yap
INSERT INTO colors AS c
VALUES
	('Blue'),
	('Yellow'),
	('Teal'),
	('Pink'),
	('Gri')
RETURNING c.color AS "Eklenen Renk";

-- Geriye alalım
ROLLBACK;

-- 2.4. "test" veri tabanında olan ve yüksek maaşlı çalışanlardan en yüksek ikinci maaşı alan kişiyi silen sorguyu yazınız, bu işlemi geriye alınız.
SELECT
	hs.emp_id AS "Yetenek ID",
	hs.first_name || ' ' || hs.last_name AS "Yetenek Adı Soyadı",
	hs.department AS "Departman",
	hs.salary AS "Yetenek Ücreti"
FROM high_salaries AS hs
ORDER BY hs.emp_id;

SELECT
	hs.emp_id AS "Yetenek ID",
	hs.first_name || ' ' || hs.last_name AS "Yetenek Adı Soyadı",
	hs.department AS "Departman",
	hs.salary AS "Yetenek Ücreti"
FROM high_salaries AS hs
ORDER BY hs.salary DESC
LIMIT 2;

SELECT
	hs.emp_id AS "Yetenek ID",
	hs.first_name || ' ' || hs.last_name AS "Yetenek Adı Soyadı",
	hs.department AS "Departman",
	hs.salary AS "Yetenek Ücreti"
FROM high_salaries AS hs
WHERE hs.salary < (
	SELECT
		MAX(h.salary)
	FROM high_salaries AS h
)
ORDER BY hs.salary DESC
LIMIT 1;

-- Transaction başlatalım
BEGIN;

-- Sorgumuzu yazalım.
DELETE FROM high_salaries AS hi
WHERE hi.emp_id = (
	SELECT
		hs.emp_id
	FROM high_salaries AS hs
	WHERE hs.salary <
	(
		SELECT
			MAX(h.salary)
		FROM high_salaries AS h
	)
	ORDER BY hs.salary DESC
	LIMIT 1
)
RETURNING
	hi.emp_id AS "Silinecek Yetenek ID",
	hi.first_name || ' ' || hi.last_name AS "Silenecek Yetenek Adı Soyadı",
	hi.salary AS "Silinecek Yetenek Maaş";

-- İşlemi geriye alalım
ROLLBACK;

-- 2.5. "test" veri tabanında en uzun açıklamaya sahip kursu silen sorguyu yazınız ve bu işlemi geriye alınız.
SELECT
	c.course_id AS "Kurs ID",
	LENGTH(c.description) AS "Açıklama Uzunluğu"
FROM courses AS c
GROUP BY c.course_id
ORDER BY LENGTH(c.description) DESC;


-- En uzun kurs açıklamasının id değeri
SELECT
	c.course_id
FROM courses AS c
WHERE 
	LENGTH(c.description) =
	 (
		SELECT
			MAX(LENGTH(co.description))
		FROM courses AS co
	);

-- Transaction Başlatalım
BEGIN;

-- En uzun açıklamaya sahip kursu silelim

DELETE FROM courses AS c
WHERE c.course_id = (
	SELECT
		c.course_id
	FROM courses AS c
	WHERE LENGTH(c.description) =
	 (
		SELECT
			MAX(LENGTH(co.description))
		FROM courses AS co
	)
)
RETURNING *;

-- İşlemi geriye alalım
ROLLBACK;


-- 2.6. "test" veri tabanında yer alan product_segment tablosunda discount oranlarını güncelleyen ve yapılan değişiklikleri geriye alan sorguyu yazınız
-- Tablomuzu inceleyelim.
SELECT
	ps.id AS "Ürün Segment ID",
	ps.segment AS "Ürün Segmenti",
	ps.discount AS "İndirim Oranı"
FROM product_segment AS ps
ORDER BY ps.id;

-- Transaction başlatalım.
BEGIN;

-- Güncelleme işlemini yapalım
UPDATE product_segment AS ps
SET
	discount = discount - 0.01;


-- İşlemi geriye alalım
ROLLBACK;



-- 2.7. "test" veri tabanında yer alan wf_test tablosunda yer alan çalışanlardan ortalama maaşın üzerinde olanlardan 300 çıkaran sorguyu yazınız ve işlemi geriye alınız.

SELECT
	emp.emp_id AS "Yetenek ID",
	emp.first_name || ' ' || emp.last_name AS "Yetenek Adı Soyadı",
	emp.department AS "Departman",
	emp.salary AS "Yetenek Ücreti"
FROM wf_test.employees AS emp
ORDER BY emp.emp_id;


SELECT
	emp.emp_id AS "Yetenek ID",
	emp.first_name || ' ' || emp.last_name AS "Yetenek Adı Soyadı",
	emp.department AS "Departman",
	emp.salary AS "Yetenek Ücreti"
FROM wf_test.employees AS emp
WHERE
	emp.salary < (
		SELECT
			FLOOR(AVG(e.salary))
		FROM wf_test.employees AS e
	)
ORDER BY emp.emp_id;

-- Transaction başlatalım.
BEGIN TRANSACTION;

-- Güncelleme yapalım.
UPDATE wf_test.employees AS emp
SET
	salary =emp.salary - 300
WHERE
	emp.salary < (
		SELECT
			FLOOR(AVG(e.salary))
		FROM wf_test.employees AS e
	)
RETURNING 
	emp.emp_id AS "Güncellenen Yetenek ID",
	emp.first_name || ' ' || emp.last_name AS "Güncellenen İsim Soyisim",
	emp.salary AS "Güncellenen Çalışan Ücreti";

-- İşlemi geriye alalım
ROLLBACK;

-- 2.8. "test" veri tabanında arabaların indirim oranlarının tümünü 1000 yapan ancak istek üzerine bu işlemden vazgeçilen (geriye alınması istenen) sorguyu yazınız.
-- Tablomuzu hatırlayalım.
SELECT
	c.id AS "Araba ID",
	c.brand AS "Araba Markası",
	c.price AS "Araba Fiyatı",
	c.discount AS "İndirim"
FROM cars AS c
ORDER BY c.id;

-- Transaction başlatalım.
BEGIN;

-- Sorgumuzu yazalım
UPDATE cars AS c
SET 
	discount = 1000;

-- İşlemimizi beğenmeyelim ve geriye alalım.
ROLLBACK;


-- 2.9. "test" veri tabanında en düşük 3 nota sahip öğrencilere 20 puan ekleyen ve bu işlemi deneme sonucunda geri alan sorguyu yazınız.

-- Tablomuza bakalım
SELECT
	s.id AS "Öğrenci ID",
	s.name AS "Öğrenci İsim Soyisim",
	s.class AS "Öğrencinin Sınıfı",
	s.mark AS "Öğrencinin Notu"
FROM student AS s;

SELECT
	s.id AS "Öğrenci ID",
	s.name AS "Öğrenci İsim Soyisim",
	s.class AS "Öğrencinin Sınıfı",
	s.mark AS "Öğrencinin Notu"
FROM student AS s
ORDER BY s.mark 
LIMIT 3;

--Transaction başlatalım
BEGIN TRANSACTION;

-- Güncelleme yapalım
-- IN kullanarak yapalım

UPDATE student AS s
SET
	mark = mark + 20
WHERE
	s.id IN (
		SELECT
			stu.id
		FROM student AS stu
		ORDER BY stu.mark
		LIMIT 3
	)
RETURNING *;

/*
UPDATE student AS s
SET
	mark = mark + 20
WHERE
	EXISTS (
		SELECT
			1
		FROM (
			SELECT stu.id 
			FROM student AS stu
			ORDER BY stu.mark
			LIMIT 3
		) AS min_marks
		WHERE
			s.id  = min_marks.stu_id
	)
RETURNING *;
*/ 


-- Geriye alalım
ROLLBACK;


-- İşlemi geriye alalım


-- 2.10. "test" veri tabanında cinsiyete göre gruplanmış olan öğrencilerin, ortalama notlarını bulan ve bunlara 5 ekleyen sorguyu yazınız ve geriye döndürünüz. Bu işlemi geriye alınız.
SELECT
	s.id AS "Öğrenci ID",
	s.name AS "Öğrenci Adı Soyadı",
	s.gender AS "Öğrenci Cinsiyeti",
	s.class AS "Öğrenci Sınıfı",
	s.mark AS "Öğrenci ",
	s.course_name AS "Öğrencinin Kursu",
	s.email AS "Öğrenci E-Posta Adresi"
FROM student AS s
ORDER BY s.id;

-- İstenilenleri deneyelim
SELECT
	s.gender AS "Öğrenci Cinsiyet",
	COUNT(*) AS "Öğrenci Sayısı",
	ROUND(AVG(s.mark), 2) AS  "Not Ortalaması"
FROM student AS s 
GROUP BY s.gender
ORDER BY s.gender;

-- Transaction başlatalım
BEGIN;

-- Güncelleme yapalım.
UPDATE student AS s
SET
	mark = s.mark + 5
WHERE
	s.mark < (
		SELECT
			ROUND(AVG(stu.mark))
		FROM student AS stu
		WHERE stu.gender = s.gender
	)
RETURNING *;

-- İşlemi geriye alalım.
ROLLBACK;



-- GROUP BY hatırlayalım değil mi:)
-- Cinsiyete göre Ortalamadan az olanların öğrenci sayısını bulalım

SELECT
	s.gender AS "Öğrenci Cinsiyet",
	COUNT(*) AS "Öğrenci Sayısı",
	ROUND(AVG(s.mark), 2) AS  "Not Ortalaması"
FROM student AS s 
WHERE s.mark < (
	SELECT
		ROUND(AVG(stu.mark))
	FROM student AS stu
	WHERE stu.gender = s.gender
)
GROUP BY s.gender
ORDER BY s.gender;

-- Diğer çözüm de :
SELECT
    s.gender AS "Öğrenci Cinsiyeti",
    COUNT(*) AS student_count
FROM student AS s
JOIN (
    SELECT
        gender, -- cinsiyet
        AVG(mark) AS avg_mark -- ortalama puan
    FROM student
    GROUP BY gender
) AS g -- tablo olarak döndürdük
    ON s.gender = g.gender
WHERE s.mark < g.avg_mark
GROUP BY s.gender
ORDER BY s.gender;

-- Bölümlerin VE cinsiyetlere göre  ortalamayı bulalım.
SELECT
	s.course_name AS "Bölüm",
	s.gender AS "Cinsiyet",
	ROUND(AVG(s.mark),2) AS "BÖlüm Ortalaması"
FROM student AS s
GROUP BY
	s.course_name,
	s.gender
ORDER BY ROUND(AVG(s.mark),2) DESC;


-- Toplam ortalamadan düşük olanları bulalım
SELECT
	s.course_name AS "Bölüm",
	s.gender AS "Cinsiyet",
	ROUND(AVG(s.mark),2) AS "BÖlüm Ortalaması"
FROM student AS s
WHERE s.mark < (
	SELECT
		ROUND(AVG(stu.mark)) -- 74
	FROM student AS stu
)
GROUP BY
	s.course_name,
	s.gender;