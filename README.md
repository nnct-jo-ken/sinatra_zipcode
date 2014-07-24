# 郵便番号検索サンプル Sinatraアプリ

郵便番号データベースファイルは権利の都合上省略しています．

## データベーススキーマ

データベースのスキーマは以下の通りです．

```sql
CREATE TABLE zipcode_list (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  zipcode TEXT NOT NULL,
  address TEXT NOT NULL
);
```

## データベースファイルの作成方法

日本郵便のWebサイトで公開されている
[郵便番号データ](http://www.post.japanpost.jp/zipcode/dl/kogaki-zip.html)
をsqliteで取り込める形式に変換するスクリプトです．

```ruby
require 'csv'

output = File.open('ziplist.dat', 'w')

open('KEN?ALL.CSV', "r", undef: :replace) do |f|
  CSV.new(f, converters: nil).each_with_index do |row, index|
    h = {
      zipcode: row[2],
      address: row[6..8].join
    }

    output.puts [index + 1, h[:zipcode], h[:address]].join('|')
  end
end

output.close
```

### sqlite3でのインポート方法

```sh
> sqlite3 zipcode.db
sqlite3> .import ziplist.dat zipcode_list
```

## 起動方法

```sh
> rackup -p 4567
```

