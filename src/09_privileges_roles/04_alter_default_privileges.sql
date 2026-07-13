-- 1. ALTER DEFAULT PRIVILEGES:
/*
1.1. ALTER DEFAULT PRIVILEGES Önemi Nedir?
- Kimin oluşturacağı nesneler için, kime, ne yetkisi verilecek?
- Geleceğe yatırım yapmış oluyoruz.
- Mevcut tablolardan başka oluşturulacak tablolar veya nesneler için önceden yetki verilmesi olarak da düşünebiliriz.

1.2. Söz Dizimi:

```sql
ALTER DEFAULT PRIVILEGES
[FOR ROLE olusturulan_role]
[IN SCHEMA sema_adi]
GRANT {Yetki}
ON {nesne_tipi}
TO {hedef_rol};

-- Örnek kullanımlar:
-- postgres kullanıcısı satis şemasında ne zaman yeni bir tablo oluştursa, analyst_dev kullanıcısı bunun anında okuyabilsin

ALTER DEFAULT PRIVILEGES
FOR ROLE postgres
IN SCHEMA satis
GRANT
    SELECT
ON TABLES
TO analyst_dev;

*/

---------------------------------------------------------------------------------------------------------------------------------------------------------
-- 2. ALTER DEFAULT PRIVILEGES EXAMPLES (Örnekleri):
-- 2.1. "digital_marketing" isminde bir schema oluşturunuz.

-- Şema oluşturalım 
CREATE SCHEMA digital_marketing;

-- 2.2. Oluşturulan "digital_marketing" şemasına erişecek dm_1, dm_2 kullanıcıları oluşturunz.

CREATE ROLE 
	dm1
WITH LOGIN
PASSWORD 'digital_marketer99.';

CREATE ROLE 
	dm2
WITH LOGIN
PASSWORD 'digital_marketer98!';


-- 2.3. Oluşturulan 'dm_1', 'dm_2' kullanıcılarına SELECT yetkisini veriniz.

GRANT 
	SELECT
ON ALL TABLES
IN SCHEMA
	digital_marketing
TO 
	dm1,
	dm2;

-- 2.4. Bu kullanıcıları "marketers" isminde bir gruba atayınız ve bu gruba ilgili yetkileri veriniz.

CREATE ROLE grp_marketers
WITH NOLOGIN;

GRANT
	USAGE,
	CREATE
ON SCHEMA digital_marketing
TO grp_marketers;


-- Yetkiyi alalım.
REVOKE
	CREATE
ON SCHEMA digital_marketing
FROM grp_marketers;


-- Şimdi tablo oluşturmak isteyelim. dm1 kullanıcısıyla bağlanalım, yeni sekme açalım.
BEGIN;


CREATE TABLE IF NOT EXISTS digital_marketing.marketing_options(
	option_id SMALLSERIAL,
	option_description VARCHAR(50) UNIQUE NOT NULL,
	CONSTRAINT pk_option_id PRIMARY KEY(option_id)
);

COMMIT;

/*
ERROR:  permission denied for schema digital_marketing
LINE 1: CREATE TABLE IF NOT EXISTS digital_marketing.marketing_optio...
*/

GRANT 
	SELECT
ON ALL TABLES
IN SCHEMA digital_marketing
TO grp_marketers;

-- Şimdi tabloyu çekebilecek. Önce tabloyu oluşturalım.

-- Tablo oluşturmayı deneyelim.db
-- 2.5. "db_dev" grubuna da erişim yetkisi veriniz ve "digital_marketing" şemasına yeni tablolar ekleyiniz.

GRANT
	USAGE,
	CREATE
ON SCHEMA digital_marketing
TO grp_db_dev;


GRANT 
	SELECT,
	INSERT,
	UPDATE
ON ALL TABLES
IN SCHEMA digital_marketing
TO grp_db_dev;

-- Bu gruba dahil olanlarla bağlanıp bir tablo oluşturmayı deneyelim.
BEGIN;

CREATE TABLE IF NOT EXISTS digital_marketing.dg_tbl(
	marketer_id SMALLINT NOT NULL,
	marketer_name VARCHAR(25) NOT NULL,
	marketer_surname VARCHAR(30) NOT NULL,
	email VARCHAR(50) UNIQUE NOT NULL,
	experiment_year SMALLINT CHECK(experiment_year >= 0 AND experiment_year <= 100)
);

COMMIT;

-- 2.6. "dm_1" ve "dm_2" kullanıcıları ile bu oluşturulan yeni tablolara erişmeyi deneyiniz.

-- dm1 kullanıcıyla bağlanalım. Bağlandı.
SELECT
	d.*
FROM digital_marketing.dg_tbl as d;

-- 2.7. "dm1" ve "dm2" kullanıcılarına yeni oluşturulacak tablolara erişim sağlayınız.

ALTER DEFAULT PRIVILEGES
FOR ROLE grp_db_dev
IN SCHEMA digital_marketing
GRANT
    SELECT,
    INSERT,
    UPDATE
ON TABLES 
TO grp_marketers; 

-- Yazılımcılarımız tablo oluşturabilsin
-- Transaction içerisinde yapalım
BEGIN TRANSACTION;

-- ROLE verelim. dev1 kullanıcısını kullanalım, grup rolünü üstlensin.Tablonun sahibi de grp_db_dev olacaktır.
SET ROLE grp_db_dev;

CREATE TABLE IF NOT EXISTS digital_marketing.campaigns_tbl(
	campaign_id SERIAL PRIMARY KEY,
	campaign_name VARCHAR(100) NOT NULL,
	budget NUMERIC(10,2)
);


-- İşlem bitince dev1 kendi orijinal kimliğine güvenli bir şekilde geri dönmesini istersek
RESET ROLE;

-- Kaydedelim
COMMIT;

/* Not: 
- ROLE ve GROUP ROLE'lerin oluşturulması, verilen yetkilerin zamanlaması önemlidir.
- Burada SET ROLE öncesinde tablo oluşturduğumuz için sahibi dev1 oldu, group değil.
- Bu nedenle de tabloyu dm1 kullanıcısı ile seçmeyi denediğimizde : "ERROR:  permission denied for table marketing_orders"  hatasını verdi.

*/