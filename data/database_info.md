# BTK PostgreSQL - Kursu Veri Tabanı Bilgileri

Bu klasör, kursta kullanılan örnek veri tabanı altyapısını ve yedek dosyalarını (backup) yönetmek için yapılandırılmıştır.
Bu kurstaki uygulamaları gerçekleştirebilmek amacıyla elzemdir.

## Veri Tabanı Yedek Dosyaları:

- **Dosya Adı**: 'dvdrental.tar'
- **Dosya Adı**: 'office.tar'
- **Dosya Adı**: 'test.tar'
- **Dosya Adı**: 'pagila.tar'

## **Boyut Yönetimi**:

Büyük veri tabanı yedekleri Git geçmişini şişirmemesi adına **'.gitignore'** ile engellenmiştir ve GitHub'da listelenmez.

## Veri Tabanı Özet Bilgilendirmesi:

- **dvdrental.tar**: Bir DVD kiralama şirketinin envanter, müşteri, personel ve ödeme süreçlerini simüle etmek amacıyla birbiriyle ilişkili tablolardan oluşturulmuş bir veri tabanıdır.
  İçerisinde actor, address, category, city, country, customer, film, film_actor, film_category, inventory, language, payment, rental, staff ve store olmak üzere on beş farklı tablo bulunmaktadır.

- **office.tar**: Ofis ve çalışanlarıyla ilgili bir veri tabanıdır.
  İçerisinde countries, departments, dependents, employees, jobs, locations, regions olmak üzere çeşitli ilişkisel tablolar barındırmaktadır.

- **test.tar**: Veri tabanında daha fazla pratik gerçekleştirebilmek amacıyla, kaybolsa dahi üzülmeyeceğiniz bir veri tabanıdır.
  İçerisinde basket_a, basket_b, budgets, car_types, cars, colors, courses, date_demo, distinct_demo, movie_reviews, movies, products, product_segment, staff ve student gibi çeşitli tablolar bulunmaktadır.

- **pagila.tar**: dvdrental veri tabanımıza benzemektedir. Daha modern ve güncel hali olarak düşünülebilir.
  dvdrental tablo yapısına benzer bir yapı barındırmaktadır.

## Yerelde Ayağa Kaldırma (Restore):

Eğer bu projeyi bilgisayarınıza klonladıysanız, veritabanını pgAdmin üzerinde sağ tıklayıp **Restore** diyerek veya terminalden aşağıdaki komutla ayağa kaldırabilirsiniz:

```bash
pg_restore -U postgres -d veritabanı_adı data/yedek_dosyası_adı.tar
```

Hatırlatma: Burada -U, user yani veri tabanı kullanıcı adınızdır.

## Önemli Hatırlatma:

Teorik bilgileri pratiğe dökebilmeniz amacıyla bu veri tabanlarını indirmeniz ve çeşitli örnekler geliştirmeniz gelişiminiz açısından önem arz etmektedir.
