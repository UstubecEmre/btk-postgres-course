-- 1. CHECK CONSTRAINT (CHECK Kısıtı):
/*
-- 1.1. CHECK Kısıtı Nedir?
CHECK kısıtı, veri girişini ve tutarlılığını sağlayan önemli bir kısıttır.
Bu kısıt sayesinde girilecek olan değerleri sınırlayabilir, veri girişinde hata ile karşılaşılmasını sağlayabiliriz.

-- 1.2. Söz Dizimi:

```sql
-- Söz dizimi
-- İlk kullanım olarak tablo oluşturulurken
CREATE TABLE tablo_ismi
(
	sutun1 veri_tipi CHECK(kisitimiz)

);

-- İkinci olarak
CREATE TABLE tablo_adi(
	sutun1 veri_tipi1,
	sutun2 veri_tipi2,
	...,
	CONSTRAINT kisit_adi CHECK(kisit)

)

-- Üçüncü olarak da sonradan ekleyebiliriz.
ALTER TABLE tablo_adi
ADD CONSTRAINT kisit_adimiz CHECK(kisit_konulacak_sutun kisitimiz);


-- Çoklu sütunlar için: İki veya daha fazla sütunu birbiriyle karşılaştırabiliriz.
CHECK(sutun_adi1 < sutun_adi2 )

```

-- 1.3. Dikkat Edilmesi Gereken Hususlar:
- CHECK kısıtında, harf duyarlılığı vardır.
- DML işlemlerinde arka planda takip edileceğinden kaynaklı performansa olumsuz etkisi de vardır.
- Daha önceden veri girişi gerçekleştirilmiş olan tablolarda verilen kısıta uymayan kayıtlar varsa, veri tabanımız
bizlere hata verecektir. 
- Bir CHECK kısıtı, ifadenin sonucu FALSE olmadığı sürece (yani TRUE veya NULL ise) veri girişine izin verir.

Bunu bertaraf etmek amacıyla:
	- Ya veri girişlerindeki değerleri güncelleyeceğiz 
	- Ya da kısıtımızı güncelleyeceğiz. 
	- NULL veri girişini engellemek için de kısıt olarak NOT NULL eklenmelidir.
	
Önemli Not:
Üretim (production) ortamlarında CHECK kısıtını sonradan eklemek istersek, sistemin eski verileri tarayıp 
kilitlenmemesi için NOT VALID ekleyebiliriz.

Örneğin:
```sql
ALTER TABLE tablo_adi
ADD CONSTRAINT kisit_adi CHECK(kisit) NOT VALID;
```

Daha sonrasında da canlı sistemi yormadan eski verileri doğrulamamız gerekmektedir.

```sql
ALTER TABLE tablo_adi
VALIDATE CONSTRAINT kisit_adimiz;
```
*/

------------------------------------------------------------------------------------------------------------------------------------------------------
-- 2. CHECK CONSTRAINT EXAMPLES (CHECK Kısıtı Örnekleri):
-- 2.1. "test" veri tabanında country_name sütununun karakter adı en az üç olan kısıtı yazınız.

-- Tablomuza bakalım.
SELECT
	c.country_id AS "Ülke ID",
	c.country_name AS "Ülke"
FROM country AS c
ORDER BY c.country_id;

-- Transaction başlatalım
BEGIN TRANSACTION;

-- Constraint ekleyelim
ALTER TABLE country
ADD CONSTRAINT ch_country_name
CHECK(LENGTH(country_name) >= 3);

-- Kaydedelim veya geriye alalım.
COMMIT;

-- pgAdmin4 üzerinden ilgili veri tabanının sütununun altında yer alan Constraints'i kontrol edelim.

-- 2.2. "test" veri tabanında person tablosunda birthdate tarihi bugünden büyük olanları kabul etmeyen sorguyu yazınız. 

-- Tablomuza bakalım
SELECT
	p.person_id AS "Kişi ID",
	p.name || ' ' || p.surname AS "Kişi",
	p.email AS "E-Posta",
	p.birthdate AS "Doğum Tarihi",
	p.gender AS "Cinsiyet",
	p.birth_city_id AS "Doğduğu Şehir ID"
FROM person AS p;

-- Transaction başlatalım
BEGIN TRANSACTION;

-- Tabloya kısıt ekleyelim.

ALTER TABLE person
ADD CONSTRAINT chk_birthdate
CHECK(birthdate <= '2026-12-31');

-- Kontrol edelim
COMMIT;


-- 2.3. "test" veri tabanında sports tablosunda founded_year sütununun 1800'den ile bugün arasında olmasını sağlayan sorguyu yazınız.

-- Tabloya bakalım
SELECT
	s.sports_id AS "Spor ID",
	s.sport AS "Spor",
	s.founded_year AS "Bulunuş Tarihi",
	s.popularity_rank AS "Popülerlik Sıralaması"
FROM sports AS s;

-- Transaction başlatalım
BEGIN;

-- Tabloya check kısıtını ekleyelim
ALTER TABLE sports
ADD CONSTRAINT chk_founded_year
CHECK(founded_year >= '1800-01-01' AND founded_year <= '2026-12-31');

-- Kaydedelim
COMMIT;

-- 2.4. "test" veri tabanında championships_won minimum değeri 0 olacak şekilde ayarlayan sorguyu yazınız.

-- İlgili tabloyu çekelim
SELECT
	t.team_id AS "Takım ID",
	t.team_name AS "Takım Adı",
	t.establishment_date AS "Kuruluş Yılı",
	t.league_id AS "Lig ID",
	t.country_id AS "Ülke ID",
	t.championships_won AS "Şampiyonluk Sayısı"
FROM teams AS t;

-- Transaction başlat
BEGIN;

-- Değiştirelim
ALTER TABLE teams
ADD CONSTRAINT chk_championships_won
CHECK(championships_won >= 0);

-- Kaydedelim
COMMIT;

-- 2.5. "test" veri tabanında tournament reward sütununa kısıt ekleyiniz.

SELECT 
	t.tournament_id AS "Turnuva ID",
	t.tournament_name AS "Turnuva Adı",
	t.tournament_reward AS "Turnuva Ödülü",
	t.winning_team_id AS "Kazanan Takım ID",
	t.tournament_year AS "Turnuva Yılı",
	t.tournament_country_id AS "Turnuvanın Yapıldığı Ülke ID"
FROM tournament AS t;


-- Minimum turnuva ödülü 0 olsun maksimum 150.000.000 yüz elli milyon
-- Transaction başlatalım
BEGIN;

-- Min ve maks değer ekleyelim
ALTER TABLE tournament
ADD CONSTRAINT chk_tournament_reward
CHECK(tournament_reward >= 0 AND tournament_reward <= 160000000);

-- Kaydedelim
COMMIT;

-- Yeni bir transaction başlatalım
BEGIN;

-- Tablomuz boşmuş, bunu da dolduralım, eksik kalmasın
INSERT INTO tournament
	(
		tournament_name,
		tournament_reward,
		winning_team_id,
		tournament_year,
		tournament_country_id
	)
VALUES
	(
		'UEFA Champions League',
		126000000,
		4,
		2010,
		(
			SELECT
				c.country_id
			FROM country AS c
			WHERE c.country_name = 'Spain'
		)
		
	)
RETURNING *;

SAVEPOINT added_uefa_tournament;

-- Kaydedelim veya ROLLBACK TO SAVEPOINT added_uefa_tournament;
COMMIT;

-- 2.6. "test" veri tabanında usage_area sütununun minimum karakter sayısını 3'e ayarlayan sorguyu yazınız.

-- Tabloyu seçelim
SELECT
	ua.usage_area_id AS "Kullanım Alanı ID",
	ua.usage_area AS "Kullanım Alanı"
FROM usage_areas AS ua;

-- Transaction başlatalım
BEGIN TRANSACTION;

-- Kısıt ekleyelim
ALTER TABLE usage_areas
ADD CONSTRAINT chk_usage_area
CHECK(LENGTH(usage_area) >= 3);

-- Kaydedelim
COMMIT;

-- 2.7. "test" veri tabanında student tablosunda minimum not 0 maksimum not 100 olacak şekilde ayarlayan sorguyu yazınız.

-- Tablomuzu görelim:)
SELECT
	s.id AS "Öğrenci ID",
	s.name AS "Öğrenci Adı Soyadı",
	s.class AS "Öğrenci Sınıfı",
	s.mark AS "Öğrenci Notu",
	s.gender AS "Öğrenci Cinsiyeti",
	s.course_name AS "Öğrenci Bölümü",
	s.email AS "Öğrenci E-Posta Adresi"
FROM student AS s;

-- Transaction başlatalım
BEGIN;

-- Değişikliği yapalım
ALTER TABLE student
ADD CONSTRAINT chk_mark
CHECK(mark >= 0 AND mark <= 100);

-- Kaydedelim
COMMIT;

-- 2.8. "test" veri tabanında tournament_year sütununu 1800 ile 2026 arasında ayarlayan sorguyu yazınız.

-- Tabloya bakalım. Eklenen veriyi kontrol edelim.
SELECT 
	t.tournament_id AS "Turnuva ID",
	t.tournament_name AS "Turnuva Adı",
	t.tournament_reward AS "Turnuva Ödülü",
	t.winning_team_id AS "Kazanan Takım ID",
	t.tournament_year AS "Turnuva Yılı",
	t.tournament_country_id AS "Turnuvanın Yapıldığı Ülke ID"
FROM tournament AS t;

-- Transaction başlatalım
BEGIN;

-- Değişikliği yapalım
ALTER TABLE tournament
ADD CONSTRAINT chk_tournament_year
CHECK(1800 <= tournament_year AND tournament_year <= 2026);

-- Kaydedelim.
COMMIT;

-- 2.9. "test" veri tabanında gender tablosunda sadece Male veya Female girişlerini yapacak şekilde kısıt ekleyiniz.

SELECT
	p.person_id AS "Kişi ID",
	p.name || ' ' || p.surname AS "Kişi",
	p.email AS "E-Posta",
	p.birthdate AS "Doğum Tarihi",
	p.gender AS "Cinsiyet",
	p.birth_city_id AS "Doğduğu Şehir ID"
FROM person AS p;

-- Transaction başlatalım
BEGIN TRANSACTION;

-- Güncellemeyi yapalım
ALTER TABLE person
ADD CONSTRAINT chk_gender
CHECK(gender IN ('Male', 'Female', 'Other'));

-- Kaydedelim
COMMIT;


-- 2.10. "test" veri tabanında yer alan student sütunundaki sınıfı 9, 10, 11, 12 olacak şekilde sınırlayan kısıtı ekleyiniz.

-- Tablomuzu görelim:)
SELECT
	s.id AS "Öğrenci ID",
	s.name AS "Öğrenci Adı Soyadı",
	s.class AS "Öğrenci Sınıfı",
	s.mark AS "Öğrenci Notu",
	s.gender AS "Öğrenci Cinsiyeti",
	s.course_name AS "Öğrenci Bölümü",
	s.email AS "Öğrenci E-Posta Adresi"
FROM student AS s;

-- Transaction başlatalım
BEGIN;

-- Değişikliği yapalım
ALTER TABLE student
ADD CONSTRAINT chk_class
CHECK("class" >= 1 AND "class" <= 12); 
-- Burada class reserve key olduğundan biraz sorunlu. Normal şartlarda student_class isimlendirmesi daha hoş olurmuş.

-- Kaydedelim
COMMIT;

