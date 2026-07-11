-- 1. REINDEX AND DROP INDEX:
/*
1.1. REINDEX Nedir?
REINDEX konusuna önceki dokümanımızda değinmiştik.
Daha önceden oluşturduğumuz bir indeximizin güncel haliyle beklentileri karşılayamaması,
hatalar vermesi, performansı iyi yansıtmaması vb. nedenlerden dolayı yeniden oluşturmamız gerekebilir.
Bu işlem için REINDEX kullanabiliriz.


1.2. REINDEX Söz Dizimi:
```sql
-- REINDEX
REINDEX INDEX guncelleyecegimiz_index_adimiz;

-- Tüm tablodaki indexleri değiştirmek istersek:
REINDEX TABLE tablo_ismimiz;

```

1.3. DROP INDEX Nedir?
Veri tabanının performansını sağlamak amacıyla gereksiz olan tüm nesneleri kaldırmamız ve iyi yönetmemiz gerekmektedir.
Bu nedenle kullanılmayan indexleri de kaldırmamız veri tabanının rahatlaması açısından iyi olacaktır.
İşimizin bittiği indexlerimizi temizlemek için DROP INDEX komutundan yararlanabiliriz.


1.4. DROP INDEX Söz Dizimi:

```sql
DROP INDEX [CONCURRENTLY] [IF EXISTS] index_adimiz
[CASCADE | RESTRICT];

```

Burada da hatırlatmalar yapmadan olmaz:
- CASCADE, ilişkili olan bağlantıları da silerdi.
- RESTRICT ise o bağımlılığı bertaraf etmeden bu işleme izin vermezdi.

Önemli Not: 
- CONCURRENTLY argümanı, canlı sistemlerde kilitlemelere neden olmadan işlemlerimizi gerçekleştirmemize
  yardımcı olmaktadır.
- DROP INDEX CONCURRENTLY bir transaction bloğu içinde ÇALIŞAMAZ.
- REINDEX bir transaction bloğu içinde ÇALIŞAMAZ.

İsterseniz, Transaction içerisinde bunları yapabilir, ilgili hataları gözlemleyebiliriz.
*/
---------------------------------------------------------------------------------------------------------------------------------------------
-- 2. REINDEX AND DROP INDEX EXAMPLES:
-- 2.1. "pagila" veri tabanını kullanarak daha önceden oluşturulmuş olan idx_last_name indexini kaldıran sorguyu yazınız.

-- Bir deneme yapmak için indexi kullanalım
EXPLAIN
SELECT
	c.customer_id,
	c.first_name,
	c.last_name,
	c.email,
	c.active
FROM customer AS c
WHERE c.last_name = 'SMITH';

/*
Query Plan'ı inceleyelim.
"Index Scan using idx_customer_last_name on customer c  (cost=0.28..8.29 rows=1 width=53)"
"  Index Cond: (last_name = 'SMITH'::text)"
*/

-- Transaction başlatalım
-- BEGIN;

-- İşlemi gerçekleştirelim
DROP INDEX CONCURRENTLY IF EXISTS idx_last_name;

-- Sorguyu çekelim
EXPLAIN
SELECT
	c.customer_id,
	c.first_name,
	c.last_name,
	c.email,
	c.active
FROM customer AS c
WHERE c.last_name = 'SMITH';

-- Kaydedelim
-- COMMIT;


-- 2.2. "pagila" veri tabanını kullanarak film_fulltext_idx indexini idx_film_fulltext olarak değiştiren sorguyu yazınız.

-- Indeximizi kullanabileceğimiz örnek bir sorgu çekelim
EXPLAIN
SELECT
	f.film_id,
	f.title,
	f.description,
	f.release_year,
	f.fulltext
FROM film AS f;
-- WHERE f.fulltext = ''battl':14 'beauti':4 'brooklyn':1 'compos':11 'dentist':8 'desert':2 'drama':5 'first':20 'man':21 'must':13 'space':22 'station':23 'sumo':16 'wrestler':17'

-- Transaction başlatalım
BEGIN TRANSACTION;

-- Index adımızı değiştirelim
ALTER INDEX film_fulltext_idx
RENAME TO idx_film_fulltext;

SAVEPOINT altered_film_fulltext_idx;
COMMIT;

-- REINDEX Kullanalım
REINDEX INDEX idx_film_fulltext;

-- Tabloyu yeniden çekelim
EXPLAIN
SELECT
	f.film_id,
	f.title,
	f.description,
	f.release_year,
	f.fulltext
FROM film AS f;
-- WHERE f.fulltext = 'istenilen_ifade'

-- Kaydedelim
-- COMMIT;

-- 2.3. "pagila" veri tabanında yer alan idx_payment_payment_date_month indexini kaldıran sorguyu yazınız.

-- Tabloyu çekelim ve indexi kontrol edelim
EXPLAIN
SELECT
	p.payment_id AS "Ödeme ID",
	p.customer_id AS "Müşteri ID",
	p.staff_id AS "Yetenek ID",
	p.rental_id AS "Kiralama ID",
	p.amount AS "Ödeme Miktarı",
	p.payment_date AS "Kiralama Tarihi"
FROM payment AS p
WHERE EXTRACT(MONTH FROM (p.payment_date AT TIME ZONE 'UTC')) = 6;

-- "ERROR: cannot drop partitioned index 'idx_payment_payment_date_month' concurrently"
/*
ÖNEMLİ NOT (PARTITIONED INDEX KISITLAMASI):
PostgreSQL, bölümlenmiş (partitioned) tabloların ana indekslerini CONCURRENTLY olarak silmeyi DESTEKLEMEZ.
Eğer CONCURRENTLY kullanırsak yukarıda belirtmiş olduğum hatayı alırız.

Bu yüzden bu işlem normal DROP INDEX ile yapılmalıdır.

*/

-- Transaction başlatalım
-- BEGIN;

-- İlgili indexi silelim
DROP INDEX IF EXISTS idx_payment_payment_date_month;


-- Sorguyu yeniden çekelim
EXPLAIN
SELECT
	p.payment_id AS "Ödeme ID",
	p.customer_id AS "Müşteri ID",
	p.staff_id AS "Yetenek ID",
	p.rental_id AS "Kiralama ID",
	p.amount AS "Ödeme Miktarı",
	p.payment_date AS "Kiralama Tarihi"
FROM payment AS p
WHERE EXTRACT(MONTH FROM (p.payment_date AT TIME ZONE 'UTC')) = 6;

-- Kaydedelim
-- COMMIT;

-- 2.4. "pagila" veri tabanında yer alan idx_unq_manager_staff_id indexini uq_idx_manager_staff_id olarak değiştiren sorguyu yazınız.

-- Sorgumuzdaki index ismini değiştirelim
BEGIN TRANSACTION;

ALTER INDEX idx_unq_manager_staff_id
RENAME TO uq_idx_manager_staff_id;

SAVEPOINT altered_idx_unq_manager_staff_id;

-- Kaydedelim
COMMIT;

-- Sorgumuzu çekelim
EXPLAIN
SELECT
	s.store_id AS "Mağaza ID",
	s.manager_staff_id AS "Yetenek Amiri ID",
	s.address_id AS "Adres ID",
	s.last_update AS "Son Güncelleme Tarihi"
FROM store AS s
WHERE s.manager_staff_id = 2;

-- Kaydedelim
-- COMMIT;

-- 2.5. "pagila" veri tabanında yer alan rental tablosundaki idx_rental_return_date indexini kaldıran sorguyu yazınız.

-- Tabloyu çekelim ve indexi görelim
EXPLAIN
SELECT
	r.rental_id,
	r.rental_date,
	r.inventory_id,
	r.customer_id,
	r.return_date,
	r.staff_id,
	r.last_update
FROM rental AS r
WHERE r.return_date IS NULL
ORDER BY r.return_date;

-- Transaction başlatalım
BEGIN TRANSACTION;

-- INDEX'i kaldıralım CONCURRENTLY kullanırsak Transaction olmamalı.
DROP INDEX /*CONCURRENTLY*/ IF EXISTS idx_rental_return_date;

-- Kaydedelim
COMMIT;

-- Sorguyu yeniden çekelim
EXPLAIN
SELECT
	r.rental_id,
	r.rental_date,
	r.inventory_id,
	r.customer_id,
	r.return_date,
	r.staff_id,
	r.last_update
FROM rental AS r
WHERE r.return_date IS NULL
ORDER BY r.return_date;


-- 2.6. "pagila" veri tabanında bulunan idx_store_id_film_id indexini kaldıran sorguyu yazınız.

-- Tabloyu inceleyelim
EXPLAIN
SELECT
	i.inventory_id,
	i.film_id,
	i.store_id,
	i.last_update
FROM inventory AS i
WHERE i.store_id = 1 
	AND i.film_id = 1;

/* 
Query Planımız:
"Bitmap Heap Scan on inventory i  (cost=4.32..16.00 rows=4 width=20)"
"  Recheck Cond: ((store_id = 1) AND (film_id = 1))"
"  ->  Bitmap Index Scan on idx_store_id_film_id  (cost=0.00..4.32 rows=4 width=0)"
"        Index Cond: ((store_id = 1) AND (film_id = 1))"

*/
-- Transaction başlatalım
-- BEGIN;

-- Silme işlemini yapalım
DROP INDEX CONCURRENTLY IF EXISTS idx_store_id_film_id;

-- Kaydedelim
-- COMMIT;

-- Sorguyu yeniden çekelim
EXPLAIN
SELECT
	i.inventory_id,
	i.film_id,
	i.store_id,
	i.last_update
FROM inventory AS i
WHERE i.store_id = 1
	AND i.film_id = 1;
	
-- 2.7. "pagila" veri tabanında yer alan idx_customer_last_name indexini temizleyen sorguyu yazınız.

-- Sorgumuzu çekelim => Indeximizi oluşturduğumuz haliyle gerçekleştirmemiz gerekmektedir.
-- Bunun için ilgili tablonun Indexes => Sağ Tık => Properties kısmından yararlanabiliriz.

EXPLAIN
SELECT
	c.customer_id,
	c.store_id,
	c.first_name,
	c.last_name,
	c.email,
	c.active
FROM customer AS c
WHERE c.last_name = 'SMITH';

-- Hatayı görmek için bırakalım
-- Transaction başlatalım ve işlemlerimizi güvence altına alalım.
BEGIN TRANSACTION;

-- Indexi kaldıralım
DROP INDEX CONCURRENTLY IF EXISTS idx_customer_last_name;

-- ERROR:  DROP INDEX CONCURRENTLY cannot run inside a transaction block 

-- Hatadan kurtulalım.
DROP INDEX IF EXISTS idx_customer_last_name;

-- Kaydedelim veya geriye alalım
COMMIT;

-- Sorguyu yeniden çekelim
EXPLAIN
SELECT
	c.customer_id,
	c.store_id,
	c.first_name,
	c.last_name,
	c.email,
	c.active
FROM customer AS c
WHERE c.last_name = 'SMITH';

-- 2.8. "pagila" veri tabanında bulunan uq_idx_customer_email indexini kaldıran sorguyu yazınız.

-- Sorgumuzu çekelim
EXPLAIN
SELECT
	c.customer_id,
	c.store_id,
	c.first_name || c.last_name AS full_name,
	c.email,
	c.active
FROM customer AS c
WHERE c.email = 'DOROTHY.TAYLOR@sakilacustomer.org';

/*
Query Plan üzerinden ilerleyelim.
"Index Scan using uq_idx_customer_email on customer c  (cost=0.28..8.29 rows=1 width=76)"
"  Index Cond: (email = 'DOROTHY.TAYLOR@sakilacustomer.org'::text)"
*/

-- Transaction başlatalım.
BEGIN;

-- İlgili INDEX'i silelim
-- DROP INDEX CONCURRENTLY IF EXISTS uq_idx_customer_email;
DROP INDEX IF EXISTS uq_idx_customer_email;

-- Kaydedelim
COMMIT;

-- Sorguyu yeniden çekelim ve sağlamasını yapalım.
EXPLAIN
SELECT
	c.customer_id,
	c.store_id,
	c.first_name || c.last_name AS full_name,
	c.email,
	c.active
FROM customer AS c
WHERE c.email = 'DOROTHY.TAYLOR@sakilacustomer.org';

/*
Görüldüğü üzere index aramamız gitmiş.
"Seq Scan on customer c  (cost=0.00..16.50 rows=1 width=76)"
"  Filter: (email = 'DOROTHY.TAYLOR@sakilacustomer.org'::text)"
*/

-- 2.9. "pagila" veri tabanında yer alan idx_last_name sorgusunu kaldıran sorguyu yazınız.

-- Tablomuzu çekelim ve indeximize uygun bir sorgu yazalım.
EXPLAIN
SELECT
	c.customer_id,
	c.store_id,
	c.first_name || c.last_name AS full_name,
	c.email,
	c.active
FROM customer AS c
WHERE c.last_name = 'TAYLOR';

-- Transaction başlatalım ve güvenli bir şekilde ilerleyelim
BEGIN;

-- Indexi silelim
-- DROP INDEX CONCURRENTLY IF EXISTS idx_last_name;

-- CONCURRENTLY kullanmadan Transaction içerisinde silelim.
DROP INDEX IF EXISTS idx_last_name;

-- Kaydedelim
COMMIT;

-- Aynı sorgumuzu yazalım ve farkı gözlemleyelim.
EXPLAIN
SELECT
	c.customer_id,
	c.store_id,
	c.first_name || c.last_name AS full_name,
	c.email,
	c.active
FROM customer AS c
WHERE c.last_name = 'TAYLOR';

-- 2.10. "pagila" veri tabanında yer alan idx_title indexini idx_film_title olarak değiştiren sorguyu yazınız.

-- Indexe uygun sorgumuzu yazalım.

EXPLAIN
SELECT
	f.film_id AS "Film ID",
	f.title AS "Film Başlığı",
	f.description AS "Film Açıklaması",
	f.release_year AS "Yayım Tarihi"
FROM film AS f
WHERE f.title = 'BASIC EASY';

/*
Query Plan'ımız bu şekilde, sizlerde bu şekilde kontrol edebilirsiniz ve karşılaştırabilirsiniz.
"Index Scan using idx_title on film f  (cost=0.28..8.29 rows=1 width=117)"
"  Index Cond: (title = 'BASIC EASY'::text)"
*/

-- Transaction başlatalım
BEGIN TRANSACTION;

-- Indeximizi yeniden isimlendirelim
ALTER INDEX idx_title
RENAME TO idx_film_title;

SAVEPOINT altered_idx_title;

-- Kaydedelim. Dilersek SAVEPOINT kısmını da yoruma alabiliriz.
COMMIT;
 
-- İlgili index silmemizi gerçekleştirelim. Bu sefer CONCURRENTLY kullanalım.
DROP INDEX CONCURRENTLY IF EXISTS idx_film_title;

-- Kaydedelim
-- COMMIT;

-- Aynı sorguyu yazalım
EXPLAIN
SELECT
	f.film_id AS "Film ID",
	f.title AS "Film Başlığı",
	f.description AS "Film Açıklaması",
	f.release_year AS "Yayım Tarihi"
FROM film AS f
WHERE f.title = 'BASIC EASY';