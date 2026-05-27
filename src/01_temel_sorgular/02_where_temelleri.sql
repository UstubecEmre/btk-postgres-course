-- 1. WHERE Temelleri:
-- WHERE ifadesi, sorgularımızda belirli koşullara göre veri filtrelememizi sağlar.
-- SQL dilinin can alıcı noktalarından biridir. Performans ve verimlilik açısından da büyük önem taşır.


-- 1.1. "office" veri tabanında countries tablosunu kullanarak country_name 'China' olanları getiren sorguyu yazınız.
SELECT
    country_id AS "Ulke Numarası",
	country_name AS "Ülke İsmi"
FROM countries
WHERE country_name = 'China';

-- 1.2. "office" veri tabanında departments tablosunda bulunan location_id sütununun değeri 3 olanları getiren sorguyu yazınız.
SELECT
    department_id AS "Departman Numarası",
	department_name AS "Departmant Adı",
	location_id AS "Konum Numarası"
FROM departments
WHERE location_id = 3;


-- 1.3. "office" veri tabanında bulunan jobs tablosunda job_title 'Programmer' olarları getiren sorguyu yazınız.ABORT
SELECT
    job_id AS "Benzersiz İş Numarası",
    job_title AS "İş Başlığı"
FROM jobs
WHERE job_title = 'Programmer';

-- 1.4. "office" veri tabanında yer alan employees tablosunda first_name 'David' olanları getiren sorguyu yazınız.
SELECT
    employee_id AS "Benzersiz Çalışan Numarası",
    first_name AS "Çalışan Adı",
    last_name AS "Çalışan Soyadı"
FROM employees
WHERE first_name = 'David';

-- 1.5. "office" veri tabanında yer alan locations tablosunda country_id 'US' olanları getiren sorguyu yazınız.
SELECT 
    street_address AS "Sokak Adresi",
    postal_code AS "Posta Kodu",
    city AS "Şehir İsmi",
    country_id AS "Ülke Numarası"
FROM locations
WHERE country_id = 'US';



-------------------------------------------------------------------------------------------------------
-- 2. Karşılaştırma Operatörleri:
/*
    = : Eşittir.
	> : Büyüktür
	< : Küçüktür
	<>, != : Eşit değildir.
Bu operatörler WHERE ile sıklıkla kullanılan operatörlerdir.
Sorgunun performansını, verimliliğini etkilemektedir.

*/

-- 2.1. "office" veri tabanında yer alan locations tablosunu kullanarak city sütununda London olanları getiren sorguyu yazınız.
SELECT
    location_id AS "Benzersiz Lokasyon Numarası",
	postal_code AS "Posta Kodu",
	city AS "Şehir İsmi"
FROM locations
WHERE city = 'London';

-- 2.2. "office" veri tabanında yer alan employees tablosunu kullanarak first_name değeri John olanları getiren sorguyu yazınız.
SELECT
    employee_id AS "Benzersiz Çalışan Numarası",
	first_name AS "Çalışan Adı",
	last_name AS "Çalışan Soyadı"
FROM employees
WHERE first_name = 'John'
ORDER BY last_name DESC;

-- 2.3. "office" veri tabanında yer alan departments tablosunu kullanarak departmen_id değeri 5'ten büyük olanları getiren sorguyu yazınız.
SELECT
    department_id,
	department_name AS "Departman Adı"
FROM departments
WHERE department_id > 5;

-- 2.4. "office" veri tabanında yer alan regions tablosunu kullanarak region_id 3'ten küçük olanları getiren sorguyu yazınız.
SELECT
    region_id AS "Benzersiz Bölge Numarası",
	region_name AS "Bölge Adı"
FROM regions
WHERE region_id < 3;

-- 2.5. "office" veri tabanında yer alan jobs tablosunu kullanarak min_salary değeri 4000 ve üzeri olanları getiren sorguyu yazınız.
SELECT
    job_id AS "Benzersiz İş Numarası",
	job_title AS "İş Başlığı",
	min_salary "Minimum Maaş Değeri"
FROM jobs 
WHERE min_salary >= 4000;

-- 2.6. "office" veri tabanında yer alan dependents tablosunda relationship Child olmayanları getiren sorguyu yazınız.
SELECT
    dependent_id,
	first_name AS "İsim",
	last_name AS "Soyisim",
	relationship "İlişkisi"
FROM dependents
WHERE relationship <> 'Child';


-- 2.6. "office" veri tabanında yer alan dependents tablosunda dependent_id 4 dışındakileri getiren sorguyu yazınız.
SELECT
    dependent_id,
	first_name AS "İsim",
	last_name AS "Soyisim",
	relationship "İlişkisi"
FROM dependents
WHERE dependent_id <> 4
ORDER BY first_name;


-------------------------------------------------------------------------------------------------------

-- 3. Mantıksal Operatörler:
/*
    AND: Tüm şartlar TRUE ise sonuç TRUE olur.
	NOT: Şart sonucunu tersine döndürür.
	OR: Herhangi bir şart TRUE ise sonuç TRUE olur.

Not: 
Sorgularımızın kalitesini artıran bir yapıdır, BOOLEAN veri tipini öğrenmeniz açısından 
da oldukça önemlidir.

*/

-- 3.1. "office" veri tabanında yer alan employees tablosunda first_name Ismael ve last_name Sciarra olan personeli getiren sorguyu yazınız.
SELECT
    employee_id AS "Benzersiz Çalışan Numarası",
	first_name AS "Yetenek İsmi",
	last_name AS "Yetenek Soyismi"
FROM employees
WHERE first_name = 'Ismael' 
	AND last_name = 'Sciarra';


-- 3.2. "office" veri tabanında yer alan countries tablosunda country_id NL veya country_name China olan sorguyu yazınız.
SELECT
    country_id "Benzersiz Ülke Numarası",
	country_name AS "Ülke Adı"
FROM countries
WHERE country_id = 'NL'
	OR country_name = 'China';

-- 3.3. "office" veri tabanında yer alan departments tablosunda department_id 4 olmayan ve department_name IT olan sorguyu yazınız.
SELECT
    department_id AS "Benzersiz Departman Numarası",
	department_name AS "Departman Adı"
FROM departments
WHERE department_id != 4
	AND department_name = 'IT';

-- 3.4. "office" veri tabanında yer alan regions tablosunda region_id 2 olan veya region_name Europe olmayanları getiren sorguyu yazınız.
SELECT
	region_id AS "Benzersiz Bölge Numarası",
	region_name AS "Bölge Adı"
FROM regions
WHERE region_id = 2
	OR NOT region_name = 'Europe';
	-- OR region_name <> 'Europe';
	-- OR region_name != 'Europe'

-- 3.5. "office" veri tabanında yer alan employees tablosunda yer alan first_name'i John olmayan veya last_name'i Ernst olan sorguyu getiren sorguyu yazınız.
SELECT
	employee_id AS "Yetenek Benzersiz Numarası",
	first_name AS "İsim",
	last_name AS "Soyisim"
FROM employees
WHERE first_name <> 'John'
	OR last_name = 'Ernst';
	-- AND last_name = 'Ernst';

-------------------------------------------------------------------------------------------------------

-- 4. BETWEEN Operatörü:
-- BETWEEN operatörü belirli bir aralıkta bulunan değerleri filtrelemek için kullanılır.

-- 4.1. "office" veri tabanında yer alan employees tablosunda salary değeri 3000 ile 7000 arasında olanları getiren sorguyu yazınız.
SELECT
	employee_id AS "Çalışan ID",
	first_name || ' ' || last_name AS "Çalışan Adı - Soyadı",
	salary AS "Minimum Maaş Değeri"
FROM employees
WHERE salary BETWEEN 3000 AND 7000;

-- 4.2. "office" veri tabanında yer alan departments tablosunda department_id değeri 2 ile 8 arasında olanları getiren sorguyu yazınız.
SELECT
    department_id AS "Departman ID",
	department_name AS "Departman Adı"
FROM departments 
WHERE department_id BETWEEN 2 AND 8;


-- 4.3. "office" veri tabanında yer alan jobs tablosunda min_salary değeri 5000 ile 10000 arasında olanları getiren sorguyu yazınız.
SELECT
	job_id AS "İş ID",
	job_title AS "İş Başlığı",
	min_salary AS "Minimum Maaş"
FROM jobs
WHERE min_salary BETWEEN 5000 AND 10000;

-- 4.4. "office" veri tabanında yer alan locations tablosunda location_id değeri 2 ile 5 arasında olanları getiren sorguyu yazınız.
SELECT
	location_id AS "Lokasyon ID",
	street_address AS "Sokak Adresi",
	city AS "Şehir"
FROM locations
WHERE location_id BETWEEN 2 AND 5
ORDER BY city;

-- 4.5. "office" veri tabanında yer alan employees tablosunda employee_id değeri 7 ile 16 arasında olanları getiren sorguyu yazınız.
SELECT
	employee_id AS "Benzersiz Çalışan Kimlik Numarası",
	first_name || ' ' || last_name AS "İsim Soyisim",
	phone_number AS "Telefon Numarası"
FROM employees
WHERE employee_id BETWEEN 7 AND 16;
-------------------------------------------------------------------------------------------------------
-- 5. IN Operatörü:
-- IN operatörü birden fazla değeri tek seferde kontrol etmek için kullanılır.

-- 5.1. "office" veri tabanında yer alan countries tablosunda country_id değeri US, UK veya CN olanları getiren sorguyu yazınız.
SELECT 
	country_id AS "Benzersiz Ülke No",
	country_name AS "Ülke Adı"
FROM countries
WHERE country_id IN ('US','UK','CN');

-- 5.2. "office" veri tabanında yer alan departments tablosunda department_name değeri IT, Sales veya Marketing olanları getiren sorguyu yazınız.
SELECT 
    department_id AS "Benzersiz Departman Numarası",
	department_name AS "Departman Adı"
FROM departments
WHERE department_name IN ('IT', 'Sales', 'Marketing');

-- 5.3. "office" veri tabanında yer alan employees tablosunda first_name değeri David, John veya Alexander olanları getiren sorguyu yazınız.
SELECT
	employee_id AS "Çalışan ID",
	first_name || ' ' || last_name AS "İsim Soyisim"
FROM employees
WHERE first_name IN ('David', 'John', 'Alexander');

-- 5.4. "office" veri tabanında yer alan jobs tablosunda job_title değeri Programmer, Manager veya Analyst olanları getiren sorguyu yazınız.
SELECT
	job_id AS "İş ID",
	job_title AS "İş Başlığı"
FROM jobs
WHERE job_title IN ('Programmer', 'Manager', 'Analyst');

-- 5.5. "office" veri tabanında yer alan regions tablosunda region_id değeri 1, 3 ve 4 olanları getiren sorguyu yazınız.
SELECT
	region_id AS "Bölge ID",
	region_name AS "Bölge Adı"
FROM regions
WHERE region_id IN (1, 3, 4);

-------------------------------------------------------------------------------------------------------
-- 6. LIKE Operatörü:
-- LIKE operatörü belirli bir desene(pattern) göre filtreleme yapmamızı sağlar.

-- 6.1. "office" veri tabanında yer alan employees tablosunda first_name değeri A harfi ile başlayanları getiren sorguyu yazınız.
SELECT
	employee_id,
	first_name AS "İsim",
	last_name AS "Soyisim" 
FROM employees
WHERE first_name LIKE 'A%';

-- 6.2. "office" veri tabanında yer alan countries tablosunda country_name değeri a harfi ile bitenleri getiren sorguyu yazınız.
SELECT
	country_id AS "Ülke ID",
	country_name AS "Ülke Adı" 
FROM countries
WHERE country_name LIKE '%a';

-- 6.3. "office" veri tabanında yer alan locations tablosunda city içerisinde 'on' geçen şehirleri getiren sorguyu yazınız.
SELECT
	location_id AS "Konum ID", 
	street_address AS "Adres",
	city AS "Şehir Adı"
FROM locations
WHERE city LIKE '%on%';

-- 6.4. "office" veri tabanında yer alan jobs tablosunda job_title değeri içerisinde 'Manager' geçenleri getiren sorguyu yazınız.
SELECT
	job_id AS "İş ID",
	job_title AS "İş Başlığı"
FROM jobs
WHERE job_title LIKE '%Manager%';

-- 6.5. "office" veri tabanında yer alan employees tablosunda last_name değeri 5 harfli olanları getiren sorguyu yazınız.
SELECT
	employee_id AS "Yetenek ID",
	first_name AS "Ad",
	last_name AS "Soyad"
FROM employees
WHERE last_name LIKE '_____';


-------------------------------------------------------------------------------------------------------
-- 7. ILIKE Operatörü:
-- ILIKE operatörü büyük-küçük harf duyarsız arama yapmamızı sağlar. (PostgreSQL özelidir.)

-- 7.1. "office" veri tabanında yer alan employees tablosunda first_name değeri 'david' olanları büyük-küçük harf duyarsız şekilde getiren sorguyu yazınız.
SELECT
    employee_id,
	first_name || ' ' || last_name AS "İsim Soyisim"
FROM employees
WHERE first_name ILIKE 'david';

-- 7.2. "office" veri tabanında yer alan countries tablosunda country_name değeri içerisinde 'uni' geçenleri büyük-küçük harf duyarsız şekilde getiren sorguyu yazınız.
SELECT
	country_id AS "Benzersiz Ülke Numarası",
	country_name AS "Ülke Adı"
FROM countries
WHERE country_name ILIKE '%uni%';
-- WHERE country_name ILIKE '%UNi%';

-- 7.3. "office" veri tabanında yer alan jobs tablosunda job_title değeri 'manager' içerenleri büyük-küçük harf duyarsız şekilde getiren sorguyu yazınız.
SELECT
    job_id "Benzersiz İş Numarası",
	job_title AS "İş Başlığı"
FROM jobs
WHERE job_title ILIKE '%Manager%';
--WHERE job_title ILIKE '%maNAgER%';

-- 7.4. "office" veri tabanında yer alan locations tablosunda city değeri 'lon' ile başlayanları büyük-küçük harf duyarsız şekilde getiren sorguyu yazınız.
SELECT
    location_id AS "Benzersiz Konum No",
	postal_code AS "Posta Kodu",
	city AS "Şehir"
FROM locations
WHERE city ILIKE 'lon%';
--WHERE city ILIKE 'loN%';

-- 7.5. "office" veri tabanında yer alan employees tablosunda last_name değeri içerisinde 'er' geçenleri büyük-küçük harf duyarsız şekilde getiren sorguyu yazınız.

SELECT
    employee_id AS "Benzersiz Çalışan Kimliği",
	first_name AS "İsim",
	last_name AS "Soyisim"
FROM employees
WHERE last_name ILIKE '%er%';
-- WHERE last_name ILIKE '%ER%';

-------------------------------------------------------------------------------------------------------
-- 8. NOT Operatörü:
-- NOT operatörü koşul sonucunu tersine çevirmek için kullanılır.

-- 8.1. "office" veri tabanında yer alan countries tablosunda country_name değeri China olmayanları getiren sorguyu yazınız.
SELECT
    country_id AS "Benzersiz Ülke ID",
	country_name AS "Ülke Adı"
FROM countries
WHERE country_name NOT LIKE 'China';

-- 8.2. "office" veri tabanında yer alan employees tablosunda first_name değeri John olmayanları getiren sorguyu yazınız.
SELECT
    employee_id AS "Benzersiz Çalışan Kimliği",
	first_name || ' ' || last_name AS "İsim Soyisim"
FROM employees
WHERE first_name NOT LIKE 'John';

-- 8.3. "office" veri tabanında yer alan jobs tablosunda min_salary değeri 5000’den küçük olmayanları getiren sorguyu yazınız.
SELECT
    job_id AS "Benzersiz İş Kimliği",
	job_title AS "İş Tanımı",
	min_salary AS "Minimum Maaş"
FROM jobs
WHERE NOT min_salary < 5000;

-- 8.4. "office" veri tabanında yer alan departments tablosunda department_id değeri 3 ve 5 olmayanları getiren sorguyu yazınız.
SELECT
    department_id AS "Benzersiz Departman Numarası",
	department_name AS "Departman Adı"
FROM departments
WHERE department_id NOT IN (3, 5);

-- 8.5. "office" veri tabanında yer alan regions tablosunda region_name değeri Europe olmayanları getiren sorguyu yazınız.
SELECT
    region_id AS "Benzersiz Bölge Numarası",
	region_name "Bölge Adı"
FROM regions
WHERE NOT region_name = 'EUROPE';


-------------------------------------------------------------------------------------------------------
-- 9. NULL Değeri:
-- NULL değeri bilinmeyen veya boş veri anlamına gelir.
-- IS NULL: NULL değerleri getirmeye imkan sağlayan ifadedir.
-- IS NOT NULL: NULL olmayan değerleri getirmeye yarayan ifadedir.

-- 9.1. "office" veri tabanında yer alan employees tablosunda manager_id değeri NULL olanları getiren sorguyu yazınız.
SELECT
    employee_id AS "Benzersiz Çalışan No",
	first_name || ' ' || last_name AS "İsim Soyisim",
	manager_id AS "Yönetici ID"
FROM employees
WHERE manager_id IS NULL;

-- 9.2. "office" veri tabanında yer alan locations tablosunda postal_code değeri NULL olmayanları getiren sorguyu yazınız.
SELECT 
    location_id AS "Konum Numarası",
	street_address AS "Adres",
	city AS "Şehir",
	postal_code AS "Posta Kodu"
FROM locations 
WHERE postal_code IS NOT NULL;

-- 9.3. "office" veri tabanında yer alan jobs tablosunda job_title değeri NULL olanları getiren sorguyu yazınız.
SELECT
    job_id AS "Benzersiz İş No",
	job_title AS "Departman Adı",
	max_salary AS "Maksimum Maaş"
FROM jobs
WHERE job_title IS NULL;


-- 9.4. "office" veri tabanında yer alan dependents tablosunda relationship değeri NULL olmayanları getiren sorguyu yazınız.
SELECT
    dependent_id,
	first_name AS "İsim",
	relationship AS "İlişkisi"
FROM dependents
WHERE relationship IS NOT NULL;


-- 9.5. "office" veri tabanında yer alan regions tablosunda region_name değeri NULL olanları getiren sorguyu yazınız.
SELECT
    region_id AS "Benzersiz Bölge Numarası",
	region_name AS "Bölge Adı"
FROM regions
WHERE region_name IS NULL;
-- WHERE region_name IS NOT NULL;
-------------------------------------------------------------------------------------------------------
-- 10. LIMIT Kullanımı:
-- LIMIT belirli sayıda kayıt getirmek için kullanılır.
-- Bazı satırların atlanmasını istiyorsanız OFFSET kullanılır.

-- 10.1. "office" veri tabanında yer alan employees tablosundan ilk 5 kaydı getiren sorguyu yazınız.
SELECT
    employee_id AS "Benzersiz Çalışan Kimliği",
	first_name || ' ' || last_name AS "İsim Soyisim"
FROM employees
LIMIT 5;

-- 10.2. "office" veri tabanında yer alan countries tablosundan, country_name sütununa göre sıralanmış ilk 3 kaydı getiren sorguyu yazınız.
SELECT
    country_id AS "Ülke ID",
	country_name AS "Ülke Adı" 
FROM countries
ORDER BY country_name
LIMIT 3;

-- 10.3. "office" veri tabanında yer alan jobs tablosundan max_salary değeri en yüksek olan ilk 4 kaydı getiren sorguyu yazınız.
SELECT
    job_id AS "Benzersiz İş No",
	job_title AS "İş Başlığı",
	max_salary AS "Maksimum Maaş"
FROM jobs
ORDER BY max_salary DESC
LIMIT 4;

-- 10.4. "office" veri tabanında yer alan departments tablosundan department_id değeri en küçük olan ilk 2 kaydı getiren sorguyu yazınız.
SELECT
    department_id AS "Departman No",
	department_name AS "Departman İsmi"
FROM departments
LIMIT 2;


-- 10.5. "office" veri tabanında yer alan locations tablosundan city adına göre sıralı şekilde ilk 6 kaydı getiren sorguyu yazınız.
SELECT
    location_id AS "Konum ID",
	city AS "Şehir Adı"
FROM locations
ORDER BY city
LIMIT 6;

-- 10.6. "office" veri tabanında yer alan dependents tablosunda dependent_id numarasını 5'ten başlayıp 7 kayıt getiren sorguyu yazınız.
SELECT
    dependent_id,
	first_name || ' ' || last_name AS "İsim Soyisim"
FROM dependents
LIMIT 7 OFFSET 5;