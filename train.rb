require 'thor'


class TrainCommand < Thor
  
  desc "start", ""
  def start 
  
    stations = [
      :新宿,
      :代々木上原,
      :下北沢,
      :登戸,
      :新百合ヶ丘,
      :町田
    ]

    trains_departs_18to20 = [
    	[1, 6, 8, 17, 26, 35],
    	[10, 15, 18, 26, 34, 42],
    	[21, 26, 28, 37, 43, 54],
    	[30, 35, 38, 46, 54, '2#'] ,
    	[41, 46, 48, 57, '6#', '15#'],
    	[50, 55, 58, '7#', '15#', '25#']
    ].map { |train| stations.zip(train).to_h }
    
    trains_departs_21 = [
    	[1, 6, 8, 17, 26, 35],
    	[10, 14, 17, 26, 34, 42],
    	[21, 26, 28, 37, 45, 53],
    	[30, 34, 37, 46, 54, '2#'],
    	[41, 46, 48, 57, '4#', '13#'],
    	[50, 54, 57, '6#', '13#', '23#']
    ].map { |train| stations.zip(train).to_h }
   
    trains_departs_22 = [
    	[1, 6, 8, 17, 24, 33],
    	# skiped 2209 because it is bounds for 唐木田
    	[20, 24, 27, 36, 42, 50],
    	[46, 51, 53, '2#', '10#', '18#']
    ].map { |train| stations.zip(train).to_h }

    trains_departs_23 = [
      [22, 26, 29, 38, 44, 53]
    ].map { |train| stations.zip(train).to_h }

    p trains =
      case Time.now.hour
      when 18..20
      	trains_departs_18to20
      when 21
      	trains_departs_21
      when 22
      	trains_departs_22
      when 23
      	trains_departs_23
      else
        p "out of range - applying test values"
      	trains_departs_18to20
      end

    p train_depart_minutes = 
        trains.map { |train| train[:新宿].to_h }

    # rid the trains already has been left
    p train_depart_minutes.delete_if { |time| time < Time.now.min } 

    depart_time = train_depart_minutes[0]
    @abording_train = trains.find { |train| train[0] == depart_time }
    
    puts "Have a nice trip!"
  end


  desc "arrives", ""
  def arrives
    
    p remaning_minutes = Time.now.min - @abording_train[:町田駅]
    puts "You will be arrived at #{Time.now.hour}:#{@abording_train[:町田駅]}\n
          which is #{remaning_minutes} to go."
  end

end

TrainCommand.start(ARGV)
