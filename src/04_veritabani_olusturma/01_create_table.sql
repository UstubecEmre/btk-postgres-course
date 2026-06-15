-- 1. Create Database and Tables (Veri Tabanı ve Tablo Oluşturma):
/*
Şu ana kadar olan ki dosyalarımızda hazır var olan veri tabanları ve bunların tablolarını kullanmıştık.
Bu andan itibaren kendi veri tabanlarımızı ve tablolarımızı nasıl oluturabileceğimizi göreceğiz.

-- 1.1. Tablo Oluşturmanın Önemli Noktaları:
Bir tabloyu oluştururken, verilerin türüne ve içeriğine göre sütunlarımızın veri tiplerini seçmemiz gerekmektedir.
Bunun için veri tiplerini bilmemiz gerekmektedir.

-- 1.2. En Çok Kullanılan Veri Tipleri Hatırlatma:
Veri tiplerini de Metinsel, Sayısal, Tarih, Tarih-Zaman vb. olarak kategorize edebiliriz.

-- 1.2.1. Metinsel Veri Tipleri:
Karakter veri tipine sahip veri tipleridir.
- CHAR(karakter_uzunlugu): Karakterden gelmektedir, sabit uzunluklu metinsel ifadeleri saklamak için kullanılan veri tipidir.
- VARCHAR(karakter_uzunlugu): Variable Character yani değişken uzunluklu metinsel ifadeleri saklamak için kullanılan veri tipidir.
- TEXT / VARCHAR: Sınırsız uzunluklu metinleri saklamak için tercih edebileceğimiz veri tipidir.

-- 1.2.2. Sayısal Veri Tİpleri:
Sayısal ifadeleri (tam sayı veya ondalıklı sayı) saklayabilmek amacıyla kullanılan veri tipleridir.
Veri tipinin sınırlarına ve kapladığı alana göre iyi tercihte bulunmamız gerekmektedir.

- SMALLINT, INT, BIGINT: Tam sayıları ifade etmek için kullanılan veri tipleridir.
- SMALLSERIAL, SERIAL, BIGSERIAL: Veri tabanı arka planda otomatik artan bir şekilde sequence oluşturulur.
Özel bir veri türüdür.
- NUMERIC(m,d): m basamak sayısını, d ise ondalık noktadan sonraki basamak sayısını ifade eder.
- DOUBLE PRECISION, REAL: Ondalıklı sayılar için tercih edilen veri tipleridir. Bellekte kapladıkları alan farklılık göstermektedir.
- MONEY: Para biriminin tutulabileceği veri tipidir.

-- 1.2.3. Tarih ve Tarih Zaman Veri Tipleri:
- DATE: Sadece tarih değerlerinin tutulduğu veri türüdür.
- TIME: Sadece saat bilgilerinin tutulduğu veri türüdür.
- TIME WITH TIME ZONE: Zaman alanı ile birlikte saatin tutulduğu veri türüdür.
- TIMESTAMP: Zaman damgası veri türünde ise tarih ve saat bilgileri tutulur.
- TIMESTAMP WITH TIME ZONE (TIMESTAMPTZ): Tarih, saat ve zaman bölgesinin tutulmak istediği durumlarda tercih edilecek veri türüdür.
- INTERVAL: Zaman aralığını tutan veri türüdür.

-- 1.2.4. Boolen ve Binary Veri Tipleri:
İki değer alabilen veri türüdür.
Karşılaştırma ifadelerinde, mantıksal operatörlerde sıklıkla tercih edilirler.
BOOLEAN: İki değer alabilen ifadelerdir. (TRUE / FALSE/ NULL): 
BYTEA (Byte Array): Küçük resimler, dosyalar ve hash'lerin tutulabildiği veri türüdür.

Bu tablolar uzayıp gider, konuyu dağıtmamak amacıyla burada durmak daha iyi.

-- 1.3. Veri Tabanı Oluşturma:
 Veri tabanını oluşturmak oldukça kolaydır.
 Nesneleri oluşturmak için kullanılan önemli komutumuz CREATE ifadesidir.

 ```sql
 -- Veri tabanı oluşturmak için
 CREATE DATABASE veri_tabani_ismi;
 ```
 
-- 1.4. Tablo Oluşturma Yöntemleri:
Bir veri tabanında tablolarımızı oluşturmanın çeşitli yöntemleri vardır.
Bunlar:
- CREATE TABLE ile Tablo Oluşturma
- SELECT INTO ile Tablo Oluşturma
- CREATE TABLE AS ile Tablo Oluşturma 
olarak kategorize edilebilir.

Bunların örneklerini ilgili .sql uzantılı dosyalarda bolca göreceksiniz:)

```
*/
-----------------------------------------------------------------------------------------------------

-- 2. CREATE DATABASE & TABLE Statement (Veri Tabanı ve Tablo Oluşturma İfadesi):
-- 2.1. "my_created_db" isminde bir veri tabanı oluşturan sorguyu yazınız.

-- Veri tabanını oluşturalım
CREATE DATABASE my_created_db;


-- 2.2. "test" veri tabanını kullanarak teams isminde bir tablo oluşturunuz ve içerisinde team_id, team_name, established_date, league_id, country_id championships_won vb. sütunlar yer alsın.

-- Transaction başlatalım.
BEGIN;

-- Tablomuzu oluşturalım
CREATE TABLE IF NOT EXISTS teams(
	team_id SMALLSERIAL PRIMARY KEY,
	team_name VARCHAR(100) NOT NULL UNIQUE,
	establishment_date DATE,
	league_id SMALLINT, 
	country_id SMALLINT,
	championships_won SMALLINT
);

-- Kaydedelim veya geriye alalım COMMIT, ROLLBACK
COMMIT;

-- 2.3. "test" veri tabanında league isminde bir tablo oluşturunuz ve içerisinde league_id, league, current_season vb. sütunlar yer alsın.

-- Transaction başlatalım
BEGIN TRANSACTION;

-- Tabloyu oluşturalım
CREATE TABLE IF NOT EXISTS league(
	league_id SMALLSERIAL PRIMARY KEY,
	league VARCHAR(60) NOT NULL UNIQUE,
	current_season_id SMALLINT 
);

-- Kaydedelim
COMMIT;

-- Transaction başlatalım
BEGIN;

-- current_season tablosunu oluşturalım
CREATE TABLE IF NOT EXISTS current_season(
    current_season_id SMALLSERIAL PRIMARY KEY,
    season_year CHAR(9) NOT NULL UNIQUE
);

-- Kaydedelim
COMMIT;


-- 2.4. "test" veri tabanında fans isminde bir tablo oluşturunuz. İçerisinde fan_id, name, surname, birthdate, gender, supported_team_id vb. yer alsın.

-- Transaction başlatalım
BEGIN TRANSACTION;

-- İki adet tablo oluşturalım
CREATE TABLE IF NOT EXISTS fans(
	fan_id SMALLSERIAL PRIMARY KEY,
	person_id SMALLINT,
	supported_team_id SMALLINT -- SMALLSERIAL olarak kaydettim, değiştirmek amaçlı
);
-- Savepoint ekleyelim
SAVEPOINT created_fans;

-- Kaydedelim.
COMMIT;

-- Transaction başlatalım
BEGIN;

-- Person tablosu oluşturalım.
CREATE TABLE IF NOT EXISTS person(
	person_id SMALLSERIAL PRIMARY KEY,
	name VARCHAR(50) NOT NULL,
	surname VARCHAR(50) NOT NULL,
	email VARCHAR(75) NOT NULL UNIQUE,
	birthdate DATE DEFAULT '1980-01-25',
	gender VARCHAR(6) NOT NULL DEFAULT 'Male'
);

-- Kaydedelim
COMMIT;

-- 2.5. "test" veri tabanında country adında bir tablo oluşturunuz. İçerisinde country_id ve country sütunları yer alsın.

-- Transaction başlatalım
BEGIN;

-- İstenilen tablomuzu oluşturalım
CREATE TABLE IF NOT EXISTS country(
	country_id SMALLSERIAL PRIMARY KEY,
	country_name VARCHAR(48) NOT NULL UNIQUE
);

-- Kaydedelim veya geriye alalım.
COMMIT;

-- 2.6. "test" veri tabanında tournament  isminde bir tablo oluşturunuz. Bu tabloda da tournament_id, tournament_name, tournament_reward, winning_team_id, tournament_year sütunları yer alsın.

-- Transaction başlatalım
BEGIN;

-- İstenilen tablomuzu oluşturalım
CREATE TABLE IF NOT EXISTS tournament(
	tournament_id SMALLSERIAL PRIMARY KEY,
	tournament_name VARCHAR(80) NOT NULL UNIQUE,
	tournament_reward INT,
	winning_team_id SMALLINT,
	tournament_year DATE DEFAULT '2016-01-01'
);

-- Kaydedelim veya geriye alalım.
COMMIT;

-- 2.7. "test" veri tabanında sports isminde bir tablo olsun. İçerisinde sports_id, sport, founded_year sütunları yer alsın.

-- Transaction başlatalım
BEGIN;

-- İstenilen tablomuzu oluşturalım
CREATE TABLE IF NOT EXISTS sports(
	sports_id SMALLSERIAL PRIMARY KEY,
	sport VARCHAR(30) NOT NULL UNIQUE, 
	founded_year DATE DEFAULT '1989-01-05'
);

-- Kaydedelim veya geriye alalım.
COMMIT;

-- 2.8. "test" veri tabanında programs isminde bir tablo oluşturunuz. program_id, program_type , usage_area_id, popularity_rank

-- Transaction başlatalım
BEGIN TRANSACTION;

-- İstenilen tablomuzu oluşturalım
CREATE TABLE IF NOT EXISTS program_type(
	program_type_id SMALLSERIAL PRIMARY KEY,
	program_type_name VARCHAR(30) NOT NULL UNIQUE
);

SAVEPOINT created_program_type;


CREATE TABLE IF NOT EXISTS usage_area(
	usage_area_id SMALLSERIAL PRIMARY KEY,
	usage_area VARCHAR(30) NOT NULL UNIQUE
);

SAVEPOINT created_usage_area;

CREATE TABLE IF NOT EXISTS programs(
	program_id SMALLSERIAL PRIMARY KEY,
	program_name VARCHAR(30) NOT NULL UNIQUE,
	program_type_id SMALLINT,
	usage_area_id SMALLINT,
	popularity_rank SMALLINT
);

-- Kaydedelim veya geriye alalım.
COMMIT;

-- 2.9. "test" veri tabanında oluşturulan tablolara en az 3 kayıt ekleyiniz.

-- Transaction başlatalım
BEGIN;

INSERT INTO current_season AS cs
    (
        season_year
    )
VALUES
    ('2016-2017'),
    ('2017-2018'),
    ('2018-2019'),
    ('2019-2020'),
    ('2020-2021'),
    ('2021-2022'),
    ('2022-2023'),
    ('2023-2024'),
    ('2024-2025'),
    ('2025-2026')
RETURNING 
    cs.current_season_id AS "Eklenen Sezon ID",
    cs.season_year AS "Eklenen Sezon Yılı";

SAVEPOINT added_seasons;

-- Kaydedelim veya geriye alalım.
COMMIT;


-- Transaction başlatalım
BEGIN;
INSERT INTO league AS l
    (
        league,
        current_season_id
    ) 
VALUES
    (
        'Premier League',
        1
    ),
    (
        'Serie A',
        1
    )
RETURNING
	l.league_id AS "Eklenen Lig ID",
	l.league AS "Eklenen Lig";

COMMIT;



-- Transaction başlatalım
BEGIN;


-- Country tablosunu dolduralım
INSERT INTO country AS c
	(
		country_name
	)
VALUES
	('England'),
	('Spain'),
	('Germany'),
	('Turkey'),
	('Italy')
RETURNING
	c.country_id AS "Eklenen Ülke ID",
	c.country_name AS "Eklenen Ülke Adı";

-- Ne olur ne olmaz, savepoint koyalım
SAVEPOINT added_countries;

-- Kaydedelim.
COMMIT;

-- Transaction başlatalım
BEGIN;

-- İstenilen tabloya güncelleme yapalım
INSERT INTO teams
	(
		team_name,
		establishment_date,
		league_id,
		country_id,
		championships_won
	)
VALUES
	(
		'Sheffield FC',
		'1857-10-24',
		1, -- İngiltere Premier Lig
		1, -- İngiltere
		0 -- kupa kazanamamış
	),
	(
		'Notts County FC',
		'1862-11-28',
		1,
		1,
		0
	),
	(
		'Genoa CFC',
		'1893-09-07',
		2, -- Serie A
		5, -- italya
		9
	),
	(
		'FC Barcelona',
		'1899-11-29',
		3, -- La Liga
		2, -- İspanya
		27
	),
	(
		'Bayern Munich',
		'1900-02-27',
		4, -- Bundesliga,
		3, -- Almanya 
		32
	)
RETURNING *;


-- Kaydedelim veya geriye alalım.
-- COMMIT veya ROLLBACK;

-- Kaydedelim
COMMIT;



-- 2.10. "test" veri tabanında ilgili tablolarda güncelleme ve silme işlemlerini gerçekleştirebilirsiniz.

-- Tablomuzu inceleyelim, eklemeler olmuş mu kontrol edelim.
SELECT
	t.team_id AS "Takım ID",
	t.team_name AS "Takım Adı",
	t.establishment_date AS "Kuruluş Tarihi"
FROM teams AS t;

-- Transaction başlatalım
BEGIN;

-- İstenilen tablodan veri silelim veya modifiye edelim
UPDATE teams AS t
SET 
	championships_won = 33
WHERE t.team_id = (
	SELECT
		te.team_id
	FROM teams AS te
	WHERE te.team_name = 'Bayern Munich'
)
RETURNING *;

-- savepoint ekleyelim.
SAVEPOINT updated_bayern;

DELETE FROM teams AS t
WHERE
	t.team_id = (
		SELECT
			MAX(te.team_id)
		FROM teams AS te
	)
RETURNING	
	t.team_id AS "Silinen Takım ID",
	t.team_name AS "Silinen Takım";

-- Geriye alalım
ROLLBACK TO SAVEPOINT updated_bayern;

-- Veya işlemi geriye alalım
COMMIT; -- ROLLBACK;




