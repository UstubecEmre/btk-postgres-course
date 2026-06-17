-- 1. ALTER TABLE Statements (ALTER TABLE İfadeleri):
/*
Bir sütunda değişiklik yapmak için ALTER TABLE komutunu kullanırız.
ALTER TABLE yalnızca sütunlar üzerinde değil, tablo seviyesinde de değişiklik yapmamıza olanak tanır.

Tablo üzerinde de değişiklikler gerçekleştirebiliriz:
- Tabloya Constraint Ekleme
- Tablodan Constraint Kaldırma
- Tablonun İsmini Değiştirme
vb. işlemleri gerçekleştirebiliriz.

-- 1.1. Tabloya Kısıt Ekleme:
Bu kısmı daha detaylı işleyeceğiz.
Şimdilik sadece söz dizimini inceleyelim.

```sql
-- Söz dizimi

ALTER TABLE tablo_ismi 
ADD CONSTRAINT vermek_istedigimiz_kisit_ismi kisit_turu;

```

-- 1.2. Tablodan Kısıt Kaldırma:

Tablomuzda var olan bir kısıtı (CHECK, NOT NULL, NULL, FOREIGN KEY vb) kaldırmak isteyebiliriz.


```sql
-- Söz dizimini görelim
ALTER TABLE degistirilecek_tablo_adimiz
DROP CONSTRAINT kisit_adi;
```


-- 1.2. Tablonun İsmini Değiştirme:
Bir tabloyu, işlevinin değişmesi veya herhangi bir nedenden dolayı ismini değiştirmemiz gerekebilir.

```
-- Söz dizimi olarak:
ALTER TABLE degistireceğimiz_tablo_ismi
RENAME TO yeni_tablo_ismimiz;
```


-- 1.3. Tabloyu Kaldırma:
Herhangi bir nedenden dolayı tablomuzu kaldırmamız gerekebilir. 

```
-- Söz dizimi

-- Tek bir tablo silmek için
DROP TABLE IF EXISTS silecegimiz_tablo_ismi;

-- Çoklu silmek için:
DROP TABLE IF EXISTS
	silinecek_tablo_ismi1,
	silinecek_tablo_ismi2,
	...
	[CASCADE | RESTRICT];


Önemli Notlar:
Tablo kaldırma işlemlerinde dikkat edilmesi hususlar da bulunmaktadır.

Bunlar:
- Bağımlılıkları iyi analiz etmek, öncelikle bağımlı olan kısıtları kaldırmak, ardından tabloyu silmek
- Canlı ortam ve saat yerine test ortamında işlemleri gerçekleştirmek.
- Bu işlemleri gerçekleştirmeden önce ve sonrasında gerekli bilgilendirmeleri gerekli kişilere, ekiplere vb. yapmak gerekmektedir.
- Varsayılan argüman olarak RESTRICT kullanılır.

-- 1.3.1. Tablo Kaldırmada Kullanılan Argümanlar:
Tabloları kaldırırken karşımıza iki argüman çıkmaktadır.

-- 1. RESTRICT: Varsayılan değerdir, tablolardaki bağımlılıkları gözeterek silme işlemlerini gerçekleştirir.
Eğer ki bağımlılıklar söz konusuysa, o bağımlılıkları kaldırmadan silme işlemine izin vermez.

-- 2. CASCADE: Bir tabloyu kaldırırken başka bir tabloya bağımlılık varsa, bu komut ilgili bağımlılıkları otomatik olarak kaldırarak o tabloyu kaldırır.
Bağımlı olduğu tabloyu kaldırmaz ama içerisindeki foreign_key’leri (ikincil anahtar) kaldırır.

Not: Çok tehlikeli ve dikkat edilmesi gereken komuttur.


-- 1.4. COMMENT ON TABLE:
Tabloları hazırlarken, sütunlarda olduğu gibi yorumlar ekleyebiliriz.

```sql
-- Söz dizimini görelim
COMMENT ON TABLE tablo_ismi IS yorumumuz;


-- Hatırlatma da yapalım. Sütun için ise kullandığımız söz dizimi ise:
COMMENT ON COLUMN tablo_ismi.yorum_yazilacak_sutun_ismi IS yorumumuz;

```
*/
-----------------------------------------------------------------------------------------------------------------------------------------------------

-- 2. ALTER TABLE EXAMPLES (ALTER TABLE Egzersizleri):
-- 2.1. "test" veri tabanında yer alan country tablosunun ismini countries olarak değiştiren sorguyu yazınız.

-- Ülkeleri çekelim
SELECT
	c.country_id AS "Ülke ID",
	c.country_name AS "Ülke Adı"
FROM country AS c
ORDER BY c.country_id;


-- Transaction başlatalım
BEGIN TRANSACTION;

-- İstenileni yapalım.
ALTER TABLE country 
RENAME TO countries;


-- İşlemi geriye alalım
ROLLBACK;

--- 2.2. "test" veri tabanında usage_area tablosunda yer alan usage_area_pkey kısıtını kaldıran ve bu işlemi ROLLBACK; ile geri alan sorguyu yazınız.

SELECT
	ua.usage_area_id AS "Kullanım Alanı ID",
	ua.usage_area AS "Kullanım Alanı"
FROM usage_area AS ua;

-- Transaction başlatalım
BEGIN TRANSACTION;

-- Sütun ismini usage_areas yapalım
ALTER TABLE usage_area
RENAME TO usage_areas;

-- Kaydedelim
COMMIT;

-- Transaction başlatalım
BEGIN;

-- Burada yer alan tabloda ki kısıtı kaldıralım
-- DROP edelim
ALTER TABLE usage_areas
DROP CONSTRAINT usage_area_pkey;

-- Geriye alalım
ROLLBACK;

-- 2.3. "test" veri tabanında bulunan budgets tablosunu kaldıran ve bunu geri alan sorguyu yazınız.

-- Tabloyu hatırlayalım.
SELECT
	b.salesman_id AS "Yetenek ID",
	b.current_year AS "Güncel Satış Miktarı",
	b.previous_year AS "Geçen Dönem ki Satış Miktarı"
FROM budgets AS b;


-- Transaction başlatalım
BEGIN TRANSACTION;

-- Tabloyu kaldıralım
DROP TABLE IF EXISTS budgets CASCADE;

-- Rollback ile geriye alalım
ROLLBACK;


-- 2.4. "test" veri tabanında yer alan tournament tablosuna yorum ekleyen sorguyu yazınız.

-- Tabloya bakalım.
SELECT
	t.tournament_id AS "Turnuva ID", 
	t.tournament_name AS "Turnuva Adı",
	t.tournament_reward AS "Turnuva Ödülü",
	t.winning_team_id AS "Kazanan Takım ID",
	t.tournament_year AS "Turnuva Yılı"
FROM tournament AS t;

-- Transaction ile işe başlayalım.
BEGIN TRANSACTION;

-- Yorum ekleyelim
COMMENT ON TABLE tournament IS 'Bu tablomuz: Turnuvaların adını, ödülünü, kazanan takımı ve yapıldığı yılı içermektedir. İlişkileri mevcuttur.';


-- Kaydedelim
COMMIT;

-- 2.5. "test" veri tabanında yer alan distinct_demo tablosunda ki constrainti kaldıran ve bu işlemi geriye alan sorguyu yazınız.

SELECT
	dd.id AS "Tekil Tarih ID",
	dd.bcolor AS "Arka Plan Rengi",
	dd.fcolor AS "Ön Plan Rengi"
FROM distinct_demo AS dd;

-- Transaction başlat
BEGIN TRANSACTION;

-- Değişikliği yapalım
ALTER TABLE distinct_demo
DROP CONSTRAINT distinct_demo_pkey;

-- Geriye alalım
ROLLBACK;


-- 2.6. "test" veri tabanında date_demo tablosunu cascade ile silen ve bunu geriye alan sorguyu yazınız.

-- Tabloyu hatırlayalım.
SELECT
	d.value_id AS "Tarih ID",
	d.date_value_str AS "Tarih Değeri"
FROM date_demo AS d
ORDER BY d.value_id;


-- Transaction ile devam edelim ve bunu sonrasında geriye alalım
BEGIN;

-- İstenileni yapalım.
DROP TABLE IF EXISTS date_demo CASCADE;

-- Geriye alalım
ROLLBACK;


-- 2.7. "test" veri tabanında bulunan high_salaries tablosuna yorum ekleyen sorguyu yazınız ve bunu kaydediniz.

-- Tablomuzu inceleyelim
SELECT
	hs.emp_id AS "Yetenek ID",
	hs.first_name || ' ' || hs.last_name AS "Yetenek Adı Soyadı",
	hs.department AS "Departmanı",
	hs.salary AS "Ücreti"
FROM high_salaries AS hs;

-- Transaction başlatalım
BEGIN TRANSACTION;

COMMENT ON TABLE high_salaries IS 'Bu tabloda, yüksek maaşlı çalışanlar yer almaktadır. employees tablosundan türetilmiştir.';

-- Kaydedelim
COMMIT;


-- 2.8. "test" veri tabanında bulunan colors tablosunu RESTRICT argümanı ile siliniz ve işlemi geriye alınız.

-- Tabloyu görelim
SELECT	
	c.color
FROM colors AS c;

-- Transaction başlatalım
BEGIN TRANSACTION;

-- Tabloyu silelim
DROP TABLE IF EXISTS colors RESTRICT;

-- Diğer sorgularımız etkilenmesin diye işlemimizi geriye alalım.
ROLLBACK;


-- 2.9. "test" veri tabanında yer alan date_demo tablosunda ki date_value_str sütunu için DEFAULT değer olarak '2024-06-15' tarihini ekleyen sorguyu yazınız.

SELECT
	d.value_id AS "Değer ID",
	d.date_value_str AS "Değer"
FROM date_demo AS d;

--Transaction başlat
BEGIN;

-- Değişikliği yapalım
ALTER TABLE date_demo
ALTER COLUMN date_value_str
SET DEFAULT '2024-06-15';

-- İşlemi geriye alalım veya kaydedelim
COMMIT;

-- 2.10. "test" veri tabanında current_season tablosuna yorum ekleyen sorguyu yazınız, current_season_id için de yorum ekleyiniz.

-- Tabloyu çekelim
SELECT
	cs.current_season_id AS "Güncel Sezon ID",
	cs.season_year AS "Güncel Sezon Yılı"
FROM current_season AS cs;

-- Transaction başlatalım
BEGIN TRANSACTION;

-- Yorum ekleyelim
COMMENT ON TABLE current_season IS 'Bu tablo, güncel sezon bilgilerini tutmaktadır. İlişkili olduğu tablolar bulunmaktadır';

SAVEPOINT added_table_comment;

-- Kaydedelim
COMMIT;

-- Sütuna ekleyelim, öncelikle de transaction başlatalım
BEGIN;

COMMENT ON COLUMN current_season.current_season_id IS 'Güncel sezonların benzersiz kimliğini tutan sütundur. Otomatik artan birincil anahtardır';

-- Kaydedelim
COMMIT;
