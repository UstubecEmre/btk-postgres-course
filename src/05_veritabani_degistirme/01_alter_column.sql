-- 1. ALTER COLUMN COMMANDS (Tablo ve Sütun Değiştirme Komutları):
/*
Bir veri tabanını tasarlarken, bu veri tabanının sütun isimlerinde, veri tiplerinde,
kısıtlarında vb. hatalar gerçekleştirebiliriz.

Bu nedenle sütunların isimlerini, veri tiplerini, kısıtlamalarını değiştirebiliriz.

-- 1.1. Sütun Ekleme:
Veri tabanını tasarlarken gözden kaçırmış olduğumuz sütun veya sütunlar olabilir.
Ya da yöneticimiz veya ekibimizin talebi üzerine değişiklik yapma gereği duyabiliriz.

```sql
-- Tek sütun için Söz dizimine bakalım.
ALTER TABLE tablo_ismi
ADD COLUMN kolon_ismi veri_tipi
	[sutun_kisiti],
	[varsayilan_deger];
	
```

```sql
-- Söz dizimi:
ALTER TABLE tablo_ismimiz
ADD COLUMN sutun_ismi1 veri_tipi1,
ADD COLUMN sutun_ismi2 veri_tipi2,
ADD COLUMN sutun_ismi3 veri_tipi3;

```

-- 1.2. Sütunun İsmini Değiştirme
Sütunun ismini değiştirmek için RENAME komutunu kullanabiliriz.

```sql

-- Söz dizimini inceleyelim
ALTER TABLE tablo_ismi
RENAME COLUMN eski_sutun_ismi TO yeni_sutun_ismi;

```

Burada da dikkat edilmesi gereken durumlar var:
- Değişiklik yapılan sütunun bağlı olduğu view vb. nesneler oluşturulmuşsa, etkilenebilir.
- Bu değişiklik yapılırken ve yapıldıktan sonra aksaklık olmaması nedeniyle çalışılan ekibe bilgi
- verilmesi iyi olacaktır.

-- 1.3. Sütunun Veri Tipini Değiştirme:
Veri tipini değiştirmek için değiştirilecek veri tipiyle kayıtların veri tiplerinin uyumlu olması gerekmektedir.

```sql

-- Söz dizimine bakalım
ALTER TABLE table_name
ALTER COLUMN column_name1 [SET DATA] TYPE new_data_type,
ALTER COLUMN column_name2 [SET DATA] TYPE new_data_type;


```

-- 1.4. Sütuna Varsayılan Değerini Değiştirme:
Söz dizimini inceleyelim.

```sql
ALTER TABLE table_name
ALTER COLUMN column_name
[SET DEFAULT value | DROP DEFAULT];
```

Görüldüğü üzere yeni bir varsayılan değer verebiliriz veya varolanı silebiliriz.


-- 1.5. Sütuna NOT NULL Kısıtı Ekleme ve Kaldırma:

```sql
ALTER TABLE table_name
ALTER COLUMN column_name 
[SET NOT NULL | DROP NOT NULL];
```

Burada da dikkat edilmesi gereken hususlar vardır.
Örneğin, NOT NULL kısıtı getirmek isteyelim, eğer ki kayıtlarımızda bir tane dahi
NULL değer varsa bu işlem gerçekleşmeyecektir, öncelikle NULL değeri doldurmamız gerekmektedir.


-- 1.6. Sütuna Yorum Ekleme:
Tablolara ve sütunlara yorum ekleyebiliriz.
Bu durum, hem dokümantasyon hem de çalışma açısından bizlere fayda sağlamaktadır.
İş birliğini de artırmaktadır.

```sql
-- Söz dizimine bakalım
COMMENT ON TABLE table_name IS comment;
```


-- 1.7. Sütun Kaldırma:
Son olarak da sütun kaldırmayı görelim.

```sql
-- Söz dizimine bakalım.
ALTER TABLE table_name
DROP COLUMN column_name;
```

Önemli Notlar:
- Değiştirilecek sütunların veri tiplerine hakim olmamız ve içindeki kayıtlarla uyumlu olmasını sağlamalıyız.
- Yapılacak değişiklikler için işbirliği içerisinde olduğumuz paydaşlara, ekip arkadaşlarımıza vb. bilgilendirmeler yapmamız iyi olacaktır.
- Kolon kaldırma işleminde içindeki veriler önemliyse, bunları yedeklememiz ve ardından kaldırmamız daha doğru olacaktır.
*/

-------------------------------------------------------------------------------------------------------------------------------------------------------
-- 2. ALTER COLUMN EXAMPLES:
-- 2.1. "test" veri tabanında yer alan sports tablosuna popularity_rank isminde yeni bir sütun ekleyiniz.

-- Tablomuzu çekelim. Henüz veri yok
SELECT
	s.sports_id AS "Spor ID",
	s.sport AS "Spor",
	s.founded_year AS "Bulunuş Yılı"
FROM sports AS s
ORDER BY s.sports_id;

-- Transaction başlatalım
BEGIN;

-- Sütun ekleyelim.
ALTER TABLE sports
ADD COLUMN popularity_rank SMALLINT;

-- Kaydedelim
COMMIT;

-- Kontrol edelim
SELECT
	s.sports_id AS "Spor ID",
	s.sport AS "Spor",
	s.founded_year AS "Bulunuş Yılı",
	s.popularity_rank AS "Popülerlik Sıralaması"
FROM sports AS s
ORDER BY s.sports_id;


-- 2.2. "test" veri tabanında yer alan teams tablosunun establishment_date varsayılan değerini '1990-01-01' olarak belirleyiniz.
-- Tabloyu görelim.
SELECT
	t.team_id AS "Takım ID",
	t.team_name AS "Takım Adı",
	t.establishment_date AS "Kuruluş Yılı",
	t.league_id AS "Lig ID",
	t.country_id AS "Ülke ID",
	t.championships_won AS "Şampiyonluk Sayısı"
FROM teams AS t;

-- Transaction başlatalım
BEGIN;

-- İstenilen değişikliği yapalım
ALTER TABLE teams
ALTER COLUMN establishment_date
SET DEFAULT '1990-01-01';

-- Kaydedelim.
COMMIT;


-- 2.3. "test" veri tabanında yer alan programs tablosunda program_name sütununun karakter sayısını 36 yapan sorguyu yazınız.

-- Tabloyu çekelim
SELECT
	p.program_id AS "Program ID",
	p.program_name "Program Adı",
	p.program_type_id "Program Tipi ID",
	p.usage_area_id AS "Kullanım Alanı ID",
	p.popularity_rank AS "Popülerlik Sıralaması"
FROM programs AS p
ORDER BY p.program_id;

-- Transaction başlatalım
BEGIN TRANSACTION;

-- Sütunda değişiklik yapalım. Eski değeri 30 karakterdi.
ALTER TABLE programs 
ALTER COLUMN program_name TYPE VARCHAR(36);

-- Kaydedelim
COMMIT;


-- 2.4. "test" veri tabanında yer alan tournament_year veri tipini DATE'ten SMALLINT olarak ayarlayınız.
SELECT
	t.tournament_id AS "Turnuva ID",
	t.tournament_name AS "Turnuva Adı",
	t.tournament_reward AS "Turnuva Ödülü",
	t.winning_team_id AS "Kazanan Takım ID",
	t.tournament_year AS "Turnuva Yılı"
FROM tournament AS t;


-- Transaction başlatalım
BEGIN TRANSACTION;

-- Veri tipini değiştirelim. Öncelikle DEFAULT değeri silmemiz gerekmektedir.
ALTER TABLE tournament
ALTER COLUMN tournament_year
DROP DEFAULT;


SAVEPOINT deleted_default_val;

COMMIT;

-- Transaction başlatalım
BEGIN;

-- Şimdi yeni veri tipini deneyelim.
ALTER TABLE tournament
ALTER COLUMN tournament_year 
TYPE SMALLINT
USING EXTRACT(YEAR FROM tournament_year)::SMALLINT;

-- Kaydedelim.
COMMIT;


-- 2.5. "test" veri tabanında league tablosunda league sütununu league_name olarak değiştiren sorguyu yazınız.

--Tabloyu çekelim
SELECT
	l.league_id AS "Lig ID",
	l.league AS "Lig",
	l.current_season_id AS "Devam Eden Sezon ID"
FROM league AS l;


-- Transaction başlatalım
BEGIN TRANSACTION;

-- Tabloda sütun ismini değiştirelim
ALTER TABLE league
RENAME COLUMN league TO league_name;

-- Kaydedelim.
COMMIT;

--Tabloyu çekelim
SELECT
	l.league_id AS "Lig ID",
	l.league_name AS "Lig",
	l.current_season_id AS "Devam Eden Sezon ID"
FROM league AS l;

-- 2.6. "test" veri tabanında person tablosunda gender'daki DEFAULT değeri kaldıran sorguyu yazınız.

-- Tabloyu çekelim
SELECT
	p.person_id AS "Kişi ID",
	p.name || ' ' || p.surname AS "Kişi",
	p.email AS "Email Adresi",
	p.birthdate AS "Doğum Tarihi",
	p.gender AS "Cinsiyet"
FROM person AS p;

-- Transaction başlatalım
BEGIN;

-- Değişikliği yapalım
ALTER TABLE person
ALTER COLUMN gender
DROP DEFAULT;

-- Kaydedelim.
COMMIT;


-- 2.7. "test" veri tabanında person tablosuna birth_city_id isminde bir sütun ekleyiniz.

-- Tablomuza yeniden bakalım.

SELECT
	p.person_id AS "Kişi ID",
	p.name || ' ' || p.surname AS "Kişi",
	p.email AS "Email Adresi",
	p.birthdate AS "Doğum Tarihi",
	p.gender AS "Cinsiyet"
FROM person AS p;


-- Transaction başlatalım
BEGIN TRANSACTION;

-- Değişikliği yapalım
ALTER TABLE person 
ADD COLUMN birth_city_id SMALLINT;

-- Kaydedelim
COMMIT;


-- Tablomuzu kontrol edelim.

SELECT
	p.person_id AS "Kişi ID",
	p.name || ' ' || p.surname AS "Kişi",
	p.email AS "Email Adresi",
	p.birthdate AS "Doğum Tarihi",
	p.gender AS "Cinsiyet",
	p.birth_city_id AS "Doğduğu Şehir ID"
FROM person AS p;

-- 2.8. "test" veri tabanında tourmanent tablosuna tournament_country_id isminde bir sütun ekleyiniz.

SELECT
	t.tournament_id AS "Turnuva ID",
	t.tournament_name AS "Turnuva Adı",
	t.tournament_reward AS "Turnuva Ödülü",
	t.winning_team_id AS "Kazanan Takım ID",
	t.tournament_year AS "Turnuva Yılı"
FROM tournament AS t;

-- Transaction başlatalım
BEGIN TRANSACTION;

-- Yeni sütunumuzu ekleyelim
ALTER TABLE tournament
ADD COLUMN tournament_country_id SMALLINT;

-- Kaydedelim
COMMIT;

-- Tablodan da emin olalım.
SELECT
	t.tournament_id AS "Turnuva ID",
	t.tournament_name AS "Turnuva Adı",
	t.tournament_reward AS "Turnuva Ödülü",
	t.winning_team_id AS "Kazanan Takım ID",
	t.tournament_year AS "Turnuva Yılı",
	t.tournament_country_id AS "Turnuva Ülke ID"
FROM tournament AS t;

-- 2.9. "test" veri tabanında tournament tablosunda winning_team_id NOT NULL kısıtı ekleyiniz.

SELECT
	t.tournament_id AS "Turnuva ID",
	t.tournament_name AS "Turnuva Adı",
	t.tournament_reward AS "Turnuva Ödülü",
	t.winning_team_id AS "Kazanan Takım ID",
	t.tournament_year AS "Turnuva Yılı",
	t.tournament_country_id AS "Turnuva Ülke ID"
FROM tournament AS t;
	

-- Transaction başlatalım
BEGIN TRANSACTION;


-- NOT NULL kısıtını ekleyelim
ALTER TABLE tournament
ALTER COLUMN winning_team_id
SET NOT NULL;

-- Kaydedelim
COMMIT;

-- 2.10. "test" veri tabanı için city isminde bir tablo oluşturunuz, buna kısıtlar ekleyiniz.

-- Transaction başlatalım.
BEGIN TRANSACTION;

-- Tablomuzu oluşturalım.

CREATE TABLE IF NOT EXISTS city(
	city_id SERIAL PRIMARY KEY,
	city_name VARCHAR(50) UNIQUE NOT NULL,
	population INT DEFAULT '100000',
	avg_income INT
);

-- SAVEPOINT ekleyelim
SAVEPOINT created_city;

-- Kaydedelim
COMMIT;

-- Tabloyu çekip gözlemleyelim.
SELECT
	c.city_id AS "Şehir ID",
	c.city_name AS "Şehir",
	c.population AS "Şehir Popülasyonu",
	c.avg_income AS "Ortalama Gelir"
FROM city AS c;

-- Transaction ile işlemimize başlayalım
BEGIN;


-- Tablodan kolon silelim
ALTER TABLE city
DROP COLUMN avg_income;

-- Kaydedelim
COMMIT;

-- Tabloyu çekip gözlemleyelim. Hata verecektir (column c.avg_income does not exist).
-- Bunun için c.avg_income sütununu yorum satırına alacağız

SELECT
	c.city_id AS "Şehir ID",
	c.city_name AS "Şehir",
	c.population AS "Şehir Popülasyonu"
	-- c.avg_income AS "Ortalama Gelir"
FROM city AS c;

