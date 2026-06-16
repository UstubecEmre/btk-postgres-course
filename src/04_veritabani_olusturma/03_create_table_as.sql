-- 1. CREATE TABLE AS STATEMENT (CREATE TABLE AS İfadesi):
/*
Tablo oluşturmanın bir diğer yöntemi de CREATE TABLE AS ifadesidir.
Bu yönteme kısaca CAS, CTAS isimleri de verilmektedir.

-- 1.1. Söz Dizimi:
```
CREATE
    [temporary | temp | unlogged]
TABLE [IF NOT EXISTS] new_table_name 
    [(column_name[,…])]
AS query
    [WITH [NO] DATA];

-- Burada verisiz bir şekilde alabilmek amacıyla WHERE 1 = 0 ifadesini de kullanabiliriz.
```


-- Notlar:
Burada [] içinde olanlar opsiyoneldir.
WITH NO DATA ile verisiz bir şekilde tablo sütunları elde edilir.

-- 1.3. SEQUENCES:
SEQUENCES, veri tabanı tarafından yönetilen, arka planda tutulan bir nesnedir.
Sıralı numara vermeye yarar.

-- 1.3.1. SEQUENCES Özellikleri:
- Otomatik olarak tekil bir numara üretir.
- Sıralanmış tam sayılar üretir.
- Genellikle primary key yerine kullanılır.
- Cache bellek üzerinden çok hızlı erişim sağlanabilir.

-- 1.3.2. SEQUENCES Söz Dizimi:
```sql
CREATE SEQUENCE [IF NOT EXISTS] sequence_name
    [AS {SMALLINT | INT | BIGINT}]
    [INCREMENT [BY] VALUE]]
    [MINVALUE MINVALUE | NO MINVALUE]
    [MAXVALUE MAXVALUE | NO MAXVALUE]
    [START [WITH] VALUE]
    [CACHE CACHE]
    [[NO] CYCLE]
    [OWNED BY {table_name.column_name | NONE}];
```

Burada pek anlaşılır olmadığının farkındayım. Gelin daha basite indirgeyelim.

```sql
CREATE SEQUENCE seq_1
INCREMENT 1
START 1;

-- Argümanlarını da kullanalım. 
CREATE SEQUENCE seq_2
INCREMENT -1
MINVALUE 1
MAXVALUE 10
START 5
CYCLE; 
```

Dikkat Edilmesi Gerekenler:
- NEXTVAL('seq_1') => seq_1'in bir sonraki değerini verir. Her çalıştırılmada değeri verilen artış miktarı kadar artar. 
- CURRVAL('seq_2') => Güncel değerini verir.
*/

----------------------------------------------------------------------------------------------------------

-- 2. CREATE TABLE AS EXAMPLES (CREATE TABLE AS Örnekleri):
-- 2.1. "pagila" veri tabanını kullanarak müşterilerden isminin ikinci harfi E olanları getiren sorguyu yeni bir tabloya aktarınız.

SELECT
	c.customer_id "Müşteri ID",
	c.first_name || ' ' || c.last_name AS "Müşteri Adı Soyadı",
	c.email AS "Müşteri E-Posta",
	c.create_date AS "Müşteri Üye Tarihi"
FROM customer AS c
ORDER BY c.customer_id;

-- Transaction başlatalım
BEGIN TRANSACTION;

-- İstenilen sorguyu hazırlayalım 
CREATE TABLE IF NOT EXISTS selected_customer_names 
(
	customer_id,
	-- first_name || ' ' ||last_name AS customer_full_name,
	customer_full_name,
	email,
	create_date
) AS
SELECT
	c.customer_id,
	c.first_name || ' ' || c.last_name,
	c.email,
	c.create_date
FROM customer AS c
WHERE c.first_name ILIKE '_E%';

-- Kaydedelim
COMMIT;


-- 2.2. "pagila" veri tabanını kullanarak kategorisi Family olanları yeni bir tabloya aktaran sorguyu yazınız.

-- Sorguyu deneyelim
SELECT
	film_id AS "Film ID",
	f.title AS "Film Başlığı",
	c.name AS "Film Kategori"
FROM film AS f
LEFT JOIN film_category AS fc
	USING(film_id)
LEFT JOIN category AS c
	USING(category_id)
WHERE
	c.category_id = (
		SELECT
			cat.category_id
		FROM category AS cat
		WHERE cat.name = 'Family'
	)
ORDER BY f.film_id;

-- Transaction başlatalım
BEGIN;

-- İstenilen sorguyu hazırlayalım
CREATE TABLE family_categories
(
    film_id,
	film_title,
	category_name

) AS
SELECT
	film_id,
	f.title,
	c.name
FROM film AS f
LEFT JOIN film_category AS fc
	USING(film_id)
LEFT JOIN category AS c
	USING(category_id)
WHERE c.category_id = (
		SELECT
			cat.category_id
		FROM category AS cat
		WHERE cat.name = 'Family'
	)
ORDER BY f.film_id;

-- Kaydedelim
COMMIT;


-- 2.3. "pagila" veri tabanını kullanarak posta kodu 3 ile başlayanları  yeni bir tabloya aktaran sorguyu yazınız.

-- Sorgumuzu yazalım
SELECT
	a.address_id AS "Adres ID",
	a.address AS "Açık Adres",
	c.city AS "Şehir",
	a.postal_code AS "Posta Kodu"
FROM address AS a
LEFT JOIN city AS c
	USING(city_id)
WHERE a.postal_code LIKE '3%'
ORDER BY a.address_id


-- Transaction başlatalım
BEGIN TRANSACTION;

-- Sorgumuzu tabloya aktaralım
CREATE TABLE start_with_3_poscodes
(
	address_id,
	address,
	city,
	postal_code
) AS
SELECT
	a.address_id,
	a.address,
	c.city,
	a.postal_code 
FROM address AS a
LEFT JOIN city AS c
	USING(city_id)
WHERE a.postal_code LIKE '3%'
ORDER BY a.address_id;

-- Kaydedelim
COMMIT;


-- 2.4. "pagila" veri tabanını kullanarak aktif olmayan müşterileri not_actives isminde bir tabloya aktaran sorguyu yazınız.
SELECT
	c.customer_id AS "Müşteri ID",
	c.first_name || ' ' || c.last_name AS "Müşteri Adı Soyadı",
	c.email AS "Email"
FROM customer AS c
WHERE c.active <> 1;

-- Transaction başlatalım
BEGIN;

-- Sorguyu tabloya aktaralım
CREATE TABLE not_active_customers
(
	customer_id,
	customer_full_name,
	email
) AS
SELECT
	c.customer_id,
	c.first_name || ' ' || c.last_name,
	c.email 
FROM customer AS c
WHERE c.active <> 1;

-- Kaydedelim
COMMIT;


-- 2.5. "pagila" veri tabanını kullanarak müşterilere göre toplam harcama miktarını total_payments isminde bir tabloya aktaran sorguyu yazınız.
SELECT
	customer_id AS "Müşteri ID",
	c.first_name || ' ' || c.last_name AS customer_full_name,
	SUM(p.amount) AS "Toplam Harcama Miktarı"
FROM customer AS c
LEFT JOIN payment AS p
	USING(customer_id)
GROUP BY 
	customer_id,
	customer_full_name;

-- Transaction başlatalım
BEGIN TRANSACTION;

-- Sorgumuzu yazalım
CREATE TABLE total_amounts_by_customers
(
	customer_id,
	customer_full_name,
	total_amount
) AS
SELECT
	customer_id,
	c.first_name || ' ' || c.last_name,
	SUM(p.amount)
FROM customer AS c
LEFT JOIN payment AS p
	USING(customer_id)
GROUP BY 
	customer_id,
	customer_full_name;


-- Kaydedelim.
COMMIT;

-- 2.6. "pagila" veri tabanını kullanarak şehri 'Bucuresti', 'Adana' veya 'Barcelona' olan çalışanları listeleyip bunları yeni bir tabloya aktaran sorguyu yazınız.
SELECT
	customer_id AS "Müşteri ID",
	cu.first_name || ' ' || cu.last_name AS "Müşteri Adı Soyadı",
	a.address AS "Açık Adres",
	c.city AS "Şehir"
FROM customer AS cu
LEFT JOIN address AS a
	USING(address_id)
LEFT JOIN city AS c
	USING(city_id)
WHERE c.city_id IN (
		SELECT
			ci.city_id
		FROM city AS ci
		WHERE ci.city IN ('Bucuresti', 'Adana','Barcelona')
	);

-- Transaction başlatalım
BEGIN TRANSACTION;

-- Tablo oluşturalım
CREATE TABLE filtered_customer_and_city
(
	customer_id,
	cutomer_full_name,
	customer_address,
	customer_city
) AS
SELECT
	cu.customer_id,
	cu.first_name || ' ' || cu.last_name,
	a.address,
	c.city
FROM customer AS cu
LEFT JOIN address AS a
	USING(address_id)
LEFT JOIN city AS c
	USING(city_id)
WHERE c.city_id IN (
		SELECT
			ci.city_id
		FROM city AS ci
		WHERE ci.city IN ('Bucuresti', 'Adana','Barcelona')
	);

-- Kaydedelim
COMMIT;


-- 2.7. "pagila" veri tabanını kullanarak müşterilerin toplam ödemeleri 115'den küçükse bunları yeni bir tabloya aktaran sorguyu yazınız.
SELECT
	c.customer_id AS "Müşteri ID",
	c.first_name || ' ' || c.last_name AS customer_full_name,
	SUM(p.amount) AS "Toplam Harcama Tutarı"
FROM customer AS c
LEFT JOIN payment AS p
	USING(customer_id)
GROUP BY 
	c.customer_id,
	customer_full_name
HAVING SUM(p.amount) < 115
ORDER BY SUM(p.amount) DESC;

-- Transaction başlatalım
BEGIN TRANSACTION;

-- CREATE TABLE AS İle tabloya aktaralım
CREATE TABLE lower_earners 
(
	customer_id,
	customer_full_name,
	total_amount
) AS
SELECT
	c.customer_id,
	c.first_name || ' ' || c.last_name AS customer_full_name ,
	SUM(p.amount)
FROM customer AS c
LEFT JOIN payment AS p
	USING(customer_id)
GROUP BY 
	c.customer_id,
	customer_full_name
HAVING SUM(p.amount) < 115
ORDER BY SUM(p.amount) DESC;

-- Kaydedelim
COMMIT;

-- 2.8. "pagila" veri tabanını kullanarak aktörlerin isim ve soyisimleri 10 karakterden az olanları ayrı bir tabloya aktaran sorguyu yazınız.
SELECT
	a.actor_id AS "Aktör ID",
	a.first_name || ' ' || a.last_name AS "Aktör İsim Soysim",
	LENGTH(CONCAT(a.first_name, a.last_name)) AS "İsim Soyisim Uzunluğu"
FROM actor AS a
WHERE LENGTH(CONCAT(a.first_name, a.last_name)) < 10;


-- Transaction başlatalım
BEGIN;

-- Sorgumuzu 
CREATE TABLE length_of_actor
(
	actor_id,
	actor_full_name,
	length_of_full_name

) AS
SELECT
	a.actor_id,
	a.first_name || ' ' || a.last_name,
	LENGTH(CONCAT(a.first_name, a.last_name))
FROM actor AS a
WHERE LENGTH(CONCAT(a.first_name, a.last_name)) < 10;

-- Kaydedelim
COMMIT;


-- 2.9. "pagila" veri tabanını kullanarak rating'i PG-13 olan filmleri verisiz bir şekilde aktaran sorguyu yazınız
SELECT
	f.film_id AS "Film ID",
	f.title AS "Film Başlığı",
	f.release_year AS "Yayın Yılı",
	f.length AS "Film Uzunluğu"
FROM film AS f
WHERE f.rating = 'PG-13';

-- Transaction başlat
BEGIN;

-- İlgili tabloyu oluşturalım.

CREATE TABLE pg_13_films
(
	film_id,
	title,
	release_year,
	film_length

) AS
SELECT
	f.film_id,
	f.title,
	f.release_year,
	f.length
FROM film AS f
WHERE f.rating = 'PG-13';


-- Kaydedelim
COMMIT;

-- 2.10. Yeni bir tablo oluşturunuz ve buna sequence numarası atayınız.

-- Transaction başlatalım
BEGIN TRANSACTION;

-- Sequence oluşturalım.
CREATE SEQUENCE sq_total_directed_id
START 1
INCREMENT 1;

SAVEPOINT created_seq;

CREATE TABLE suggested_director
(
	director_id SERIAL PRIMARY KEY,
	director_name VARCHAR(20) NOT NULL,
	director_surname VARCHAR(20) NOT NULL,
	director_email VARCHAR(50) UNIQUE NOT NULL,
	directed_film_total SMALLINT NOT NULL DEFAULT NEXTVAL('sq_total_directed_id')
);

--Kaydedelim
COMMIT;

-- Transaction başlatalım
BEGIN;

-- Ekleme yapalım ve sequence'imizin çalışıp çalışmadığını gözlemleyelim.
INSERT INTO suggested_director
    (
	     director_name,
		 director_surname,
		 director_email
    )
VALUES
	(
		'Christopher',
		'Nolan',
		'christopher_nolan@director.com'
	)
RETURNING *;

SAVEPOINT inserted_nolan;

-- Kaydedelim
COMMIT;

-- Kontrol edelim
SELECT
	s.director_id,
	s.director_name,
	s.director_surname,
	s.director_email,
	s.directed_film_total
FROM suggested_director AS s
ORDER BY s.director_id;

-- Transaction ekleyelim
BEGIN;

-- Yeni eklemeler yapalım.
INSERT INTO suggested_director
    (
	     director_name,
		 director_surname,
		 director_email
    )
VALUES
	(
		'Quentin',
		'Tarantino',
		'tarantino-quentin@director.com'
	),
	(
		'Martin',
		'Scorsese',
		'martin-scoresese@outlook.com'
	),
	(
		'Steven',
		'Spielberg',
		'st_spielberg@gmail.com'
	),
	(
		'David',
		'Fincher',
		'fincher_david@yahoo.com'
	),
	(
		'Stanley',
		'Kubrick',
		'stanley_kubrick@gmail.com'
	),
	(
		'Alfred',
		'Hitchcock',
		'alfred_hitchcock@yahoo.com'
	)
RETURNING *;

-- Kaydedelim
COMMIT;

-- Yeniden bir kontrol edelim.
SELECT
	s.director_id,
	s.director_name,
	s.director_surname,
	s.director_email,
	s.directed_film_total
FROM suggested_director AS s
ORDER BY s.director_id;
