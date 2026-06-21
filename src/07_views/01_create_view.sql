-- 1. VIEWS:
/*
-- 1.1. VIEW Nedir?
VIEW, verileri çekmek için arayüz sağlayan nesnelerdir.
Materialized olanlar haricinde içlerinde veri tutmazlar.
Bir tablo gibi davranırlar, gerektiğinde güncellenebilirler.


-- 1.2. VIEW Özellikleri:
- İçlerinde veri tutmadıklarından kaynaklı veriye bağımlı değildirler.
- Kolay yönetim sağlarlar.
- Karmaşık sorguları tekrar yazma derdinden kurtarırlar, bizlere modülerlik sağlarlar.
- Veri erişimine kısıtlama getirirler, bu nedenle de veri tabanı güvenliğine katkı sağlarlar.

Örneğin, veri tabanımızdaki tablolarımızı ve sütunlarımızı görmelerini istemiyorsak, VIEW oluşturarak
bu VIEW nesnesi üzerinden verilere erişmelerini sağlayabiliriz. 
Burada bizim sorgumuz sonucu verdiklerimizin haricinde bir bilgiye ulaşmalarını engellemiş oluruz. Bu da
bizlere veri güvenliğini sağladığımızı gösterir.

-- 1.3. VIEW Oluşturma:
CTAS yöntemi (CREATE TABLE AS) ile tablo oluşturmayı görmüştük.
Burada, oluşturduğumuz tablolar, diğer tablolara bağlı olarak oluşturuluyordu.
Ancak, oluşturulan tablolarda herhangi bir değişiklik olduğunda bu oluşturulan tabloya yansımıyordu. 
Çünkü bu oluşturulan tablo, harici bir veriyle beslenmiyor, güncellenmiyordu.

Ancak VIEW'lar oluşturuldukları tablolardaki değişikliklerden etkilenirler, veriler güncellendikçe sorgu sonucumuz
da değişmektedir.


```
-- 1.4. Söz Dizimi:

```sql
CREATE [OR REPLACE] VIEW view_adi
AS
Sorgumuz
```

Burada yer alan OR REPLACE argümanı opsiyoneldir.
VIEW'ların güncellenmesinde OR REPLACE argümanı kullanılmalıdır.

-- 1.5. Dikkat Edilmesi Gerekenler:
- VIEW'lar bizleri karmaşık sorguları tekrar ve tekrar yazma zahmetinden kurtarırlar.
- VIEW'lar değiştirilebilir ve güncellenebilirler.
- İç içe VIEW oluşturulabilir, ikiden fazla iç içe VIEW oluşturmak ise karmaşıklığını yönetmesi zor olacağından önerilmez.

*/

------------------------------------------------------------------------------------------------------------------------------------------------
-- 2. CREATE VIEW EXAMPLES (VIEW Oluşturma Örnekleri):
-- 2.1. "office" veri tabanını kullanarak çalışanların işlerini beraber getiren view'ı oluşturunuz.

-- Tablolarımızı hatırlayarak işlemlerimize başlayalım.
SELECT
	emp.employee_id AS "Yetenek ID",
	emp.first_name || ' ' || emp.last_name AS "Yetenek Adı Soyadı",
	emp.email AS "E-Posta Adresi",
	emp.phone_number AS "Telefon Numarası",
	emp.hire_date AS "İşe Giriş Tarihi",
	j.job_title AS "İş Tanımı"
FROM employees AS emp
LEFT JOIN jobs AS j
	USING(job_id)
ORDER BY emp.employee_id;

-- Transaction başlatalım
BEGIN TRANSACTION;

-- VIEW oluşturalım
CREATE OR REPLACE VIEW vw_employees_with_departments
AS
SELECT
	emp.employee_id,
	emp.first_name || ' ' || emp.last_name AS full_name,
	emp.email,
	emp.phone_number,
	emp.hire_date,
	j.job_title,
	emp.salary
FROM employees AS emp
LEFT JOIN jobs AS j
	USING(job_id)
ORDER BY emp.employee_id;

-- Vıew'ı çekelim
SELECT
	vw_emp.employee_id,
	vw_emp.full_name,
	vw_emp.email,
	vw_emp.salary,
	vw_emp.job_title
FROM vw_employees_with_departments AS vw_emp;

-- Kaydedelim.
COMMIT;



-- 2.2. "office" veri tabanını kullanarak bölgesi Europe olan çalışanların departmanlarıyla beraber getiren view'ı oluşturan sorguyu yazınız.

-- Tablomuzu görelim
SELECT
	r.region_id AS "Bölge ID",
	r.region_name AS "Bölge"
FROM regions AS r;


-- JOIN işlemleri yapalım
SELECT
	emp.employee_id,
	emp.first_name || ' ' || emp.last_name AS full_name,
	d.department_name,
	l.city,
	c.country_name,
	r.region_name
FROM employees AS emp
INNER JOIN departments AS d
	USING(department_id)
INNER JOIN locations AS l
	USING(location_id)
INNER JOIN countries AS c
	USING(country_id)
INNER JOIN regions AS r
	USING(region_id)
WHERE r.region_id = (
	SELECT
		re.region_id	
	FROM regions AS re
	WHERE LOWER(re.region_name) = 'europe'
	)
ORDER BY emp.employee_id;


-- Transaction başlatalım
BEGIN;

-- View oluşturalım.
CREATE OR REPLACE VIEW vw_europe_emp
AS
SELECT
	emp.employee_id,
	emp.first_name || ' ' || emp.last_name AS full_name,
	d.department_name,
	l.city,
	c.country_name,
	r.region_name
FROM employees AS emp
INNER JOIN departments AS d
	USING(department_id)
INNER JOIN locations AS l
	USING(location_id)
INNER JOIN countries AS c
	USING(country_id)
INNER JOIN regions AS r
	USING(region_id)
WHERE r.region_id = (
	SELECT
		re.region_id	
	FROM regions AS re
	WHERE LOWER(re.region_name) = 'europe'
	)
ORDER BY emp.employee_id;

-- Veriye bakalım.
SELECT
	--vw_europe.*
	vw_europe.employee_id,
	vw_europe.full_name,
	vw_europe.department_name,
	vw_europe.city,
	vw_europe.country_name,
	vw_europe.region_name
FROM vw_europe_emp AS vw_europe;

-- Kaydedelim
COMMIT;

-- 2.3. "office" veri tabanında yönetici pozisyonundaki çalışanların departmanlarını, isim soyisim ve maaşlarını getiren VIEW'ı yazınız.
SELECT
	m.emp_name,
	m.job_title,
	emp.salary
FROM managers AS m
INNER JOIN employees AS emp
	USING(employee_id);

-- VIEW oluşturalım. => Daha önceden managers oluşturmuştuk, bu yoktur diye join ile yapalım
SELECT
	emp.employee_id,
	emp.first_name || ' ' || emp.last_name AS full_name,
	j.job_title,
	emp.salary
FROM employees AS emp
LEFT JOIN jobs AS j
	USING(job_id)
WHERE j.job_id IN (
	SELECT
		jo.job_id
	FROM jobs AS jo
	WHERE jo.job_title ILIKE '%Manager%'
);

-- Transaction başlatalım
BEGIN TRANSACTION;

CREATE OR REPLACE VIEW vw_managers
AS
SELECT
	emp.employee_id,
	emp.first_name || ' ' || emp.last_name AS full_name,
	j.job_title,
	emp.salary
FROM employees AS emp
LEFT JOIN jobs AS j
	USING(job_id)
WHERE j.job_id IN (
	SELECT
		jo.job_id
	FROM jobs AS jo
	WHERE jo.job_title ILIKE '%Manager%'
);

-- Veri çekelim
SELECT
	-- vw_m.*
	vw_m.employee_id,
	vw_m.full_name,
	vw_m.job_title,
	vw_m.salary
FROM vw_managers AS vw_m;

-- Kaydedelim
COMMIT;


-- 2.4. "office" veri tabanında  lokasyon tablosunu kullanarak ülke id 2 olanları getiren VIEW'ı oluşturunuz.

-- Tablomuzu alalım
SELECT
	r.region_name AS "Bölge Adı",
	c.country_name AS "Ülke Adı",
	l.city AS "Şehir Adı",
	l.street_address AS "Sokak Adresi",
	l.postal_code AS "Posta Kodu",
	l.state_province AS "İlçe"
FROM locations AS l
LEFT JOIN countries AS c
	USING(country_id)
LEFT JOIN regions AS r
	USING(region_id)
WHERE country_id IN ('DE', 'CA');

-- Transaction başlatalım
BEGIN TRANSACTION;

-- VIEW oluşturalım
CREATE OR REPLACE VIEW vw_selected_address
AS
SELECT
	r.region_name,
	c.country_name,
	l.city,
	l.street_address,
	l.postal_code, 
	l.state_province
FROM locations AS l
LEFT JOIN countries AS c
	USING(country_id)
LEFT JOIN regions AS r
	USING(region_id)
WHERE country_id IN ('DE', 'CA');

-- VIEW'ı sorgulayalım
SELECT
	-- vw_address.*
	vw_address.region_name,
	vw_address.country_name,
	vw_address.city,
	vw_address.street_address,
	vw_address.postal_code,
	vw_address.state_province
FROM vw_selected_address AS vw_address;

-- Kaydedelim 
COMMIT;

-- 2.5. "office" veri tabanında public.avg_salaries_by_departments tablosunda ortalama maaşı bulan VIEW'ı yazınız.

SELECT
	avg_sal.department_name AS "Departman Adı",
	avg_sal.department_avg_salary AS "Departmanın Ortalama Maaşı"
FROM avg_salaries_by_departments AS avg_sal;

-- Toplam Ortalama Maaşı Bulalım
SELECT
	COUNT(DISTINCT avg_sal.department_name) AS "Toplam Departman Sayısı",
	ROUND(AVG(avg_sal.department_avg_salary),2) AS "Ortalama Maaş"
FROM avg_salaries_by_departments AS avg_sal;

-- Transaction başlatalım
BEGIN;

-- VIEW oluşturalım
CREATE OR REPLACE VIEW vw_avg_salary
AS
SELECT
	COUNT(DISTINCT avg_sal.department_name) AS department_count,
	ROUND(AVG(avg_sal.department_avg_salary),2) average_salary
FROM avg_salaries_by_departments AS avg_sal;

-- VIEW'ı sorgulayalım
SELECT
	sal.department_count,
	sal.average_salary
FROM vw_avg_salary AS sal;

-- Kaydedelim
COMMIT;

-- 2.6. "office" veri tabanında high_earners tablosunda en yüksek maaşı ve en düşük maaşı alan çalışanı getiren VIEW'ı oluşturunuz.

SELECT
	hs.department_name AS "Departman",
	hs.employee_full_name "Yetenek Adı Soyadı",
	hs.salary AS "Yetenek Ücreti"
FROM high_earners AS hs
ORDER BY hs.department_name;

-- En yüksek ve düşük ücreti alanları getiren sorguyu yazalım
SELECT
	COUNT(*) AS "Katılımcı Sayısı",
	MAX(hs.salary) AS "Maksimum Ücret",
	MIN(hs.salary) AS "Minimum Ücret"
FROM high_earners AS hs;

-- Transaction başlatıp devam edelim
BEGIN TRANSACTION;

-- VIEW oluşturalım
CREATE OR REPLACE VIEW vw_salary_details
AS
SELECT
	COUNT(*) AS employee_count,
	MAX(hs.salary) AS max_salary,
	MIN(hs.salary) AS min_salary 
FROM high_earners AS hs;

-- View'ı çekelim ve kontrol edelim
SELECT
	sd.employee_count,
	sd.max_salary,
	sd.min_salary
FROM vw_salary_details AS sd;

-- Kaydedelim
COMMIT;

-- 2.7. "office" veri tabanında jobs tablosunu kullanarak min_salary'si 6000 ve altında olan veya max_salary'si 11500 ve fazla olan çalışanların tutulduğu VIEW'ı sorgulayınız.

SELECT
	emp.employee_id AS "Yetenek ID",
	emp.first_name || ' ' || emp.last_name AS emp_full_name,
	emp.salary AS "Yetenek Ücreti",
	j.job_title AS "İş Başlığı"
FROM jobs AS j
LEFT JOIN employees AS emp
	USING(job_id)
WHERE 
	j.min_salary < 6000
	OR 11500 <= j.max_salary;

-- Transaction başlatalım
BEGIN;

-- VIEW oluşturalım
CREATE OR REPLACE VIEW vw_emp_salary_details
AS
SELECT
	emp.employee_id AS emp_id,
	emp.first_name || ' ' || emp.last_name AS emp_full_name,
	emp.salary,
	j.job_title
FROM jobs AS j
LEFT JOIN employees AS emp
	USING(job_id)
WHERE 
	j.min_salary < 6000
	OR 11500 <= j.max_salary;


-- Sorguyu çalıştıralım
SELECT
	-- vw_emp_salary_details.*
	vw_emp_salary_details.emp_id,
	vw_emp_salary_details.emp_full_name,
	vw_emp_salary_details.salary,
	vw_emp_salary_details.job_title
FROM vw_emp_salary_details;

-- Kaydedelim
COMMIT;

-- 2.8. "office" veri tabanında low_purchasing_salaries tablosunda departman adına göre maksimum ve minimum maaşlı tutan VIEW'ı oluşturunuz.

-- Tabloyu çekelim
SELECT
	lps.employee_id AS "Yetenek ID",
	lps.employee_full_name AS "Yetenek Adı Soyadı",
	lps.department_name AS "Departman",
	lps.salary AS "Yetenek Ücreti"
FROM low_purchasing_salaries AS lps;


-- En düşük ve en yüksek çalışanı alalım
SELECT
	COUNT(*) AS "Kişi Sayısı",
	CONCAT(FLOOR(MAX(lps.salary)), ' ₺') AS "Maksimum Ücret",
	CONCAT(FLOOR(MIN(lps.salary)), ' ₺') AS "Minimum Ücret"
FROM low_purchasing_salaries AS lps;

-- Transaction ile işleri başlatalım
BEGIN;

-- VIEW ile devam edelim.
CREATE OR REPLACE VIEW vw_low_purchasing_salaries
AS
SELECT
	COUNT(*) AS emp_count,
	CONCAT(FLOOR(MAX(lps.salary)), ' ₺') AS low_max_salary,
	CONCAT(FLOOR(MIN(lps.salary)), ' ₺') AS low_min_salary
FROM low_purchasing_salaries AS lps;

-- Çekip kontrol edelim
SELECT
	vw_lps.emp_count,
	vw_lps.low_max_salary,
	vw_lps.low_min_salary
FROM vw_low_purchasing_salaries as vw_lps;

-- Kaydedelim
COMMIT;

