#!/usr/bin/env ruby
require 'thor'

# TODO　例外処理


class TrainCommand < Thor
  
    def assign_train(hour) 
      # NOTE In this list, 新宿 is department time but the rests are all "arrival time". 
      @stations = [
        :新宿,
        :代々木上原,
        :下北沢,
        :登戸,
        :新百合ヶ丘,
        :町田
      ]
  
      @trains_departs_18to20 = [
      	[1, 6, 8, 17, 26, 35],
      	[10, 15, 18, 26, 34, 42],
      	[21, 26, 28, 37, 43, 54],
      	[30, 35, 38, 46, 54, '2#'] ,
      	[41, 46, 48, 57, '6#', '15#'],
      	[50, 55, 58, '7#', '15#', '25#']
      ].map { |train| @stations.zip(train).to_h }
      
      @trains_departs_21 = [
      	[1, 6, 8, 17, 26, 35],
      	[10, 14, 17, 26, 34, 42],
      	[21, 26, 28, 37, 45, 53],
      	[30, 34, 37, 46, 54, '2#'],
      	[41, 46, 48, 57, '4#', '13#'],
      	[50, 54, 57, '6#', '13#', '23#']
      ].map { |train| @stations.zip(train).to_h }
     
      @trains_departs_22 = [
      	[1, 6, 8, 17, 24, 33],
      	# skiped 2209 because it is bounds for 唐木田
      	[20, 24, 27, 36, 42, 50],
      	[46, 51, 53, '2#', '10#', '18#']
      ].map { |train| @stations.zip(train).to_h }
  
      @trains_departs_23 = [
        [22, 26, 29, 38, 44, 53]
      ].map { |train| @stations.zip(train).to_h }

      case hour
      when 18..20
      	@trains_departs_18to20
      when 21  
      	@trains_departs_21
      when 22
      	@trains_departs_22
      when 23
      	@trains_departs_23
      else
        p "out of range - applying test values"
      	@trains_departs_18to20
      end
    end

  desc "start", "Use it when departing 新宿. It will assign the train you are currently taking."
  def start 

p    trains = assign_train(Time.now.hour)
p    train_depart_minutes = 
        trains.map { |train| train[:新宿] }
    
    # rid the trains already has been left
p    train_depart_minutes.delete_if { |time| time < Time.now.min } 
    
    # If all trains have been left in current hour,
    # check the next hour
    if train_depart_minutes.empty? then
p      @abording_train = assign_train(Time.now.hour + 1)[0]
    else
    depart_time = train_depart_minutes[0]
p    @abording_train = trains.find { |train| train[:新宿] == depart_time }
    end    

    puts "Have a nice trip!"
  end


  desc "arrives", "Displays info when you will arive to 町田."
  def arrives

    arrival_hour = Time.now.hour 
p    町田 = @abording_train[:町田]

    if 町田.is_a?(String)
      町田 = 町田[0..1].to_i
      arrival_hour += 1
      remaning_minuts = (60 - Time.now.min) + 町田
    else
    remaning_minutes = 町田 - Time.now.min
   end

    puts "You will be arrived at #{sprintf("%02d:%02d", arrival_hour, 町田)}
          which is #{remaning_minutes} minutes to go."
  end

  desc "search", "Pass the next station name as an arg. This command will reassign the train you are taking."
  def search(next_station)

    trains = assign_train(Time.now.hour)

    # fetch the list of the current station arrival time (before of the arg station)
    # ex) arg:新百合ヶ丘 -> list of 登戸 
    # TODO 例外処理 when arg station doesn't exist
p    next_station_index = @stations.index(next_station.to_sym)
p    current_station = @stations[next_station_index - 1]
p    current_station_arrival_times = trains.map { |train| train[current_station] }

    # find the largest number which fufilles the following condition
    # arrival time (elements of the list) < current minutes

    # TODO BUG: when time contains '#' 
p    current_station_arrival_times =
       current_station_arrival_times.select { |time| 
        if time.is_a?(String)
          time = time.to_i + 60
        end
        time < Time.now.min
      }
    # past_arrival_times = current_station_arrival_times.select { |time| time < Time.now.min } 
    
    current_station_arrival_time = current_station_arrival_times.max
    
p    @abording_train = trains.find { |train| train[current_station] == current_station_arrival_time }
  end

end

TrainCommand.start(ARGV)
