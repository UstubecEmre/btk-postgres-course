-- 1. ROLES:
/*
1.1. SQL Güvenlik Mimarisi:
-- 1.1.1. Authentication Nedir?
“Kimsin?” (Login) sorusunun cevabıdır.
Kullanıcının iddia ettiği kişi olduğunu doğrulamak için kullanılır.
Bu, parola, güven (trust) veya Kerberos gibi diğer bir birleşik oturum açma yöntemiyle yapılabilir.


-- 1.1.2. Authorization Nedir?
“Ne Yapabilirsin?” sorusunun cevabıdır.
Kimliği doğrulanmış bir kullanıcı olarak, sistem içinde neler yapmama izin veriliyor?

Hatırlatma:
- İlk adım Authentication, ikinci adım ise Authorization’dır.


-- 1.2. ROLE Mimarisi:

1.2.1. ROLE Nedir?
- PostgreSQL’de yalnızca bir tür kimlik doğrulama sorumlusu vardır, bu da ROLE’dür ve CLUSTER düzeyinde bulunan bir roldür.
- Bir Cluster içerisinde birden fazla veri tabanı olabilir, bu bütün veri tabanları üzerinde kontrolleri sağlayan bir rol yönetimidir. 
- Roller, bunların üzerinde bulunur ve bizlere verilen roller üzerinden ilgili veri tabanlarına erişim sağlayabiliriz.

1.2.2. Database Objects (Veri Tabanı Objeleri) Nelerdir?
- PostgreSQL’de Cluster’ında oluşturulabilen veya erişilebilen her şey nesne olarak adlandırılır.
- Veri tabanları(databases), şemalar(schemas), tablolar(tables), görünümler(views), prosedürler(procedures), fonksiyonlar(functions) ve daha fazlası, 
  her rol(ROLE) için farklı ayrıcalıklara sahip olabilir.

1.2.3. Privileges (Yetkiler) Nelerdir? 
- Bir veri tabanı nesnei için bir role verilebilecek erişim türleri.
- Bunlar genellikle veri tabanı veya şema düzeyinde uygulanır, ancak bireysel nesnelere özel erişim uygulama yeteneği her zaman mevcuttur.

Önemli Hatırlatma:
İster veri tabanı yöneticisi istersek de veri tabanı kullanıcısı olalım, minimum yetki prensibi ile ilerlememiz sağlıklı olacaktır.
Principle of Least Privilege (PoLP): Mümkün olduğunca az yetki istemeli ve vermeliyiz.

1.2.4. Owner Nedir? 
- Her veri tabanı nesnesinin bir sahibi vardır.
- Sahip (owner), nesne üzerinde tam kontrole sahiptir.
- Nesneyi değiştirebilir, silebilir veya diğer kullanıcılara ve gruplara ayrıcalıklar verebilir.


-- 1.3. Önemli ROLE'ler:
ROLE’lerin özelliklerini biliyor olmamız önem arz etmektedir.
 
1.3.1. LOGIN / NOLOGIN:
- LOGIN hakkına sahipse veri tabanına bağlanabilir.
- NOLOGIN, grup rollerinde seçilen bir yetkilendirmedir. 
Not: Varsayılan olarak NOLOGIN ROLE'ü geçerlidir.


1.3.2. CREATEDB / NOCREATEDB: 
- CREATEDB: Veri tabanı oluşturabilir.
- NOCREATEDB: Veri tabanı oluşturmasına yetkisi yoktur.
Not: Varsayılan olarak NOCREATEDB verilmektedir.

1.3.3. CREATEROLE / NOCREATEROLE:
- CREATEROLE: Bir rol oluştururuz ve bu rolün başka bir rol oluşturup oluşturamayacağını belirleriz. Oluşturmasına yetki vermek istersek CREATEROLE kullanırız.
- NOCREATEROLE: Oluşturulan ROLE’ün başka bir ROLE oluşturmasına yetki vermemek için kullanılan özelliktir.
Not: Varsayılan olarak NOCREATEROLE verilmektedir.

1.3.4. SUPERUSER / NOSUPERUSER:
- postgres kullanıcısı, PostgreSQL veri tabanında en yetkili kullanıcıdır.
- Bundan sonra en yetkili kullanıcı ise SUPERUSER yetkisine sahip rollere sahip kişiler ve kullanıcılardır.
- Genelde sadece bir veya iki tane SUPERUSER olabilir. (Yönetimi zorlaştıracağından kaynaklı)
- Güvenlik açısından önemlidir. 
Not: DEFAULT değeri NOSUPERUSER’dır.

INHERIT / NOINHERIT: 
- Özetle :Roller arası yetki aktarımıdır.
- INHERIT: Verilen bir yetkiyi Kalıtım (miras) alabilir.
- NOINHERIT: Verilen bir özelliği, yetkiyi vb. kendisine aktaramaz.

Önemli Hatırlatmalar:
- Bir ROLE’e yetki verdik ve bu rolü de başka bir role veya kullanıcıya atadık diyelim. 
- Bu durumda, o rolün üzerinde ki tüm yetkiler ilgili kullanıcıya aktarılır.

Not: INHERIT olması DEFAULT’dur.

1.3.5. PUBLIC Role:
- Genel yetkilendirmedir.
- Varsayılan ROLE’dür.
- Kaldırılamaz veya yeniden oluşturulamaz.
- Herkese verilen roldür, otomatik olarak arka planda atanır.
- Üzerinde değişiklik yapamamasına rağmen görme yetkisine sahip olabilir.

Önemli Hatırlatma:
- PUBLIC ROLE, tehlikeli bir roldür.
- Canlı sistemlerde DBA’ler tarafından diğer kullanıcılardan kaldırılır. Otomatik olarak verilmesi engellenebilir.
- Test sistemlerinde ise çok daha rahat kullanım sağlar, bir kullanıcı veya rol oluşturduğumuzda yetki karmaşasını engellemek amacıyla Production aşamasında diğer kullanıcılardan kaldırılır.

-- 1.4. ROLE Oluşturma Söz Dizimi:
```sql
CREATE ROLE rol_ismi
WITH verilecek_yetki
PASSWORD 'verilecek_sifre';

-- Örneğin
CREATE ROLE emre
WITH LOGIN
PASSWORD '1829360';

```

Not: 
- PostgreSQL’de USER diye bir kavram yoktur, sadece ROLE kavramı vardır. 
- USER ifadesini postgreSQL kaldırmaktadır. ROLE’ün içerisinde tamamen yönetiyoruz.
=> Kısaca USER: ROLE + LOGIN

``sql
-- USER oluşturma
CREATE USER erol
WITH PASSWORD '147852369';
```

=> GROUP ROLE'leri ayrı bir bölümde ele alacağız:)

*/

------------------------------------------------------------------------------------------------------------------------------
-- 2.1. "test" veri tabanını kullanarak 'emre' isminde bir ROLE oluşturunuz. Bu rolün veri tabanına bağlanabilmesini sağlayınız. 

-- ROLE oluşturalım.
CREATE ROLE emre
WITH LOGIN
PASSWORD '172936';

-- pgAdmin4 üzerinden ilerlersek Servers => Register => Server => General ve Connection bölümleri kullanılır.


-- 2.2. "test" veri tabanına 'emre' isimli ROLE ile bağlanınız ve veri çekmeyi deneyiniz.

--emre_localhost ile bağlanıyoruz. Yeni bir sekmede.
SELECT
	c.city_id,
	c.city_name,
	c.population
FROM city AS c;

-- ERROR:  permission denied for table city hatasını alırız. Yetki vermediğimizden kaynaklı

-- 2.3. "test" veri tabanında 'erol' isimli ROLE oluşturunuz ve bu role veri tabanına bağlanma ve veri tabanı oluşturma rollerini veriniz.

-- erol isimli kullanıcı oluşturalım
-- CREATE USER erol PASSWORD 'ilgili_parola';
CREATE ROLE erol
WITH 
	LOGIN
	CREATEDB
PASSWORD '10202023';


-- 2.4. "test" veri tabanında 'erol' isimli role ile yeni bir veri tabanı oluşturmayı deneyiniz.

-- Servers => Register => ... erol kullanıcısını oluşturup bağlanalım. Yeni bir sekmede
CREATE DATABASE db_example1;

-- Açtığımız sekmede yazacağımız kodlar şu şekildedir:
-- Transaction başlatalım
BEGIN;

CREATE TABLE IF NOT EXISTS db_example_tbl(
	example_id SERIAL NOT NULL,
	example_name VARCHAR(25) NOT NULL UNIQUE,
	created_date DATE DEFAULT CURRENT_DATE
);

-- ERROR:  permission denied for schema public
-- LINE 1: CREATE TABLE IF NOT EXISTS db_example_tbl(
-- Geriye alalım
ROLLBACK;

/*
Kafa Karışıklığını Önlemek Adına:
- CREATE DATABASE komutu mevcut bağlantıyı değiştirmez. 
- Hala 'test' veritabanında olduğumuz ve buradaki public şemasına yetkimiz olmadığı için bu hatayı alırız.
-- Eğer yeni oluşturduğumuz db_example1'e bağlanıp bu tabloyu açsaydık, DB sahibi (Owner) olduğumuz için hata almazdık!

*/

-- 2.5. "test" veri tabanında 'emre' rolü ile veri tabanı oluşturmayı deneyiniz.

-- 'emre' kullanıcısı ile bağlanalım ve oluşturmayı deneyelim.
CREATE DATABASE db_example2;
-- Hata alacağız, bu role bu özellik verilmemiş. ERROR:  permission denied to create database 

-- 2.6. "test" veri tabanında 'dev1' isminde bir kullanıcı oluşturunuz ve bu kullanıcıya CREATEROLE veriniz.

-- dev1 oluşturalım
CREATE ROLE dev1
WITH 
	CREATEROLE
PASSWORD 'dev1_147852369';


-- 2.7. "test" veri tabanıa 'dev1' kullanıcısıyla bağlanmayı deneyiniz, bağlanabilirseniz 'dev2' isminde kullanıcı oluşturunuz.

-- SERVERS => Register => dev1 oluşturalım. 
CREATE ROLE dev2
WITH
	LOGIN
PASSWORD 'dev2_963874521';


-- 2.8. "test" veri tabanında 'dev1' kullanıcısı ile bağlanamazsanız LOGIN yetkisi de veriniz ve sonrasında 'dev2' rolü oluşturunuz.
-- ROLE'e LOGIN de ekleyelim.
ALTER ROLE dev1 LOGIN;

CREATE ROLE dev2
WITH
	LOGIN
PASSWORD 'dev2_963874521';

-- 2.9. 'dev2' kullanıcısı ile farklı veri tabanlarına bağlanmayı deneyiniz.

-- pgAdmin4 kullanıyorsak değiştirmemizin yolu Query Tool kullanmaktır. 
-- VSCode için ise: Ctrl + Shift + P (Mac'te Cmd + Shift + P) tuşlarına basıp PostgreSQL: Select Database

-- 2.10. 'emre' kullanıcısına NOINHERIT rolünü ekleyiniz.

-- ROLE'e yeni özellik ekleyelim.
ALTER ROLE emre NOINHERIT;