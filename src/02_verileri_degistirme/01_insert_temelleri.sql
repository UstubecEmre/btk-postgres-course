-- 1. INSERT BASICS (Veri Ekleme Temelleri):

/*
Bir önceki bölümümüzde, SQL'de veri sorgulama temelleri hakkında teorik bilgiler öğrendik ve bunları pratik etme imkanı bulduk.
Bu kısım DQL (Data Query Language), yazılım, veri ve veri tabanı ile ilgilenenler için zaruridir.

Şimdi ise Veri Tabanı Yöneticisi (DBA) için şart ve geliştiricilerin (Developer) fayda göreceği DML (Data Manipulation Language) konularını irdeleyeceğiz. 
Burada bir tablo oluşturma, kayıt ekleme, güncelleme ve silme işlemlerini göreceğiz. 

1.1. DML Komutları:
Bu bölümde öğreneceğimiz DML (Verileri Değiştirme Komutları) komutları şunlardır:
Verileri değiştirme komutları:

- INSERT: Tablolara veri eklemek (satır) eklemek için kullanılan komuttur.
- UPDATE: Varolan verileri güncellemek için kullanırız.
- DELETE: Verileri silmek için kullanacağımız komuttur.

Not:
Literatürde bunlara CRUD (Create Read Update Delete) ismi verilmektedir.
READ, SELECT’i ifade etmektedir.

1.2. INSERT INTO Türleri:
Verileri eklemek için kullanılan yöntemler:
- Explicit: Kolonları yazarak veri ekleme yöntemidir. 
- Implicit: Sütunları belirtmeden veri ekleme yöntemidir. 
	Dikkat edilmesi gereken nokta, değerlerin tablonun sütunlarının oluşturulma sırasına göre eklememiz gerekmektedir.
	Zaten örtülü, kapalı anlamına gelmektedir.
	

İlk olarak INSERT INTO komutunu kullanarak bir tabloya nasıl veri ekleyeceğimizi öğreneceğiz.

```sql
-- Söz dizimi:
INSERT INTO tablo_adi [(kolon1, kolon2, kolon3, ...)]
VALUES (deger1, deger2, deger3, ...);
```
Not:
- Eğer ki otomatik artan bir sütununuz var ise, bu sütunu INSERT INTO komutunda belirtmenize gerek yoktur.

1.3. Varsayılan Değer (Default Value):
Bir tablodaki sütunun herhangi bir değeri girilmediği zaman DEFAULT olarak veri tabanı tarafından verilmesi gereken bir değer tanımlanmışsa
buna DEFAULT değer tanımlama ismi verilmektedir. 

Bu değerleri öğrenmek için pgAdmin4 üzerinde, ilgili tabloya sağ tıklayarak Properties (Özellikler) seçeneğine tıklayarak 
açılan pencerede Columns (Sütunlar) sekmesine geçiş yaparak ilgili sütunu seçip, sağ tarafta açılan pencerede Default Value (Varsayılan Değer) kısmında görebilirsiniz.

1.4. RETURNING:
INSERT INTO komutundan sonra RETURNING ifadesini kullanarak, son eklediğimiz kayıt veya kayıtların istediğimiz kolonlarını ve değerlerinin ne olduğunu görebiliriz.
Bir örnek üzerinden ilerlemek daha anlaşılır olacaktır. 

```sql
INSERT INTO students
    (
        name,
        age,
        grade
    
    )
VALUES
    (
        'Emre Üstübeç',
        27,
        'A'
    )
RETURNING name; 
-- RETURNING * 
-- RETURNING name AS student_name, age AS student_age;


```

1.5. Birden Fazla Satır Eklemek:
Birden fazla satır eklemek için INSERT INTO kısmımız aynı kalıyor, ancak VALUES kısmında ekleyeceğimiz kayıtları
parantez içerisinde yazarak ve virgülle diğer ekleyeceklerimizden ayırarak yapıyoruz.
Örnek üzerinden ilerlemek daha akılda kalıcı ve anlaşılır olacaktır.

```sql
-- İlk yöntemimiz
INSERT INTO courses
    (
        course_name,
		course_duration,
		course_description
	)
VALUES(
	'PostgreSQL',
	'18 Saat',
	'SQL Temellerinden Orta Seviyeye Kadar!'
)

INSERT INTO courses
    (
        course_name,
		course_duration,
		course_description
	)
VALUES(
	'Advanced PostgreSQL',
	'20 Saat',
	'POSTGRESQL İleri Seviyeye Kadar (CTE, Window Function, Index vb. dahil) '
)

-- İkinci Yöntem ise:
INSERT INTO courses
    (
        course_name,
		course_duration,
		course_description
	)
VALUES
    (
		'PostgreSQL',
	    '18 Saat',
	    'SQL Temellerinden Orta Seviyeye Kadar!'
	),
	(
        'Advanced PostgreSQL',
		'20 Saat',
		'POSTGRESQL İleri Seviyeye Kadar (CTE, Window Function, Index vb. dahil) '
	)

```

Görüldüğü üzere ikinci yöntemimiz yani çoklu kayıt ekleme daha pratiktir.


Dikkat edilmesi gereken noktalar: 
- Kolon ve değer sırası aynı olmalıdır.
- Veri tipleri, sırası ile uyumlu olmalıdır.
- Metin değerleri tek tırnak içinde olmalıdır.
- İşlem öncesinde ve sonrasında tabloyu kontrol etmek iyi bir uygulamadır.

*/

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 2. INSERT EXAMPLES (Veri Ekleme Egzersizleri):

-- 2.1. "test" veri tabanını kullanarak public.car_types tablosuna "Minivan" türünü ekleyen sorguyu yazınız.

-- İlk olarak tablomuzu tanıyalım.
SELECT
	ct.*
FROM car_types AS ct;

-- Veri ekleyelim. Sequences kısmından car_types_id_seq olduğunu gözlemleyebiliriz. 

INSERT INTO car_types
	(
		type_name
	)
VALUES
	(
		'Minivan'
	)


-- 2.2. "test" veri tabanını kullanarak public.courses tablosuna birden fazla kurs kaydı yapan sorguyu yazınız.

-- Tablomuzu inceleyelim. Burada da public.courses_course_id_seq var. 
SELECT
	c.course_id,
	c.course_name,
	c.description,
	c.published_date
FROM courses AS c
ORDER BY c.course_id DESC;

-- İlk yöntem, ayrı ayrı sorguları yazıp beraber çalıştırmak:
INSERT INTO courses
	(
		course_name,
		description,
		published_date
	)
VALUES
	(
		'PostgreSQL Essentials',
		'Bu kurs PostgreSQL için başlangıç seviyesinden orta seviyeye kadar olan konuları kapsayan, sektöre yönelik bir kurstur.',
		NOW()

	);
	
INSERT INTO courses
	(
		course_name,
		description,
		published_date
	)
VALUES
	(
		'Advanced Python for Data Scientist / AI-ML Engineers',
		'Bu kurs, Veri Bilimi, Yapay Zeka, Üretken Yapay Zeka alanlarına ilgi duyanlar içindir. İçerisinde Python dilinin temel unsurlarından Makine Öğrenmesine uzanan bir süreç ilerlemektedir.',
		TO_TIMESTAMP('2024-05-14 14:45:30', 'YYYY-MM-DD H24:MI:SS')

	);

-- İkinci yöntem: Çoklu satır ekleme

INSERT INTO courses
	(
		course_name,
		description,
		published_date
	)
VALUES
	(
		'MSSQL SERVER for Everyone',
		'Bu kurs Microsoft SQL Server öğretmeyi amaçlayan,ileri seviyeye kadar uzanan, öğrenci dostu fiyata sahip bir kurstur.',
		TO_TIMESTAMP('2021/11/18 20:45:59', 'YYYY/MM/DD H24:MI:SS')

	),
	(
		'RUST: Zero to Hero',
		'Günümüzde öneminin artacağına inandığım, RUST dilinin temellerine odaklanan, hız ve performans artışı isteyenlere yönelik bir eğitimdir.',
		TO_TIMESTAMP('2014.04.25 08:12:35', 'YYYY.MM.DD HH:MI:SS')
	),
	(
		'Linux and Bash Script Essentials',
		'Bu kursumuzda her bir yazılımcının bilmesini gerektiğini düşündüğüm Linux işletim sistemi ve BASH programlamaya yer vereceğiz. IT, Backend vb. alanlarda çalışmak istiyorsanız bu kurs size göre.',
		TO_TIMESTAMP('2026-09-01 09:00:00', 'YYYY-MM-DD HH:MI:SS')
	
	),
	(
		'Containerization: Docker and Kubernetes',
		'Son dönemlerin en popüler konularından olan konteyner mimarisi hakkında sektöre yönelik hazırlanan ve pratiklerin bolca yer aldığı eğitimimize kayıt olmayı unutmayın.',
		TO_TIMESTAMP('2026-04-17 23:30:14','YYYY-MM-DD H24:MI:SS')
		
	);

-- 2.3. "test" veri tabanını kullanarak public.movies tablosuna çoklu satır ekleyen sorguyu yazınız ve bu eklenen değerlerin otomatik üretilen "movie_id" bilgilerini döndürünüz.

-- Movies tablosunu inceleyelim, movie_id ve title olduğunu görelim. public.movies_movie_id_seq'de mevcut.
SELECT
	m.*
FROM movies AS m
ORDER BY m.movie_id DESC;


INSERT INTO movies AS m
	(
		title	
	)
VALUES
	(
		'Black Swan'
	),
	(
		'Pulp Fiction '
	),
	(
		'Anchorman'
	),
	(
		'The Shawshank Redemption'
	),
	(
		'Fight Club'
	)
-- RETURNING m.movie_id;
RETURNING movie_id;

-- 2.4. "test" veri tabanında yer alan public.movies tablosunu verisiz bir şekilde kopyalayarak suggested_movies isminde bir tablo oluşturan; ardından public.movie_reviews tablosu içerisinde inceleme metni (review) 'A' harfi ile başlayan kayıtların film id'lerini ve isimlerini movies tablosundan bularak bu yeni tabloya topluca ekleyen sorguyu yazınız.

-- suggested_movies tablosunu
CREATE TABLE suggested_movies AS 
SELECT
	movie_id,
	title
FROM movies
WITH NO DATA;


-- Tabloya ekleme yapalım.
INSERT INTO suggested_movies
	(
		movie_id,
		title
	)
SELECT
	m.movie_id,
	m.title 
FROM movies AS m
WHERE m.movie_id IN(
	SELECT
		mr.movie_id
	FROM movie_reviews AS mr
	WHERE mr.review LIKE 'A%'
);

SELECT
	s.movie_id,
	s.title
FROM suggested_movies AS s
ORDER BY s.movie_id;

/*
-- Aynı sorguyu EXISTS ile de yapabiliriz.
INSERT INTO suggested_movies
	(
		movie_id,
		title
	)
SELECT
	m.movie_id,
	m.title 
FROM movies AS m
WHERE EXISTS(
	SELECT
		1
	FROM movie_reviews AS mr
	WHERE 
		m.movie_id = mr.movie_id
		AND mr.review LIKE 'A%'
);
*/

-- 2.5. "test" veri tabanındaki public.cars tablosuna, sütun isimlerini açıkça belirtmeden (implicit yöntemle) tüm alanları (id, brand, price, discount) sırasıyla dolduracak şekilde yeni bir araç kaydı ekleyen sorguyu yazınız.

-- id alanı sequences yani veri tabanı tarafından otomatik artan şekilde takip ediliyor. 
-- Yine de verelim, normalde çok tavsiye edilmez.

SELECT
	c.*
FROM cars AS c
ORDER BY c.id DESC;

INSERT INTO cars
VALUES
	(
		13,
		'Suzuki',
		16000,
		250
	)

-- 2.6. "test" veri tabanındaki wf_test.employees tablosuna sadece "emp_id", "first_name", "last_name" ve "department" sütunlarını açıkça belirterek (explicit yöntemle) yeni bir personel ekleyen sorguyu yazınız.
SELECT
	-- *
	e.emp_id,
	e.first_name, 
	e.last_name,
	e.department,
	e.salary,
	e.hire_date,
	e.job_title
FROM wf_test.employees AS e
ORDER BY e.emp_id DESC;

-- Burada NOT NULL kısıtlaması olduğundan buna izin vermeyecektir, NOT NULL kısıtını
-- Tablo => Sağ tık => Properties => Columns kısmından değiştirebilir ve DEFAULT değer ekleyebilirsiniz.
INSERT INTO wf_test.employees
	(	
		emp_id,
		first_name,
		last_name,
		department
		/*salary,
		hire_date,
		job_title
		*/
	)
VALUES
	(
		201,
		'John',
		'Jardani',
		'Marketing'
		/*
		DEFAULT,
		DEFAULT,
		DEFAULT
		*/
	);
-- 2.7. "test" veri tabanındaki public.student tablosuna yeni bir öğrenci ekleyiniz. Öğrencinin sınıfını belirten "class" sütununa tablonun kendi varsayılan değerini ataması için sorgu içinde açıkça "DEFAULT" anahtar kelimesini kullanan kodu yazınız.
SELECT
	s.id,
	s.name,
	s.class,
	s.mark
FROM student AS s
ORDER BY s.id DESC;

INSERT INTO student
	(
		id,
		name,
		class,
		mark,
		gender,
		course_name,
		email
	)
VALUES	
	(
		36,
		'Eve Margotery',
		DEFAULT,
		89,
		'female',
		'Computer Science',
		'margotery_eve@gmail.com'
		
	);
	
-- 2.8. "test" veri tabanındaki public.student tablosuna yeni bir öğrenci kaydı ekleyiniz. Öğrencinin cinsiyetini belirten "gender" ve notunu belirten "mark" sütunlarını sorguya ve sütun listesine hiç dahil etmeyerek, tablonun bu alanları otomatik olarak kendi varsayılan (default) değerleriyle doldurmasını sağlayan sorguyu yazınız.
SELECT
	s.*
FROM student AS s
ORDER BY s.id DESC;

INSERT INTO student
	(
		id,
		name,
		course_name,
		email
	)
VALUES
	(
		37,
		'Anna Huyl',
		'Mechanical Engineer',
		'anna.huyl@outlook.com'
	);

-- 2.9. "test" veri tabanındaki public.product tablosuna tekli ürün kaydı ekleyiniz. İşlem bittiğinde sistemin otomatik ürettiği "id" bilgisini RETURNING ifadesiyle ekranda gösteren sorguyu yazınız.

-- public.product_id_seq ile takip ediliyor
SELECT
	p.id,
	p.name,
	p.price,
	p.net_price,
	p.segment_id
FROM product AS p
ORDER BY p.id DESC;

INSERT INTO product
	(
		name,
		price,
		net_price,
		segment_id
 	)
VALUES
	(
		'PC',
		8750.50,
		NULL,
		2
	)
RETURNING id;

-- 2.10. "test" veri tabanındaki public.colors tablosuna tek bir INSERT komutuyla aynı anda 3 farklı renk ekleyen ve işlem sonunda sadece eklenen bu renklerin isimlerini ("color") ekrana döndüren sorguyu yazınız.

SELECT
	c.color
FROM colors AS c
ORDER BY c.color;

INSERT INTO colors
VALUES
	(
		'Blue'
	),
	(
		'Purple'
	),
	(
		'Orange'
	)
RETURNING color;

-- 2.11. "test" veri tabanında yer alan public.basket_b tablosuna, public.basket_a tablosunda yer alan ve id_a numarası 10'dan büyük olan meyve kayıtlarını alt sorgu yardımıyla (INSERT INTO ... SELECT) tek seferde aktaran sorguyu yazınız.
-- Herhangi bir ekleme olmayacaktır, tablolardan 10'dan büyük id'ye sahip meyve bulunmamaktadır.
INSERT INTO basket_b
	(
		id_b,
		fruit_b
	)
SELECT
	id_a,
	fruit_a
FROM basket_a AS ba
WHERE ba.id_a > 10;


-- 2.12. "test" veri tabanındaki wf_test.employees tablosundan "first_name" ve "last_name" verilerini seçerek public.staff tablosuna aktaran bir sorgu yazınız.  

SELECT
	s.staff_id,
	s.first_name,
	s.last_name,
	s.hire_date,
	s.departure_date
FROM staff AS s
ORDER BY s.staff_id DESC;

INSERT INTO public.staff
	(
		first_name,
		last_name	
	)
SELECT
	emp.first_name,
	emp.last_name
FROM wf_test.employees AS emp;

-- 2.13. "test" veri tabanındaki wf_test.employees tablosunun yapısını verisiz olarak kopyalayıp high_salaries adında boş bir tablo oluşturunuz. Ardından wf_test.employees tablosunda maaşı (salary) 5000 ve üzerinde olan personelleri filtreleyerek bu yeni tabloye tek seferde ekleyen sorguyu yazınız.
-- Tablomuzu oluşturalım
CREATE TABLE high_salaries AS
SELECT
	emp_id,
	first_name,
	last_name,
	department,
	salary,
	hire_date,
	job_title
FROM wf_test.employees
WITH NO DATA;

SELECT
	hs.*
FROM public.high_salaries AS hs
ORDER BY hs.emp_id DESC;

-- Tabloaya verileri ekleyelim.
INSERT INTO high_salaries
SELECT
	e.emp_id,
	e.first_name,
	e.last_name,
	e.department,
	e.salary,
	e.hire_date,
	e.job_title
FROM wf_test.employees AS e
WHERE e.salary >= 5000;

-- 2.14. "test" veri tabanındaki public.product tablosuna yeni bir ürün kaydı ekleyiniz. Bu ürünün net fiyatı ("net_price") sütununa, tablodaki mevcut en yüksek ürün fiyatını (price) bir alt sorguyla (Subquery) dinamik olarak bulup yerleştiren sorguyu yazınız.
SELECT
	p.id,
	p.name,
	p.price,
	p.net_price,
	p.segment_id
FROM product AS p
ORDER BY p.id DESC;


INSERT INTO product
	(
		name,
		price,
		net_price,
		segment_id
	)
VALUES
	(
		'Laptop',
		10500,
		(
			SELECT
				MAX(pr.price)
			FROM product AS pr
		),
		3
	);

-- 2.15. "test" veri tabanında bulunan budgets tablosuna yeni kayıt ekleyen ve bunun current_year ve previous_year sütunlarını döndüren sorguyu yazınız.
INSERT INTO budgets
	(
		salesman_id,
		current_year,
		previous_year
	)
VALUES
	(
		70,	
		(
			SELECT
				COALESCE(CEIL(AVG(b.current_year)),10000)
			FROM budgets AS b
		),
		(
			SELECT
				COALESCE((MAX(b.previous_year) - 1400), 14000)
			FROM budgets AS b
		)
	)
RETURNING 
	current_year AS calculated_avg_current_year,
	previous_year AS subtracted_previous_year;

-- Alternatif

INSERT INTO budgets
	(
		salesman_id,
		current_year,
		previous_year
	)
SELECT
	80,
	COALESCE(CEIL(AVG(b.current_year)),12000),
	COALESCE(MAX(previous_year) - 1400, 16000)
FROM budgets AS b
RETURNING
	current_year AS calculated_avg_current_year,
	previous_year AS subtracted_previous_year;

SELECT
	b.*
FROM budgets AS b
ORDER BY b.salesman_id DESC;
