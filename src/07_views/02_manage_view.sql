-- 1. Manage VIEWS (VIEW'ları Yönetmek):
/*
-- 1.1. VIEW'ları Yönetmek:
VIEW'lar bizlere veri tabanı güvenliğine yardımcı olan ve karmaşık sorgu yükünden kurtaran 
obje olarak karşımıza çıkmaktadır.
VIEW'ları güncelleyebilir ve silebiliriz.
İç içe view'lar oluşturarak onları yönetebiliriz.

-- 1.2. VIEW'ları GÜncellemek:

-- 1.2.1. VIEW GÜncelleme Kısıtları:
VIEW'lar üzerinde her türlü güncelleme işlemini gerçekleştiremeyiz.
Bunun gereklilikleri mevcuttur:
- VIEW'ımız simple tek bir tablodan oluşmalıdır.
- Güncelleme yaptığımız zaman güncellenen kısım VIEW'lar içerisinde veri tutmadığından kaynaklı
ana tablomuz olacaktır.

Söz Dizimi:
```sql
-- Simple VIEW üzerinden güncelleme yapalım

UPDATE view_ismimiz
SET ilgili_guncelleme;

-- Veri eklemek için
INSERT INTO view_ismimiz
    (
        guncellenecek_sutun_adi1,
		guncellenecek_sutun_adi2,
		...,

	)
VALUES
	(
		guncellenecek_deger1,
		guncellenecek_deger2,
		...
	)
WHERE kisitimiz;

```

-- 1.2.2. WITH CHECK OPTION Argümnı:
Verilerimizi güncellerken, veri eklerken WHERE ifadesinde yer alan kısıtımızın korunmasını
sağlamak amacıyla WITH CHECK OPTION argümanını kulanabiliriz. 
Bu bizlere verilerin tutarlılığının sağlanmasını ve veri bütünlüğünü korunmasında etki etmektedir.
Bunları soyut tanımlamalardan ziyade somut örneklerle göreceğiz:)

```sql
CREATE [OR REPLACE] VIEW view_ismi
AS
SELECT
	sutun_adi,
	sutun_adi
FROM tablo_adi
WHERE kisit,
ORDER BY sutun_adi
WITH CHECK OPTION; -- En son satırda yer alacaktır.

```


```
-- 1.3. VIEW'ları Silmek:
Veri tabanımızda kullanmadığımız ve uzun vadede işimize yaramayacak nesnelerden kurtulmamız
optimizasyon açısından iyi olacaktır.
Bir VIEW'ı silerken bu VIEW'a bağlı olan diğer nesneleri (Tablo, VIEW, vb.) iyi analiz etmemiz gerekmektedir.

```sql
DROP VIEW [IF EXISTS] view_adi;
```

Önemli Notlar:
- VIEW'daki güncellemelerimiz ve veri eklemelerimiz ana tabloda gerçekleşmektedir.
- VIEW'a bağımlı nesneler varsa, bu VIEW'ı silebilmek amacıyla bağımlı olan nesnelerin
bağımlılığından kurtarmamız veya öncelikle onları silmemiz gerekmektedir.

*/
-------------------------------------------------------------------------------------------------------------------------------
-- 2. MANAGE VIEW EXAMPLES (VIEW'ları GÜncelleme ve Silme Örnekleri):
-- 2.1. "office" veri tabanında yer alan employees tablosunu kullanarak ismi A ile başlayanları listeleyen VIEW'ı oluşturunuz.

SELECT
	emp.employee_id,
	emp.first_name || ' ' || emp.last_name AS emp_full_name,
	emp.email,
	emp.salary
FROM employees AS emp;

-- Transaction başlatalım
BEGIN;

-- VIEW oluşturup çekelim
CREATE OR REPLACE VIEW vw_selected_names
AS
SELECT
	emp.employee_id,
	emp.first_name || ' ' || emp.last_name AS emp_full_name,
	emp.email,
	emp.salary
FROM employees AS emp
WHERE emp.first_name ILIKE 'A%';

SAVEPOINT created_selected_names_view;
ROLLBACK TO SAVEPOINT created_selected_names_view;

-- Çekelim
SELECT
	vw_s.*
FROM vw_selected_names AS vw_s;

-- Transaction başlatalım

-- Güncelleyelim
UPDATE vw_selected_names AS vw_sm
SET
	salary = salary * 1.05
WHERE vw_sm.emp_full_name ILIKE 'Al%';

-- Çekip inceleyelim
SELECT
	vw_sm.*
FROM vw_selected_names AS vw_sm;

SELECT
	emp.employee_id,
	emp.first_name || ' ' || emp.last_name,
	emp.salary
FROM employees AS emp;

-- Kaydedelim
COMMIT;

-- 2.2. "office" veri tabanında employee_detailed_list tablosunu kullanarak job_title Marketing Manager olanı Proactive Marketing Manager olarak değiştiren VIEW'ı oluşturunuz.

SELECT
	edl.employee_id,
	edl.employee_full_name,
	edl.job_title,
	edl.department_name
FROM employee_detailed_list AS edl;

-- VIEW oluşturalım
-- Transaction başlatalım
BEGIN;

CREATE OR REPLACE VIEW vw_marketing_emp
AS
SELECT
	edl.employee_id,
	edl.employee_full_name,
	edl.job_title,
	edl.department_name
FROM employee_detailed_list AS edl
WHERE
	edl.job_title ILIKE 'Marketing Manager';

SAVEPOINT created_vw_marketing_emp;


-- VIEW'ı çekelim
SELECT
	vw_me.employee_id,
	vw_me.employee_full_name,
	vw_me.job_title,
	vw_me.department_name
FROM vw_marketing_emp AS vw_me;

-- Bunu güncelleyelim
UPDATE vw_marketing_emp AS vw_me
SET
	job_title = 'Proactive Marketing Manager'
WHERE
	vw_me.job_title = 'Marketing Manager'
RETURNING *;

-- Değişikliklere bakalım
SELECT
	edl.employee_id,
	edl.employee_full_name,
	edl.job_title,
	edl.department_name
FROM employee_detailed_list AS edl
ORDER BY edl.job_title;

-- Kaydedelim
COMMIT;



-- 2.3. "office" veri tabanında departmanı Public Relations veya Executive olan departmanları getiren VIEW nesnesini oluşturunuz, bunu güncelleyiniz.

SELECT
	d.department_id AS "Departman ID",
	d.department_name AS "Departman"
FROM departments AS d;


-- Transaction başlatalım
BEGIN;

-- VIEW oluşturup devam edelim
CREATE OR REPLACE VIEW vw_selected_deps
AS
SELECT
	d.department_id,
	d.department_name
FROM departments AS d
WHERE 
	d.department_name IN ('Public Relations', 'Executive');

SAVEPOINT created_vw_selected_deps;

-- Çekip görelim
SELECT
	vw_sd.department_id,
	vw_sd.department_name
FROM vw_selected_deps AS vw_sd;


-- Güncelleyeilm
UPDATE vw_selected_deps AS vw_dep
SET
	department_name = 'Organizational Operation'
WHERE
	vw_dep.department_name = 'Executive'
RETURNING *;

-- Çekelim
SELECT
	vw_sd.*
FROM vw_selected_deps AS vw_sd;

-- Kaydedelim
COMMIT;

-- 2.4. "office" veri tabanında vw_managers view'ına bir yönetici ekleyiniz. Karmaşık sorgu olduğundan izin vermez.
-- Yeni bir soru ile bunu giderelim. Yeni view oluşturalım

SELECT
	emp.employee_id,
	emp.first_name || ' ' || last_name AS full_name,
	emp.hire_date,
	emp.salary
FROM employees AS emp
WHERE emp.salary >= 14500;

-- Transaction başlatalım
BEGIN;

CREATE OR REPLACE VIEW vw_high_salary_emps
AS
SELECT
	emp.employee_id,
	emp.first_name,
	emp.last_name,
	emp.hire_date,
	emp.salary
FROM employees AS emp
WHERE emp.salary >= 12500;

SAVEPOINT created_high_salary_emps;

-- Çekelim
SELECT
	vw_hse.*
FROM vw_high_salary_emps AS vw_hse;


-- Güncelleyelim
/*
UPDATE vw_high_salary_emps AS vw_hse
SET
	salary = vw_hse.salary + 1250
WHERE
	vw_hse <= 14500
RETURNING *;
*/

-- Veri ekleyelim => Burada NOT NULL kısıtları var, yeni bir VIEW oluşturmamız gerekiyor.
INSERT INTO vw_high_salary_emps
	(
		first_name,
		last_name,
		hire_date,
		salary
	)
VALUES
	(
		'Cemil',
		'Duzgun',
		'2018-05-19',
		12850.00
	),
	(
		'Steven',
		'McKennie',
		'2008-10-01',
		18750.00
	),
	(
		'Alexandra',
		'Juaminga',
		'2020-01-31',
		8852.00
	)
RETURNING *;

-- Veriyi çekelim => Ana tablodan
SELECT
	emp.employee_id,
	emp.first_name || ' ' || emp.last_name,
	emp.salary,
	emp.hire_date
FROM employees AS emp
ORDER BY emp.salary DESC;

-- Kaydedelim
COMMIT;



-- 2.5. "office" veri tabanında country id değeri  AU ve BR olanları VIEW ile çeken sorguyu yazınız.

SELECT
	-- c.*
	c.country_id,
	c.country_name,
	c.region_id
FROM countries AS c;


-- Transaction
BEGIN;

-- VIEW oluşturalım
CREATE OR REPLACE VIEW vw_oceania_south_america 
AS
SELECT 
    c.country_id,
    c.country_name,
    c.region_id
FROM countries AS c
WHERE c.country_id IN ('AU', 'BR');

-- VIEW'ı çekelim
SELECT * FROM vw_oceania_south_america;

-- Veri ekleyelim
INSERT INTO vw_oceania_south_america
	(	
		country_id,
		country_name,
		region_id
	)
VALUES
	(
		'NZ',
		'New Zealand',
		3
	)
RETURNING *;

-- VIEW ve ana tabloyu tekrar çekelim
SELECT 
	vw_osa.* 
FROM vw_oceania_south_america AS vw_osa;

SELECT
	c.*
FROM countries AS c;

/* Eski sorumuz karmaşık sorgu (join içerdiğinden) kaynaklı güncellemeye izin vermez. Denemeniz için bırakıyorum.
SELECT
	vw_sa.region_name,
	vw_sa.country_name,
	vw_sa.city,
	vw_sa.street_address,
	vw_sa.postal_code,
	vw_sa.state_province
FROM vw_selected_address AS vw_sa;	

-- EKleme yapalım
INSERT INTO vw_selected_address
(
	region_name,
	country_name,
	city,
	street_address,
	postal_code,
	state_province
)
VALUES
	(
		'Europe',
		'Turkey',
		'Tekirdag',
		'Serefpasa Sokak',
		'59200',
		'Suleymanpasa'
	),
	(
		'Asia',
		'Vıetnam',
		'Hanoi',
		'Ho Chi Minh',
		'700000',
		'Than Pho'
	)
RETURNING *;

-- VIEW veya ana tabloyu çekelim
SELECT
	vw_sd.*
FROM vw_selected_address AS vw_sd;
*/
-- Kaydedelim
COMMIT;

-- 2.6. "office" veri tabanında bulunan 2012 öncesi işe başlayan çalışanlara %5 ek zam yapan view'ı yazınız.

SELECT
	emp.employee_id,
	emp.first_name || ' ' || emp.last_name AS full_name,
	emp.salary, 
	emp.hire_date
FROM employees AS emp;

-- 2008 öncesi çalışanları
SELECT
	emp.employee_id,
	emp.first_name || ' ' || emp.last_name AS full_name,
	emp.salary, 
	emp.hire_date
FROM employees AS emp
WHERE EXTRACT(YEAR FROM emp.hire_date) <= 2012;


-- Transaction başlatalım
BEGIN;

-- VIEW oluşturalım
CREATE OR REPLACE VIEW vw_increased_salary_emp
AS
SELECT
	emp.employee_id,
	emp.first_name || ' ' || emp.last_name AS full_name,
	emp.salary, 
	emp.hire_date
FROM employees AS emp
WHERE EXTRACT(YEAR FROM emp.hire_date) <= 2012;

SAVEPOINT created_vw_increased_salary_emp;

-- Sorguyu çekelim
SELECT
	vw_ise.employee_id,
	vw_ise.full_name,
	vw_ise.salary,
	vw_ise.hire_date
FROM vw_increased_salary_emp AS vw_ise;

-- Güncelleme yapalım
UPDATE vw_increased_salary_emp AS vw_ise
SET
	salary = vw_ise.salary + 500
RETURNING *;
-- Tüm çalışanlara yapalım.

SELECT
	vw_ise.*
FROM vw_increased_salary_emp AS vw_ise;


-- Kaydedelim
COMMIT;


-- 2.7. "office" veri tabanında yeni bir VIEW oluşturunuz. WITH CHECK OPTION argümanı kullanınız.

SELECT
	c.country_id,
	c.country_name,
	c.region_id
FROM countries AS c
ORDER BY c.country_name;

-- Transaction başlatalım
BEGIN;

-- VIEW oluşturalım
CREATE OR REPLACE VIEW vw_selected_countries
AS
SELECT
	c.country_id,
	c.country_name,
	c.region_id
FROM countries AS c
WHERE c.country_id IN ('UK','US','BE','IL', 'KW', 'DE', 'FR')
WITH CHECK OPTION;

-- Kontrol edelim
SELECT
	vw_sc.country_id,
	vw_sc.country_name,
	vw_sc.region_id
FROM vw_selected_countries AS vw_sc;

-- Güncelleyelim veya silelim -- Country_id IL, FR olanları silelim
DELETE FROM vw_selected_countries AS vw_sc
WHERE vw_sc.country_id IN ('IL', 'FR')
RETURNING *;

-- Kaydedelim veya geriye alalım
-- ROLLBACK;
COMMIT;

	
-- 2.8. "office" veri tabanında vw_managers tablosunu kullanarak departmanı Stock Manager olanları yeni bir VIEW ile oluşturan sorguyu yazınız.

SELECT
	vw_m.*
FROM vw_managers AS vw_m;

-- Transaction başlatalım
BEGIN;

-- İlgili VIEW nesnesini de oluşturalım.
CREATE OR REPLACE VIEW vw_stock_manager
AS
SELECT
	vw_m.employee_id,
	vw_m.full_name,
	vw_m.job_title,
	vw_m.salary
FROM vw_managers AS vw_m
WHERE vw_m.job_title = 'Stock Manager';

-- Çekelim
SELECT
	-- vw_sm.*
	vw_sm.employee_id,
	vw_sm.full_name,
	vw_sm.job_title,
	vw_sm.salary
FROM vw_stock_manager AS vw_sm;
-- Kaydedelim
COMMIT;

-- 2.9. "office" veri tabanında vw_selected_address VIEW'ını silen sorguyu yazınız.

-- View nesnemizi hatırlayalım
SELECT
	vw_add.region_name,
	vw_add.country_name,
	vw_add.city,
	vw_add.street_address,
	vw_add.postal_code,
	vw_add.state_province
FROM public.vw_selected_address AS vw_add;

-- Transaction başlatalım
BEGIN TRANSACTION;

-- Silelim
DROP VIEW vw_selected_address;

-- Kaydedelim veya geriye alalım
COMMIT;


-- Transaction başlatalım
BEGIN TRANSACTION;

-- VIEW'ı silelim => NOTICE:  view "vw_selected_address" does not exist, skipping DROP VIEW
DROP VIEW IF EXISTS vw_selected_address;

-- Yeniden çekip kontrol edelim. Tabloyu bulamayağından kaynaklı hata verir.
/*ERROR:  relation "public.vw_selected_address" does not exist
 LINE 3: FROM public.vw_selected_address AS vw_add;
*/

SELECT
	vw_add.*
FROM public.vw_selected_address AS vw_add;

-- Kaydedelim
COMMIT;

-- 2.10. "office" veri tabanından 2.8. soruda oluşturulan VIEW nesnesini silen sorguyu yazınız.

-- VIEW'ı çekelim.
SELECT
	vw_sm.*
FROM vw_stock_manager AS vw_sm;

-- Transaction başlatalım
BEGIN;

-- Silelim => Başka bir view'a bağlı olduğundan hata almayız ancak ana view'ımızı silmeye kalkarsak hata alırız..
DROP VIEW IF EXISTS vw_stock_manager;

-- Kaydedelim
COMMIT;

