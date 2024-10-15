![RubyMachida](https://github.com/user-attachments/assets/10ce990b-7b63-4667-ba28-4ab36cc91271)



通勤・帰宅電車内で使用するCLIアプリケーション。  目的地の着時刻・所要時間等を表示します。  
DBのカラム名を動的に取得するため、テーブルを作成さえすれば世界中の路線に対応可能。  
サンプルとしてJR中央線　新宿~立川間に対応。

<br>

# 実行
Rubyのインストール・環境構築など一切不要。
当リポジトリをダウンロードし、ディレクトリ直下で以下のコマンドを実行してください。
```
$ docker build -t ruby-image-name .  #初回のみ実行
$ docker run --rm -it --name ruby-container-name ruby-image-name ruby ruby_machida.rb　<コマンド> <引数>
```
<br>

# コマンド
## start
出発前に実行。乗車中の車両を検索・登録

## arrives
目的地に到着する時刻・所要時間を表示

## search <次の駅名>
出発時の start を忘れてしまった場合に使用。
start と同様に乗車中の車両を検索・登録

## reset
乗車中の車両の登録を解除

<br>

# 構成

![image](https://github.com/user-attachments/assets/957ecfb8-cc73-4fc1-a579-489f0917aa38)
