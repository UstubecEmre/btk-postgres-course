-- 1. Aggregation Functions (Toplulaştırma Fonksiyonları):
/*
SQL dillerinde karşımıza sıklıkla çıkan çok önemli fonksiyonlardır.
Bu fonksiyonlar sayesinde bir grup içerisindeki değerlerin minimum, maksimum, ortalama değeri vb. değerleri alabiliyoruz.
Gruplama işlemlerinde sıklıkla kullanılırlar.

En Çok Kullanılan AGGREGATION FONKSİYONLARI:
    - COUNT(): Bir grup içerisindeki kayıt sayısını veren fonksiyondur.
    - SUM(): Bir grup içerisindeki sayısal değerlerin toplamını veren fonksiyondur. 
    - AVG(): Bir grup içerisindeki sayısal değerlerin ortalamasını veren fonksiyondur.
    - MIN(): Bir grup içerisindeki minimum değeri veren fonksiyondur.
    - MAX(): Bir grup içerisindeki maksimum değeri veren fonksiyondur.

Önemli Notlar:
- Bu fonksiyonlar tek başına kullanılabilecekleri gibi genellikle GROUP BY ifadesi ile birlikte kullanılırlar. 
- HAVING ile de bu fonksiyonların sonuçlarını filtreleyebiliriz.
*/

---------------------------------------------------------------------------------------------------------------------------------------------
-- 2. Aggregate Functions Example (Gruplama Fonksiyon Örnekleri)

-- 2.1. "pagila" veri tabanında yer alan film tablosundaki toplam film sayısını döndüren sorguyu yazınız. 
SELECT
	COUNT(*) AS "Film Sayısı"
FROM film;
-- GROUP BY film_id;

-- 2.2. "pagila" veri tabanında film tablosundaki filmlerin ortalama kiralama süresini (rental_duration) veren sorguyu yazınız. 
SELECT
	ROUND(AVG(rental_duration),2) AS "Ortalama Kiralama Süresi"
FROM film;

-- 2.3. "pagila" veri tabanında language tablosundaki benzersiz kayıt sayısını döndüren sorguyu yazınız.
SELECT
	COUNT(DISTINCT language_id) AS "Benzersiz Dil Sayısı"
FROM language;

-- 2.4. "pagila" veri tabanında city tablosundaki en eski last_update döndüren sorguyu yazınız. 
SELECT
	MAX(last_update) AS "En Yeni Tarih",
	MIN(last_update) AS "En Eski Tarih"
FROM city;


-- 2.5. "pagila" veri tabanındaki tüm filmlerin toplam değiştirme maliyetini (replacement_cost) getiren sorguyu yazınız. (SUM)
SELECT
	SUM(replacement_cost) AS "Toplam Değiştirme Maliyeti"
FROM film;

	
-- 2.6. "pagila" veri tabanında actor tablosundaki first_name'i 'C' ile başlayanların sayısını bulan sorguyu yazınız.
SELECT
	COUNT(*) AS "C ile Başlayan İsimlerin Sayısı"
FROM actor
WHERE first_name LIKE 'C%';

-- 2.7. "pagila" veri tabanında address tablosunda postal_code sütunu boş olanların sayısını getiren sorguyu yazınız.
SELECT
	COUNT(*) AS "Posta Kodu Girilmemiş Kayıt Sayısı"
FROM address
WHERE postal_code = '';

-- 2.8. "pagila" veri tabanında yer alan rental tablosunda return_date sütununda en büyük ve en küçük değerleri alan sorguyu yazınız.
SELECT
	MIN(return_date) AS "En Güncel Olmayan Kiralama Tarihi",
	MAX(return_date) AS "En Güncel Olan Kiralama Tarihi"
FROM rental;

-- 2.9. "pagila" veri tabanında film tablosunda süresi (length) 120 dakikadan büyük olan filmlerin ortalama kiralama ücretini hesaplayan sorguyu yazınız.
SELECT
	TRUNC(AVG(replacement_cost),3) AS "Ortalama Kiralama Ücreti"
FROM film
WHERE length > 150;


-- 2.10. "pagila" veri tabanında replacement_cost değeri 25.00 ile 29.99 arasında olan filmlerin en uzun olanının süresini getiren sorguyu yazınız.
SELECT
	MAX(replacement_cost) AS "25-30 Arası Tutara Sahip En Pahalı Ödeme Miktarı"
FROM film
WHERE replacement_cost BETWEEN 25.00 AND 29.99

-- 2.11. "pagila" veri tabanında staff tablosunda en kısa first_name ve last_name'e sahip ismin karakter sayısını getiren sorguyu yazınız.
SELECT
	MIN(LENGTH(first_name)) AS "En Kısa Karakterli İsmin Karakter Sayısı",
	MIN(LENGTH(last_name)) AS  "En Kısa Karakterli Soyismin Karakter Sayısı",
	MAX(LENGTH(first_name)) AS "En Uzun Karakterli İsmin Karakter Sayısı",
	MAX(LENGTH(last_name)) AS "En Uzun Karakterli Soyismin Karakter Sayısı",
	MIN(LENGTH(first_name || ' ' || last_name) - 1) AS "Minimum Ad Soyad Karakter Sayısı",
	MAX(LENGTH(first_name || ' ' || last_name) -1) AS "Maksimum Ad Soyad İsmin Karakter Sayısı"
FROM staff;

-- 2.12. "pagila" veri tabanında yer alan payment tablosundaki toplam tahsilat (amount) miktarını döndüren sorguyu yazınız.
SELECT
	SUM(amount) AS "Ortalama Harcama Tutarı"
FROM payment;

-- 2.13. "pagila" veri tabanında payment tablosunda yapılmış olan toplam ve ortalama ödeme tutarunu döndüren sorguyu yazınız.
SELECT
	COUNT(*) AS "Toplam Harcama Adedi",
	COUNT(DISTINCT customer_id) AS "Benzersiz Müşteri Sayısı",
	COUNT(DISTINCT staff_id) AS "Benzersiz Çalışan Sayısı",
	SUM(amount) AS "Toplam Harcama Miktarı"
FROM payment;

-- 2.14. "pagila" veri tabanında country tablosundaki ortalama ülke adı uzunluğunu döndüren sorguyu yazınız. 
SELECT
	COUNT(DISTINCT country_id) AS "Benzersiz Ülke Kaydı",
	MIN(LENGTH(country)) AS "En Kısa Ülke Karakteri",
	MAX(LENGTH(country)) AS "En Uzun Ülkenin Karakter Sayısı",
	SUM(LENGTH(country)) AS "Toplam Karakter Uzunluğu",
	CEIL(AVG(LENGTH(country))) AS "Ortalama Karakter Uzunluğu"
FROM country;


-- 2.15. "pagila" veri tabanında staff_id değeri 2 olan personelin aldığı toplam ödeme tutarını getiren sorguyu yazınız. 
SELECT
	FLOOR(SUM(amount)) AS "Harcama Tutarı Toplamı"
FROM payment
WHERE staff_id = 2;

-- 2.16. "pagila" veri tabanında customer_id değeri 300 olan müşterinin yaptığı ödemelerin en yüksek olanını getiren sorguyu yazınız.
SELECT
	MAX(amount) AS "Maksimum Tutarlı Sipariş"
FROM payment
WHERE customer_id = 300;

-- 2.17. "pagila" veri tabanında ödeme tarihi (payment_date) '2007-03-01' ile '2007-03-31' arasında olan ödemelerin ortalamasını getiren sorguyu yazınız. 
SELECT
	COUNT(*) AS "Kayıt Sayısı",
	ROUND(AVG(amount),3) AS "Ortalama Ödeme Tutarı"
FROM payment
WHERE payment_date BETWEEN '2022-03-01' AND '2022-03-31';

-- 2.18. "pagila" veri tabanında yer alan customer tablosunda sistemde kayıtlı toplam aktif (active = 1) müşteri sayısını veren sorguyu yazınız. 
SELECT
	COUNT(*) AS "Aktif Kullanıcı Sayısı"
FROM customer
WHERE active = 1;


-- 2.19. "pagila" veri tabanında yer alan store_id değeri 1 olan mağazaya kayıtlı kaç farklı müşteri olduğunu listeleyen sorguyu yazınız. 
SELECT
	COUNT(*) AS "Satış Yapılan Farklı Müşteri Adedi"
FROM staff
WHERE store_id = 1;

-- 2.20. "pagila" veri tabanında yer alan rental tablosunda staff_id değeri 1 olan çalışanın kiraladığı toplam film/envanter sayısını döndüren sorguyu yazınız. 
SELECT
	COUNT(*) AS "Kiralama Adedi"
FROM rental
WHERE staff_id = 1;


-- 2.21. "pagila" veri tabanında film_actor tablosunu kullanarak actor_id değeri 10 olan aktörün toplam kaç farklı filmde rol aldığını listeleyen sorguyu yazınız. 
SELECT
	COUNT(DISTINCT film_id) AS "10 ID'li Aktörün Oynadığı Farklı Film Sayısı"
FROM film_actor
WHERE actor_id = 10;

-- 2.22. "pagila" veri tabanında yer alan film tablosunda 'NC-17' veya 'R' reytingine sahip filmlerin toplam süresini (length) dakika cinsinden getiren sorguyu yazınız. (WHERE ile SUM)
SELECT
	SUM(length) AS "Toplam Süre (Dakika)",
	(SUM(length) / 60) AS "Toplam Süre (Saat)"
FROM film
WHERE rating IN ('NC-17','R');

-- 2.23. "pagila" veri tabanında payment tablosunda ödeme miktarı 5.00'den büyük olan kaç farklı ödeme tutarı (amount) olduğunu döndüren sorguyu yazınız. 
SELECT
	COUNT(DISTINCT amount) AS "Beşten Büyük Farklı Ödeme Tutarı "
FROM payment
WHERE amount > 5.00;


-- 2.24. "pagila" veri tabanında film tablosunda ismi (title) 'A' harfi ile başlayan filmlerin ortalama kiralama süresini döndüren sorguyu yazınız. 
SELECT
	ROUND(AVG(rental_duration),2) AS "Ortalama Kiralama Süresi"
FROM film
WHERE title ILIKE 'A%';

-- 2.25. "pagila" veri tabanında payment tablosundaki en yüksek ve en düşük ödeme miktarlarını tek bir sorguda yan yana getiren sorguyu yazınız.
SELECT	
	MIN(amount) AS "Minimum Ödeme Tutarı",
	MAX(amount) AS "Maksimum Ödeme Tutarı",
	MAX(amount) || '-' || MIN(amount) AS "Maksimum - Minimum Ödeme Tutarı"
FROM payment;

---------------------------------------------------------------------------------------------------------------------------------------------
-- 3. GROUP BY (Gruplama) 

/*
- Sütunlara göre gruplamak istediğimizde kullanabileceğimiz ifadedir.
- Aggregation Functions (Gruplama Fonksiyonları) ile beraber kullanılabilir.



Önemli Notlar:

- HAVING kullanılan yerde GROUP BY kullanmak zorunluyken; GROUP BY kullanılan yerde HAVING kullanmak zorunlu değildir.
- Gruplama fonksiyonlarını filtrelemek istersek HAVING kullanmamız gerekmektedir.

*/

-- 3.1. "pagila" veri tabanında yer alan film tablosundaki filmleri reytinglerine (rating) göre gruplayarak, her reyting grubunda kaçar adet film olduğunu listeleyen sorguyu yazınız.
SELECT
	rating AS "Film Rating Değeri",
	COUNT(*) AS "Film Adedi"
FROM film
GROUP BY rating;

-- 3.2. "pagila" veri tabanında yer alan film tablosundaki her bir kiralama ücreti (rental_rate) seçeneği için filmlerin ortalama süresini (length) dakika cinsinden getiren sorguyu yazınız.
SELECT
	rental_rate AS "Kiralama Seçeneği",
	ROUND(AVG(length),3) AS "Ortalama Film Uzunluğu"
FROM film
GROUP BY rental_rate
ORDER BY rental_rate ;

-- 3.3. "pagila" veri tabanında yer alan payment tablosundaki verileri müşteri numaralarına (customer_id) göre gruplayarak, her müşterinin toplam ne kadarlık ödeme yaptığını listeleyen sorguyu yazınız.
SELECT
	customer_id AS "Müşteri ID",
	SUM(amount) AS "Toplam Harcama"
FROM payment
GROUP BY customer_id
ORDER BY customer_id;

-- 3.4. "pagila" veri tabanında yer alan payment tablosundaki her bir personelin (staff_id) bugüne kadar tahsil ettiği en yüksek ödeme tutarını listeleyen sorguyu yazınız.
SELECT
	staff_id AS "Yetenek ID",
	MAX(amount) AS "En Yüksek Ödeme Tutarı"
FROM payment
GROUP BY staff_id
ORDER BY staff_id;

-- 3.5. "pagila" veri tabanında yer alan customer tablosundaki aktiflik durumlarına (active) göre, her grupta kaçar adet müşteri bulunduğunu gösteren sorguyu yazınız.
SELECT
	active AS "Aktiflik Durumu",
	COUNT(DISTINCT customer_id)
FROM customer
GROUP BY active
ORDER BY active;

-- CASE-WHEN-THEN hatırlayalım:) Beraber kullanabiliriz. Deneme yanılma ile sizler de bu tarz öğrendiğimiz şeyleri pratik yapabilirsiniz.
SELECT
	active AS "Aktiflik Değeri",
	CASE active
		WHEN 1 THEN 'Aktif'
		ELSE 'Aktif Değil'
		END AS "Aktiflik Durumu",
	COUNT(DISTINCT customer_id) AS "Benzersiz Müşteri Sayısı"
FROM customer
GROUP BY active
ORDER BY active;

-- 3.6. "pagila" veri tabanında yer alan film_actor tablosunu kullanarak, her bir aktörün (actor_id) toplam kaç farklı filmde rol aldığını listeleyen sorguyu yazınız.
SELECT
	actor_id AS "Aktör ID",
	COUNT(DISTINCT film_id) AS "Bulunduğu Film Sayısı"
FROM film_actor
GROUP BY actor_id
ORDER BY actor_id;

-- 3.7. "pagila" veri tabanında yer alan inventory tablosunu kullanarak, her bir mağazada (store_id) toplam kaç adet envanter/film kasedi bulunduğunu listeleyen sorguyu yazınız.
SELECT
	store_id AS "Mağaza ID",
	COUNT(inventory_id) AS "Envanter Sayısı",
	CASE
		WHEN COUNT(inventory_id) <= 2270 THEN 'Yetersiz Envanter'
		ELSE 'Yeterli Envanter'	
	END AS "Envanter Durumu"
FROM inventory
GROUP BY store_id 
ORDER BY store_id;

-- 3.8. "pagila" veri tabanında yer alan film tablosunda, her bir değiştirme maliyeti (replacement_cost) grubu için en kısa film süresini döndüren sorguyu yazınız.
SELECT
	replacement_cost AS "Değiştirme Maliyeti",
	MIN(length) AS "Minimum Film Süresi"
FROM film
GROUP BY replacement_cost
ORDER BY replacement_cost;

---------------------------------------------------------------------------------------------------------------------------------------------
-- 4. HAVING İfadesi:
/*
- Gruplar, WHERE ifadesinde sınırlandırılamaz.
- Grup fonksiyonları WHERE ifadesinde kullanılamaz.
- HAVING ifadesi, grupları sınırlandırmak için kullanılır.
- Başka bir deyişle WHERE satırlara uygulanırken HAVING satır gruplarına uygulanır
*/

-- 4.1. "pagila" veri tabanında yer alan film tablosunda, reytinglerine göre gruplanan filmlerden toplam film sayısı 200'den fazla olan reyting gruplarını ve film sayılarını listeleyen sorguyu yazınız.
SELECT
	rating AS "Film Rating Bilgisi",
	COUNT(DISTINCT film_id) AS "Benzersiz Film Sayısı"
FROM film
GROUP BY rating
HAVING COUNT(DISTINCT film_id) > 200
ORDER BY rating;

-- 4.2. "pagila" veri tabanında yer alan payment tablosunda, müşteri bazında (customer_id) yapılan toplam ödeme tutarlarını inceleyerek, sisteme toplamda 150 birimden fazla ödeme yapmış olan müşterileri ve toplam tutarlarını listeleyen sorguyu yazınız.
SELECT
	customer_id AS "Müşteri ID",
	SUM(amount) AS "Ödeme Tutarı Toplamı"
FROM payment
GROUP BY customer_id
HAVING SUM(amount) > 150
ORDER BY SUM(AMOUNT) DESC;

-- 4.3. "pagila" veri tabanında yer alan payment tablosunda, her bir müşterinin (customer_id) yaptığı toplam başarılı işlem sayısını inceleyerek, bugüne kadar 35'ten fazla ödeme işlemi gerçekleştirmiş müşterileri listeleyen sorguyu yazınız.
SELECT
	customer_id AS "Müşteri ID",
	COUNT(*) AS "Sipariş Sayısı"
FROM payment
GROUP BY customer_id
HAVING COUNT(*) > 35
ORDER BY customer_id;

-- 4.4. "pagila" veri tabanında yer alan film_actor tablosunda, aktörlerin rol aldığı film sayılarını inceleyerek, kariyeri boyunca 40'tan fazla filmde oynamış olan aktörlerin numaralarını ve film sayılarını listeleyen sorguyu yazınız.
SELECT
	actor_id AS "Aktör ID",
	COUNT(DISTINCT film_id) AS "Yer Aldığı Film Sayısı"
FROM film_actor
GROUP BY actor_id
HAVING COUNT(DISTINCT film_id) > 40
ORDER BY COUNT(DISTINCT film_id) DESC;

-- 4.5. "pagila" veri tabanında yer alan film tablosunda, kiralama ücretlerine (rental_rate) göre gruplanan filmlerin ortalama sürelerini inceleyerek, ortalama süresi 115 dakikadan büyük olan kiralama ücreti gruplarını listeleyen sorguyu yazınız.
SELECT
	rental_rate AS "Kiralama Ücreti",
	ROUND(AVG(length), 2) AS "Ortalama Film Süresi"
FROM film
GROUP BY rental_rate
HAVING ROUND(AVG(length), 2) > 115
ORDER BY rental_rate;


-- 4.6. "pagila" veri tabanında yer alan customer tablosunda, mağaza bazlı (store_id) müşteri sayılarını inceleyerek, sistemde 300'den fazla kayıtlı müşterisi olan mağazaları ve müşteri sayılarını listeleyen sorguyu yazınız.
SELECT
	store_id AS "Mağaza ID",
	COUNT(customer_id) AS "Müşteri Sayısı"
FROM customer
GROUP BY store_id
HAVING COUNT(customer_id) > 300
ORDER BY store_id;

-- 4.7. "pagila" veri tabanında yer alan payment tablosunda, her bir müşterinin (customer_id) yaptığı ödemelerin ortalamasını inceleyerek, ortalama ödeme miktarı 4.50'den yüksek olan müşterileri listeleyen sorguyu yazınız.
SELECT
	customer_id AS "Müşteri ID",
	ROUND(AVG(amount),2) AS "Ortalama Ödeme Tutarı",
	SUM(amount) AS "Toplam Ödeme Tutarı"
FROM payment 
GROUP BY customer_id
HAVING ROUND(AVG(amount), 2) > 4.50
ORDER BY customer_id;

-- 4.8. "pagila" veri tabanında yer alan payment tablosunda, sadece 5.00 birimden yüksek olan ödemeleri (amount) dikkate alarak müşteri (customer_id) bazında gruplama yapınız. Bu gruplama sonucunda, yaptığı bu yüksek tutarlı ödemelerin toplamı 50.00 birimi geçen müşterileri ve toplam ödeme tutarlarını listeleyen sorguyu yazınız.
SELECT
	customer_id AS "Müşteri ID",
	SUM(amount) AS "Toplam Harcama Tutarı"
FROM payment
WHERE amount > 5.00
GROUP BY customer_id
HAVING SUM(amount) > 50.00
ORDER BY customer_id
LIMIT 5 OFFSET 10; -- 10 Kayıt atlasın, 5 kaydı getirsin.

-- 4.9. "pagila" veri tabanında yer alan film tablosunda, kiralama ücreti (rental_rate) 2.99 veya daha düşük olan filmleri reytinglerine (rating) göre gruplayınız. Bu gruplama sonucunda, içerisinde bu uygun fiyata sahip 40'tan fazla film barındıran reyting gruplarını ve film sayılarını listeleyen sorguyu yazınız.
SELECT
	rating AS "Rating",
	COUNT(*) AS "Kategoriye Sahip Film Sayısı"
FROM film
WHERE rental_rate <= 2.99
GROUP BY rating
HAVING COUNT(*) > 40
ORDER BY COUNT(*);

-- 4.10. "pagila" veri tabanında yer alan rental tablosunda, iade işlemi gerçekleşmiş (return_date sütunu boş olmayan) kayıtları müşteri (customer_id) bazında gruplayınız. Bu gruplama sonucunda, bugüne kadar 25'ten fazla kiraladığı filmi başarılı bir şekilde iade etmiş olan müşterileri ve toplam iade sayılarını listeleyen sorguyu yazınız.
SELECT
	customer_id AS "Müşteri ID",
	COUNT(*) AS "İade İşlem Sayısı"
FROM rental
WHERE return_date IS NOT NULL
GROUP BY customer_id
HAVING COUNT(*) > 25
ORDER BY customer_id;
