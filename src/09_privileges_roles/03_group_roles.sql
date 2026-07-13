-- 1. OBJECT PRIVILEGES AND GROUP ROLES:
/*
1.1. Objelerin Yetkilendirilmesi:
- SCHEMA, TABLE vb. veri tabanı nesnelerine yetkiler vermemiz gerekebilir.
- Bir önceki bölümümüzde Tablolara yetki vermeyi ve yetkiyi elinden almayı incelemiştik.

1.2. Şemalara Yetki Verilmesi:
- Şu zamana kadar varsayılan olarak gelen public şeması ile işlemlerimizi gerçekleştirdik.
- Bu aşamada da diğer şemaları kullanmayı da göreceğiz.

1.3. Şema Oluşturmak:
```sql
CREATE SCHEMA sema_ismi;

-- Şema içine tablo oluşturmak için
CREATE TABLE IF NOT EXISTS schema_ismi.ilgili_tablo_adi(
	sutun_adi VERI_TIPI
);

-- Örneğin
CREATE SCHEMA schema1;

CREATE TABLE IF NOT EXISTS schema1.sports(
	sport_id SERIAL NOT NULL,
	name VARCHAR(50) UNIQUE NOT NULL
);

```
1.2.1. Şemalara Yetki Verilmesi Söz Dizimi:
```sql
-- Yetkiyi verelim
GRANT
    yetki(ler)
ON sema_ismi.tablo_ismi(isimleri)
TO yetki_verilecek_kisi_rol;

-- Tüm tablolar için vermek istersek
GRANT
    yetki(ler)
ON ALL TABLES
IN SCHEMA sema_ismi
TO yetki_verilecek_kisi_rol;

-- Örnek olarak da 
GRANT 
    USAGE,
	CREATE
	-- Tüm yetkileri vermek için ise ALL
ON SCHEMA schema1
TO emre;

```

1.4.GROUP ROLE Nedir?
-- GROUP ROLE, veri tabanı yöneticisinin, her bir kişiye tek tek yetki vermesinden kaynaklanacak zaman 
kaybını bertaraf edecek bir ROLE verme yöntemidir.
Bu sayede, group içerisinde tanımlanmış olan kullanıcılara tek bir yerden ilgili yetkiler verilebilir ve yetkiler onlardan alınabilir.
Bu sayede yönetim kolaylaşır ve merkezileşir.

1.4.1. GROUP ROLE Verme Söz Dizimi:
```sql
CREATE ROLE group_role_ismi
WITH yetki;

-- Örneğin
CREATE ROLE grp_dev
WITH NOLOGIN;

-- Yetki verelim
GRANT
    ilgili_yetki(ler)
ON SCHEMA sema(lar)
TO yetki_verilecek_group;

-- Örneğin
GRANT
    USAGE
ON SCHEMA
    public,
	schema1
TO grp_dev;

```
*/

-----------------------------------------------------------------------------------------------------------------------------
-- 2. GROUP ROLES EXAMPLES:
-- 2.1. "test" veri tabanında dev_1 isminde bir GROUP ROLE tanımlayınız. Bu gruba "emre" ve "erol" kullanıcılarını ekleyiniz.

CREATE ROLE grp_dev_1
WITH NOLOGIN;

-- Kullanıcıları atayalım.
GRANT grp_dev_1
TO
	emre,
	erol;

-- 2.2. "dev_1" grubuna SELECT yetkisini veriniz.
GRANT
	SELECT
ON public.product
TO grp_dev_1;

GRANT
	USAGE,
	SELECT
ON SEQUENCE public.product_id_seq 
TO grp_dev_1;

-- "erol" isimli kullanıcıyla deneyince, çekebildiğimiz gördük.

-- 2.3. "dev_1" grubu üyelerinden "emre" ile product tablosuna veri eklemeyi deneyiniz.

-- emre kullanıcısıyla yeni bir tab açalım. Transaction içerisinde ekleme yapmayı deneyelim
BEGIN;

INSERT INTO product
	(
		name,
		price,
		net_price,
		segment_id
		
	)
VALUES
	(
		'Action Figure',
		4.89,
		4.59,
		2
	)
RETURNING *;

-- 2.4. "dev_1" grubuna bütün tablolarda işlem yapma yetkisini veriniz.

GRANT
	SELECT
ON ALL TABLES
IN SCHEMA public
TO grp_dev_1;

-- 2.5. "schema1" isminde bir şema oluşturunuz.
CREATE SCHEMA schema1;

GRANT 
	USAGE
ON SCHEMA
	public,
	schema1
TO grp_dev_1;

-- 2.6. "db_dev" isminde bir GROUP ROLE oluşturunuz ve bunlara gerekli yetkileri veriniz.

CREATE ROLE grp_db_dev
WITH NOLOGIN;

GRANT
	USAGE,
	CREATE
ON SCHEMA 
	public,
	schema1
TO grp_db_dev;

GRANT grp_db_dev
TO
	dev1,
	dev2;

-- Yetkileri de ekleyelim.
GRANT
	SELECT,
	INSERT,
	UPDATE
ON ALL TABLES
IN SCHEMA
	public,
	schema1
TO grp_db_dev;

-- 2.7. "db_dev" GROUP'una yeni kullanıcılar ekleyiniz ve tablo create etmeyi deneyiniz.

-- Yeni tablo oluşturmayı deneyelim, sekmemizi açıp bağlanalım.

CREATE TABLE IF NOT EXISTS friends(
	friend_id SERIAL NOT NULL,
	full_name VARCHAR(50) NOT NULL,
	birthdate DATE CHECK(birthdate >= '1900-01-01' AND birthdate <= CURRENT_DATE),
	gender VARCHAR(6)
);

-- 2.8. "db_dev" grubundan INSERT ve UPDATE yetkilerini geriye alınız.

REVOKE
	INSERT,
	UPDATE
ON public.cars
FROM grp_db_dev;

-- 2.9. "schema1" şemasını kullanarak yeni tablolar oluşturunuz. Bu tablolara SELECT, INSERT yetkilerini kullanabilecek kişiler oluşturunuz.

BEGIN;

CREATE TABLE IF NOT EXISTS schema1.family(
	family_id SMALLSERIAL NOT NULL,
	family_name VARCHAR(20) UNIQUE
);

COMMIT;

-- Yetki verelim

GRANT
	SELECT,
	INSERT
ON ALL TABLES
IN SCHEMA schema1
TO grp_db_dev;


-- 2.10. "schema1" içerisinde yer alan tablolara SELECT ile ulaşınız ve INSERT ile ekleme yapmayı deneyiniz.

-- grp_db_dev üyelerinden biriyle bağlanmayı deneyelim. "dev1" ile bağlandık ve yetkilendirme işlemlerinden sonra ilgili işlemleri tamamladık.
GRANT 
	USAGE
ON SCHEMA schema1
TO grp_db_dev;

-- Sorgu çekelim
SELECT
	f.*
FROM schema1.family AS f;

-- Ekleme yapalım
BEGIN;

INSERT INTO schema1.family
	(
		family_name
	)
VALUES
	(
		'Üstübeç'
	),
	(
		'Yüksel'
	)
RETURNING *;

COMMIT;

