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

  CURRENT_HOUR = case Time.now.hour
                 when 0..17
                   puts " OUTATIME! 通勤時間外での使用を検知しました。テストとして、現在時刻を18:#{Time.now.min}と仮定して起動します。"
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
    
    # TODO Time に変更する。
    # Time も自由に hour を変更できるため問題ない。
    # 　しかし、Time にする利点は何か検討する
    #     ・統一性
    arrival_hour = CURRENT_HOUR
    abording_train = Train.find_by(abording: true)

#   町田に次のhourに到着するか判定
#   例）18時に出発した場合、19時着となるか？
#        [48, 54, 0, 4, 7, 15, 21]
#   到着分が54 → 0 と現象している箇所がある。よって、以降駅は19時着である。
    all_stations_arrival_times = abording_train.attributes.values[2..-3]
    all_stations_arrival_times.each_cons(2).with_index.each do |(a, b), index|
      if a > b
        arrival_hour += 1
        break
      end
    end
    
    arrival_minute = abording_train[FINAL_STATION_COLUMN]

      destination_arrival_time = Time.now.change(hour: arrival_hour, min: arrival_minute)
      remaning_minutes = ((destination_arrival_time - Time.now.change(hour: arrival_hour, min: Time.now.min)) / 60).to_i


    puts "You will be arrived at #{sprintf("%02d:%02d", arrival_hour, arrival_minute)}
          which is #{remaning_minutes} minutes to go."
  end


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
