-- 1. SET Operators (Set Operatörleri):
/*
Bir önceki bölümümüzde tabloları nasıl birleştireceğimizi (JOIN ile) görmüştük.
Şimdi de sorgularımızı nasıl birleştireceğimizi göreceğiz.

-- 1.1. SET Operatörleri:
	- UNION: Sorguları birleştirirken, aynı sorgu sonucuna sahip kayıtları tekilleştiren, diğer operatörlere nispeten
	arka planda tekrar eden kayıtları tekilleştirdiğinden yani DISTINCT işlemi gibi çalıştığından kaynaklı daha yavaş çalışan birleştirme operatörüdür.
	
	- UNION ALL: Sorguları birleştiren, birleştirme işlemi sırasında tekilleştirme işlemi yapmayan, bu nedenle de
	UNION operatörüne göre daha hızlı çalışan birleştirme operatörüdür.
	Her iki sorgumuzda da tekrar etme olasılığı olmayan kayıtlar olduğuna eminsek kesinlikle ve kesinlikle UNION ALL kullanmamız tavsiye edilir. 
	
	- INTERSECT: Her iki sorgumuzda da kesişenleri getiren birleştirme operatörüdür.
	Küme işlemlerindeki kesişim olarak düşünebilirsiniz.
	
	- EXCEPT: EXCEPT operatörünün üstünde yer alan sorgunun tamamından, EXCEPT'ten
	sonra gelen sorguyu çıkaran operatördür. Kümelerdeki fark olarak düşünülebilir.
	
-- Önemli Notlar:
	- Bu operatörler, birlikte de kullanılabilirler.
	- Birden fazla farklı set operatörü kullanılacaksa parantez () içerisinde sorguları yazmamız iyi olacaktır.
	- UNION, UNION ALL, INTERSECT operatörlerinde sorguların sırası önemli değilken; EXCEPT ifadesinde sorguların sırası önemlidir.
	Aksi takdirde farklı bir sorgu sonucu ile karşılaşabiliriz.

-- Dikkat Edilmesi Gerekenler:
Bu operatörleri kullanırken dikkat edilmesi gereken iki kural yer almaktadır.

1.) Sorgularda kullanılan sütunların karşılıklı eşleşmeleri söz konusudur. Bu nedenle karşılıklı sütunların veri tiplerinin
aynı türde olması gerekmektedir. Aksi takdirde hata verecektir. (Data Types)

2.) Sorgularda kullanılan sütun sayıları da eşit olmalıdır, farklı olursa yeniden hata verecektir.

*/

---------------------------------------------------------------------------------------------------------------------------------------
-- 2. Birleştirme Operatörleri Örnekleri:
-- 2.1. "office" veri tabanındaki tüm çalışanların (employees) ve tüm bağımlıların (dependents) ad ve soyadlarını tek bir benzersiz liste olarak getiren sorguyu yazınız. 
SELECT
	e.first_name || ' ' || e.last_name AS "Yetenek Adı Soyadı"
FROM employees AS e
UNION
SELECT 
	d.first_name || ' ' || d.last_name AS "Bağımlı Yetenek Adı Soyadı"
FROM dependents AS d
ORDER BY "Yetenek Adı Soyadı"; -- alias'a göre verebiliriz, aksi halde çalışmaz.
--ORDER BY 1;

--Görüleceği üzere ilk yazılan tablonun sütun adlarını alır. Eşleşen kayıtları teke indirir

-- 2.2. "office" veri tabanındaki tüm çalışanların ve bağımlıların ad ve soyadlarını, mükerrer (tekrar eden) kayıtları ayıklamadan, tüm satırlarıyla birlikte listeleyen sorguyu yazınız. 
SELECT
	-- e.employee_id AS "Yetenek ID",
	e.first_name || ' ' || e.last_name AS "Yetenek Adı Soyadı"
FROM employees AS e
UNION ALL 
SELECT
	-- d.dependent_id,
	d.first_name || ' ' || d.last_name 
FROM dependents AS d
ORDER BY "Yetenek Adı Soyadı"; --"Yetenek ID";

-- 2.3. Hem çalışanlar (employees) tablosunda hem de bağımlılar (dependents) tablosunda ortak olarak bulunan ilk isimleri (first_name) listeleyen sorguyu yazınız. 
SELECT
	e.first_name AS "Yetenek Adı"
FROM employees AS e 
INTERSECT
SELECT
	d.first_name
FROM dependents AS d
ORDER BY "Yetenek Adı";

-- 2.4. Çalışanlar (employees) tablosundaki tüm benzersiz employee_id değerlerinden, bağımlısı (dependents) olan çalışanların employee_id değerlerini çıkartarak, hiç bağımlısı olmayan çalışanları bulan sorguyu yazınız. 
SELECT
	e.employee_id AS "Yetenek ID"
FROM employees AS e
EXCEPT 
SELECT
	d.employee_id
FROM dependents AS d
ORDER BY "Yetenek ID" 

-- 2.5. Ülke adı (country_name) 'A' veya 'M' harfi ile başlayan ülkelerin isimleri ile bölge adı (region_name) 'A' veya 'M' harfi ile başlayan bölgelerin isimlerini tek bir benzersiz listede birleştiren sorguyu yazınız. 
SELECT
	c.country_name AS "Ülke Adı"
FROM countries AS c
WHERE 
	c.country_name LIKE 'A%'
	OR c.country_name LIKE 'M%'
UNION
SELECT
	r.region_name AS "Bölge Adı"
FROM regions AS r
WHERE 
	r.region_name LIKE 'A%'
	OR r.region_name LIKE 'M%'
ORDER BY "Ülke Adı";

-- 2.6. İş unvanı (job_title) içinde 'Manager' veya 'Clerk' ifadesi geçen işlerin job_id değerleri ile departman adı (department_name) 'IT' veya 'Sales' olan departmanlardaki çalışanların job_id değerlerini tüm tekrarlarıyla listeleyen sorguyu yazınız. 
SELECT
	j.job_id AS "Yetenek İş ID"
FROM jobs AS j
WHERE 
	j.job_title ILIKE '%Manager%'
	OR j.job_title ILIKE '%Clerk%'
UNION ALL
SELECT
	e.job_id
FROM employees AS e
INNER JOIN departments AS d
	USING(department_id)
WHERE d.department_name IN ('IT','Sales')
ORDER BY 1; -- ORDER BY "Yetenek İş ID"

-- 2.7. 2015 yılından sonra işe giren (hire_date) çalışanların üstlendiği job_id değerleri ile minimum maaşı (min_salary) 5000'den büyük olan işlerin job_id değerlerinden ortak olanları listeleyen sorguyu yazınız. 
SELECT
	e.job_id AS "Yetenek İş ID"
FROM employees AS e
WHERE DATE_PART('Year',e.hire_date) > 2015
INTERSECT
SELECT 
	j.job_id
FROM jobs AS j
WHERE j.min_salary > 5000
ORDER BY "Yetenek İş ID";


-- 2.8. Sistemde kayıtlı tüm departmanların (departments) department_id numaralarından, bünyesinde aktif olarak çalışan (employees) barındıran departmanların department_id numaralarını çıkartarak tamamen boş olan departmanları listeleyen sorguyu yazınız. 
SELECT
	d.department_id AS "Departman ID"
FROM departments AS d
EXCEPT
SELECT
	e.department_id 
FROM employees AS e
ORDER BY "Departman ID";

-- 2.9. Çalışanların e-posta (email) adreslerinin sadece '@' işaretinden önceki kısımlarını tamamen küçük harfli olarak, bağımlıların ilk isimlerini (first_name) ise tamamen büyük harfli olarak tek bir kümede birleştiren sorguyu yazınız. 
SELECT
	LOWER(SPLIT_PART(e.email, '@',1)) AS "E-Postadan Elde Edilmiş Kısım"
FROM employees AS e
UNION 
SELECT
	UPPER(d.first_name) AS "İsim" -- Alias öylesine yazılmış gibi kalacaktır:)
FROM dependents AS d
ORDER BY "E-Postadan Elde Edilmiş Kısım";

-- 2.10. Telefon numarası (phone_number) bilgisi girilmemiş olan çalışanların id'leri ile bağımlı ilişkisi (relationship) 'Child' olanların bağlı olduğu employee_id değerlerini, olası NULL durumları COALESCE ile sıfırlayarak benzersiz şekilde birleştiren sorguyu yazınız. (UNION / COALESCE)
SELECT
	COALESCE(e.employee_id,0) AS "Yetenek ID"
FROM employees AS e
WHERE e.phone_number IS NULL
UNION 
SELECT
	COALESCE(d.employee_id,0)
FROM dependents AS d
WHERE d.relationship = 'Child'
ORDER BY "Yetenek ID";

-- 2.11. Şirketteki en yüksek maaşlı 3 çalışanın adı, soyadı, maaşı ve yanına 'En Yüksek Maaş' etiketi ile en düşük maaşlı 3 çalışanın adı, soyadı, maaşı ve yanına 'En Düşük Maaş' etiketi eklenmiş halini tek bir tabloda birleştiren sorguyu yazınız.
(
SELECT
	e.first_name || ' ' || e.last_name AS "Yetenek Adı Soyadı",
	e.salary AS "Ücret",
	CASE e.salary
		WHEN MAX(e.salary) THEN 'En Yüksek Ücret'
		ELSE 'Kategorize Edilemedi'
	END AS "Ücret Kategorisi"
FROM employees AS e
GROUP BY 
	e.first_name || ' ' || e.last_name, 
	e.salary
ORDER BY e.salary DESC
LIMIT 3
)
UNION ALL
(
SELECT
	e.first_name || ' ' || e.last_name AS "Yetenek Adı Soyadı",
	e.salary AS "Ücret",
	CASE e.salary
		WHEN MIN(e.salary) THEN 'En Düşük Ücret'
		ELSE 'Kategorize Edilemedi'
	END AS "Ücret Kategorisi"
FROM employees AS e
GROUP BY 
	e.first_name || ' ' || e.last_name, 
	e.salary
ORDER BY e.salary
LIMIT 3
);

/*

(
SELECT
	e.first_name || ' ' || e.last_name AS "Yetenek Adı Soyadı",
	e.salary AS "Ücret ",
	'En Yüksek Ücret' AS "Ücret Kategorisi"
FROM employees AS e
ORDER BY e.salary DESC
LIMIT 3
)
UNION ALL
(
SELECT
	emp.first_name || ' ' || emp.last_name AS "Yetenek Adı Soyadı",
	emp.salary AS "Ücret",
	'En Düşük Ücret' AS "Ücret Kategorisi"
FROM employees AS emp
ORDER BY emp.salary
LIMIT 3
);


*/


-- 2.12. İşe giriş tarihi (hire_date) üzerinden bakıldığında yılın ilk çeyreğinde (1. Çeyrek) işe giren çalışanların çalıştığı department_id değerleri ile departman bazlı ortalama maaşı 7000'den büyük olan departmanların id değerlerinin kesişimini listeleyen sorguyu yazınız. 
SELECT
	e.department_id AS "Departman ID"
	-- e.salary AS "Ücret"
FROM employees AS e
WHERE EXTRACT(QUARTER FROM e.hire_date) = 1
INTERSECT
SELECT
	emp.department_id
	-- CEIL(AVG(emp.salary)) AS "Ortalama Ücret"
FROM employees AS emp
GROUP BY department_id
HAVING CEIL(AVG(emp.salary)) > 7000
ORDER BY  "Departman ID" ;

-- 2.13. Maksimum maaşı (max_salary) 10000'den büyük olan işlerin (jobs) benzersiz id'lerinden, belirli bir yıldan sonra işe başlamış çalışanların job_id değerlerini çıkartarak listeleyen sorguyu yazınız. (EXCEPT / DATE_TRUNC)
SELECT
	j.job_id AS "İş ID"
FROM jobs AS j
WHERE j.max_salary > 10000
EXCEPT
SELECT
	e.job_id
FROM employees AS e
WHERE DATE_TRUNC('YEAR', e.hire_date) > TO_TIMESTAMP('2010-10-15 09:30:00', 'YYYY-MM-DD H12:MI:SS')
-- WHERE EXTRACT(YEAR FROM e.hire_date)
ORDER BY "İş ID";
/*
--Not: Tarihlerde hangi tarihin daha büyük veya küçük olduğunu hatırlamak için örnek bir sorgu türetin.
SELECT
	TO_TIMESTAMP('2010-10-15 09:30:00', 'YYYY-MM-DD H12:MI:SS') > TO_TIMESTAMP('2011-10-15 09:30:00', 'YYYY-MM-DD H12:MI:SS')
*/

-- 2.14. Maaşı 9000'den büyük olan çalışanların ilk isimleri ile tüm bağımlıların ilk isimlerinin kesişimini bulunuz; ardından elde edilen bu isim kümesini, bölge adı (region_name) 'Americas' olan yerlerdeki departmanlarda çalışanların ilk isimleri ile benzersiz şekilde birleştiriniz. (INTERSECT & UNION / MULTIPLE JOINS)
(
SELECT
	e.first_name AS "Yetenek İsmi"
FROM employees AS e
WHERE e.salary > 9000
INTERSECT
SELECT
	d.first_name 
FROM dependents AS d

)
UNION
SELECT
	emp.first_name
FROM employees AS emp
INNER JOIN departments AS d
	USING(department_id)
INNER JOIN locations AS l
	USING(location_id)
INNER JOIN countries
	USING(country_id)
INNER JOIN regions AS r
	USING(region_id)
WHERE r.region_name = 'Americas'
ORDER BY "Yetenek İsmi";

-- 2.15. İşe giriş tarihindeki ay bilgisi çift sayı (2, 4, 6, 8, 10, 12) olan çalışanların id değerleri ile bir yöneticisi (manager_id) olan çalışanların id değerlerini tüm tekrarlarıyla birleştiriniz ; son olarak oluşan bu büyük kümeden bağımlısı (dependents) olan çalışanların id değerlerini çıkartınız 
(
SELECT
	-- DATE_PART('MONTH', e.hire_date)
	e.employee_id AS "Yetenek ID"
FROM employees AS e
WHERE EXTRACT(MONTH FROM e.hire_date) IN (2, 4, 6, 8, 10, 12)
UNION ALL
SELECT
	emp.manager_id 
FROM employees AS emp
)
EXCEPT
(
SELECT
	d.employee_id
FROM dependents AS d
)
ORDER BY "Yetenek ID" NULLS FIRST;

-- 2.16. 'US' (Amerika) ülkesindeki lokasyonlarda bulunan departmanların şehir (city) isimleri ile departman adı 'Executive' veya 'Finance' olan departmanların bulunduğu şehir isimlerini benzersiz şekilde birleştiriniz ; elde edilen bu şehir listesinden, içinde hiçbir bağımlının ilişkisi olmayan şehirleri EXCEPT kullanarak çıkartınız. 
(
SELECT
	l.city AS "Şehir"
FROM locations AS l
JOIN departments AS d
	USING(location_id)
WHERE l.country_id = 'US'
UNION 
SELECT
	l.city AS "Şehir"
FROM locations AS l
JOIN departments AS d
	USING(location_id)
WHERE d.department_name IN ('Executive', 'Finance')
)
EXCEPT
(
SELECT
	city
FROM locations
EXCEPT
SELECT
	l.city 
FROM dependents d
JOIN employees AS e
	USING(employee_id)
JOIN departments AS depa
	USING(department_id)
JOIN locations AS l
	USING(location_id)
)
ORDER BY "Şehir" NULLS FIRST;
