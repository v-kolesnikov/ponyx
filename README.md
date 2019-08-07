# Ponyx 🐴

Ponyx is a web-application for explore [ONIX](https://www.editeur.org/8/ONIX/) data from PostgreSQL database.

## Objective

Consider you have several ONIX messages in XML files:

```xml
# 20190806T081541Z.xml
<ONIXMessage xmlns="http://ns.editeur.org/onix/3.0/reference" release="3.0">
  <Header>
    <SentDateTime>20190806T081541Z</SentDateTime>
  </Header>
  <Product>
    <RecordReference>1</RecordReference>
  </Product>
  <Product>
    <RecordReference>2</RecordReference>
  </Product>
  ...
</ONIXMessage>

# 20190807T081541Z.xml
<ONIXMessage xmlns="http://ns.editeur.org/onix/3.0/reference" release="3.0">
  <Header>
    <SentDateTime>20190807T081541Z</SentDateTime>
  </Header>
  <Product>
    <RecordReference>1</RecordReference>
  </Product>
  <Product>
    <RecordReference>2</RecordReference>
  </Product>
  ...
</ONIXMessage>

...
```

And you want to look at all the changes of the product with the reference `2`.
Ponyx stores each ONIX message to the database table as `xml` column and then queries it with SQL and XPath to extract exactly what you want.
