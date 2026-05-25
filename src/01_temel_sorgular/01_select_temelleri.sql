-- 1. Temel SELECT Sorguları:

-- Bütün sütunları seçmek için * kullanabilirsiniz.

-- 1.1. "dvdrental"'de bulunan actor tablosunun tüm kayıtlarını getiren sorguyu yazınız.
SELECT * FROM actor; 

-- 1.2. "dvdrental"'de bulunan actor tablosundan isim ve soyisim sütunlarını getiren sorguyu yazınız.
SELECT 
    first_name, 
    last_name 
FROM actor;

-- 1.3. "dvdrental"'de bulunan city tablosunda yer alan city ve last_update sütunlarını getiren sorguyu yazınız.
SELECT 
    city, 
    last_update 
FROM city;

-- 1.4. "dvdrental"'de bulunan customer tablosundan customer_id, first_name ve last_name sütunlarını getiren sorguyu yazınız
SELECT
    customer_id,
    first_name,
	last_name
FROM customer;

-- 1.5. "dvdrental"'de bulunan film_category tablosundan category_id ve last_update sütunlarını getiren sorguyu yazınız.
SELECT
    category_id,
	last_update
FROM film_category;

-------------------------------------------------------------------------------------------------------
-- 2. Aritmetik Operatörler:
-- 2.1. Toplama, çıkarma, çarpma, bölme, mod alma ilgili karışık işlemler gerçekleştirin.

-- Not: AS ile alias yani takma ad verebilirsiniz.
SELECT
    90 + 45 - 52 "işlem Önceliği İşlem Sonucu 1",
	65 * 35 / 4 "İşlem Sonucu 2",
	14 / 2 "Bölme Sonucu",
	52 % 6 "Kalan Sonucu",
	14 / 2 * 6 - 5 "Karışık İşlem Sonucu";

-- 2.2. 'dvdrental' veri tabanında yer alan customer tablosunda yer alan oluşturulma tarihinden bir hafta çıkartın.
SELECT
    create_date AS "Oluşturulma Tarihi",
	create_date - 7 AS "Bir Hafta Önceki Tarih"
FROM customer;

-- 2.3. "dvdrental" veri tabanında yer alan category tablosunun last_update sütununu günümüzden çıkaran sorguyu yazınız.
SELECT
    last_update "Son Güncelleme Tarihi",
	CURRENT_DATE - last_update AS "Son Güncelleme Tarihinden İtibaren Geçen Zaman"
FROM category;

-- 2.4. "dvdrental" veri tabanında yer alan film tablosunda length sütununu saate çeviren sorguyu yazınız.
SELECT 
    film_id,
    length AS "Film Uzunluğu",
	length / 60 AS "Film Saati"
FROM film;

-- 2.5. "dvdrental" veri tabanında yer alan payment tablosunda payment_date tarihini güncel yıldan çıkarın.
SELECT
    payment_date AS "Ödeme Tarihi",
	CURRENT_DATE - payment_date "Geçen Zaman"
FROM payment;

--------------------------------------------------------------------------------------------------
-- 3. Birleştirme Operatörü (||):

-- 3.1. "dvdrental" veri tabanında yer alan customer tablosunda first_name ve last_name sütunlarını birleştirin.
SELECT
    first_name AS "İsim",
	last_name AS "Soyisim",
	first_name || ' ' || last_name AS "İsim Soyisim"
FROM customer;

-- 3.2. "dvdrental" veri tabanında yer alan staff tablosunda staff_id, username, password sütunlarını birleştiren sorguyu yazınız.
SELECT
    staff_id AS "Çalışan ID",
	username AS "Kullanıcı Adı",
	password AS "Kullanıcı Şifresi",
	staff_id || '-' || username || '-' || password AS "ID-AD-PAROLA"
FROM staff;

-- 3.3. "dvdrental" veri tabanında yer alan language tablosunda language_id ve name sütunlarını birleştiren sorguyu yazınız.
SELECT
    language_id AS "Dil ID",
	name AS "Dil",
	language_id || ':' || name AS "ID: Dil"
FROM language;

-- 3.4. "dvdrental" veri tabanında yer alan inventory tablosunda inventory_id, film_id ve last_update sütunlarını birleştiren sorguyu yazınız.
SELECT
    inventory_id,
	film_id,
	last_update,
	inventory_id || '_' || film_id || '_' || last_update AS "BARKOD"
FROM inventory;

-- 3.5. "dvdrental" veri tabanında yer alan rental tablosunda yer alan rental_id, customer_id, return_date ve rental_date sütunlarını birleştiren sorguyu yazınız.
SELECT
    rental_id,
	customer_id,
	rental_date,
	return_date,
	'CustomerID: ' || customer_id || ' ' ||
	'RentalID: ' || rental_id || ' ' ||
	'ReturnDate - RentalDate: ' || return_date - rental_date AS "Kısa Özet"
FROM rental;

--------------------------------------------------------------------------------------------------
-- 4.Alias (Kolon Takma Adları)
-- Önemli Hatırlatma: AS kullanmak opsiyoneldir.

-- 4.1. "dvdrental" veri tabanında yer alan film_actor tablosunu actor_id ve film_id birleştirip yeni bir takma isim veriniz.
SELECT
    actor_id AS "Benzersiz Aktör Numarası",
	film_id AS "Benzersiz Film Numarası",
	'Aktör No: ' || actor_id || ' ' || '/Film No: ' || film_id AS "Birleştirilmiş Sütun" 
FROM film_actor;

-- 4.2. "dvdrental" veri tabanında yer alan country tablosunun country_id ve country sütunlarına takma ad veren sorguyu yazınız. (AS Kullanmayınız)
SELECT
    country_id "Benzersiz Ülke ID",
	country "Ülke Adı"
FROM country;

-- 4.3. Dört işlem gerçekleştirin ve ilgili aritmetiksel işlemin ismini alias olarak verin.
SELECT
    32 / 4 "Bölme Sonucu",
	25 * 9 "Çarpma Sonucu",
	20 + 694 "Toplama Sonucu",
	14 - 41 "Çıkarma Sonucu";

-- 4.4. "dvdrental" veri tabanında yer alan address tablosunuda yer alan phone ve postal_code sütunlarına ilgili takma adı veren sorguyu yazınız.
SELECT
    postal_code AS "Posta Kodu",
	phone AS "Telefon Numarası",
	'Adres Numarası: '|| address_id || ' / ' || address AS "Adres Tanımı"
FROM address;
	

-- 4.5. "dvdrental" veri tabanında yer alan store tablosunu kullanarak gerekli sütunlara alias veren sorguyu yazınız.
SELECT
    store_id AS "Mağaza Numarası",
	manager_staff_id AS "Yönetici Çalışan Numarası",
	address_id AS "Adres Numarası",
	last_update AS "Son Güncelleme Tarihi"
FROM store;

--------------------------------------------------------------------------------------------------
-- 5. Sıralama İşlemleri (ORDER BY)
/* 
 ASC: Ascending, artan yönde sıralama yapmamızı sağlayan, varsayılan değerdir.
 DESC: Descending, azalan yönde sıralama yapmamızı sağlayan ifadedir. 
 Kolon numaralarının uyumlu olması gerekmektedir, (SELECT'e verilen kolon sırası). 
 İsimlendirme ile sıralama yapmak daha fazla tavsiye edilmektedir.
*/
-- 5.1. "dvdrental" veri tabanında yer alan customer tablosunda bulunan email sütununu A'dan Z'ye sıralayan sorguyu yazınız.

SELECT
    first_name || ' ' || last_name AS "İsim Soyisim",
    email
FROM customer
ORDER BY email ASC;

-- 5.2. "dvdrental" veri tabanında yer alan category tablosunda bulunan name sütununu azalan yönde sıralayan sorguyu yazınız.
SELECT
    category_id AS "Kategori Numarası",
	name AS "İsim"
FROM category
ORDER BY category DESC;


-- 5.3. "dvdrental" veri tabanında yer alan film_actor tablosunda  bulunan last_update sütununa göre sıralayan sorguyu yazınız. ASC kullanmayınız.
SELECT
    actor_id AS "Aktör No",
	last_update AS "Son Güncellenme Tarihi"
FROM film_actor
ORDER BY last_update;

-- 5.4. "dvdrental" veri tabanında yer alan staff tablosunda first_name'i artan, last_name'i azalan yönde sıralayan sorguyu yazınız.
SELECT 
    first_name AS "Personel Adı",
	last_name AS "Personel Soyadı",
	staff_id AS "Personel Numarası"
FROM staff
ORDER BY first_name ASC, last_name DESC;

-- 5.5.  "dvdrental" veri tabanında yer alan payment tablosunda bulunan amount ve payment_date azalan yönde sıralayan sorguyu yazınız.
SELECT
    payment_date AS "Ödeme Tarihi",
	amount AS "Ödeme Tutarı",
    payment_id AS "Ödeme Numarası"
FROM payment
ORDER BY payment_date DESC, amount DESC;

-- 5.6.  "dvdrental" veri tabanında yer alan rental tablosunda bulunan return_date ve rental_date farkından oluşan bir sütun oluşturun ve buna göre azalana göre sıralayın. 
SELECT
    return_date - rental_date AS "Geçen Zaman",
	return_date AS "Teslim Tarihi",
	rental_date AS "Kiralama Tarihi"
FROM rental
ORDER BY "Geçen Zaman" DESC;

-- 5.7.  "dvdrental" veri tabanında yer alan film tablosunda rental_duration ve rental_rate sütunlarına göre azalan sıralama işlemi gerçekleştiriniz (Numara ile)
SELECT
    *
FROM film
ORDER BY 6 DESC, 7 DESC;


-- 5.8. "dvdrental" veri tabanında yer alan address tablosunu kullanarak address_id, addresss, district, phone sütunlarını 3 kolona göre azalan yönde sıralayan sorguyu yazın.
SELECT
    address_id,
	address,
	district,
	phone
FROM address
ORDER BY 3 DESC;

-- 5.9. "dvdrental" veri tabanında yer alan address tablosunu kullanarak postal_code null olanları azalana göre sıralayın.
SELECT
    address_id,
	district,
	postal_code,
	phone
FROM address
ORDER BY postal_code DESC NULLS FIRST;

-- 5.10. "dvdrental" veri tabanında yer alan address tablosunu kullanarak phone sütununun NULL değerlerini en sonda göstererek sıralayan sorguyu yazınız.
SELECT
    address_id,
	address,
	district,
	phone,
	postal_code
FROM address
ORDER BY phone NULLS LAST;

--------------------------------------------------------------------------------------------------
-- 6. DISTINCT:
-- Tekrar eden değerleri tekilleştiren önemli bir komuttur.
-- Distinct ifadesinden önce kolon ya da ifade gelemez.

-- 6.1. "dvdrental" veri tabanında yer alan film tablosunda bulunan title sütununu tekilleştiren sorguyu yazınız.
SELECT
	DISTINCT title AS "Benzersiz Film Başlığı"
    -- film_id AS "Film Numarası", --opsiyonel olarak ne olacağını görmek isteyebilirsiniz.
	-- length AS "Film Uzunluğu" --opsiyonel olarak ne olacağını görmek isteyebilirsiniz.
FROM film; 


-- 6.2. "dvdrental" veri tabanında yer alan film tablosunda bulunan rental_duration, length, rating sütunlarını tekilleştiren sorguyu yazınız.
SELECT
    DISTINCT rental_duration,length, rating
FROM film;
-- ORDER BY length DESC; --opsiyonel olarak ne olacağını görmek isteyebilirsiniz.

-- 6.3. "dvdrental" veri tabanında yer alan rental tablosunu kullanarak return_date tarihini tekilleştiren sorguyu yazınız.
SELECT
    DISTINCT return_date
FROM rental
ORDER BY return_date NULLS FIRST;


-- 6.4. "dvdrental" veri tabanında yer alan payment tablosunda customer_id'yi tekilleştiren amount sütununu azalana göre getiren sorguyu yazınız.
SELECT
    DISTINCT customer_id AS "Benzersiz Müşteri Numarası",
	-- payment_id AS "Ödeme ID", --opsiyonel olarak ne olacağını görmek isteyebilirsiniz.
	amount AS "Harcama Tutarı"
FROM payment
ORDER BY amount DESC;

-- 6.5. "dvdrental" veri tabanında yer alan payment tablosunda yer alan amount sütununu tekilleştiren, cuve payment_date sütununu tekilleştiren  (payment_date'i azalana göre sıralayan) sorguyu yazınız.
SELECT
    DISTINCT amount AS "Benzersiz Harcama Tutarı",
	payment_id AS "Ödeme ID",
	payment_date AS "Ödeme Tarihi"
FROM payment
ORDER BY payment_date;

------------------------------------------------------------
/*
Önemli Notlar:
    1. Tekli yorum satırında bulunmak istersek -- (iki tire) kullanabiliriz.
	
    2. Çoklu yorum satırı için de: 
	/*
	Yoruma alacağınız satırlar. 
	*/

    Dikkatli bir şekilde kullanmamız gerekmektedir.

	3. 'DISTINCT ON' komutu postgresql'e özgüdür.
	Bu komut ile beraber, tekilleştirme işlemi bir seviye daha atlar,
	bulduğu ilk satırı getirecektir.
	
    Test etmek için:
	'test veri' tabanını kullanarak distinct_demo tablosu üzerinde çalışabilirsiniz.
    
    4. Örnek DISTINCT ve DISTINCT ON kullanımı:
    
    ```sql
	SELECT 
	    DISTINCT bcolor, fcolor
	FROM distinct_demo
	ORDER BY bcolor, fcolor
    ```
    
    ```sql
	SELECT 
	    DISTINCT ON (bcolor) bcolor, fcolor
	FROM distinct_demo
	ORDER BY bcolor, fcolor
	```

	Arasındaki farkı gözlemleyebilirsiniz. 
    Hatırlatma: pgAdmin4 kullanıyorsanız, tek bir veri tabanı üzerinde işlem yapmanıza imkan vermektedir. 
    Bu nedenle burada buna yer vermedim. 

Bu konu BTK Akademi PostgreSQL için SQL Dili 4.bölüm 12. ders içinde 
değerli eğitmenimiz Tuncay Tiryaki tarafından anlatılmaktadır.	
*/

/*
Editör Seçimi:

Not: 
VS Code kullanıyorsanız, PostgreSQL eklentisi ile birlikte farklı veri tabanları üzerinde çalışabilirsiniz.
Öncelikle pgAdmin4'te oluşturduğunuz veri tabanını VS Code'a tanıtmanız gerekmektedir.

Bunun için, VS Code'da PostgreSQL eklentisini açın ve "Add New Connection" seçeneği ile pgAdmin4'te oluşturduğunuz veri tabanını ekleyin.
Gerekli bilgileri doldurduktan sonra, bağlantıyı oluşturabilirsiniz.
*/
