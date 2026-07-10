-- 1. INDEXES (Indexler):

/*
-- 1.1. Index Nedir?
Indexler, sorguları hızlandırmak için kullanılan nesnelerdir.
İstenilen verileri çok hızlı getirmek için kullanılırlar.
Diskte de Input/Output işlemlerinde azalma sağlar.
Verilerin önceden sıralanmasında katkı sunarlar.


-- 1.2. Index Çeşitleri:

-- BTREE INDEX: 
Varsayılan olarak gelen indextir.
Karşılaştırma operatörleri ile birlikte kullanılırlar (<, >, <=, >=, =, BETWEEN)
ORDER BY, IS NULL ve IS NOT NULL İle de kullanılabilirler.

-- HASH INDEX: 
Sadece eşitlik anlamında kullanılan bir sorgumuz varsa tercih edilmesi gereken indextir.
= operatörü ile birlikte kullanılır.

-- GIN(Generalized Inverted Index) INDEX
Array, Jsonb, Full Text Search vb. konularla beraber kullanılan index çeşididir.
Arama parametreleri olan @, ?, && ile kullanılırlar.

-- GIST (Generalized Search Tree) INDEX:
Geometrik verilerde tercih edilen index türüdür.
PostGIS Spatial sorgularda tercih edilir.

-- SP-GIST (Space-Partitioned Generalized Search Tree) INDEX:
Veriyi bölerek indexleyen index türüdür.
Kullanılan verilere örnek olarak:
	IP Adresi (192.168.10.10)
	Telefon Numaraları 
	Ağaç yapıları (Tree, Radix Tree) 

-- BRIN:
Çok büyük tablolarda tercih edilen index türüdür.
Zaman serisi verilerinde ve sıralı (append-only) büyük tablolarda kullanılırlar. 


-- 1.3. Index Söz Dizimi
Index türünü vermek istersek mutlaka ama mutlaka USING kullanmamız gerekmektedir.
```sql

-- Varsayılanı BTREE olan index oluşturma
CREATE INDEX index_adimiz
ON tablo_adimiz
(
	sutun_adimiz [ASC | DESC] [NULLS {FIRST | LAST}],
	...
);

-- Eğer ki index çeşidini kendimiz belirleyeceksek:
CREATE INDEX index_adimiz
ON tablo_adimiz
USING BTREE | HASH | GIN | GIST | SPGIST | BRIN
(column_name);


-- 1.4. UNIQUE INDEX Kullanımı:
Eğer indexlerimizi oluştururken verilerimizin de benzersiz olmasını istersek,
UNIQUE INDEX kullanmamız iyi olacaktır.

```sql
CREATE UNIQUE INDEX index_adimiz
ON tablo_adimiz(sutun_adi(adlari));
```
Burada kullanmış olduğumuz sütun adlarına girilen verilerin benzersiz olmasını da kontrol eder.
Veri ekleme vb. işlemlerde eğer ki benzersizlik şartı sağlanmazsa uyarı verir ve işlemi gerçekleştirmez.

-- 1.5. REINDEX:
Daha önceden oluşturulan bir indeximizi yeniden oluşturmamızı sağlayan komuttur.
Indeximizin beklenilen performansı gerçekleştirememesi vb. nedenlerden dolayı kullanılabilir.

```sql

-- Belirli bir indexi yeniden oluşturmak için kullanılan söz dizimimiz:
REINDEX INDEX index_adimiz;


-- Bir tablodaki tüm indexleri sıfırlamak için kullanabileceğimiz söz dizimimiz:
REINDEX TABLE tablo_adimiz;
```

-- 1.6. INDEX Kaldırma:

```sql
DROP INDEX [CONCURRENTLY] [IF EXISTS] index_adimiz
[CASCADE | RESTRICT];

```
Burada da hatırlatmalar yapmadan olmaz:
CASCADE, ilişkili olan bağlantıları da silerdi.
RESTRICT ise o bağımlılığı bertaraf etmeden bu işleme izin vermezdi.
CONCURRENTLY argümanı, canlı sistemlerde kilitlemelere neden olmadan işlemlerimizi gerçekleştirmemize
yardımcı olmaktadır.



```sql
-- Partial yani parçalı index için kısıtımıza göre indexi oluştururuz
CREATE INDEX index_adi
ON tablo_adimiz(sutun_adi)
WHERE sartimiz;


-- Function index ise, sorguda bir fonksiyon kullanacaksak oluşturmamız gereken indextir.
CREATE INDEX index_adi 
ON tablo_adimiz( FONKSIYON(sutun_adi) )


Önemli Hatırlatmalar:
- Bir indexi oluştururken, kısıtlamalarımıza göre indexlerimizi oluşturmamız iyi olacaktır.
- Bu nedenle Partial Index, Function index oluşturabiliriz.
- Bir indexi sürekli olarak kullanmayacaksak, veri tabanımızı gereksiz yere şişirmemesi amacıyla
  silmemiz iyi olacaktır.
- INDEX, IN, ILIKE, LIKE vb. operatörleri sevmemektedir. Bu operatörlerin kullanılacağı sorgularda index kullanmamak gerekmektedir. Var olan INDEX kullanılmayacaktır.


EXPLAIN ifadesi ile veri tabanları EXECUTION PLAN oluşturmakta, hangi yöntemi kullanacaklarına karar vermektedirler.

Önemli Not:
Eğer ki index'imizin çalışmasını zorlamak istemiyorsak ve doğal yoldan index ile arama yapılmasını arzuluyorsak,
gelecek olan verilerin tüm tablonun %5-%15 arasında olmasını sağlamalıyız:) 
*/


---------------------------------------------------------------------------------------------------------
-- 2. INDEX EXAMPLES (Index Örnekleri):
-- 2.1. "pagila" veri tabanını kullanarak 'country' sütununa index oluşturan sorguyu yazınız.

-- Tabloyu hatırlayalım
SELECT
	c.country_id AS "Ülke ID",
	c.country AS "Ülke",
	c.last_update AS "Son Güncellenme Tarihi"
FROM country AS c;

-- Transaction başlatıp index oluşturalım
BEGIN;

-- Indeximiz
CREATE INDEX idx_country_country
ON country(country);

-- EXPLAIN İle sorgumuzu çalıştıralım
EXPLAIN
SELECT
	c.country_id,
	c.country,
	c.last_update
FROM country AS c
WHERE c.country = 'Italy';

-- Burada seq scan kullandı. Tablomuz yeterince büyük olmadığından olabilir.

-- Kaydedelim
COMMIT;

-- 2.2: "pagila" veri tabanında "film" tablosundaki "title" (film adı) sütununa göre yapılan aramaları hızlandırmak amacıyla varsayılan türde (B-Tree) bir indeks oluşturan sorguyu yazınız.

-- Tablomuzu görelim
EXPLAIN
SELECT
	f.film_id AS "Film ID",
	f.title AS "Film Başlığı",
	f.description AS "Film Açıklaması",
	f.release_year AS "Yayın Tarihi",
	f.length AS "Film Uzunluğu",
	f.rating AS "Film Ratingi",
	f.rental_rate AS "Kiralama Tutarı"
FROM film AS f;
--WHERE f.title = 'ARACHNOPHOBIA ROLLERCOASTER'; -- açarsak index_scan

-- Seq Scan on film f  (cost=0.00..98.00 rows=1000 width=129)

-- Transaction başlatalım
BEGIN;

-- Index oluşturalım
CREATE INDEX idx_film_title
ON film(title);

-- Sorgumuzu yeniden deneyelim
EXPLAIN
SELECT
	f.film_id AS "Film ID",
	f.title AS "Film Başlığı",
	f.description AS "Film Açıklaması",
	f.release_year AS "Yayın Tarihi",
	f.length AS "Film Uzunluğu",
	f.rating AS "Film Ratingi",
	f.rental_rate AS "Kiralama Tutarı"
FROM film AS f
WHERE f.title = 'ARACHNOPHOBIA ROLLERCOASTER';

-- Index Scan using idx_title on film f  (cost=0.28..8.29 rows=1 width=129)
-- Kaydedelim 
COMMIT;

-- 2.3. "pagila" veri tabanında bulunan "customer" tablosunda müşterilerin soyadlarına ("last_name") göre arama ve sıralama işlemlerinin yoğun olduğunu fark ettiniz. Bu sütun için uygun indeksi oluşturunuz.

-- Tabloyu çekelim
EXPLAIN
SELECT
	c.customer_id AS "Müşteri ID",
	c.store_id AS "Mağaza ID",
	c.first_name AS "Müşteri Adı",
	c.last_name AS "Müşteri Soyadı",
	c.email AS "E-Posta Adresi"
FROM customer AS c;
-- WHERE c.last_name = 'RIVERA';

-- Transaction başlatalım
BEGIN;

-- Index oluşturalım
CREATE INDEX idx_customer_last_name
ON customer(last_name);

-- Tablomuzu yeniden çekelim
EXPLAIN
SELECT
	c.customer_id AS "Müşteri ID",
	c.store_id AS "Mağaza ID",
	c.first_name AS "Müşteri Adı",
	c.last_name AS "Müşteri Soyadı",
	c.email AS "E-Posta Adresi"
FROM customer AS c
WHERE c.last_name = 'RIVERA';

-- Kaydedelim
COMMIT;


-- 2.4. "pagila" veri tabanında bulunan "actor" tablosunda arama yaparken büyük/küçük harf duyarlılığını (Case-Sensitivity) tamamen ortadan kaldırmak amacıyla, "first_name" sütununa harfleri büyüterek arama yapacak bir Fonksiyon İndeksi (Function Index) uygulayınız.

-- Tabloyu çekelim
EXPLAIN
SELECT
	a.actor_id AS "Aktör ID",
	a.first_name AS "Aktör Adı",
	a.last_name AS "Aktör Soyadı",
	a.last_update AS "Son GÜncelleme Tarihi"
FROM actor AS a
WHERE UPPER(a.first_name) = 'PENELOPE';
-- Seq Scan on actor a  (cost=0.00..5.00 rows=1 width=25) ;   Filter: (upper(first_name) = 'PENELOPE'::text)

-- Transaction başlatalım
BEGIN;

-- INDEX oluşturalım
CREATE INDEX idx_actor_first_name
ON actor(UPPER(first_name));

-- Tablomuzu yeniden çekelim
EXPLAIN
SELECT
	a.actor_id AS "Aktör ID",
	a.first_name AS "Aktör Adı",
	a.last_name AS "Aktör Soyadı",
	a.last_update AS "Son GÜncelleme Tarihi"
FROM actor AS a
WHERE UPPER(a.first_name) = 'PENELOPE';

-- Kaydedelim
COMMIT;

-- 2.5. "pagila" veri tabanında bulunan "film" tablosunda süresi 170 dakikadan uzun olan filmler üzerinde sıkça analiz yapılmaktadır. Sadece bu uzun filmleri hedefleyen ve diskten tasarruf sağlayan bir Kısmi İndeks oluşturunuz.

-- Tablomuza bakalım
EXPLAIN
SELECT
	f.film_id AS "Film ID",
	f.title AS "Film Başlığı",
	f.description AS "Film Açıklaması",
	f.length AS "Film Uzunluğu",
	f.replacement_cost AS "Değiştirme Maliyeti"
FROM film AS f
WHERE f.length > 180;
/* 
Query Plan'ı inceleyeilm.
Seq Scan on film f  (cost=0.00..100.50 rows=123 width=122)
Filter: (length > 170) 170 ile denedim, alt sorguda da seq scan kullandı:)

*/
-- Transaction başlatalım

BEGIN;

-- Index oluşturalım
CREATE INDEX idx_film_length
ON film(length)
WHERE length > 180;

-- Filmi yeniden çekelim
EXPLAIN
SELECT
	f.film_id AS "Film ID",
	f.title AS "Film Başlığı",
	f.description AS "Film Açıklaması",
	f.length AS "Film Uzunluğu",
	f.replacement_cost AS "Değiştirme Maliyeti"
FROM film AS f
WHERE f.length > 180;

/*
QUERY PLAN:
Bitmap Heap Scan on film f  (cost=8.34..78.94 rows=39 width=122)
Recheck Cond: (length > 180)"
->  Bitmap Index Scan on idx_film_length  (cost=0.00..8.34 rows=39 width=0)"

*/
-- Kaydedelim 
COMMIT;

-- 2.6 "pagila" veri tabanında bulunan "address" tablosunda yer alan "district" sütununda sadece tam eşitlik (`=`) mantığıyla sorgulamalar yapılmaktadır. Bu senaryoya en uygun performanslı indeks çeşidini belirterek indeksi oluşturunuz.
-- Tabloyu çekelim
EXPLAIN
SELECT
	ad.address_id AS "Adres ID",
	ad.address AS "Adres 1",
	ad.address2 AS "Adres 2",
	ad.district AS "Bölge"
FROM address AS ad
WHERE ad.district = 'California';

-- Seq Scan on address ad  (cost=0.00..14.03 rows=603 width=34)
-- "Seq Scan on address ad  (cost=0.00..15.54 rows=9 width=34)" Filter: (district = 'California'::text)"

-- Transaction başlatalım
BEGIN TRANSACTION;

-- Index oluşturalım => HASH işe yarar
CREATE INDEX idx_address_district
ON address
USING HASH (district);


-- Tabloyu yeniden çekelim
EXPLAIN
SELECT
	ad.address_id AS "Adres ID",
	ad.address AS "Adres 1",
	ad.address2 AS "Adres 2",
	ad.district AS "Bölge"
FROM address AS ad
WHERE ad.district = 'California';

/*
Bitmap Heap Scan on address ad  (cost=4.07..12.59 rows=9 width=34)
Recheck Cond: (district = 'California'::text)"
->  Bitmap Index Scan on idx_address_district  (cost=0.00..4.07 rows=9 width=0)"
Index Cond: (district = 'California'::text)"

Aşağıdan yukarıya doğru süreç ilerlemektedir.
*/

-- Kaydedelim
COMMIT;



-- 2.7. "pagila" veri tabanında bulunan "payment" tablosunda hem belirli bir müşterinin (`customer_id`) hem de o müşterinin belirli bir tarihteki (`payment_date`) ödemelerini aynı anda filtreleyen sorgular için bir Bileşik İndeks (Composite Index) tasarlayınız.

-- Tabloyu çekelim
EXPLAIN
SELECT
	p.payment_id AS "Ödeme ID",
	p.customer_id AS "Müşteri ID",
	p.staff_id AS "Yetenek ID",
	p.rental_id AS "Kiralama ID",
	p.amount AS "Ödeme Tutarı",
	p.payment_date AS "Sipariş Tarihi"
FROM payment AS p
WHERE 
	p.customer_id = 280
	AND p.payment_date = '2022-02-06 03:01:36.023609+03';

/*
"Append  (cost=0.00..361.74 rows=16049 width=30)"
->  Seq Scan on payment_p2022_01 p_1  (cost=0.00..13.23 rows=723 width=30)"
->  Seq Scan on payment_p2022_02 p_2  (cost=0.00..42.01 rows=2401 width=30)"
->  Seq Scan on payment_p2022_03 p_3  (cost=0.00..47.13 rows=2713 width=30)"
->  Seq Scan on payment_p2022_04 p_4  (cost=0.00..44.47 rows=2547 width=30)"
->  Seq Scan on payment_p2022_05 p_5  (cost=0.00..46.77 rows=2677 width=30)"
->  Seq Scan on payment_p2022_06 p_6  (cost=0.00..46.54 rows=2654 width=30)"
->  Seq Scan on payment_p2022_07 p_7  (cost=0.00..41.34 rows=2334 width=30)"

Burada index kullanmadan gelen sonuç budur.
/*

Index Scan using payment_p2022_02_pkey on payment_p2022_02 p  (cost=0.28..8.30 rows=1 width=30)
Index Cond: (payment_date = '2022-02-06 03:01:36.023609+03'::timestamp with time zone)"
Filter: (customer_id = 280)"

*/
*/
-- Transaction başlatalım
BEGIN;

-- Index oluşturalım
CREATE INDEX idx_payment_customer_payment_date
ON payment(customer_id, payment_date);

-- Sorgu sonucumuzu çekelim
EXPLAIN
SELECT
	p.payment_id AS "Ödeme ID",
	p.customer_id AS "Müşteri ID",
	p.staff_id AS "Yetenek ID",
	p.rental_id AS "Kiralama ID",
	p.amount AS "Ödeme Tutarı",
	p.payment_date AS "Sipariş Tarihi"
FROM payment AS p
WHERE
	p.customer_id = 280
	AND p.payment_date = '2022-02-06 03:01:36.023609+03';

/*
Index Scan using payment_p2022_02_customer_id_payment_date_idx on payment_p2022_02 p  (cost=0.28..8.30 rows=1 width=30)"
Index Cond: ((customer_id = 280) AND (payment_date = '2022-02-06 03:01:36.023609+03'::timestamp with time zone))"

*/

-- Kaydedelim veya geriye alalım
COMMIT;

-- 2.8. "pagila" veri tabanında bulunan "rental" tablosunda henüz iade edilmemiş filmler kritik öneme sahiptir. Sistem performansını artırmak için sadece iade edilmemiş kiralamaları kapsayan bir Kısmi İndeks (Partial Index) yazınız.

EXPLAIN
SELECT
	r.rental_id AS "Kiralama ID",
	r.rental_date AS "Kiralama Tarihi",
	r.inventory_id AS "Envanter ID",
	r.customer_id AS "Müşteri ID",
	r.return_date AS "Geri Dönüş Tarihi",
	r.staff_id AS "Yetenek ID",
	r.last_update AS "Son Güncellenme"
FROM rental AS r
WHERE r.return_date IS NULL;

/*

Seq Scan on rental r  (cost=0.00..310.44 rows=183 width=40)
Filter: (return_date IS NULL)
*/

-- Transaction başlatalım
BEGIN;

-- Index oluşturalım
CREATE INDEX idx_rental_return_date
ON rental(return_date)
WHERE return_date IS NULL;

-- Yeniden sorgumuzu çekelim
EXPLAIN
SELECT
	r.rental_id AS "Kiralama ID",
	r.rental_date AS "Kiralama Tarihi",
	r.inventory_id AS "Envanter ID",	
	r.customer_id AS "Müşteri ID",
	r.return_date AS "Geri Dönüş Tarihi",
	r.staff_id AS "Yetenek ID",
	r.last_update AS "Son Güncellenme"
FROM rental AS r
WHERE r.return_date IS NULL;

-- Index Scan using idx_rental_return_date on rental r  (cost=0.14..37.45 rows=183 width=40)

-- Kaydedelim
COMMIT;

-- 2.9. "pagila" veri tabanında bulunan "payment" tablosunda ödeme tarihinin ("payment_date") sadece ay bilgisini (`EXTRACT` veya `TO_CHAR` kullanarak) analiz eden raporlar çekilmektedir. Bu ay bazlı raporları hızlandıracak bir Fonksiyon İndeksi (Function Index) oluşturunuz.

EXPLAIN
SELECT
	p.payment_id AS "Ödeme ID",
	p.customer_id AS "Müşteri ID",
	p.staff_id AS "Yetenek ID",
	p.rental_id AS "Kiralama ID",
	p.amount AS "Ödeme Tutarı",
	EXTRACT(MONTH FROM p.payment_date) AS "Ödeme Ayı"
FROM payment AS p;

-- Transaction başlatalım
BEGIN TRANSACTION;

-- Index oluşturalım
CREATE INDEX idx_payment_payment_date_month
ON payment ((EXTRACT(MONTH FROM (payment_date AT TIME ZONE 'UTC')))); -- zaman alanını sabit yapmalıyız

-- Yeniden çalıştıralım, WHERE şartı da ekleyebiliriz.
EXPLAIN
SELECT
	p.payment_id AS "Ödeme ID",
	p.customer_id AS "Müşteri ID",
	p.staff_id AS "Yetenek ID",
	p.rental_id AS "Kiralama ID",
	p.amount AS "Ödeme Tutarı",
	EXTRACT(MONTH FROM p.payment_date) AS "Ödeme Ayı"
FROM payment AS p
WHERE (EXTRACT(MONTH FROM (payment_date AT TIME ZONE 'UTC'))) = 4;

-- Kaydedelim
COMMIT;

-- 2.10. "pagila" veri tabanında bulunan "film" tablosunda filmlerin kiralama bedelleri ("rental_rate") azalan sırada, boş değerler ise en sonda olacak şekilde sıralanarak sıkça listelenmektedir. Bu sıralama kuralına özel bir B-Tree indeks atayınız.

EXPLAIN
SELECT
	f.film_id AS "Film ID",
	f.title AS "Film Başlığı",
	f.description AS "Film Açıklaması",
	f.rental_rate AS "Kiralama Bedeli"
FROM film AS f;

-- Transaction başlatalım
BEGIN;

-- Index oluşturalım
CREATE INDEX idx_film_rental_rate
ON film(rental_rate DESC NULLS LAST);

-- Sorguyu yeniden çekelim
EXPLAIN
SELECT
	f.film_id AS "Film ID",
	f.title AS "Film Başlığı",
	f.description AS "Film Açıklaması",
	f.rental_rate AS "Kiralama Bedeli"
FROM film AS f
ORDER BY rental_rate DESC 
NULLS LAST;

-- Kaydedelim
COMMIT;