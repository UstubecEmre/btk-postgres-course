-- 1. PRIVILEGES (Yetkiler):
/*
-- 1.1. PRIVILEGES Nedir?
Bir kullanıcı oluşturduktan sonra veri tabanı nesneleri üzerinde işlemler gerçekleştirebilmesi
için yetkilerin verilmesi gerekmektedir.
DBA tarafından gerekli görünürse bu yetkiler de alınabilir.

-- 1.2. Başlıca Yetkiler:
Obje				Yetkiler
DATABASE		CONNECT, CREATE
SCHEMA			USAGE, CREATE
TABLE			SELECT, INSERT, UPDATE, DELETE
SEQUENCE		USAGE, SELECT, UPDATE
FUNCTION		EXECUTE

Burada veri tabanı objelerinin kullanabileceği yetkiler gösterilmektedir.

-- 1.3. GRANT ve REVOKE Komutları:
- GRANT, yetki vermek için kullanılan komuttur.
- REVOKE ise yetkiyi geri almak için kullanabileceğimiz komuttur.


-- 1.4. Söz Dizimi:

```sql
-- Yetki vermek için
GRANT 
	yetki
ON TABLE tablo_adi 
TO yetki_verilecek_kullanici_role_veya_grup;

-- Örneğin
GRANT
    SELECT,
	INSERT,
	UPDATE
ON TABLE test
TO emre;
```

```sql
-- Geri almak için kullanılacak söz dizimi
REVOKE
    geri_alinacak_yetki(ler) 
ON TABLE tablo_adi 
FROM yetki_alinacak_kullanici_rol_veya_grup;

-- Örnek
REVOKE 
    INSERT
ON TABLE test
FROM emre;

```
*/
--------------------------------------------------------------------------------------------------------------------
-- 2. PRIVILEGES EXAMPLES (Yetkilendirme Örnekleri):
-- 2.1. "emre" ROLE'üne "test" veri tabanı üzerinde SELECT, INSERT yetkilerini veren sorguyu yazınız.

-- Kullanma yetkisi verelim
GRANT 
	USAGE
ON SCHEMA public
TO emre;

-- SELECT, INSERT yetkisini tüm tablolar için verelim
GRANT
	SELECT,
	INSERT
ON ALL TABLES 
IN SCHEMA public
TO emre;


-- 2.2. "emre" kullanıcısını kullanarak colors tablosundan veri çekmeyi deneyiniz.

-- "emre" kullanıcısı ile bağlanınız. Ardından yeni sekmede veri_tabani/kullanici_adi@hangi_isimle_kaydettiyseniz vb. gibi
SELECT
	c.*
FROM colors AS c;

-- 2.3. "emre" kullanıcısı ile colors tablosundan son kaydı silmeyi deneyiniz. Hata alırsanız bunu gösteriniz.

-- İlgili sekmemizden devam edelim.
BEGIN TRANSACTION;

DELETE FROM colors
WHERE color = (
	SELECT
		c.color
	FROM colors AS c
	ORDER BY c.color DESC
	LIMIT 1
)
RETURNING *;

-- Burada permission denied hatası verecektir.
-- Kaydedelim
COMMIT;


-- 2.4. "erol" kullanıcısı ile "test" veri tabanına bağlanınız. Bu kullanıcıya SELECT yetkisini veriniz.

-- "erol" kullanıcısı ile bağlanalım
-- Ne olur ne olmaz, bağlanma yetkisi verelim.
GRANT 
	USAGE
ON SCHEMA public
TO erol;

-- public şemasındaki tüm tablolar için seçme yetkisi verelim.
GRANT
    SELECT
ON ALL TABLES
IN SCHEMA public
TO erol;


-- 2.5. "erol" kullanıcısıyla "test" veri tabanında yer alan cars tablosundan veri çekiniz.

-- Bağlandıktan sonra Veri çekmeyi deneyelim
SELECT
	c.id,
	c.brand,
	c.price,
	c.discount
FROM cars AS c;



-- 2.6. "erol" kullanıcısıyla "cars" tablosundan veri eklemeyi deneyiniz. Çıktıyı metin halinde yazınız.

-- İlgili sekmemizden devam edelim.
-- Transaction içerisinde yapalım
BEGIN;

-- Eklemeyi deneyelim
INSERT INTO cars
	(
		brand,
		price,
		discount
	)
VALUES
	(
		'Jeep',
		29600,
		600
	)
RETURNING *;

-- Kaydedelim veya geriye alalım COMMIT veya ROLLBACK;
COMMIT;

-- "ERROR:  permission denied for table cars" Hatasını verdi.

-- 2.7. "dev1" kullanıcına "test" veri tabanında yer alan courses tablosunda SELECT, INSERT, UPDATE, DELETE yetkisi veriniz. Sadece cars tablosuna erişebilsin

-- dev1 kullanıcısı ile bağlanalım
GRANT 
	SELECT,
	INSERT,
	UPDATE,
	DELETE
ON TABLE public.courses
TO dev1;


-- 2.8. "dev1" kullanıcısını kullanarak courses tablosunda ekleme, güncelleme ve silme işlemi gerçekleştiriniz.


-- dev1 kullanıcısı ile bağlanalım. Başka bir tabloda veri çekmeyi deneyelim
SELECT
	c.*
FROM cars AS c;

-- ERROR:  permission denied for table cars 

-- Yeni kayıt eklemeyi deneyelim. 
-- ERROR:  permission denied for sequence courses_course_id_seq almamak için :
GRANT
	USAGE,
	SELECT
ON SEQUENCE courses_course_id_seq
TO dev1;


BEGIN;

INSERT INTO courses
	(
		course_name,
		description,
		published_date
	)
VALUES
	(
		'Docker Fundamentals',
		'This course includes docker basics',
		'2024-10-19'
	)
RETURNING *;



-- Kaydedelim
COMMIT;

-- Kaydettiğini görebilirsiniz.



-- 2.9. "dev1" kullanıcısından INSERT, UPDATE ve DELETE yetkilerini geri alınız.
-- Geriye alalım.
REVOKE
	INSERT,
	UPDATE,
	DELETE
ON TABLE public.courses
FROM dev1;

-- Açtığımız sekmede silme işlemini deneyelim.
-- Silme yetkisini aldık, deneyelim
BEGIN;

DELETE FROM public.courses
WHERE course_id = (
	SELECT
		MIN(c.course_id)
	FROM courses AS c
);

COMMIT;
-- ERROR:  permission denied for table courses 

-- 2.10. "erol" kullanıcısından SELECT yetkisini de elinden alınız.

REVOKE
	SELECT
ON TABLE public.cars
FROM erol;

-- Tablodan seçmeyi deneyelim, erol kullanıcısı ile bağlandığımız sekmede bu işlemi gerçekleştireceğiz.
SELECT
	c.brand
FROM cars AS c;

-- "ERROR:  permission denied for table cars" hatasını alırız.




