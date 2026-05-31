-- 1. PosgreSQL Fonksiyonları:
/*
	PostgreSQL'de kullanılan fonksiyonları sınıflandıracak olursak:
	- String Fonksiyonları (lower(), upper(), initcap(), substring()...)
    - Date Fonksiyonları (current_date(), current_time(), now(), ... )
    - Math Fonksiyonları (round(), ceil(), floor(), abs(), sqrt() ...)
    - Aggregate Fonksiyonları (count(), sum(), min(), max(), avg() ...)
    - Conversion Fonksiyonları (cast, ::, to_char(), to_date(), to_number() ...)
*/
SELECT current_database();
-----------------------------------------------------------------------------------------------------------------------------------------------------
-- 2. String Functions (Metinsel Fonksiyonlar):

-- 2.1. "test" veri tabanında yer alan cars tablosunda bulunan brand sütununu büyük harfe çeviren sorguyu yazınız.
SELECT
	id AS "Benzersiz Kimlik",
	brand AS "Marka",
	UPPER(brand) AS "MARKA ADI",
	LOWER(brand) AS "marka adı",
	INITCAP(brand) AS " Marka Adı"
FROM cars;

-- 2.2. "test" veri tabanında bulunan product tablosunu kullanarak name sütunundaki değerlerin soldan 2, sağdan 4 karakter getiren sorguyu yazınız.
SELECT
	id AS "Ürün ID",
	name AS "Ürün Adı",
	LEFT(name, 2) "Soldan İki Karakter",
	RIGHT(name, 3) "Sağdan Üç Karakter"
FROM product;


-- 2.3. "test" veri tabanında colors tablosunu kullanarak 2 ve 5. karakterleri arasındaki değerleri getiren sorguyu yazınız.
SELECT
    color AS "Renk",
	SUBSTRING(color, 2, 3) AS "Parça Alınmış Renk"
FROM colors;

-- 2.4. "test" veri tabanında car_types tablosunu kullanarak type_name karakter uzunluğunu döndüren sorguyu yazınız.
SELECT
	id AS "ID",
	type_name AS "Araba Tipi",
	LENGTH(type_name) AS "Tipin Karakter Uzunluğu"
FROM car_types;

-- 2.5. "test" veri tabanında budgets tablosunu kullanarak current_year 10 karaktere tamamlayın, soldan 0 ekleyen sorguyu yazınız.
SELECT
	salesman_id AS "Satışçı ID",
	current_year AS "Güncel Geçen Zaman",
	LPAD(current_year::varchar, 10, '0') "Soldan 10 Karaktere Tamamlanmış",
	previous_year AS "Geçen Zaman",
	RPAD(previous_year::varchar, 10, '0') AS "Sağdan 10 Karaktere Tamamlanmış"
FROM budgets;

-- 2.6. "test" veri tabanında basket_a tablosunu kullanarak id_a ve fruit_a sütunlarını birleştiren sorguyu yazınız.
SELECT
    id_a AS "ID",
	fruit_a AS "Meyve",
	CONCAT(id_a, '-', fruit_a)
FROM basket_a;

-- 2.7. "test" veri tabanında courses tablosunda yer alan description sütununda geçen 21 yerine 30 yapan sorguyu yazınız.
SELECT
	course_id AS "Kurs ID",
	course_name AS "Kurs Adı",
	description AS "Kurs Açıklaması",
	replace(description, '21', '30') AS "Değiştirilmiş Kurs Açıklaması"
FROM courses;

-- 2.8. "test" veri tabanında basket_b tablosunda yer alan fruit_b sütununda 'a' harfinin geçtiği ilk yeri bulan sorguyu yazınız.
SELECT
	id_b "ID",
	fruit_b AS "Meyve Adı",
	POSITION('a' IN fruit_b) AS "a Harfinin Geçtiği İlk Karakter"
FROM basket_b;

-- 2.9. "test" veri tabanında courses tablosunda yer alan published_date sütununda yıl bilgisini alan sorguyu yazınız.
SELECT
	course_id AS "Kurs ID",
	course_name AS "Kurs Adı",
	published_date AS "Yayım Tarihi",
	--LEFT(published_date, 4) AS "Yayım Yılı"
	SPLIT_PART(published_date::varchar, '-', 1)
FROM courses
WHERE published_date IS NOT NULL
ORDER BY published_date;

-- 2.10. "test" veri tabanında distinct_demo tablosunda bcolor ve fcolor karakter sayısını bulan sorguyu yazınız.
SELECT
	id AS "ID",
	bcolor,
	fcolor,
	LENGTH(bcolor) AS "bcolor Karakter Sayısı",
	LENGTH(fcolor) AS "fcolor Karakter Sayısı"
FROM distinct_demo;

----------------------------------------------------------------------------------------------------
-- 3. Math Functions (Matematiksel Fonksiyonlar):
-- ROUND(): Sayıyı yuvarlar.
-- CEIL(): Sayıyı yukarı yuvarlar.
-- FLOOR(): Sayıyı aşağı yuvarlar.
-- ABS(): Mutlak değer alır.
-- SIGN(): Sayının işaretini verir.
-- SQRT(): Karekök alır.
-- RANDOM(): Rastgele sayı üretir.
-- TRUNC(): Sayının belirli basamağını keser.
-- POWER(): Üs alma işlemi yapar.
-- MOD(): Mod alma işlemi yapar.


-- 3.1. "test" veri tabanını kullanarak cars tablosunda yer alan discount sütununu 0.10 ile çarpıp 2 basamaklı gösteren sorguyu yazınız.
SELECT 
	id AS "Araba ID",
	brand AS "Marka",
	discount AS "İndirim",
	(discount * 0.010) AS "Yeni İndirim Oranı",
	TRUNC((discount * 0.010), 2) AS "Yeni İki Küsüratlı İndirim"
FROM cars;



-- 3.2. "test" veri tabanını kullanarak product tablosunda yer alan price sütununu yukarı yuvarlayan sorguyu yazınız.
SELECT
	price AS "Fiyat",
	CEIL(price) AS "Yukarı Yuvarlanmış Fiyat"
FROM product;

-- 3.3. "test" veri tabanını kullanarak budgets tablosunda yer alan current_year sütununu aşağı yuvarlayan sorguyu yazınız.
SELECT
	salesman_id AS "Satışcı ID",
	current_year AS "Güncel Yıl",
	TRUNC((current_year / 10000), 4) AS "Sadeleştirilmiş Yıl",
	FLOOR((current_year / 10000)) AS "Aşağı Sadeleştirilmiş Yıl",
	FLOOR(current_year) AS "Aşağı Yuvarlanmış Yıl"
FROM budgets;

-- 3.4. "test" veri tabanını kullanarak cars tablosunda yer alan price sütunundan 15000 indirim yapın ve bunun mutlak değerini alan sorguyu yazınız.
SELECT
	id AS "Araba ID",
	brand AS "Araba Markası",
	price AS "Araba Fiyatı",
	(price - 15000) AS "Kesintili Fiyat",
	ABS(price - 15000) AS "Kesinti Yapılmış Mutlak Değer"
FROM cars;


-- 3.5. "test" veri tabanını kullanarak budgets tablosunda yer alan previous_year sütununun işaret bilgisini getiren sorguyu yazınız.
SELECT
	previous_year AS "Önceki Yıl",
	SIGN(previous_year) AS "Önceki Yılın İşareti",
	(previous_year - 180000) AS "Önceki Yıl Farkı",
	SIGN((previous_year - 180000)) AS "Önceki Yıl Farkı İşaraet"
	-- SIGN(-8) AS "İşaret Değeri"
FROM budgets;

-- 3.6. "test" veri tabanını kullanarak product_segment tablosunda yer alan discount sütununun karekökünü getiren sorguyu yazınız.
SELECT
	id AS "Ürün ID",
	discount AS "İndirim Oranı",
	SQRT(discount) AS "İndirim Oranının Karekökü"
FROM product_segment
ORDER BY discount DESC;


-- 3.7. "test" veri tabanını kullanarak product tablosundan rastgele 5 kayıt getiren sorguyu yazınız.
SELECT
	id AS " ID",
	name AS "Ürün Adı"
FROM product
ORDER BY RANDOM() --Rastgele sıralayacak, LIMIT 5 ile 5 kayıt getirecek
LIMIT 5;

-- 3.8. "test" veri tabanını kullanarak cars tablosunda yer alan price sütununu virgülden sonra 1 basamak olacak şekilde kesen sorguyu yazınız.
SELECT
	id AS "Araba ID",
	brand AS "Araba Markası",
	price AS "Araba Fiyatı",
	TRUNC(price, 1) AS "Küsuratsız Araba Fiyatı"
FROM cars;

-- 3.9. "test" veri tabanını kullanarak product tablosunda yer alan price sütununun karesini alan sorguyu yazınız.
SELECT
	price AS "Ücret",
	ROUND(SQRT(price), 2) AS "Net Ücretin Karekökü",
	ROUND(POW(price, 2),2) AS "Net Ücretin İki Katı"
FROM product
ORDER BY POW(price, 2) DESC;

-- 3.10. "test" veri tabanını kullanarak cars tablosunda yer alan price sütununun 400'ye göre modunu alan sorguyu yazınız.
SELECT
	id AS "Araba ID",
	brand AS "Araba Markası",
	price AS "Araba Fiyatı",
	MOD(price, 400) AS "Modlu Araba Fiyatı"
FROM cars;

-- 3.11. "test" veri tabanını kullanarak cars tablosunda yer alan price sütununu 1000'e bölüp 2 basamaklı yuvarlayan sorguyu yazınız.
SELECT
	id AS "Araba ID",
	brand AS "Araba Markası",
	price AS "Araba Fiyatı",
	TRUNC((price / 1000),2) AS "Bölünmüş Araba Fiyatı"
FROM cars;

-- 3.12. "test" veri tabanını kullanarak product_segment tablosunda discount değeri 0.08'den küçük olanların discount değerini aşağı yuvarlayan sorguyu yazınız.
SELECT
	discount AS "İndirim Oranı",
	FLOOR(discount) AS "Aşağıya Yuvarlanmış İndirim Oranı",
	CEIL(discount) AS "Yukarı Yuvarlanmış İndirim Oranı",
	ROUND(discount, 1) AS "Yuvarlanmış İndirim Oranı"
FROM product_segment
WHERE discount <=0.08;

-- 3.13. "test" veri tabanını kullanarak product tablosunda price sütununu aşağı yuvarlayıp ilk 7 kaydı getiren sorguyu yazınız.
SELECT
	price AS "Fiyat",
	FLOOR(price) AS "Aşağı Yuvarlanmış Fiyat",
	CEIL(price) AS "Yukarı Yuvarlanmış Fiyat",
	ROUND(price, 1) AS "Yuvarlanmış Fiyat"
FROM product
LIMIT 7;


-- 3.14. "test" veri tabanını kullanarak cars tablosunda discount değerinden 250 çıkartılmış olan negatif olan kayıtların mutlak değerini getiren sorguyu yazınız.
-- NOT: discount sütunu NULL olmayanlar üzerinden değerlendirin.
SELECT
	id AS "Araba ID",
	brand AS "Araba Marka",
	price AS "Araba Fiyat",
	discount AS "İndirim Oranı",
	ABS(discount - 250) AS "İndirilmiş Mutlak İndirim Değeri",
	TRUNC((price * (1 - (discount / 10000)))) AS "Net Fiyat"
FROM cars
WHERE discount IS NOT NULL;


-- 3.15. "test" veri tabanında student tablosunu kullanarak name sütununun karakter boyutuna göre cinsiyeti male olanların mark değerini 0.02 ile çarpıp yuvarlayan sorguyu yazınız.
SELECT
	name AS "İsim",
	LENGTH(name) AS "İsim Karakteri"
FROM student
WHERE gender='male'
ORDER BY name;


-------------------------------------------------------------------------------------------------------
-- 4. Date Functions (Tarih Fonksiyonları):

/*
En Çok Kullanılan Tarih Fonksiyonları:
	- current_date: Güncel zamanı yıl, ay, gün olarak döndürür.
	- current_time: Güncel zamanı yıl, ay, güni saat, dakika, saniye formatında döndürür.
	- now(): Şimdiki zamanı döndürür.
	- date_part('century', 'bulunmak_istenen_zaman'): Verilen zaman içerisinde verilen parametreyi döndürür.
	- extract('ilgilenilen_kisim' FROM 'ilgilenilen_tarih')
	-- date_trunc('ilgilenilen_kisim', 'ilgilenilen_tarih')
	-- 'ilgilenilen_kisim' ise bir argümandır. Bunlar ise, 'century', 'quarter', 'year', 'month', 'day', 'hour', 'minute', 'dow', 'doy', 'timezone' olabilir.

-- Extra Notlar - 1:
	- Aynı işi yapan farklı fonksiyonlar bulunmaktadır.
	- Bazı fonksiyonları ekstradan yazarlar, ORACLE’da DATEPART yoktur, EXTRACT vardır.
	- Veri tabanı uyumluluklarını sağlamaktadırlar.
	- DATE_TRUNC, bir truncate işlemi yapılır. Belirtilen tarihin quarter’ını bulur ve başlangıç tarihini verir.

-- Extra Notlar - 2:
	-- Tarih ve Saat formatları ile çalışırken Tarih ve Saat Formatlarını iyi bilmek gerekmektedir.
	-- YYYY | YYY | YY 
	-- MONTH | Month | month vb. her biri farklı sonuç getirmektedir.
*/

-- 4.1. Yukarıda belirtilen tarih parametrelerini bugünün tarihi üzerinden gösteriniz.

SELECT
    CURRENT_DATE AS "Şimdiki Tarih",
    CURRENT_TIME AS "Şimdiki Zaman",
    LOCALTIME AS "Yerel Zaman",
    NOW() AS "Şimdiki Zaman",
    DATE_PART('CENTURY', CURRENT_DATE) AS century_, -- yüzyıl
    DATE_PART('QUARTER', CURRENT_DATE) AS quarter_, -- çeyreklik
    DATE_PART('YEAR', CURRENT_DATE) AS year_, -- yıl
    DATE_PART('MONTH', CURRENT_DATE) AS month_, -- ay
    DATE_PART('DAY', CURRENT_DATE) AS day_, -- gün
	
    -- Burada dikkat edilmesi gerekmektedir. 
	DATE_PART('HOUR', CURRENT_DATE) AS hour_, -- saat
	DATE_PART('HOUR', CURRENT_TIME) AS hour_,
    
	DATE_PART('MINUTE', CURRENT_DATE ) AS minute_, -- dakika
	DATE_PART('MINUTE', CURRENT_TIME) AS minute_,
    DATE_PART('DOW', CURRENT_DATE) AS dow_, -- day of week
    DATE_PART('DOY', CURRENT_DATE) AS doy_, -- day of year
    DATE_PART('TIMEZONE', CURRENT_TIME) AS timezone_;

-- 4.2. Yukarıda yapılan işlemleri Extract fonksiyonlarını kullanarak gerçekleştiriniz.
SELECT
	EXTRACT(CENTURY FROM CURRENT_DATE) AS "Extract ile Yüzyıl Bilgisi",
	EXTRACT(QUARTER FROM CURRENT_DATE) AS "Extract ile Çeyrek Bilgisi",
	EXTRACT(YEAR FROM CURRENT_DATE) AS "Extract ile Yıl Bilgisi",
	EXTRACT(MONTH FROM CURRENT_DATE) AS "Extract ile Ay Bilgisi",
	EXTRACT(DAY FROM CURRENT_DATE) AS "Extract ile Gün Bilgisi",
	EXTRACT(HOUR FROM CURRENT_TIME) AS "Extract ile Saat Bilgisi",
	EXTRACT(MINUTE FROM CURRENT_TIME) AS "Extract ile Dakika Bilgisi",
	EXTRACT(SECOND FROM CURRENT_TIME) AS "Extract ile Saniye Bilgisi";


-- 4.3. "30-05-2026 20:39:45" Zaman Damgasını kullanarak ilgili DATE_TRUNC işlemlerini gerçekleştiriniz.
SELECT
    DATE_TRUNC('CENTURY', TIMESTAMP '2026-05-30 20:39:45') AS "DATE_TRUNC ile Yüzyıl Bilgisi",
	DATE_TRUNC('QUARTER', TIMESTAMP '2026-05-30 20:39:45')  AS "DATE_TRUNC ile Çeyrek Bilgisi",
	DATE_TRUNC('YEAR', TIMESTAMP '2026-05-30 20:39:45')  AS "DATE_TRUNC ile Yıl Bilgisi",
	DATE_TRUNC('MONTH', TIMESTAMP '2026-05-30 20:39:45')  AS "DATE_TRUNC ile Ay Bilgisi",
	DATE_TRUNC('DAY', TIMESTAMP '2026-05-30 20:39:45')  AS "DATE_TRUNC ile Gün Bilgisi",
	DATE_TRUNC('HOUR', TIMESTAMP '2026-05-30 20:39:45')  AS "DATE_TRUNC ile Saat Bilgisi",
	DATE_TRUNC('MINUTE', TIMESTAMP '2026-05-30 20:39:45')  AS "DATE_TRUNC ile Dakika Bilgisi",
	DATE_TRUNC('SECOND', TIMESTAMP '2026-05-30 20:39:45') AS "DATE_TRUNC ile Saniye Bilgisi"

-- 4.4. "test" veri tabanında bulunan courses tablosunda yer alan published_date sütununu kullanarak yıl bilgisini alan sorguyu yazınız.
SELECT
	course_id AS "Kurs ID",
	course_name AS "Kurs Adı",
	published_date AS "Yayım Tarihi",
	DATE_PART('YEAR', published_date) AS "Yayım Yılı"
FROM courses
WHERE published_date IS NOT NULL;


-- 4.5. "test" veri tabanında bulunan staff tablosunu kullanarak hire_date sütununu kullanarak ilgili ay bilgilerini getiren sorguyu yazınız. Yeteneklerin baş harfi S ile başlasın.
SELECT
	staff_id AS "Yetenek ID",
	first_name || ' ' || last_name AS "Yetenek Ad Soyad",
	EXTRACT(MONTH FROM hire_date) AS "İş Başlangıç Ay Bilgisi",
	DATE_TRUNC('QUARTER', hire_date) AS "İş Başlangıç Çeyrek Bilgisi"
FROM staff
WHERE first_name LIKE 'S%';
--LIMIT 5;

-- 4.6. "test" veri tabanında bulunan staff tablosunu kullanarak departure_date sütununu kullanarak ilgili ay bilgilerini getiren sorguyu yazınız. 
SELECT 
	staff_id AS "Yetenek ID",
	first_name || ' ' || last_name AS "Yetenek İsim Soyisim",
	departure_date AS "Ayrılış Tarihi",
	DATE_PART('YEAR', departure_date) AS "Ayrılış Yılı",
	EXTRACT(MONTH FROM departure_date) AS "Ayrılış Ayı",
	DATE_TRUNC('DAY', departure_date) AS "Ayrılış Günü"
FROM staff;

-- 4.7. '30.05.2026' tarihini kullanarak ilgili tarih formatlarını gözlemleyen sorguyu yazınız.
SELECT
	TO_DATE('30.05.2026', 'DD.MM.YYYY') AS "Gün.Ay.Yıl Format Örneği",
	TO_DATE('24/03/17', 'YY/MM/DD') AS "Yıl/Ay/Gün Format Örneği",
	TO_DATE('2026-Apr-30', 'YYYY-Mon-DD') AS "Yıl-Ay-Gün Format Örneği",
	TO_DATE('2026 APRIL 28', 'YYYY MONTH DD') AS "Yıl Ay Gün Format Örneği",
	TO_DATE('2026 april 28', 'YYYY month DD') AS "Yıl Ay Gün Format Örneği Farkı",
	TO_DATE('2026 174', 'YYYY DDD') AS "Yıl Yılın Kaçıncı Günü Formatı Örneği",
	TO_DATE('January 17,2026', 'Month DD, YYYY') AS "Ay Gün, Yıl Formatı Örneği";
	

-- 4.8. '03.05.1979 09:41:51' timestamp ifadesinin formatlarını test ederek sorgulayınız.
SELECT
    TO_TIMESTAMP('03.05.1979 09:41:51', 'DD.MM.YYYY HH:MI:SS') AS "Gün.Ay.Yıl Saat:Dakika:Saniye Örneği",
	TO_TIMESTAMP('03.05.1979 21:41:51', 'DD.MM.YYYY HH24:MI:SS') AS "Gün.Ay.Yıl 24lüSaat:Dakika:Saniye",
	TO_TIMESTAMP('1964/11/18 20:10:42', 'YYYY/MM/DD HH24:MI:SS') AS "Yıl/Ay/Gün 24lüSaat:Dakika:Saniye",
	TO_TIMESTAMP('31 12 97 05:12:07', 'DD MM YY HH:MI:SS') AS "Gün Ay Yıl Saat:Dakika:Saniye",
	TO_TIMESTAMP('14 SEP 1999 02:47:56', 'DD MON YYYY HH:MI:SS') AS "Gün AyIsmi Yıl Saat:Dakika:Saniye";

-- 4.9. "test" veri tabanında staff tablosunu kullanarak departured_date ile hire_date farkını formatlayan sorguyu yazınız.
SELECT 
	staff_id AS "Yetenek ID",
	first_name || ' ' || last_name AS "Yetenek İsim Soyisim",
	hire_date AS "İşe Giriş Tarihi",
	departure_date AS "Ayrılış Tarihi",
	EXTRACT(DOY FROM hire_date) AS "Başlama Tarihi Yılın Gün Sayısı",
	EXTRACT(DOY FROM departure_date) AS "Ayrılış Tarihi Yılın Gün Sayısı",
	(departure_date - hire_date) AS "Çalışma Gün Tarihi"
FROM staff;


-- 4.10. "test" veri tabanında staff tablosunu kullanarak departured_date ile hire_date YIL farkını formatlayan sorguyu yazınız.
SELECT 
	staff_id AS "Yetenek ID",
	first_name || ' ' || last_name AS "Yetenek İsim Soyisim",
	hire_date AS "İşe Giriş Tarihi",
	departure_date AS "Ayrılış Tarihi",
	EXTRACT(YEAR FROM hire_date) AS "Başlama Tarihi Yılın Gün Sayısı",
	EXTRACT(YEAR FROM departure_date) AS "Ayrılış Tarihi Yılın Gün Sayısı",
	DATE_PART('YEAR',departure_date) - DATE_PART('YEAR',hire_date) AS "Çalışma Yılı"
FROM staff;


----------------------------------------------------------------------------------------------------
-- 5. Conversion Functions (Dönüşüm Fonksiyonları):

/*
Dönüşüm Fonksiyonları, veri tipleri arasında gerekli olabilecek veri tipi dönüşümlerini
gerçekleştirmekte kullanılmaktadır.

En Çok Tercih Edilenler:
	- TO_DATE(): Tarih formatına dönüşüm gerçekleştiren fonksiyondur.
	- TO_TIMESTAMP(): Zaman damgası formatına dönüşüm gerçekleştiren fonksiyondur.
	- TO_NUMBER(): Sayısal formata dönüşüm gerçekleştiren fonksiyondur.
	- TO_CHAR(): Karakter dizisi veri tipine dönüştüren fonksiyondur.
	
	- 'donusturulecek_ifade'::donusturulecek_tip
		-- Örnek: '12450'::integer;
	
	- CAST() Fonksiyonu: Bir diğer veri dönüştürme fonksiyonudur.
		-- Örnek: CAST('14269' AS integer);

Önemli Not:
	- Tip dönüşümlerini gerçekleştireceğimiz veri tiplerinin birbiriyle uyumlu olması gerekmektedir.

*/

-- 5.1. "test" veri tabanını kullanarak budgets tablosunda yer alan current_year sütununu ,binlik ayıracı ve .ondalık ayıracı formatıyla yazdıran sorguyu yazınız.
SELECT
	salesman_id AS "Satış Yetenek ID",
	current_year AS "Bu Yıl ki Satış Adedi",
	TO_CHAR(current_year, '999,999.99') AS "Formatlı Satış Adedi"
FROM budgets
WHERE current_year IS NOT NULL;


-- 5.2. "test" veri tabanında yer alan cars tablosundaki price sütununu formatlayan sorguyu yazınız.
SELECT
	id AS "Araba ID",
	brand AS "Araba Markası",
	price AS "Araba Fiyatı",
	TO_CHAR(price, '9G999G999D99') AS "Formatlanmış Fiyat"
FROM cars;

-- 5.3. "test" veri tabanında yer alan product price sütununu formatlayan sorguyu yazınız. Formatı siz belirleyiniz.
SELECT
	id AS "Ürün ID",
	name AS "Ürün Adı",
	price AS "Ürün Fiyatı",
	TO_CHAR(price, '999,999D99') AS "Formatlı Ürün Fiyatı 1",
	TO_CHAR(price, '999D') || ' ₺' AS "Net TL Fiyatı"
FROM product
WHERE segment_id = 1
ORDER BY price;

-- 5.4. "test" veri tabanında product_segment tablosunda yer alan discount oranını formatlayan sorguyu yazınız. Format: %6 gibi olacaktır.
SELECT
	id AS "Ürün ID",
	segment AS "Ürün Segmenti",
	discount AS "İndirim Oranı",
	'%' || TO_CHAR(discount * 100,'99') AS "Yüzdelik İndirim Oranı"
	--'%' || TO_CHAR(discount * 100, 'FM999D99') AS "Yüzdelik İndirim Oranı"
FROM product_segment;

-- 5.5. "test" veri tabanında budgets tablosunu kullanarak previous_year sütununu formatlayan sorguyu yazınız.
SELECT
	salesman_id AS "Yetenek ID",
	previous_year AS "Geçen ki Satış Miktarı",
	TO_CHAR(previous_year, 'FM999G999D') AS "Geçen Yıl ki Formatlı Satış Miktarı"
FROM budgets;

-- 5.6. "test" veri tabanında yer alan cars tablosundaki price sütununu stringe çeviren sorguyu yazınız.
SELECT
	id AS "Araba ID",
	brand AS "Araba Markası",
	price AS "Fiyat (Integer)",
	CAST(price AS VARCHAR) AS "Fiyat(String)",
	(price + 100) AS "Zamlı Fiyat (Integer)",
	-- (price::VARCHAR) + 100) AS "Zamlı Fiyat (String)" --Tip uyuşmazlığından toplama gerçekleştirmez
FROM cars;

-- 5.7. "test" veri tabanında bulunan student tablosunda mark ve class sütunlarını stringe çeviren sorguyu yazınız.
SELECT
	id AS "Öğrenci ID",
	name AS "Öğrenci İsim",
	class::VARCHAR AS "Öğrenci Sınıfı",
	mark::VARCHAR AS "Öğrenci Notu"
FROM student;


-- 5.8. "test" veri tabanında yer alan staff tablosunda departure_date sütununu varchar'e çeviren sorguyu yazınız.
SELECT
	staff_id AS "Yetenek ID",
	first_name || ' ' || last_name AS "Yetenek Adı Soyadı",
	departure_date AS "Ayrılış Tarihi (DATE)",
	CAST(departure_date AS VARCHAR) AS "Ayrılış Tarihi (Date)",
	DATE_PART('YEAR',departure_date) AS "Ayrılış Yılı",
	DATE_PART('Month', departure_date) AS "Ayrılış Ayı",
	EXTRACT(DAY FROM departure_date) AS "Ayrılış Günü",
	TO_CHAR(departure_date, 'DD.MM.YYYY') "Ayrlış Tarihi Gün.Ay.Yıl Formatlı"
FROM staff;

-- 5.9. "test" veri tabanından yer alan date_demo tablosunda yer alan date_value_str sütununu date'e çeviren sorguyu yazınız. ID değeri 1 için olan formatı bulunuz.
SELECT
	value_id AS "Tarih ID",
	date_value_str AS "Tarih Bilgisi (String)",
	TO_DATE(date_value_str, 'YYYYMMDD') AS "Tarih Bilgisi (Date)"
FROM date_demo
WHERE value_id = 1;

-- 5.10. "test" veri tabanında yer alan date_demo tablosunda ID değeri 4 olan kayıdın formatını düzenleyiniz.
SELECT
	value_id AS "Tarih ID",
	date_value_str AS "Orijinal Tarih",
	TO_DATE(date_value_str, 'YYYY Mon DD') AS "Formatlı Tarih"
FROM date_demo
WHERE value_id = 4;


----------------------------------------------------------------------------------------------------
-- 6. Conditional Functions (Şartlı Fonksiyonlar):

/*
Verilen bir şarta göre işlemlerimizi gerçekleştiren fonksiyonlardır.
En çok tercih edilenleri:
	- COALESCE: İlk NULL olmayan değeri döndüren fonksiyondur.
		Öncelik belirlerken de önemli olabilmektedir. Örneğin, TC_Kimlik_No, Telefon_No, Kullanici_Adi vb. 
		sütunlarından ilk getirilmesi gerekeni belirlememize imkan verir.
	
	- NULLIF: Verilen iki ifadenin eşit olup olmamasına göre karşılaştırma yapmamıza olanak tanıyan fonksiyondur.
		Eğer iki değer birbiriyle eşitse NULL; değilse ilk verilen ifadeyi döndürür.
		
	- CASE: Diğer programlama dillerinde yer alan if, else, else if veya elif gibi belirli bir şarta göre 
	işlemlerlimizi gerçekleştirebilmemize olanak veren ifadedir.
    	SELECT, WHERE, GROUP BY, HAVING gibi sorgunun her bölümünde kullanılabilir.
    	CASE ifadesinin iki biçimi vardır: Genel (General) ve Basit (Simple)

*/
-- 6.1. "test" veri tabanında yer alan student tablosundaki mark sütununu harf notuna (A, B, C, F) çeviren sorguyu yazınız.
SELECT
	id AS "Öğrenci ID",
	name AS "Öğrenci Adı",
	class AS "Öğrenci Sınıfı",
	mark AS "Öğrenci Notu",
	CASE
		WHEN mark BETWEEN 88 AND 100 THEN 'AA'
		WHEN mark BETWEEN 81 AND 87 THEN 'BA'
		WHEN mark BETWEEN 74 AND 80 THEN 'BB'
		WHEN mark BETWEEN 67 AND 73 THEN 'CB'
		WHEN mark BETWEEN 60 AND 66 THEN 'CC'
		WHEN mark BETWEEN 53 AND 59 THEN 'DC'
		WHEN mark BETWEEN 46 AND 52 THEN 'DD'
		WHEN mark BETWEEN 39 AND 45 THEN 'FD'
		WHEN mark BETWEEN 0 AND 38 THEN 'FF'
		ELSE 'Geçersiz Not'
	END AS "Harf Notu Karşılığı"
FROM student;


-- 6.2. "test" veri tabanında yer alan cars tablosundaki price sütununa göre araçları 'Lüks', 'Orta', 'Ekonomik' olarak segmentlere ayıran sorguyu yazınız. 
SELECT
	id AS "Araba ID",
	brand AS "Araba Markası",
	price AS "Araba Fiyatı",
	CASE 
		WHEN price >= 150000 THEN 'Lüks Segment'
		WHEN price BETWEEN 75000 AND 149999 THEN 'Orta Segment'
		WHEN price BETWEEN 0 AND 74999 THEN 'Ekonomik Segment'
		ELSE 'Segment Tespit Edilemedi'
	END AS "Araba Segmenti"
FROM cars
ORDER BY price DESC;



-- 6.3. "test" veri tabanındaki staff tablosunda departure_date sütununa bakarak personelin 'Aktif' veya 'Ayrıldı' durumunu listeleyen sorguyu yazınız. (CASE Örneği)
SELECT
	staff_id AS "Yetenek ID",
	first_name || ' ' || last_name AS "Yetenek Adı Soyadı",
	departure_date AS "Ayrılık Tarihi",
	CASE
		WHEN DATE_PART('YEAR',departure_date) >= DATE_PART('YEAR',NOW()) THEN 'Aktif'
		ELSE 'Ayrılmış'
	END "Çalışma Durumu"
FROM staff;


-- 6.5. "test" veri tabanında yer alan product tablosundaki net_price sütunundaki NULL değerler yerine 'Güncel Fiyat Bekleniyor' yazdıran sorguyu yazınız.
SELECT
	id AS "Ürün ID",
	name AS "Ürün Adı",
	price AS "Ürün Fiyatı",
	net_price AS "Net Ürün Fiyatı",
	COALESCE(net_price, 0) AS "Maskelenmiş Fiyat",
	
	CASE net_price::VARCHAR
		WHEN NULL THEN 'Güncel Fiyat Bekleniyor'
		ELSE CAST((price * 1.30) AS VARCHAR)
	END AS "Güncel Fiyat Bilgisi"
	-- COALESCE(CAST((price * 1.30) AS VARCHAR), 'Güncel Fiyat Bekleniyor') AS "Güncel Fiyat Bilgisi"
FROM product;

-- 6.6. "test" veri tabanında yer alan student tablosundaki email sütunu NULL ise yerine 'E-posta Yok' yazdıran sorguyu yazınız. (COALESCE Örneği)
SELECT
	id AS "Öğrenci ID",
	name AS "Öğrenci Adı",
	class AS "Öğrenci Sınıfı",
	email AS "Öğrenci Mail",
	COALESCE(email, 'E-Postası Yok')
FROM student
WHERE gender <> 'male'
ORDER BY class;

-- 6.7. "test" veri tabanındaki product tablosunda net_price sütunu boşsa price sütununu, o da boşsa 0 alıp üzerine %18 KDV ekleyen sorguyu yazınız. (COALESCE Örneği)
SELECT
	id AS "Ürün ID",
	name AS "Ürün Adı",
	price AS "Fiyat",
	net_price AS "Net Fiyat",
	(COALESCE(net_price, price, 0) * 1.18) AS "Yeni Fiyat"
FROM product;

-- 6.8. "test" veri tabanında bulunan courses tablosunda description uzunluğu 50 karakterden uzun olanlara 'Uzun Açıklama', kısa olanlara 'Kısa Açıklama' yazan sorguyu yazınız.
SELECT
	course_id AS "Kurs ID",
	course_name AS "Kurs Adı",
	description AS "Kurs Açıklaması",
	COALESCE(description, 'Kurs Açıklaması Eklenecektir') AS "Kurs Ek Açıklaması",
	LENGTH(description) AS "Kurs Açıklama Uzunluğu",
	CASE 
		WHEN LENGTH(description) >=100 THEN 'Uzun Açıklama'
		WHEN LENGTH(description) BETWEEN 20 AND 99 THEN 'Orta Uzunlukta Açıklama'
		WHEN LENGTH(description) BETWEEN 0 AND 19 THEN 'Kısa Açıklama'
		ELSE 'Geçersiz Uzunluk'
	END AS "Kurs Açıklama Uzunluğu"
FROM courses
ORDER BY LENGTH(description) DESC;

-- 6.9. "test" veri tabanındaki budgets tablosunda current_year ve previous_year satış adetleri birbirine eşitse NULL, değilse current_year değerini döndüren sorguyu yazınız. (NULLIF Örneği)
SELECT
	salesman_id AS "Yetenek ID",
	current_year AS "Güncel Satış Miktarı",
	previous_year AS "Geçen Dönem ki Satış Miktarı",
	NULLIF(current_year, previous_year) AS "Satış Performansı",
	COALESCE(NULLIF(current_year, previous_year), 0) AS "Performans Başarısı" --İki değer birbirine eşitse 0 yazalım.
FROM budgets;

-- 6.10. "test" veri tabanındaki product tablosunda price sütunu NULL ise 0 yapan, fiyatı 500 ise NULL'a çeken ve çıkan sonuca göre 'Bedelsiz', 'Ucuz', 'Pahalı' diye listeleyen sorguyu yazınız. (COALESCE, NULLIF ve CASE Karışık Örneği)
SELECT
	id AS "Ürün ID",
	name AS "Ürün Adı",
	price AS "Ürün Fiyatı",
	COALESCE(price, 0) AS "Güncel Ürün Fiyatı",
	CASE 
		WHEN price = 500 THEN NULL -- 500 ise NULL yapalım.
		--WHEN price IS NULL THEN 0::VARCHAR
		WHEN price > 500 THEN 'Pahalı'
		WHEN price BETWEEN 251 AND 499 THEN 'Alınabilir'
		WHEN price BETWEEN 0 AND 250 THEN 'Ucuz'
		ELSE 'Bedelsiz'
	END "Ürün Fiyat Durumu"
FROM product;