-- 1. PRIMARY KEY CONSTRAINT (PRIMARY KEY Kısıtı):
/*

-- 1.1. Primary Key Nedir?

PRIMARY KEY (Birincil Anahtar): İlişkisel veri tabanlarında genellikle her tabloda bir primary key olması tavsiye edilir.
UNIQUE’lik sağlar.
Arka planda her bir primary key (birincil anahtar) için index oluşturulur.
Bu da sorgularımızın daha hızlı bir şekilde gerçekleşmesini sağlamaktadır.

-- 1.2. Primary Key Söz Dizimi:
Tablomuzdaki sütunlara birincil anahtar (primary key) eklemenin birkaç alternatifi bulunmaktadır.

```sql

-- 1.Yöntem => Tablo oluşturulurken sütun yanına ekleme
CREATE TABLE tablo_adi
(
    sutun_adi1 veri_tipi1 PRIMARY KEY,
	sutun_adi2 veri_tipi2,
	...

);

-- 2. yöntem => Birden fazla birincil anahtar vermek için kullanılan yöntem
CREATE TABLE tablo_adi
(
    sutun_adi1 veri_tipi1,
	sutun_adi2 veri_tipi2,
	
	...
	 PRIMARY KEY(sutun_adi1, sutun_adi2)
);

-- 3. Yöntem => Sonradan ekleme ile 
ALTER TABLE tablo_adi
ADD PRIMARY KEY(sutun_adi)

-- Ya da
ALTER TABLE tablo_adi
ADD CONSTRAINT kisit_adi PRIMARY KEY(sutun_adi);

```

Önemli Notlar:
- PRIMARY KEY, en çok tercih edilen kısıtlardandır.
- Verilerimizin tutarlılığını ve takip edilmesini sağlar.
- Arka planda oluşturulan indexler sayesinde sorgu hızımızı artırmaktadır.
- DML komutları ile kullanılırken diğer kısıtlamalarda olduğu gibi (constraints) arka planda kontrol edilir,
bu da veri tabanımızın yavaşlamasına neden olmaktadır.


*/
------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 2. PRIMARY KEY EXAMPLES (Birincil Anahtar Örnekleri):

-- 2.1. "test" veri tabanında yer alan colors tablosuna color_id sütununu ekleyiniz ve bunu primary key yapınız.

SELECT
	c.color AS "Renk"
FROM colors AS c;


--Transaction başlatalım
BEGIN TRANSACTION;

-- Tablomuzu değiştirelim
ALTER TABLE colors
ADD COLUMN color_id SERIAL
CONSTRAINT pk_color_id PRIMARY KEY;


-- Kontrol edelim.
SELECT
	c.*
FROM colors AS c;

-- Kaydedelim veya geriye alalım. Tablodaki veri bütünlüğünü bozmayalım.
ROLLBACK;

-- 2.2. "test" veri tabanında games isminde bir tablo oluşturunuz. game_id sütununu primary key yapınız.

--Transaction başlatalım
BEGIN TRANSACTION;

-- Tabloyu oluşturalım

CREATE TABLE IF NOT EXISTS games
(
	game_id SMALLSERIAL, --PRIMARY KEY,
	gamer_id SMALLINT,
	popularity_rank SMALLINT,
	CONSTRAINT pk_game_id PRIMARY KEY(game_id)
);

-- Çekelim
SELECT
	g.game_id AS "Oyun ID",
	g.gamer_id AS "Oyuncu ID",
	g.popularity_rank AS "Popülerlik Sıralaması"
FROM games AS g;

-- Geriye alalım
ROLLBACK;


-- 2.3. "test" veri tabanında gamers isminde bir tablo oluşturunuz ve burada da gamers_id sütununu primary key yapınız.

-- Transaction başlatalım
BEGIN TRANSACTION;

-- Tablomuzu oluşturalım
CREATE TABLE IF NOT EXISTS gamers
(
	gamers_id SMALLSERIAL, -- Yanına PRIMARY KEY ekleyebiliriz
	user_name VARCHAR(50),
	user_rank SMALLINT,
	favorite_game_id SMALLINT,
	-- avg_access_time SMALLINT eklenebilir.
	CONSTRAINT pk_gamers_id PRIMARY KEY(gamers_id)
);


-- Tabloyu çekelim
SELECT
	g.gamers_id AS "Oyuncu ID",
	g.user_name AS "Kullanıcı Adı",
	g.user_rank AS "Kullanıcı Sıralaması",
	g.favorite_game_id AS "Favori Oyun ID"
FROM gamers AS g;

-- Geriye alalım
ROLLBACK;


-- 2.4. "test" veri tabanında exams isminde bir tablo oluşturunuz. supervisor ve exeminee sütunları primary key olsun

-- Transaction başlatalım
BEGIN TRANSACTION;

-- Tabloyu oluşturalım
CREATE TABLE IF NOT EXISTS exams(
	-- exam_id SMALLSERIAL PRIMARY KEY, -- Ben olsam böyle yapardım, ancak deneme amaçlı bu tabloyu oluşturuyoruz.
	supervisor_id SMALLSERIAL,
	testee_id SMALLSERIAL,
	exam_name VARCHAR(50),
	exam_date TIMESTAMP,
	exam_duration TIME,
	exam_address VARCHAR(300),
	is_invalid BOOL,
	CONSTRAINT pk_exams_supervisor_testee PRIMARY KEY(supervisor_id, testee_id)
);


-- Tablo oluştu mu diye kontrol edelim
SELECT
	e.supervisor_id AS "Gözetmen ID",
	e.testee_id AS "Sınava Giren ID",
	e.exam_name AS "Sınav İsmi",
	e.exam_date AS "Sınav Tarihi",
	e.exam_duration AS "Sınav Süresi"
FROM exams AS e;


-- Geriye alalım
ROLLBACK;


-- 2.5. "test" veri tabanına supervisor isminde bir tablo ekleyiniz. supervisor_id'yi primary key yapınız.

-- Transaction başlatalım
BEGIN TRANSACTION;

-- Tablomuzu oluşturalım
CREATE TABLE IF NOT EXISTS supervisors
(
	supervisor_id SMALLSERIAL,
	exam_id SMALLINT,
	experiment_year SMALLINT,
	assigned_address_id SMALLINT,
	is_participate BOOL,
	CONSTRAINT pk_supervisor_id PRIMARY KEY(supervisor_id)
);

-- Tabloyu çekelim
SELECT
	s.supervisor_id AS "Gözetmen ID",
	s.exam_id AS "Sınav ID",
	s.experiment_year AS "Deneyim Yılı",
	s.assigned_address_id AS "Görevlendirilmiş Adres ID",
	is_participate AS "Katıldı mı"
FROM supervisors AS s;

-- Geriye alalım
ROLLBACK;

--2.6. "test" veri tabanında testee isminde bir tablo oluşturunuz. testee_id isminde bir birincil anahtar atayınız.

-- Transaction başlat
BEGIN;

-- Tablo oluştur
CREATE TABLE IF NOT EXISTS testee(
	testee_id SMALLSERIAL,
	exam_id SMALLINT,
	assigned_address_id SMALLINT,
	attempt_number SMALLINT,
	CONSTRAINT pk_testeee_id PRIMARY KEY(testee_id)
);

-- Tabloyu çekelim
SELECT
	t.testee_id AS "Sınav Katılımcısı ID",
	t.exam_id AS "Sınav ID",
	t.assigned_address_id AS "Sınav Adres ID",
	t.attempt_number AS "Katılım Sayısı"
FROM testee AS t;

-- Geriye alalım
ROLLBACK;

-- 2.7. "test" veri tabanında computer isminde bir tablo oluşturunuz. PRIMARY KEY kısıtı ekleyiniz.

-- Transaction başlat
BEGIN;

-- Tabloyu oluşturalım. Sonradan constaint ekleyelim
CREATE TABLE IF NOT EXISTS computer(
	computer_id SMALLSERIAL,
	brand VARCHAR(30),
	price INT,
	popularity_rank SMALLINT
);

SAVEPOINT created_computer;

-- Kısıt ekleyelim

ALTER TABLE computer
ADD CONSTRAINT pk_computer_id PRIMARY KEY(computer_id);


/* Diğer yöntem:
ALTER TABLE computer 
ADD PRIMARY KEY (computer_id);

*/
-- Geriye alalım.
ROLLBACK;


-- 2.8. "test" veri tabanında var olan budgets tablosuna budget_id sütununu primary key olarak ekleyelim. Kalıcı olarak olmasın.

-- Transaction başlatalım
BEGIN TRANSACTION;

-- Tabloyu değiştirelim
ALTER TABLE budgets
ADD COLUMN budget_id SMALLSERIAL
CONSTRAINT pk_budget_id PRIMARY KEY;

-- Tablomuzu çekelim
SELECT
	b.*
FROM budgets AS b;

-- İşlemi geriye alalım, veri tutarlılığımız bozulmasın.
ROLLBACK;

