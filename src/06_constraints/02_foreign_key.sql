-- 1. FOREIGN KEY CONSTRAINT (FOREIGN KEY Kısıtı):
/*
-- 1.1. FOREIGN KEY Nedir?
Foreign Key (ikincil anahtar), tablolar arasında ilişkileri sağlamakta kullanılan özel bir kısıttır.


-- 1.2. SÖz Dizimi:

İkincil anahtar kısıtının oluşturulma alternatifleri mevcuttur.

```sql
-- İlk yöntem:
CREATE TABLE bagimli_tablo(
    sutun_adi veri_tipi
    REFERENCES  referans_alinacak_ebeveyn_tablo(referans_alinacak_sutun)
        [ON DELETE ACTION] | [ON UPDATE ACTION]
);

-- İkinci yöntem
CREATE TABLE bagimli_tablo(
    sutun_ismi1 veri_tipi,
    sutun_ismi2 veri_tipi,
    CONSTRAINT kisitimizin_ismi
        FOREIGN KEY (sutun_adi)
        REFERENCES bagimli_olunan_tablo(bagimli_olunan_sutun)
        [ON DELETE ACTION] [ON UPDATE ACTION]


-- Üçüncü yöntem: Sonradan eklemek istersek
ALTER TABLE bagimli_tablomuz
ADD CONSTRAINT kisit_adimiz
    FOREIGN KEY (bagimli_sutun_adimiz)
    REFERENCES bagimli_olunan_tablo(bagimli_olunan_sutun)
    [ON DELETE ACTION] [ON UPDATE ACTION];

```
Buradan pek anlaşılır olmadığını düşünüyorum. Örneklerimiz ile bunu anlaşılabilir kılmayı hedefliyorum.

-- 1.2.1. Argümanların Tanımları:
Burada gözlemlenen ACTION kısımları:

CASCADE: 
	- Parent tablodan sildiğimiz bir değer otomatik olarak chil tablodan da silinir.
	- Çok tehlikelidir. 
    
RESTRICT: 
	-Parent tabloda bir bağımlılık varsa herhangi bir işlem yapılmasına müsaade etmez. Restrict ise sorgu anında çalışır.
    
NO ACTION: 
	- RESTRICT’e çok benzer. 
	- Bağımlılıkları olan tablolarda silme ve güncelleme işlemlerimizde denetleme sağlar. 
	- Eğer uygun görmezse işleme izin vermez. 
	- RESTRICT'ten farkı ise sorgunun sonunda çalışmasıdır
	- ACTION olarak hiçbir şey vermezsek varsayılan olan argümandır.
    
SET NULL: 
- Parent tabloda silme ve güncelleme yaptığımızda ona bağlı child tabloda ki sütunun değerini otomatik olarak NULL yapar, herhangi bir hata vermez.


-- 1.3. Dikkat Edilmesi Gerekenler:
- Tabloların oluşturulması ve eklenme sırası oldukça önemlidir.
- Bağımlı olunan tabloların ve verilerin önceden oluşturulması ve eklenmesi gerekmektedir.
- Silme işlemlerinde de bağımlı olunan tabloda ON DELETE CASCADE vb. argüman kullanılırsa bağımlı olunanda da silme işlemi uyarı
verilmeden gerçekleşir.
- Kısıtlar, DML komutlarında çalıştırıldığından kaynaklı büyük miktarda veriye sahip veri tabanlarında yavaşlığa neden olabilmektedir.

*/

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 2. FOREIGN KEY EXAMPLES (FOREIGN KEY Egzersizleri):
-- 2.1. "test" veri tabanında yer alan tournament tablosuna winning_team_id sütununu ikincil anahtar yapan sorguyu yazınız.

-- Tabloyu çekelim ve bağımlılıklarını anlayalım.
SELECT
	t.tournament_id AS "Turnuva ID",
	t.tournament_name AS "Turnuva Adı",
	t.tournament_reward AS "Turnuva Ödülü",
	t.winning_team_id AS "Kazanan Takım ID",
	t.tournament_year AS "Turnuva Yılı",
	t.tournament_country_id AS "Turnuvanın Yapıldığı Ülke ID"
FROM tournament AS t
ORDER BY t.tournament_id;

-- Henüz veri eklenmemiş. Transaction başlatalım
BEGIN TRANSACTION;

-- FOREIGN KEY Ekleyelim
ALTER TABLE tournament
ADD CONSTRAINT fk_tournament_teams_winning_team
	FOREIGN KEY(winning_team_id)
	REFERENCES teams(team_id);


-- Tabloyu yeniden çekelim.
SELECT
	t.tournament_id AS "Turnuva ID",
	t.tournament_name AS "Turnuva Adı",
	t.tournament_reward AS "Turnuva Ödülü",
	t.winning_team_id AS "Kazanan Takım ID",
	t.tournament_year AS "Turnuva Yılı",
	t.tournament_country_id AS "Turnuvanın Yapıldığı Ülke ID"
FROM tournament AS t
ORDER BY t.tournament_id;

-- Kaydedelim.
COMMIT;


-- 2.2. "test" veri tabanında programs tablosunda program_type_id sütununu ikincil anahtar yapan sorguyu yazınız.

SELECT
	p.program_id AS "Program ID",
	p.program_name AS "Program Adı",
	p.program_type_id AS "Programlama Tipi ID",
	p.usage_area_id AS "Kullanım Alanı ID",
	p.popularity_rank AS "Popülerlik Sıralaması"
FROM programs AS p;

-- Transaction başlatalım
BEGIN TRANSACTION;

-- Değişikliği yapalım
ALTER TABLE programs
ADD CONSTRAINT fk_programs_program_type_ptid
	FOREIGN KEY(program_type_id)
	REFERENCES program_type(program_type_id);

-- Tabloyu çekelim ve görelim. Veya ilgili IDE üzerinden Constraints kısmına bakalım.

SELECT
	p.program_id AS "Program ID",
	p.program_name AS "Program Adı",
	p.program_type_id AS "Programlama Tipi ID",
	p.usage_area_id AS "Kullanım Alanı ID",
	p.popularity_rank AS "Popülerlik Sıralaması"
FROM programs AS p;

-- Kalıcı olarak kaydedelim.
COMMIT;

-- 2.3. "test" veri tabanında league tablosunda current_season_id sütununu ikincil anahtar yapan sorguyu yazınız.

-- Tabloyu çekelim
SELECT
	l.league_id AS "Lig ID",
	l.league_name AS "Lig Adı",
	l.current_season_id AS "Mevcut Sezon ID"
FROM league AS l
ORDER BY l.league_id;


-- Begin ile transaction başlatalım.
BEGIN;

-- Tabloya constraint ekleyelim
ALTER TABLE league
ADD CONSTRAINT fk_league_current_season
	FOREIGN KEY(current_season_id)
	REFERENCES current_season(current_season_id);

-- Kontrol edip kaydedelim.
COMMIT;

-- 2.4. "test" veri tabanında person tablosunda birth_city_id sütununu ikincil anahtar yapan sorguyu yazınız.

-- Tablomuzu çekelim ve görelim.
SELECT
	p.person_id AS "Benzersiz Kimlik",
	p.name || ' ' || p.surname AS "Ad Soyad",
	p.email AS "E-posta Adresi",
	p.birthdate AS "Doğum Tarihi",
	p.gender AS "Cinsiyet",
	p.birth_city_id AS "Doğduğu Şehir ID"
FROM person AS p
ORDER BY p.person_id;

-- Burada tasarım olarak sürekli tekrarı engellemek amacıyla genders isminde tablo oluşturabiliriz. Veri tutarlılığını artırmış olurduk:)

-- Transaction başlatalım
BEGIN;

ALTER TABLE person
ADD CONSTRAINT fk_person_city_birth_city
	FOREIGN KEY(birth_city_id)
	REFERENCES city(city_id);

-- Kontrol edelim.
SELECT
	p.person_id AS "Benzersiz Kimlik",
	p.name || ' ' || p.surname AS "Ad Soyad",
	p.email AS "E-posta Adresi",
	p.birthdate AS "Doğum Tarihi",
	p.gender AS "Cinsiyet",
	p.birth_city_id AS "Doğduğu Şehir ID"
FROM person AS p
ORDER BY p.person_id;

-- Kaydedelim
COMMIT;

-- 2.5. "test" veri tabanında programs tablosunda usage_area_id sütununu ikincil anahtar yapan sorguyu yazınız.

-- Hatırlayalım:
SELECT
	p.program_id AS "Program ID",
	p.program_name AS "Program Adı",
	p.program_type_id AS "Programlama Tipi ID",
	p.usage_area_id AS "Kullanım Alanı ID",
	p.popularity_rank AS "Popülerlik Sıralaması"
FROM programs AS p;

-- Transaction başlatalım
BEGIN;

-- Değişiklikleri yapalım.
ALTER TABLE programs
ADD CONSTRAINT fk_programs_usage_area_uaid
	FOREIGN KEY(usage_area_id)
	REFERENCES usage_areas(usage_area_id);

-- Kaydedelim.
COMMIT;

-- 2.6. "test" veri tabanında teams league_id ve country_id sütunlarını ikincil anahtar olarak gerçekleştiren sorguyu yazınız.

-- Tablomuzu seçelim
SELECT
	t.team_id AS "Takım ID",
	t.team_name AS "Takım",
	t.establishment_date AS "Kuruluş Yılı",
	t.league_id AS "Lig ID",
	t.country_id AS "Ülke ID",
	t.championships_won AS "Kazanılan Şampiyonluk Sayısı"
FROM teams AS t 
ORDER BY t.team_id;

-- Transaction başlatalım
BEGIN;

-- Tabloda kısıtları ekleyelim
ALTER TABLE teams
ADD CONSTRAINT fk_teams_league
	FOREIGN KEY(league_id)
	REFERENCES league(league_id),
ADD CONSTRAINT fk_teams_country
	FOREIGN KEY(country_id)
	REFERENCES country(country_id);


-- Test  => Önce veri eklemesi yapmamız lazımdır, league tablosuna veri ekledikten sonra gelip bu kodu çalıştırınız.
SELECT
	t.team_id AS "Takım ID",
	t.team_name AS "Takım",
	t.establishment_date AS "Kuruluş Yılı",
	t.league_id AS "Lig ID",
	t.country_id AS "Ülke ID",
	t.championships_won AS "Kazanılan Şampiyonluk Sayısı"
FROM teams AS t 
ORDER BY t.team_id;

-- Kaydedelim
COMMIT;


-- 2.7. "testchampionships_won" veri tabanında tournament tablosunda yer alan tournament_country_id sütununu ikincil anahtar olarak gerçekleştiren sorguyu yazınız.

-- Tabloyu çekelim
SELECT
	t.tournament_id AS "Turnuva ID",
	t.tournament_name AS "Turnuva Adı",
	t.tournament_reward AS "Turnuva Ödülü",
	t.winning_team_id AS "Kazanan Takım ID",
	t.tournament_year AS "Turnuva Yılı",
	t.tournament_country_id AS "Turnuvanın Yapıldığı Ülke ID"
FROM tournament AS t
ORDER BY t.tournament_id;

-- Transaction başlatalım.
BEGIN TRANSACTION;

-- Foreign Key ekleyelim
ALTER TABLE tournament
ADD CONSTRAINT fk_tournament_country_tcid
	FOREIGN KEY(tournament_country_id)
	REFERENCES country(country_id);

-- Kaydedelim
COMMIT;


-- 2.8. "test" veri tabanında ilgili tablolara veri eklemesi gerçekleştiriniz.

-- Verileri eklemek için bağımlı olmayanlardan başlamamız gerekmektedir. country vb.

BEGIN;

-- country tablosuna ekleme yapalım

INSERT INTO country
(
	country_name
)
VALUES
	('France'),
	('Belgium'),
	('Greece'),
	('Brazil'),
	('Argentina'),
	('Portugal'),
	('Netherlands')
RETURNING *;

SAVEPOINT inserted_countries;

-- Gerekirse geriye döneriz ROLLBACK TO SAVEPOINT inserted_countries;

-- Kaydedelim
COMMIT;

-- current_season için ekleme yapabiliriz ancak veriler var.

-- city tablosunun hiçbir bağımlılığı yok, onu dolduralım
SELECT
	c.*
FROM city AS c;

-- Transaction başlatalım
BEGIN;

-- Ekleyelim
INSERT INTO city
	(
		city_name,
		population
	)
VALUES
	(
		'London',
		9927000
		
	),
	(
		'Madrid',
		6800000
	),
	(
		'Sao Paulo',
		22000000
	),
	(
		'Buenos Aires',
		15891000
	),
	(
		'Istanbul',
		15600000
	),
	(
		'Paris',
		11200000
	),
	(
		'Barcelona',
		5600000
	),
	(
		'Manchester',
		3400000
	),
	(
		'Munich',
		6000000
	)
RETURNING *;

SAVEPOINT added_cities;

-- Geri dönmek istersek ROLLBACK TO SAVEPOINT added_cities;

-- Kaydedelim.
COMMIT;

-- Person tablosuna şimdi ekleme yapabiliriz.
BEGIN;

INSERT INTO person
	(
		name,
		surname,
		email,
		birthdate,
		gender, 
		birth_city_id
	)
VALUES
	(
		'Lionel',
		'Messi',
		'leo_messi@footballer.com',
		'1987/06/24',
		'Male',
		4
	),
	(
		'Cristiano',
		'Ronaldo',
		'christiano_ronaldo@footballer.com',
		'1985/02/05',
		'Male',
		8
	),
	(
		'Arda',
		'Turan',
		'arda_turan@footballer.com',
		'1987/01/30',
		'Male',
		5
	)
RETURNING *;

SAVEPOINT added_players;

-- ROLLBACK TO SAVEPOINT added_players;
-- Kaydedelim
COMMIT;


-- sports
-- Transaction başlatalım.
BEGIN;

INSERT INTO sports
	(
		sport,
		founded_year,
		popularity_rank
	)
VALUES
	(
		'Football',
		'1863/01/01',
		1
	),
	(
		'Basketball',
		'1891/10/15',
		2
	),
	(
		'Volleyball',
		'1895/01/20',
		3
	)
RETURNING *;

SAVEPOINT added_sports;

-- Kaydedelim.
COMMIT;

-- league tablosuna ekleme yapalım
BEGIN;

INSERT INTO league
	(
		league_name,
		current_season_id
	)
VALUES
	(
		'La Liga',
		2
	),
	(
		'Bundesliga',
		2
	),
	(
		'Ligue 1',
		3
	),
	(
		'Brasileirao',
		4
	),
	(
		'Süper Lig',
		4
	),
	(
		'Primeira Liga',
		5
	)
RETURNING *;

SAVEPOINT added_leagues;

-- Geri alma opsiyonumuz olsun. ROLLBACK TO SAVEPOINT added_leagues;
-- Kaydedelim.
COMMIT;

-- teams tablosuna ekleme yapalım

-- Değişiklikleri transaction içinde yapalım.
BEGIN;

-- Veri ekleyelim
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
		'Galatasaray',
		'1905-10-01',
		--7,
		(
			SELECT
				league_id
			FROM league
			WHERE league_name = 'Süper Lig'),
		--4,
		(
			SELECT
				country_id
			FROM country
			WHERE country_name = 'Turkey'
		),
		
		26
	)
RETURNING *;

-- Kaydedelim.
COMMIT;

-- tournament tablosuna ekleme yapalım. Zaten ekliler var. Bunlar yeterli.
SELECT
	t.team_id AS "Takım ID",
	t.team_name AS "Takım",
	t.establishment_date AS "Kuruluş Yılı",
	t.league_id AS "Lig ID",
	t.country_id AS "Ülke ID",
	t.championships_won AS "Kazanılan Şampiyonluk Sayısı"
FROM teams AS t 
ORDER BY t.team_id;

-- Bağımlılığı olmayan tablolardan devam edelim.

-- Transaction başlatmayı unutmayalım.
BEGIN TRANSACTION;


-- usage_areas
INSERT INTO usage_areas
	(
		usage_area
	)
VALUES
	('Data Science'),
	('Web Development'),
	('Database Management'),
	('Game Development'),
	('Mobile Development'),
	('Cybersecurity'),
	('Embedded Systems'),
	('IoT')
RETURNING *;

SAVEPOINT added_usage_areas;

-- Hata varsa: ROLLBACK TO SAVEPOINT added_usage_areas;
-- Kaydedelim.
COMMIT;


-- Transaction başlatalım
BEGIN;

-- program_type
INSERT INTO program_type
	(
		program_type_name
	)
VALUES
	('Machine Language'),
	('Low-Level Languages'),
	('Mid-Level Languages'),
	('High-Level Languages'),
	('Very High-Level')
RETURNING *;

-- Ne olur ne olmaz, geriye alabiliriz.
SAVEPOINT added_program_type;

-- ROLLBACK TO SAVEPOINT added_program_type;
-- Kaydedelim.
COMMIT;


-- programs
BEGIN TRANSACTION;

-- Programları ekleyelim
INSERT INTO programs
	(
		program_name,
		program_type_id,
		usage_area_id,
		popularity_rank
	)
VALUES
	(
		'Python',
		4,
		1,
		1
	),
	(
		'JavaScript',
		4,
		2,
		2
	),
	(
		'Java',
		4,
		5,
		3
		
	),
	(
		'C',
		3,
		7,
		4
	),
	(
		'C++',
		3,
		8,
		5
	),
	(
		'Assembly',
		2,
		7,
		9
		
	)
RETURNING *;

SAVEPOINT added_programs;

-- ROLLBACK TO SAVEPOINT added_programs;

-- Kaydedelim.
COMMIT;