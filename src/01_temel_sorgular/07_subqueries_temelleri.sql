--1. SUBQUERIES Basics (Alt Sorgu Temelleri)
/*
Alt sorgular (subqueries), bir sorgunun sonucunu başka bir sorguda kullanmamıza olanak tanır. 
Alt sorgumuz, ana sorgudan önce çalışır.

-- 1.1. Alt Sorgu Kullanım Alanları:
    - Alt sorguları,SELECT, INSERT, UPDATE ve DELETE gibi DML (Data Manipulation Language) komutlarıyla kullanabiliriz.
    - Alt sorguları SELECT, WHERE, FROM ve HAVING gibi SQL cümlelerinde de (DQL - Data Query Language) kullanabiliriz.


-- 1.2. Alt Sorgu Türleri:
Alt sorgu türleri, döndürdüğü satır sayısına göre sınıflandırılmaktadır.

- Tek Satır Alt Sorgu (Scalar Subquery): Alt sorgu sonucunda, tek bir satır ve sütun döndüren alt sorgu türüdür.
* Kullanılan Operatörler:
    Eşittir (=)
    Büyüktür (>),
    Küçüktür (<) ,
    Büyük Eşit (>=),
    Küçük Eşit (<=),
    Eşit Olmayan (<> / !=) 
    vb. karşılaştırma operatörleridir. 


- Çok Satır Alt Sorgu (Multi-Row Subquery): Alt sorgu sonucunda, birden fazla satır ve tek bir sütun döndüren alt sorgu türüdür.
 * Kullanılan Operatörler:
    IN,
    NOT IN,
    ANY,
    ALL
    vb. karşılaştırma operatörleridir.

Önemli Notlar:
1) Alt sorgu kullanılırken, hangi alt sorgu türüne sahip olduğunu bilmemiz oldukça önemlidir.
   Bunun nedeni de kullanılacak olan operatörler ve yazım şekli birbirlerinden farklıdır. Çalışma zamanı hatasına yol açabilir:)

2) SUBQUERY'nin kullanıldığı cümle çok önemlidir.
	WHERE'den sonra kullanımda => Satır
	SELECT'ten sonra kullanımda => Sütun
	FROM'dan sonra kullanımda ise => Tablo 
olarak algılanmaktadır. Bunun için ALIAS vermek önemlidir.
 
Dikkat Edilmesi Gerekenler:
Öncelikle alt sorguların çalışıp çalışmadığının kontrol edilmesi bizler açısından iyi olacaktır.
Sorgu sonucunun doğru geldiğinden emin olduktan sonra kalan işlemleri gerçekleştirmek oldukça kolay olacaktır.
*/

-- 2.1. Filmler tablosundaki tüm filmlerin ortalama süresinden DAHA UZUN olan filmlerin isimlerin ve sürelerini listeleyen sorguyu yazınız. 
SELECT
	f.film_id AS "Film ID",
	f.title AS "Film Adı",
	f.length AS "Film Uzunluğu"
FROM film AS f
WHERE f.length > (
    SELECT
		CEIL(AVG(fi.length))
	FROM film AS fi
)
ORDER BY f.length DESC;


-- 2.2.En yüksek replacement_cost'a (Yenileme Maliyeti) sahip olan filmlerin id, isim ve replacement_cost değerlerini getiren sorguyu yazınız. (Maksimum değeri alt sorguyla bulunuz)
SELECT
	f.film_id AS "Film ID",
	f.title AS "Film Başlığı",
	f.replacement_cost AS "Yenileme Ücreti"
FROM film AS f
WHERE f.replacement_cost = (
	SELECT
		MAX(fi.replacement_cost)
	FROM film AS fi
)
ORDER BY f.film_id;


-- 2.3. Her bir filmin adını, süresini ve yanına o filmin süresinin veri tabanındaki EN UZUN film süresinden ne kadar kısa olduğunu (Fark) gösteren sorguyu yazınız.

--En uzun film için alt sorgumuzu yazalım.
SELECT
	MAX(f.length) AS "En Uzun Filmin Süresi"
FROM film AS f
ORDER BY 1 DESC; -- 185

SELECT
	f.title AS "Film Başlığı",
	f.length AS "Film Uzunluğu",
	(
		SELECT
		    MAX(fi.length) AS "En Uzun Film Süresi"
		FROM film AS fi
	) - f.length AS "En Uzun Film İle Süre Farkı"
FROM film AS f
ORDER BY f.length DESC;



-- 2.4.'Action' veya 'Comedy' kategorilerine ait filmlerin id numaralarını ve isimlerini getiren sorguyu JOIN KULLANMADAN, iç içe IN operatörlü alt sorgularla yazınız.

-- Adım adım gidelim. İlk aşama kategorilerden kategorilerin id değerlerini bulmak
SELECT
	fc.category_id AS "Kategori ID"
FROM film_category AS fc
WHERE fc.category_id IN (
	SELECT
		c.category_id
	FROM category AS c
	WHERE c.name IN ('Action', 'Comedy')
)
-- İkinci aşamada da bu alt sorgularımızı, ana sorgumuz olan film id ve başlığına göre alt sorgu olarak eklemek.

SELECT
	f.film_id AS "Film ID",
	f.title AS "Film Başlığı"
FROM film AS f
WHERE film_id IN (
	SELECT
	fc.film_id AS "Film ID"
	FROM film_category AS fc
	WHERE fc.category_id IN (
		SELECT
			c.category_id AS "Kategori ID"
		FROM category AS c
		WHERE c.name IN ('Action', 'Comedy')
	)
)
ORDER BY f.film_id;


-- 2.5. Aktif olan (active = 1) ama bugüne kadar 2 id numaralı personelden (staff_id = 2) hiç kiralama yapmamış olan müşterilerin id, ad ve soyadlarını listeleyen sorguyu yazınız.
SELECT
	c.customer_id AS "Müşteri ID",
	c.first_name || ' ' || c.last_name AS "Müşteri Adı Soyadı"
FROM customer AS c
WHERE 
	c.active = 1
	AND c.customer_id NOT IN(
		SELECT
			r.customer_id
		FROM rental AS r
		WHERE r.staff_id = 2
	)
ORDER BY c.customer_id;

-- 2.6. 'NC-17' reytingine sahip filmlerin HERHANGİ BİRİNİN süresinden daha uzun olan 'PG' reytingli filmleri listeleyen sorguyu yazınız.
SELECT
	f.title,
	f.rating,
	f.length
FROM film AS f
WHERE 
	f.rating = 'PG' 
	AND f.length > ANY(
	-- Burada karşılaştırmak amacıyla en büyük değeri alacak, en büyük değerden büyük olanları getirecek
	-- 184 DK'dan daha uzun 'PG' ratingine sahip filmleri getirecek sorgu
	SELECT
		fi.length
		-- MAX(fi.length) => 184
	FROM film AS fi
	WHERE fi.rating = 'NC-17'
	)
ORDER BY f.length DESC;

-- İkinci yöntem MAX kullanarak
SELECT
	f.title,
	f.rating,
	f.length
FROM film AS f
WHERE 
	f.rating = 'PG' 
	AND f.length > (
	SELECT
	    MAX(fi.length) -- 184
	FROM film AS fi
	WHERE fi.rating = 'NC-17'
	)
ORDER BY f.length;

-- 2.7. Yenileme maliyeti 15.00'dan küçük olan TÜM filmlerin kiralama ücretinden daha büyük veya eşit kiralama ücretine sahip filmleri listeleyen sorguyu yazınız. 
-- Birinci Yöntem olarak ALL operatörü kullanımı
SELECT
	f.title AS "Film Başlığı",
	f.replacement_cost AS "Yenileme Maliyeti",
	f.rental_rate AS "Kiralama Ücreti"
FROM film AS f
WHERE 
	f.replacement_cost < 15.00
	AND f.rental_rate >= ALL(
		SELECT
			fi.rental_rate
		FROM film AS fi
	)

-- İkinci yöntem >= ALL Kullanmadan >= Operatörü ve MAX ile
SELECT
	MAX(f.rental_rate) AS "Maksimum Kiralama Bedeli"
FROM film AS f;
--WHERE f.replacement_cost < 15.00;

SELECT
	f.title AS "Film Başlığı",
	f.rental_rate AS "Kiralama Ücreti",
	f.replacement_cost AS "Yenileme Ücreti"
FROM film AS f
WHERE
	f.replacement_cost < 15.00
	AND f.rental_rate >= (
		SELECT
			MAX(fi.rental_rate) AS "Maksimum Kiralama Ücreti"
		FROM film AS fi
		WHERE fi.replacement_cost < 15.00 -- kriteri buraya da ekleyelim.
	)
ORDER BY f.replacement_cost DESC;

-- 2.8. 'R' reytingli filmlerin sahip olduğu kiralama sürelerinin HEPSİNDEN daha küçük veya eşit kiralama süresine sahip benzersiz filmleri listeleyen sorguyu yazınız.
SELECT
	DISTINCT(f.film_id),
	f.title AS "Film Başlığı",
	f.rating AS "Film Ratingi",
	f.rental_duration AS "Kiralama Süresi"
FROM film AS f
WHERE 
	f.rating = 'R'
	AND f.rental_duration <= ALL(
		SELECT
			fi.rental_duration
		FROM film AS fi
		WHERE fi.rating = 'R'
	)
--ORDER BY 1;
ORDER BY f.film_id;


-- İkinci Yöntem ise MIN fonksiyonu ile
SELECT
	DISTINCT(f.film_id),
	f.title AS "Film Başlığı",
	f.rating AS "Film Ratingi",
	f.rental_duration AS "Kiralama Süresi"
FROM film AS f
WHERE 
	f.rating = 'R'
	AND f.rental_duration <= (
		SELECT
			MIN(fi.rental_duration) AS "Minimum Kiralama Süresi"
		FROM film AS fi
	)
ORDER BY f.film_id;

-- 2.9. En az bir adet 'Action' kategorisinde filmi olan aktörlerin id, ad ve soyadlarını EXISTS operatörü kullanarak listeleyen sorguyu yazınız. (Dış sorgu ile iç sorgu ilişkilendirilmeli)

-- İlk yöntem JOIN Kullanmadan: 
SELECT
	a.actor_id AS "Aktör ID",
	a.first_name || ' ' || a.last_name AS "Aktör Adı Soyadı"
FROM actor AS a 
WHERE EXISTS(
	SELECT
		1
	FROM film_actor AS fa
	WHERE a.actor_id = fa.actor_id
		AND fa.film_id IN (
		SELECT
			fc.film_id
		FROM film_category AS fc
		WHERE fc.category_id IN (
			SELECT
				c.category_id
			FROM category AS c
			WHERE c.name = 'Action'
		)
	)
)

-- 2.Yöntem:
SELECT
	a.actor_id AS "Aktör ID",
	a.first_name || ' ' || a.last_name AS "Aktör Adı Soyadı"
FROM actor AS a 
WHERE EXISTS(
	SELECT
		1
	FROM film_actor AS fa
	JOIN film_category AS fc
		ON fa.film_id = fc.film_id
	JOIN category AS c
		USING(category_id)
	WHERE a.actor_id = fa.actor_id
	)
ORDER BY a.actor_id;

-- 2.10. Sistemde kayıtlı olan ancak 25 Mayıs 2022 Saat 13.00'den  sonra (>= '2022-05-25 13:00:07') hiçbir kiralama işlemi yapmamış olan müşterilerin id, ad ve soyadlarını NOT EXISTS kullanarak listeleyen sorguyu yazınız.
SELECT
	c.customer_id AS "Müşteri ID",
	c.first_name || ' ' || c.last_name AS "Müşteri Adı Soyadı"
FROM customer AS c
WHERE NOT EXISTS(
	SELECT
		1
	FROM rental AS r
	WHERE 
		c.customer_id = r.customer_id
		AND r.rental_date >= '2022-05-25 13:00:00'
)
ORDER BY c.customer_id;


-- 2.11. Her bir müşterinin ödediği toplam miktarları (SUM) bulduktan sonra, bu toplam miktarların veri tabanındaki GENEL ORTALAMASINI (tüm müşterilerin harcamalarının ortalamasını) veren sorguyu FROM içinde alt sorgu kullanarak yazınız.

-- Parçalara bölüp ilerleyelim.
-- İlk adım: Toplam ödeme tutarını bulalım
SELECT
	CEIL(SUM(p.amount)) AS "Toplam Ödeme Tutarı"
FROM payment AS p;

-- Ortalama ödeme tutarını bulalım
SELECT
	CEIL(AVG(p.amount)) AS "Ortalama Ödeme Tutarı"
FROM payment AS p;

-- Müşteri bazında harcamalar
SELECT
	c.customer_id,
	SUM(p.amount)
FROM customer AS c
JOIN payment AS p
	ON p.customer_id = c.customer_id
GROUP BY c.customer_id
ORDER BY c.customer_id;

-- Birleştirelim:
SELECT
	ROUND(AVG(customer_payment.total_amount),2) AS "Ortalama Harcama"
FROM (
	SELECT
		p.customer_id,
		SUM(p.amount) AS total_amount 
	FROM payment AS p
	GROUP BY p.customer_id
) AS customer_payment
ORDER BY "Ortalama Harcama";



-- 2.12. [İleri Düzey - HAVING Subquery] Kategori bazlı filmlerin ortalama süreleri hesaplandığında, kendi kategori ortalaması, veri tabanındaki TÜM filmlerin genel ortalama süresinden büyük olan kategorilerin isimlerini ve ortalama sürelerini listeleyen sorguyu yazınız.

-- Tüm filmlerin ortalaması:
SELECT
	ROUND(AVG(f.length)) AS "Ortalama Film Uzunluğu"
FROM film AS f;

-- Kategori bazlı filmlerin süreleri
SELECT
	c.name AS "Kategori Adı",
	AVG(f.length) AS "Kategorinin Ortalama Süresi"
FROM film AS f
INNER JOIN film_category AS fc
	USING(film_id)
JOIN category AS c
	USING(category_id)
GROUP BY c.name
HAVING AVG(f.length) >= ALL(
	SELECT
		ROUND(AVG(fi.length),2)
	FROM film AS fi
)

-- Bunu MAX ile çözelim
SELECT
	c.name AS "Kategori Adı",
	AVG(f.length) AS "Kategorinin Ortalama Süresi"
FROM film AS f
INNER JOIN film_category AS fc
	USING(film_id)
JOIN category AS c
	USING(category_id)
GROUP BY c.name
HAVING AVG(f.length) >(
	SELECT
		ROUND(AVG(fi.length),2)
	FROM film AS fi
)
ORDER BY c.name;

-- 2.13. Veri tabanında en çok kiralanan (en popüler) filmin içinde rol almış aktörlerin ad ve soyadlarını iç içe subquery mimarisiyle getiren sorguyu yazınız. (JOIN kullanmadan aktör ve film ilişkisini subquery ile kurunuz)

-- En çok kiralanan filmi subquery ile bulalım.
SELECT
	i.film_id AS "Envanter ID",
	COUNT(*) AS "Kayıt Sayısı"
FROM rental AS r
JOIN inventory AS i
	USING(inventory_id)
GROUP BY i.film_id
ORDER BY COUNT(r.rental_id) DESC
LIMIT 1;

-- Burada iç sorgu ilk önce çalışır, katman katman ilerleyeceğiz.
-- Rental => Inventory => Film => Film Actor => Actor

-- Bu cevap ile alttaki sorgu farklı yanıtlar üretecektir.
-- Bu sorgu, envanterde en çok bulunan filme göre getirir.
SELECT
	a.first_name || ' ' || a.last_name AS "Aktör Adı Soyadı"
FROM actor AS a
WHERE a.actor_id IN(
	SELECT
		fa.actor_id
	FROM film_actor AS fa
	WHERE film_id IN(
		SELECT
			f.film_id
		FROM film AS f
		WHERE f.film_id IN (
			SELECT
				i.film_id
			FROM inventory AS i
			WHERE i.inventory_id IN (
				SELECT
					r.inventory_id
				FROM rental AS r
				)
			GROUP BY i.film_id
			ORDER BY COUNT(*) DESC
			LIMIT 1
			)
		)
	)
ORDER BY a.first_name || ' ' || a.last_name;

-- Burada Yapay Zeka yardımı da alabilirsiniz:) 
SELECT
	a.first_name || ' ' || a.last_name AS "Aktör Adı Soyadı"
FROM actor AS a
WHERE a.actor_id IN (
	SELECT
		fa.actor_id
	FROM film_actor AS fa
	WHERE fa.film_id = (
		SELECT 
			i.film_id
		FROM inventory AS i
		GROUP BY i.film_id
		ORDER BY (
			-- Dışarıdaki film_id'ye ait kiralama sayısını bulan alt sorgu
			SELECT COUNT(*) 
			FROM rental AS r 
			WHERE r.inventory_id IN (
				SELECT 
					sub_i.inventory_id 
				FROM inventory AS sub_i 
				WHERE sub_i.film_id = i.film_id
			)
		) DESC
		LIMIT 1
	)
);

