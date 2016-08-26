# WPIDemo

## Watson Personality Insights サービスのデモアプリ

### アプリ仕様

- Java SE

- IBM Bluemix 環境(Liberty for Java)に最適化

### 前提サービス（カッコ内は Bluemix でバインドすべきサービス名）

- MySQL(ClearDB)

- Memcached(Memcached Cloud)

- Personality Insights

### 事前準備

- OAuth のための Twitter API のキーとシークレット情報を https://apps.twitter.com/ で取得する（手順についてはこちらを参照 http://dotnsf.blog.jp/archives/1044796238.html）

- 取得したキーとシークレットを App.java 内の tw_consumer_key/tw_consumer_secret 変数にそれぞれ設定する

- （必要に応じて）memcached で利用するユニークなキー値を App.java 内の mm_keyname 変数に設定する

- 性格分析の対象となる人の Twitter ID 一覧を App.java 内の twitter_ids 変数内に配列で指定する

- （Bluemix 以外の環境から利用する場合は）App.java 内の L.161-169 までの各変数の値を実際に利用するものに書き換える

- （必要に応じて）各 \*.jsp 内の（主にヘッダーやフッターの）情報を書き換える

- （必要に応じて）画像ファイルを好みのものに置き換える

- InitTables.java をスタンドアロン実行して、テーブルを初期化する

- resetMM.java をスタンドアロン実行して、対象者の性格をあらかじめ分析して memcached に入れておく（時間がかかります）

- このプロジェクトを Java アプリケーションサーバー上にデプロイして実行する

## Copyright

- 2016 dotnsf@gmail.com(c) all rights reserved.


