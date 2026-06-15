-- 1. SELECT INTO Statement (SELECT INTO İfadesi):
/*
CREATE TABLE kullanarak tablo oluşturmayı görmüştük.
SELECT INTO ile de tablo oluşturabiliriz.

-- 1.1. Gereklilikleri:
SELECT INTO ifadesi ile tablo oluşturabilmemiz için referans almamız gereken bir tablo gerekmektedir.

-- 1.2. SELECT INTO Söz Dizimi:

```sql
SELECT select_list -- sütun, ifade vb.
    INTO [temporary | temp | unlogged] -- burada tablonun türü 
    [table] new_table_name -- tablomuzun ismi
FROM table_name
WHERE search_condition; -- arama kriteri

```
Üstteki söz diziminden çok açıklayıcı durmadığının farkındayım. Bunu açıklayıcı kılabilmek
amacıyla örnekler gerçekleştireceğiz.

*/

------------------------------------------------------------------------------------------------------------------------------

-- 2. SELECT INTO EXAMPLES (SELECT INTO Örnekleri):
-- 2.1. "office" veri tabanını kullanarak job_title'da manager geçenleri managers isminde tabloda tutan tabloyu oluşturunuz.

-- Tablomuz inceleyelim.
SELECT
	j.job_id AS "İş ID",
	j.job_title AS "İş Başlığı",
	j.min_salary AS "Minimum Maaş",
	j.max_salary AS "Maksimum Maaş"
FROM jobs AS j
ORDER BY j.job_id;

-- Transaction başlatalım
BEGIN;

-- Sorguyu yazalım.
SELECT 
	emp.employee_id,
	emp.first_name || ' ' || emp.last_name AS emp_name,
	j.job_id,
	j.job_title
INTO TABLE managers
FROM employees AS emp
JOIN jobs AS j
	ON emp.job_id = j.job_id
WHERE 
	j.job_title ILIKE '%Manager%';

-- Kaydedelim
COMMIT;

-- 2.2. "office" veri tabanında adı B ile başlayan veya soyadı N ile biten kayıtları special_names isimli tabloda tutan sorguyu yazınız.

-- İlgili sorguyu deneyelim ve tablolarımızı gözlemleyelim.
SELECT
	emp.employee_id AS "Yetenek ID",
	emp.first_name AS "Yetenek Adı",
	emp.last_name AS "Yetenek Soyadı",
	emp.email AS "Yetenek E-Posta",
	emp.phone_number AS "Telefon Numarası",
	emp.salary AS "Yetenek Ücret"
FROM employees AS emp
ORDER BY emp.employee_id;

--Transaction başlatalım
BEGIN;

-- SELECT INTO ile tablo oluşturalım
SELECT
	emp.employee_id,
	emp.first_name || ' ' || emp.last_name AS employee_full_name,
	emp.email,
	emp.hire_date,
	emp.job_id,
	emp.salary
INTO TABLE special_names
FROM employees AS emp
WHERE
	emp.first_name ILIKE 'B%'
	OR emp.last_name ILIKE '%n';

-- Kaydedelim
COMMIT;

-- 2.3. "office" veri tabanında departman id'si 3 olan ve maaşı ortalamanın altında olan çalışanların yer aldığı tabloyu oluşturunuz.

-- Tablomuzu inceleyelim.
SELECT
	d.department_id AS "Departman ID",
	emp.first_name || ' ' || emp.last_name AS "Yetenek Adı",
	emp.salary AS "Yetenek Ücreti",
	d.department_name AS "Departman Adı"
FROM departments AS d
JOIN employees AS emp
	USING(department_id)
ORDER BY d.department_id;

-- Transaction başlatalım
BEGIN TRANSACTION;

-- İstenileni yapalım
SELECT
	emp.employee_id,
	emp.first_name || ' ' || emp.last_name AS employee_full_name,
	d.department_name,
	emp.salary
INTO TABLE low_purchasing_salaries
FROM departments AS d
JOIN employees AS emp
	USING(department_id)
WHERE
	d.department_id = 3
	AND emp.salary < (
		SELECT
			FLOOR(AVG(e.salary))
		FROM employees AS e
	);

-- Savepoint ekleyelim.
SAVEPOINT created_low_purchasing_salaries;

-- Kaydedelim veya geriye alalım COMMIT | ROLLBACK;
COMMIT;


-- 2.4. "office" veri tabanında departmanlara göre ortalama maaşları avg_salaries isminde tabloya aktaran sorguyu yazınız.

-- İstenilen sorguları deneyelim ki hata almayalım.
SELECT
	d.department_name AS "Departman",
	ROUND(AVG(emp.salary)) AS "Ortalama Ücret"
FROM departments d
LEFT JOIN employees AS emp
	USING(department_id)
GROUP BY d.department_name;

-- Maaşın altında olanları bulalım.
SELECT
	d.department_name AS "Departman",
	ROUND(AVG(emp.salary)) AS "Ortalama Ücret"
FROM departments d
LEFT JOIN employees AS emp
	USING(department_id)
GROUP BY d.department_name
HAVING AVG(emp.salary) < (
	SELECT
		ROUND(AVG(e.salary))
	FROM employees AS e
);

-- Transaction başlatalım
BEGIN;

-- İstenilen tabloyu oluşturalım
SELECT 
	d.department_name,
	ROUND(AVG(emp.salary)) AS department_avg_salary
INTO TABLE avg_salaries_by_departments
FROM departments d
LEFT JOIN employees AS emp
	USING(department_id)
GROUP BY d.department_name
HAVING AVG(emp.salary) < (
	SELECT
		ROUND(AVG(e.salary))
	FROM employees AS e
);

-- Kaydedelim.
COMMIT;

-- 2.5. "office" veri tabanında location_id 3, 5, 6 olan departmanları tabloya aktaran sorguyu yazınız.

-- Tablomuzu inceleyelim
SELECT
	d.department_id AS "Departman ID",
	d.department_name AS "Departman",
	location_id AS "Departman Lokasyon ID"
FROM departments AS d
ORDER BY d.department_id;

-- Transaction başlatalım
BEGIN TRANSACTION;

-- İstenilen tabloyu oluşturalım
SELECT
	d.department_id,
	d.department_name,
	location_id,
	c.country_name
INTO TABLE dep_with_selected_loc
FROM departments AS d
INNER JOIN locations AS l
	USING(location_id)
INNER JOIN countries AS c
	USING(country_id)
WHERE 
	l.location_id IN (3, 5, 6);

-- Kaydedelim
COMMIT;

-- 2.6. "office" veri tabanında, 4 numaralı departmanda çalışan en yüksek maaşlı personelden (MAX) daha fazla maaş alan tüm çalışanların bilgilerini `high_earners` isimli yeni bir tabloya aktaran sorguyu yazınız. (Subquery kullanımı)

-- Tablolarımızı birleştirelim ve ilgili işlemleri adım adım yapalım.
SELECT
	d.department_id AS "Departman ID",
	d.department_name AS "Departman",
	e.first_name || ' ' || e.last_name AS "Yetenek Adı Soyadı",
	e.salary AS "Yetenek Ücreti"
FROM departments AS d
JOIN employees AS e
	USING(department_id)
ORDER BY d.department_id;

-- maaşı, departman id'si 4 olan en yüksek maaşlı çalışandan yüksek olanları
SELECT
	d.department_id AS "Departman ID",
	d.department_name AS "Departman",
	e.first_name || ' ' || e.last_name AS "Yetenek Adı Soyadı",
	e.salary AS "Yetenek Ücreti"
FROM departments AS d
JOIN employees AS e
	USING(department_id)
WHERE e.salary > (
		SELECT
			MAX(emp.salary)
		FROM employees AS emp
		WHERE emp.department_id = 4
	)
ORDER BY d.department_id;

-- Transaction başlatalım
BEGIN TRANSACTION;

-- Tablomuzu oluşturalım
SELECT
	d.department_id ,
	d.department_name, 
	e.first_name || ' ' || e.last_name AS employee_full_name,
	e.salary
INTO TABLE high_earners
FROM departments AS d
JOIN employees AS e
	USING(department_id)
WHERE e.salary > (
		SELECT
			MAX(emp.salary)
		FROM employees AS emp
		WHERE emp.department_id = 4
	);

-- Kaydedelim
COMMIT;


-- 2.7. "office" veri tabanında yer alan çalışanların adını, soyadını, mevcut iş unvanını ve bağlı oldukları departman adını tek bir yapıda birleştirerek `employee_detailed_list` isimli yeni bir tabloya aktaran sorguyu yazınız.

-- Sorgumuzu deneyelim
SELECT
	emp.employee_id,
	emp.first_name || ' ' || emp.last_name AS employee_full_name,
	j.job_title,
	d.department_name 
FROM employees AS emp
JOIN jobs AS j
	USING(job_id)
JOIN departments AS d
	USING(department_id)
ORDER BY emp.employee_id;

-- Transaction başlatalım
BEGIN;

SELECT
	emp.employee_id,
	emp.first_name || ' ' || emp.last_name AS employee_full_name,
	j.job_title, 
	d.department_name
INTO TABLE employee_detailed_list
FROM employees AS emp
JOIN jobs AS j
	USING(job_id)
JOIN departments AS d
	USING(department_id);

-- Kaydedelim
COMMIT;

-- 2.8. "office" veri tabanında, kadrosunda 5'ten fazla çalışan barındıran departmanların ID'lerini ve içerdiği personel sayılarını `crowded_departments` adında bir tabloya aktaran sorguyu yazınız. 

-- Sorgumuzu çekelim
SELECT
	d.department_id AS "Departman ID",
	COUNT(*) AS "Çalışan Yetenek Sayısı"
FROM departments AS d
LEFT JOIN employees AS e
	USING(department_id)
GROUP BY d.department_id
HAVING COUNT(*) > 5
ORDER BY d.department_id;

-- Transaction başlatalım
BEGIN TRANSACTION;

-- Bu sorgumuzu SELECT INTO ile tabloya aktaralım
SELECT
	d.department_id,
	COUNT(*) AS employee_count
INTO TABLE crowded_departments
FROM departments AS d
LEFT JOIN employees AS e
	USING(department_id)
GROUP BY d.department_id
HAVING COUNT(*) > 5
ORDER BY d.department_id;

-- Veri tabanına kalıcı olarak kaydedelim
COMMIT;

-- 2.9. "office" veri tabanındaki departman ve lokasyon bilgilerini kullanarak; 'London', 'Toronto' veya 'Oxford' şehirlerinde faaliyet gösteren departmanlarda çalışan personellerin bilgilerini `uk_ca_staff` isimli yeni bir tabloya aktaran sorguyu yazınız. 

-- İstenilen sorguyu deneyelim.
SELECT
	emp.employee_id AS "Yetenek ID",
	emp.first_name || ' ' || emp.last_name AS "Yetenek Adı Soyadı",
	emp.salary AS "Yetenek Ücreti",
	d.department_name AS "Departman",
	l.city AS "Şehir"
FROM employees AS emp
LEFT JOIN departments AS d
	USING(department_id)
LEFT JOIN locations AS l
	USING(location_id)
WHERE l.city IN ('London', 'Toronto', 'Oxford')
ORDER BY emp.employee_id;

-- Transaction başlatalım.
BEGIN TRANSACTION;


-- SELECT INTO ile bu yazdığımız sorguyu tabloya aktaralım
SELECT
	emp.employee_id,
	emp.first_name || ' ' || emp.last_name AS employee_full_name,
	emp.salary,
	d.department_name,
	l.city
INTO TABLE uk_ca_staff
FROM employees AS emp
LEFT JOIN departments AS d
	USING(department_id)
LEFT JOIN locations AS l
	USING(location_id)
WHERE l.city IN ('London', 'Toronto', 'Oxford')
ORDER BY emp.employee_id;

-- Kaydedelim veya geriye alalım (ROLLBACK)
COMMIT;

-- 2.10. "office" veri tabanında, kendi çalıştığı departmanın ortalama maaşından (AVG) daha yüksek maaş alan sıra dışı çalışanların ID, ad, soyad, maaş ve departman ID bilgilerini `above_dept_avg_employees` isimli yeni bir tabloya aktaran sorguyu yazınız. 

-- İstenilen sorguyu gerçekleştirelim
SELECT
	emp.employee_id AS "Yetenek ID",
	emp.first_name || ' ' || emp.last_name AS "Yetenek Adı Soyadı",
	emp.salary AS "Yetenek Ücreti",
	emp.department_id AS "Departman"
FROM employees AS emp
JOIN (
		SELECT
			e.department_id AS dep_id,
			ROUND(AVG(e.salary)) AS dep_avg_sal
		FROM employees AS e
		GROUP BY e.department_id
		
	) AS dep_salary
	ON emp.department_id = dep_salary.dep_id
WHERE
	emp.salary > dep_salary.dep_avg_sal;

-- Begin ile transaction başlatalım
BEGIN;

-- SELECT INTO ile tablo oluşturalım
SELECT
	emp.employee_id,
	emp.first_name || ' ' || emp.last_name AS employee_full_name,
	emp.salary,
	emp.department_id 
INTO TABLE above_dept_avg_employees
FROM employees AS emp
JOIN (
		SELECT
			e.department_id AS dep_id,
			ROUND(AVG(e.salary)) AS dep_avg_sal
		FROM employees AS e
		GROUP BY e.department_id
		
	) AS dep_salary
	ON emp.department_id = dep_salary.dep_id
WHERE
	emp.salary > dep_salary.dep_avg_sal;

-- Kaydedelim
COMMIT;
