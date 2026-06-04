-- 1. JOIN İşlemleri:
/*
JOIN, farklı tabloları birleştirmek ve ilgili sorguları gerçekleştirmek amacıyla
tercih edilen SQL ifadesidir.

1.1. JOIN Türleri (JOIN Types)
Kendi içerisinde de farklı türlere sahiptir.
	- INNER JOIN: Her iki tablodaki kesişimi veren join türüdür.
	- LEFT JOIN: Soldaki tablonun tümünü, sağdaki tablonun ise kesişen kısmını veren join türüdür.
	- RIGHT JOIN: LEFT JOIN'in tersidir. Sağdaki tablonun tamamını ve soldaki tablodaki kesişen verileri getiren join türüdür.
	- FULL (OUTER) JOIN: LEFT JOIN ve RIGTH JOIN'in birleşimi gibidir. Kümelerdeki birleşim akla getirilebilir.
	- CROSS JOIN: İki tablo arasındaki oluşabilecek kombinasyonların hepsini deneyip getiren join türüdür. ((Kartezyen Çarpım - Cartesian Product))
	- SELF JOIN: Bir tablonun kendisini sorguda kullanmamız gerekebilir. Bu nedenle kullanılan join türüdür.
	- NATIVE JOIN: tablolar arasındaki aynı isimli tüm sütunları otomatik bulup birleştiren join türüdür.
	
1.2. JOIN Yazılış Biçimleri ve Klasik Yöntem:

	```sql
-- 1.INNER JOIN Yöntemi : Foreign key üzerinden bağlantı kurulur. İlgili tabloların kesişimleri getirilir. Alias kullanmak gereklidir.
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    p.amount,
    p.payment_date
FROM customer c
INNER JOIN payment p
    ON p.customer_id = c.customer_id;

-- 2.USING kullanımı: Aynı isme sahip, foreign key üzerinden bağlantı kurulur. Burada alias kullanılmasa da olur. 

SELECT 
    customer_id, -- customer_id
    c.first_name, -- first_name
    c.last_name, -- last_name
    p.amount, -- amount
    p.payment_date -- payment_date
FROM customer AS c
INNER JOIN payment
    USING(customer_id);


--3. Klasik Yöntem: INNER JOIN veya sadece JOIN yazılmaz. FROM’dan sonra ilgili tablolar virgülle ayrılacak şekilde yazılır (Büyük olan tablonun en başa yazılması tavsiye edilir). ON kısmında tablolar arasındaki FOREIGN KEY üzerinden kurulan ilişki  ise WHERE ifadesinden sonra yazılır. 
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    p.amount,
    p.payment_date
FROM customer c, payment p
WHERE p.customer_id = c.customer_id;

Önemli Hatırlatmalar:
	-- JOIN işlemlerinde tablolarımıza alias vermemiz iyi olacaktır. Hem sorgumuzu okunabilir kılacak hem de sütunların nereden geldiğinin karışmasını engelleyecektir.
	-- Aynı işlemleri gerçekleştirirken eğer ki birleştirilecek foreign key adları aynıysa, daha kısa kod yazılması bakımından USING kullanımı tavsiye edilir.
	-- Klasik yöntem daha çok ORACLE'da tercih edilen bir yöntemdir. Güncel olarak çok tavsiye edilmemektedir.
	-- SELF JOIN'i örnekle açıklamak daha iyi olacaktır. Biraz soyut kalabilir, bu da normal bir durum.
		Bir 'Personel' tablosunda, personelin yöneticisinin ID'si de aynı tabloda tutuluyorsa, personeller ile yöneticileri eşleştirmek için 
		tablonun kendisiyle joinlenmesidir.

*/

---------------------------------------------------------------------------------------------------------------------------------------------
-- 2. JOIN Örnekleri

-- 2.1. "dvdrental" veri tabanında bulunan 3 numaralı id'ye sahip filmin, id numarasını, oyuncuların adını, soyadını ve son güncelleme tarihini getiren sorguyu yazınız.
SELECT
	f.film_id AS "Film ID",
	f.title AS "Film Başlığı",
	fa.actor_id AS "Aktör ID",
	ac.first_name || ' ' || ac.last_name AS "Aktör Adı Soyadı"
FROM film f
INNER JOIN film_actor fa
	ON f.film_id = fa.film_id
INNER JOIN actor AS ac
	ON fa.actor_id = ac.actor_id
WHERE f.film_id = 3
ORDER BY f.film_id;
	
-- 2.2. "dvdrental" veri tabanındaki tüm şehirlerin adını ve bu şehirlerin bağlı olduğu ülkelerin adını listeleyen sorguyu yazınız.
SELECT
	co.country_id AS "Ülke ID",
	co.country AS "Ülke Adı",
	c.city AS "Şehir Adı"
FROM city AS c
INNER JOIN country AS co
	ON c.country_id = co.country_id
ORDER BY c.country_id
LIMIT 10;

-- 2.3. "dvdrental" veri tabanındaki tüm filmlerin isimlerini ve filmlerin çekildiği dillerin isimlerini yan yana listeleyen sorguyu yazınız.
SELECT
	f.film_id AS "Film ID",
	f.title AS "Film Başlığı",
	f.release_year AS "Filmin Yayın Tarihi",
	l.language_id AS "Kullanılan Dil ID",
	l.name AS "Kullanılan Dil"
FROM film AS f
LEFT JOIN language AS l
	ON f.language_id = l.language_id
ORDER BY film_id
LIMIT 20;

-- 2.4. "dvdrental" veri tabanında yer alan tüm envanterlerin benzersiz numaralarını ve bu envanterlere ait filmlerin isimlerini listeleyen sorguyu yazınız.
SELECT
	i.inventory_id AS "Envanter ID",
	f.film_id AS "Film ID",
	f.title AS "Film Adı"
FROM inventory AS i
LEFT JOIN film AS f
	ON i.film_id = f.film_id
ORDER BY i.inventory_id
LIMIT 20;
-- 2.5. "dvdrental" veri tabanındaki müşterilerin id'lerini, adlarını, soyadlarını ve sistemde kayıtlı olan açık adres metinlerini listeleyen sorguyu yazınız.
SELECT
	address_id AS "Adres ID",
	c.customer_id AS "Müşteri ID",
	c.first_name || ' ' || c.last_name AS "Müşteri Adı Soyadı",
	a.address AS "Adres Bilgisi"
FROM customer AS c
INNER JOIN address AS a
	USING(address_id)
ORDER BY c.customer_id
LIMIT 20;


-- 2.6. "dvdrental" veri tabanındaki tüm adresleri ve eğer adrese tanımlı bir şehir varsa o şehrin adını listeleyen sorguyu yazınız.
SELECT
	c.city_id  AS "Şehir ID",
	a.address AS "Adres Bilgisi",
	c.city AS "Şehir"
FROM address AS a
LEFT JOIN city AS c
	ON c.city_id = a.city_id
ORDER BY c.city_id
LIMIT 20;

-- RIGTH JOIN ile 
SELECT
	c.city_id  AS "Şehir ID",
	a.address AS "Adres Bilgisi",
	c.city AS "Şehir"
FROM city AS c
RIGHT JOIN address AS a
	ON c.city_id = a.city_id
ORDER BY c.city_id
LIMIT 20;

-- NATURAL JOIN : Burada ortak kolonlardan ilerler.
-- Ortak olarak last_update'de olduğundan kaynaklı sorgumuz boş gelir.
SELECT 
	c.city_id  AS "Şehir ID",
	a.address AS "Adres Bilgisi",
	c.city AS "Şehir"
FROM address AS a
NATURAL JOIN city AS c
LIMIT 20;

-- USING ile
SELECT
	c.city_id  AS "Şehir ID",
	a.address AS "Adres Bilgisi",
	c.city AS "Şehir"
FROM address AS a
INNER JOIN city AS c
	USING(city_id)
ORDER BY city_id
LIMIT 20;

-- 2.7. "dvdrental" veri tabanında görev yapan personellerin adını, soyadını ve personellerin çalıştığı mağazaların id numaralarını listeleyen sorguyu yazınız.
SELECT
	s.staff_id AS "Yetenek ID",
	s.first_name || ' ' || s.last_name AS "Yetenek Adı Soyadı",
	st.store_id AS "Mağaza ID"
FROM staff AS s
LEFT JOIN store AS st
	ON s.store_id = st.store_id
ORDER BY s.staff_id NULLS FIRST
LIMIT 20;

-- 2.8. "dvdrental" veri tabanında yapılan kiralama işlemlerinin numaralarını ve bu işlemleri gerçekleştiren müşterilerin ad ve soyadlarını listeleyen sorguyu yazınız.
SELECT
	r.rental_id AS "Kiralama ID",
	c.customer_id AS "Müşteri ID",
	c.first_name || ' ' || c.last_name AS "Müşteri Adı Soyadı"
FROM rental AS r
LEFT JOIN customer AS c
	ON r.customer_id = c.customer_id
ORDER BY c.customer_id
LIMIT 20;

-- 2.9. "dvdrental" veri tabanında yapılan ödemelerin miktarını, ödeme tarihini ve ilgili ödemeyi tahsil eden personelin adını listeleyen sorguyu yazınız.
SELECT
	p.amount AS "Ödeme Miktarı",
	p.payment_date AS "Ödeme Tarihi",
	s.first_name || ' ' || s.last_name AS "Ödemeyi Gerçekleştiren Yetenek"
FROM payment AS p
INNER JOIN staff AS s
	USING(staff_id)
ORDER BY p.amount DESC
LIMIT 20; -- Sorgu veri tabanını çok yormasın.

-- 2.10. "dvdrental" veri tabanındaki tüm filmlerin isimlerini ve ait oldukları kategorilerin isimlerini listeleyen sorguyu yazınız.
SELECT
	f.film_id AS "Film ID",
	f.title AS "Film Başlığı",
	c.name AS "Kategori Adı"
FROM film AS f
LEFT JOIN film_category AS fc
	ON f.film_id = fc.film_id
INNER JOIN category AS c
	ON c.category_id = fc.category_id
ORDER BY f.film_id
LIMIT 20;

-- 2.11. "dvdrental" veri tabanında kayıtlı olan tüm dilleri ve o dillerde çekilmiş filmlerin isimlerini, henüz filmi olmayan diller de tabloda yer alacak şekilde listeleyen sorguyu yazınız.
SELECT
	language_id AS "Dil ID",
	f.film_id AS "Film ID",
	f.title AS "Film Başlığı"
FROM language AS l
LEFT JOIN film AS f
	USING(language_id)
ORDER BY language_id
LIMIT 25;


-- 2.12. "dvdrental" veri tabanındaki mağazaların id numaralarını ve bu mağazaların yöneticiliğini yapan personellerin adını ve soyadını listeleyen sorguyu yazınız.
SELECT
	store_id AS "Mağaza ID",
	sta.first_name || ' ' || sta.last_name AS "Yetenek Adı Soyadı"
FROM store AS sto
INNER JOIN staff AS sta
	USING(store_id)
WHERE sta.staff_id = sto.manager_staff_id
ORDER BY store_id
LIMIT 15;

-- 2.13. "dvdrental" veri tabanında bulunan her bir kiralama kaydı için, kiralanan envanterin numarasını ve o envantere ait filmin adını listeleyen sorguyu yazınız.
SELECT
	i.inventory_id AS "Envanter ID",
	r.rental_id AS "Kiralama ID",
	f.title AS "Film Başlığı"
FROM rental AS r
LEFT JOIN inventory AS i
	ON r.inventory_id = i.inventory_id --USING(inventory_id)
LEFT JOIN film AS f
	ON i.film_id = f.film_id -- USING(film_id)
ORDER BY i.inventory_id
LIMIT 10;

-- 2.14. "dvdrental" veri tabanında bulunan müşterilerin adını, soyadını ve yaptıkları ödeme tutarlarını, henüz sistemde hiç ödeme kaydı bulunmayan müşteriler de dahil olacak şekilde listeleyen sorguyu yazınız.
SELECT
	customer_id AS "Müşteri ID",
	p.payment_id AS "Ödeme ID",
	c.first_name || ' ' || c.last_name AS "Müşteri Adı Soyadı",
	p.amount AS "Ödeme Tutarı"
FROM payment AS p
RIGHT JOIN customer AS c
	USING(customer_id)
ORDER BY customer_id
LIMIT 10;

-- 2.15. "dvdrental" veri tabanında henüz hiçbir filmde rol almamış olan aktörler varsa, bu aktörlerin adını ve soyadını listeleyen sorguyu yazınız.
SELECT 
	a.actor_id AS "Aktör ID",
	a.first_name || ' ' || a.last_name AS "Aktör Adı Soyadı"
FROM actor AS a
-- FULL OUTER JOIN film_actor AS fa
LEFT JOIN film_actor AS fa
	ON a.actor_id = fa.actor_id
WHERE fa.film_id IS NULL
ORDER BY a.actor_id;

-- 2.16. "dvdrental" veri tabanındaki tüm filmlerin isimlerini, bu filmlerde oynayan aktörlerin adlarını, soyadlarını ve filmlerin kategori isimlerini tek bir tabloda listeleyen sorguyu yazınız.
SELECT
	film_id AS "Film ID",
	f.title AS "Film Başlığı",
	a.first_name || ' ' || a.last_name AS "Aktör Adı Soyadı",
	c.name AS "Kategori"
FROM film AS f
LEFT JOIN film_actor AS fa
	USING(film_id)
LEFT JOIN actor AS a
	USING(actor_id)
LEFT JOIN film_category AS fc
	USING(film_id)
LEFT JOIN category AS c
	USING(category_id)
ORDER BY film_id
LIMIT 20;

-- 2.17. "dvdrental" veri tabanındaki müşterilerin adını, soyadını, yaşadıkları şehrin adını ve bağlı oldukları ülkenin adını tek bir sorguyla listeleyen sorguyu yazınız. İlk 50 kayıt gelsin.
SELECT
	c.first_name || ' ' || c.last_name AS "Müşteri Adı Soyadı",
	ci.city AS "Şehir",
	co.country AS "Ülke"
FROM customer AS c
JOIN address AS a -- JOIN ile INNER JOIN aynıdır.
	USING(address_id)
JOIN city AS ci
	USING(city_id)
JOIN country AS co
	USING(country_id)
ORDER BY customer_id
LIMIT 50;

-- 2.18. "dvdrental" veri tabanında gerçekleştirilen kiralama işlemlerinin id'sini, işlemi yapan müşterinin adını, işlemi yürüten personelin adını ve kiralanan filmin adını birlikte listeleyen sorguyu yazınız.
SELECT
	r.rental_id AS "Kiralama ID",
	c.first_name || ' ' || c.last_name AS "Müşteri Adı Soyadı",
	s.first_name || ' ' || s.last_name AS "İşlemi Gerçekleştiren Yetenek",
	f.title AS "Kiralanan Film"
FROM rental AS r
INNER JOIN customer AS c
	ON r.customer_id = c.customer_id --USING(customer_id)
INNER JOIN staff AS s
	ON r.staff_id = s.staff_id -- USING(staff_id)
INNER JOIN inventory AS i
	ON r.inventory_id = i.inventory_id -- USING(inventory_id)
INNER JOIN film AS f
	ON i.film_id = f.film_id -- USING(film_id)
ORDER BY r.rental_id
LIMIT 20;

-- Daha kısa yazalım.
SELECT
	rental_id,
	c.first_name || ' ' || c.last_name AS "Müşteri Adı Soyadı",
	s.first_name || ' ' || s.last_name AS "İşlemi Gerçekleştiren Yetenek",
	f.title AS "Kiralanan Film"
FROM rental AS r
JOIN customer AS c
	USING(customer_id)
JOIN staff AS s
	USING(staff_id)
JOIN inventory AS i
	USING(inventory_id)
JOIN film AS f
	USING(film_id)
ORDER BY rental_id
LIMIT 20;

-- 2.19. "dvdrental" veri tabanında yapılan ödemelerin id'lerini, ödemeyi yapan müşterinin ad ve soyadını, müşterinin kayıtlı olduğu mağazanın id'sini ve o mağazanın bulunduğu adresin tam metnini listeleyen sorguyu yazınız.
SELECT
	p.payment_id AS "Ödeme ID",
	c.first_name || ' ' || c.last_name AS "Müşteri Adı Soyadı",
	s.store_id AS "Mağaza ID",
	a.address AS "Müşterinin Tam Adresi"
FROM payment AS p
INNER JOIN customer AS c
	ON p.customer_id = c.customer_id
INNER JOIN store AS s
	ON c.store_id = s.store_id
INNER JOIN address AS a
	ON s.address_id = a.address_id
ORDER BY p.payment_id
LIMIT 20;

-- 2.20. "dvdrental" veri tabanındaki aktörlerin adını, soyadını, rol aldıkları filmlerin isimlerini ve bu filmlerin dillerinin isimlerini listeleyen sorguyu yazınız.
SELECT
	a.first_name || ' ' || a.last_name AS "Aktör Adı Soyadı",
	f.title AS "Film Başlığı",
	l.name AS "Filmin Dili"
FROM actor AS a
INNER JOIN film_actor AS fa
	USING(actor_id)
INNER JOIN film AS f
	USING(film_id)
INNER JOIN language AS l
	USING(language_id)
ORDER BY 1
LIMIT 25; -- a.first_name || ' ' || a.last_name yazılabilir. Sütunların yeri değişirse sorun çıkartabilir:)

---------------------------------------------------------------------------------------------------------------------------------------------
-- INTERSECT, LIKE, GROUP BY ve HAVING ile İç İçe JOIN Örnekleri

-- 2.21. "dvdrental" veri tabanında ismi 'A' veya 'M' harfi ile başlayan filmlerin isimlerini, ait oldukları kategorileri ve film sürelerini listeleyen sorguyu yazınız.
SELECT
	f.title AS "Film Başlığı",
	f.length AS "Film Süresi",
	c.name AS "Kategori"
FROM film AS f
JOIN film_category AS fc
	USING(film_id)
JOIN category AS c
	USING(category_id)
WHERE 
	f.title ILIKE 'A%'
	OR f.title ILIKE 'M%'
ORDER BY f.title
LIMIT 20;

-- 2.22. "dvdrental" veri tabanında yer alan her bir film kategorisindeki toplam film sayısını, kategori adına göre gruplayarak listeleyen sorguyu yazınız.
SELECT
	COUNT(film_id) AS "Film Sayısı",
	c.name AS "Kategori Adı"
FROM film_category AS fc
INNER JOIN category AS c
	USING(category_id)
GROUP BY c.name
ORDER BY c.name;

-- 2.23. "dvdrental" veri tabanında ülkelere göre kayıtlı şehir sayılarını hesaplayarak, bünyesinde 10'dan fazla şehir barındıran ülkelerin adını ve şehir sayılarını listeleyen sorguyu yazınız.
SELECT
	co.country AS "Ülke Adı",
	COUNT(*) AS "Şehir Sayısı"
FROM country AS co
INNER JOIN city AS ci
	ON co.country_id = ci.country_id
GROUP BY co.country
HAVING COUNT(*) > 10
ORDER BY COUNT(*) DESC;

-- 2.24. "dvdrental" veri tabanında müşterilerin adını, soyadını ve sisteme kazandırdıkları toplam ödeme miktarını hesaplayarak, toplam ödemesi en yüksek olandan en düşük olana doğru sıralı listeleyen sorguyu yazınız.
SELECT
	c.first_name || ' ' || c.last_name AS "Müşteri Adı Soyadı",
	SUM(p.amount) AS "Toplam Harcama Tutarı"
FROM customer AS c
INNER JOIN payment AS p
	USING(customer_id)
-- GROUP BY c.first_name || ' ' || c.last_name kullanabilirsiniz. Ancak:
GROUP BY c.customer_id -- yapmamız daha iyi olacaktır. Benzersiz gruplama yapar.
ORDER BY SUM(p.amount) DESC;

-- 2.25. "dvdrental" veri tabanında henüz iade edilmemiş kiralama işlemlerini gerçekleştiren müşterilerin adını, soyadını ve kiralanan filmin adını, iade tarihi girilmemiş olanlar en üstte görünecek şekilde listeleyen sorguyu yazınız.
SELECT
	c.first_name || ' ' || c.last_name AS "Müşteri Adı Soyadı",
	f.title AS "Film Başlığı",
	r.rental_date AS "Kiralama Tarihi"
FROM rental AS r
JOIN customer AS c
	USING(customer_id)
JOIN inventory AS i
	USING(inventory_id)
JOIN film AS f
	USING(film_id)
WHERE return_date IS NULL
ORDER BY return_date NULLS FIRST; 

-- 2.26. "dvdrental" veri tabanında 'Action', 'Comedy' veya 'Drama' kategorilerinde yer alan ve yapılan ödeme tutarı 4.00'ten büyük olan işlemler için filmlerin isimlerini, kategori adlarını ve kiralama (ödeme) ücretlerini, tutara göre en yüksekten en düşüğe doğru sıralı listeleyen sorguyu yazınız.
SELECT
	f.title AS "Film Başlığı",
	c.name AS "Film Kategorisi",
	p.amount AS "Kiralama Ücreti"
FROM category AS c
JOIN film_category AS fc
	ON c.category_id = fc.category_id
JOIN film AS f
	ON fc.film_id = f.film_id
JOIN inventory AS i
	ON f.film_id = i.film_id
JOIN rental AS r
	ON i.inventory_id = r.inventory_id
JOIN payment AS p
	ON r.rental_id = p.rental_id
WHERE 
	c.name IN ('Action', 'Comedy', 'Drama')
	AND p.amount > 4.00
ORDER BY p.amount DESC;
	
/*
Burada tablolar arasında nasıl geçiş yaptığınızı denemeniz iyi olacaktır.
Primary Key - Foreign key geçişlerinin nasıl olabileceğini karaladığınız bir sayfanız olsun. 
O size yol gösterecektir. Örnek olarak 

İstenenler
Film ismi => Film tablosu	f.title
Kategori ismi => Kategori Tablosu c.name
Kiralama Ücreti => Payment tablosu p.amount

Tablo geçişleri:
film tablosundan => film_category => category
	       film_id	    category_id üzerinden

Kiralama ve ödeme için
inventory => rental 	=> payment => 
             inventory_id	     rental_id üzerinden

*/

-- 2.27. "dvdrental" veri tabanında çalışan personellerin adını, soyadını ve her bir personelin bugüne kadar yürüttüğü kiralama işlemlerinin toplam sayısını, sadece toplam işlem sayısı 8000'den fazla olan personeller için listeleyen sorguyu yazınız.
SELECT
	s.first_name || ' ' || s.last_name AS "Yetenek Adı Soyadı",
	COUNT(*) AS "İşlem Sayısı"
FROM staff AS s
JOIN rental AS r
	USING(staff_id)
-- GROUP BY s.first_name || ' ' || s.last_name --Not : Aynı isim soyisimli de olabilir.
GROUP BY s.staff_id
HAVING COUNT(*) > 8000; 



