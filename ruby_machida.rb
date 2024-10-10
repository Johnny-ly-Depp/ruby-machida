#!/usr/bin/env ruby
require 'thor'
require 'active_record'

bin_dir = File.dirname(__FILE__)
db_path = File.join(bin_dir, 'train.db')

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: db_path
)

class Train < ActiveRecord::Base
end

class TrainCommand < Thor
  FIRST_STATION_COLUMN = Train.column_names[2]
  FINAL_STATION_COLUMN = Train.column_names[-3]

  # TODO　起動時刻が0-17時であるとき
  #           ・0に設定してしまう
  #           ・「 OUTATIME! 通勤時間外での使用を検知しました。テストデータを使用します。」の出力
  #           ・ＤＢに0-17時用のデータを挿入
  CURRENT_HOUR = case Time.now.hour
                 when 0..17
                   puts " OUTATIME! 通勤時間外での使用を検知しました。テストとして18時のデータを使用します。"
                   18
                 else
                   Time.now.hour
                 end
  
  desc "start", "Use it when departing 新宿. It will assign the train you are currently taking."
  def start 
    Train.all.update(abording: false)

    trains = Train.where(depart_hour: CURRENT_HOUR)
    train_depart_minutes = 
      trains.map { |train| train[FIRST_STATION_COLUMN] }
    
    # rid the trains already has been left
    train_depart_minutes.delete_if { |time| time < Time.now.min } 
   
    # If all trains have been left in current hour,
    # check the next hour
    if train_depart_minutes.empty? then
       abording_train = Train.where(depart_hour: CURRENT_HOUR + 1).first
    else
      depart_time = train_depart_minutes[0]
      abording_train = Train.find_by(FIRST_STATION_COLUMN => depart_time)
    end    
    
    abording_train.update(abording: true)
    puts "Have a nice trip!"
  end


  desc "arrives", "Displays info when you will arive to 町田."
  def arrives
    
    arrival_hour = Time.now.hour # assigning to variable since might changing later
    abording_train = Train.find_by(abording: true)
    destination_arrival_time = abording_train[FINAL_STATION_COLUMN]

    # checking if train arrives at 町田 in next hour
    # ex) LHS: arrival time of the station which is next hour 
    #      新宿: 41,
    #      代々木上原: 46,
    #      下北沢: 48, 登戸: 57,
    #      新百合ヶ丘: 6,
    #      町田: 15,
    #      station_arrives_next_hour: 4
    #       -> 6
    #
    #     RHS: 15
    #     6 ≠ 15
    if abording_train[:station_arrives_next_hour] == destination_arrival_time
      arrival_hour += 1
      remaning_minuts = (60 - Time.now.min) + destination_arrival_time
    else
    remaning_minutes = destination_arrival_time - Time.now.min
   end

    puts "You will be arrived at #{sprintf("%02d:%02d", arrival_hour, destination_arrival_time)}
          which is #{remaning_minutes} minutes to go."
  end


  # TODO BUG: おそらく arrives_next_hour が作動していない
#
# 20:47 
# user@DESKTOP-4C0I1O6 MINGW64 ~/coding/shell (main)
# $ train search 新百合ヶ丘
# You will be arrived at 20:02
#          which is -47 minutes to go.
#
  desc "search", "Pass the next station name as an arg. This command will reassign the train you are taking."
  def search(next_station)
    stations = Train.column_names[2...-2] #NOTE heavily dependent on the table schema.
    unless stations.include?(next_station)
      puts 'That station does not exist.'
      return
    end

    trains = Train.where(depart_hour: CURRENT_HOUR)

    # fetch the list of current station arrival time (before of the arg station)
    # ex) arg:新百合ヶ丘 -> list of 登戸 
    next_station_index = stations.index(next_station)
    current_station = stations[next_station_index - 1]
    current_station_times = trains.map { |train| train[current_station] }

    # find the largest number which fufilles the following condition
    # arrival time (elements of the list) < current minutes

    # handle "station_arrives_next_hour"
    # add 60 if num increases in list 
    # ex) [10, 20, 30, 1, 2, 3]
    #   ->[10, 20, 30, 61, 62, 63]
    decrease_index = current_station_times.each_cons(2).find_index{ |a, b| a > b } # each_cons -> get adjacent elements 
        # find_index -> find index which returns TRUE

    # replace half part of array which decresed
    # ex) [10, 20, 30, 1, 2, 3]
    #     merging     [61, 62, 63]  (RHS)
    #   ->[10, 20, 30, 61, 62, 63]
    if decrease_index # nil check
      current_station_times[decrease_index + 1..-1]  = current_station_times[decrease_index + 1..-1].map {|time| time + 60}
    end

    current_station_times_from_past =
      current_station_times.select { |time| time < Time.now.min } 
    current_station_time = current_station_times_from_past.max

    abording_train = trains.find { |train| train[current_station] == current_station_time }
    abording_train.update(abording: true)
    arrives()
  end

  desc "reset", ""
  def reset
    Train.all.update(abording: false)
  end
end

TrainCommand.start(ARGV)
