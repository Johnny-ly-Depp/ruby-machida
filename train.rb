require 'thor'


class TrainCommand < Thor

  def start   #現在時刻から一番近い未来の電車を「乗っている車両」に設定する。

    # 現在時刻を取得
    p hour_HH = Time.now.strftime("%H" ).to_i
    p minute_MM = Time.now.strftime("%M").to_i

    # hour_HHに新宿駅を発車する時間一覧を取得
    p trains =
      case hour_HH
      when 18..20
      	trains_departs_18to20
      when 21
      	trains_departs_21
      when 22
      	trains_departs_22
      when 23
      	trains_departs_23
      else #NOTE test values
        [5, 10, 20, 30, 40, 50]
      end

    # TODO when nill

    # 一番近い未来の時刻に発車する列車情報を取得
    #   ex) HH05
    #       → trainB: 15
    #       trainB == [1815, 1831, 1847...]
    
    # 新宿駅出発MM分一覧を取得
    train_depart_minutes = 
      trains.map { |train| train[0] }

    # 出発時刻一覧のうち、既に出発したものを除外
    current_minute = minute_MM.to_i
    train_depart_minutes.delete_if { |time| time < current_minute } 

    # 配列の先頭の要素が「直近の新宿駅出発時刻」
    depart_time = train_depart_minutes[0]
    abording_train = trains.find { |train| train[0] == depart_time }       

    # TODO 取得した着時刻が「15a」のように三桁だった場合のロジック

    puts "Have a nice trip!"
  end
  
  def arrives #「乗っている車両」について以下の情報を表示「町田駅の到着時刻」「到着時刻までの残り時間（分）」
  end
  
  def delay(minuts)  #arrives の時間を minuts 分だけ遅らせる。
  end

  def rinkaiLine
    puts "ERROR: No way, that railway doesn't work."
  end

end

TrainCommand.start(ARGV)

# 電車時刻表
# Note) 登録するのは「1800 以降」「平日」の列車だけで良し
#

stations = [
  :新宿,
  :代々木上原,
  :下北沢,
  :登戸,
  :新百合ヶ丘,
  :町田
]

# HHは変数だが、各駅到着MMは固定
# ~ 20まで

# 01発

train_departs_18to20 = [
	[1, 6, 8, 17, 26, 35],
	[10, 15, 18, 26, 34, 42],
	[21, 26, 28, 37, 43, 54],
	[30, 35, 38, 46, 54, '2#'] ,
	[41, 46, 48, 57, '6#', '15#'],
	[50, 55, 58, '7#', '15#', '25#']
]

# 21~ 変則

train_departs_21 = [
	[1, 6, 8, 17, 26, 35],
	[10, 14, 17, 26, 34, 42],
	[21, 26, 28, 37, 45, 53],
	[30, 34, 37, 46, 54, '2#'],
	[41, 46, 48, 57, '4#', '13#'],
	[50, 54, 57, '6#', '13#', '23#']
]

train_departs_22 = [
	[1, 6, 8, 17, 24, 33],
	# skiped 2209 because it is boudn for 唐木田
	[20, 24, 27, 36, 42, 50],
	[46, 51, 53, '2#', '10#', '18#']
]

train_departs_23 = [22, 26, 29, 38, 44, 53]
