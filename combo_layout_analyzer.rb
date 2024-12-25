#Marc St. Pierre
#September 13 2024

#import libraries
require 'csv'

#layouts from bottom to top row then by columns from left to right
qwerty =    [['', '', '', '','', '', '', '', ' ', '', '', '', '', '', ' ', '', '', '', '','', '', '', ''], #benchmark 80wpm efficiency
             ['', '', '', '','', '', '', '', '', '', '', '', '', '', '', '', '', '', '','', '', '', ''],
             ['','', 'z', '', 'x', '', 'c', '', 'v', '', 'b', '', 'b', '', 'n', '', 'm', '', '', '', '-', '', ''],
             ['', '', '', '','', '', '', '', '', '', '', '', '', '', '', '', '', '', '','', '', '', ''],
             ['', '', 'a', '', 's', '', 'd', '', 'f', '', 'g', '', 'h', '', 'j', '', 'k', '', 'l', '', '\'', '', ''],
             ['', '', '', '','', '', '', '', '', '', '', '', '', '', '', '', '', '', '','', '', '', ''],
             ['', '', 'q', '', 'w', '', 'e', '', 'r', '', 't', '', 'y', '', 'u', '', 'i', '', 'o', '', 'p', '', '']]

colemak =   [['', '', '', '','', '', '', '', ' ', '', '', '', '', '', ' ', '', '', '', '','', '', '', ''], #benchmark 89wpm efficiency
             ['', '', '', '','', '', '', '', '', '', '', '', '', '', '', '', '', '', '','', '', '', ''],
             ['','', 'z', '', 'x', '', 'c', '', 'v', '', 'b', '', 'b', '', 'k', '', 'm', '', '', '', '-', '', ''],
             ['', '', '', '','', '', '', '', '', '', '', '', '', '', '', '', '', '', '','', '', '', ''],
             ['', '', 'a', '', 'r', '', 's', '', 't', '', 'd', '', 'h', '', 'n', '', 'e', '', 'i', '', 'o', '', ''],
             ['', '', '', '','', '', '', '', '', '', '', '', '', '', '', '', '', '', '','', '', '', ''],
             ['', '', 'q', '', 'w', '', 'f', '', 'p', '', 'g', '', 'j', '', 'l', '', 'u', '', 'y', '', '\'', '', '']]

tukey =     [['', '', '', '','', '', '', '', ' ', '', '', '', '', '', ' ', '', '', '', '','', '', '', ''], #achieved 90wpm efficiency
             ['', '', '', '','', '', '', '', '', '', '', '', '', '', '', '', '', '', '','', '', '', ''],
             ['','', 'q', '', 'x', '', 'g', '', 'r', '', 'b', '', 'j', '', 'l', '', 'y', '', 'v', '', 'z', '', ''],
             ['', '', '', '','', '', '', '', '', '', '', '', '', '', '', '', '', '', '','', '', '', ''],
             ['', '', 'a', '', 'n', '', 'd', '', 's', '', 'w', '', 'u', '', 'e', '', 'i', '', 'h', '', 'p', '', ''],
             ['', '', '', '','', '', '', '', '', '', '', '', '', '', '', '', '', '', '','', '', '', ''],
             ['', '', 'o', '', 'l', '', 'c', '', 't', '', 'f', '', 'k', '', 'o', '', 'r', '', 'm', '', 't', '', '']]

combo_og = [['', '', '', '','', '', '', '', ' ', '', '', '', '', '', ' ', '', '', '', '','', '', '', ''], #achieved 101wpm efficiency
             ['', '', '', '','', '', '', '', '', '', '', '', '', '', '', '', '', '', '','', '', '', ''],
             ['','', 'z', 'time', 'x', 'con', 'c', 'ect', 'v', 'ver', 'b', '', 'o', 'now', 'n', 'ome', 'm', 'but', 'e', 'differ', 'i', '', ''],
             ['', '', 'any', '','was', '', 'der', '', 'nce', '', 'between', '', 'ight', '', 'ent', '', 'ike', '', 'all','', 'ing', '', ''],
             ['', '', 'a', 'what', 's', 'have', 'd', 'from', 'f', 'for', 'g', '', 'h', 'his', 'j', 'and', 'k', 'can', 'l', 'only', '\'', '', ''],
             ['', '', 'not', '','with', '', 'the', '', 'are', '', 'ted', '', 'oun', '', 'ould', '', 'I', '', 'ough','', 'people', '', ''],
             ['', '', 'q', 'whi', 'w', 'whe', 'e', 'ter', 'r', 'tha', 't', '', 'y', 'you', 'u', 'out', 'i', 'ion', 'o', 'because', 'p', '', '']]

combo_new = [['', '', '', '','', '', '', '', ' ', '', '', '', '', '', ' ', '', '', '', '','', '', '', ''], #achieved 104.33wpm efficiency
             ['', '', '', '', '', '', '', '', 'c', '', '', '', '', '', 'r', '', '', '', '','', '', '', ''],
             ['','', 'z', 'was', 'x', 'nce', 'c', 'ect', 'v', 'ver', 'b', '', 'o', 'now', 'n', 'me', 'm', 'but', 'e', 'ight', 'i', '', ''],
             ['', '', '1', '', '2', '', '3', '', '4', '', '5', '', '6', '', '7', '', '8', '', '9', '', '0', '', ''],
             ['', '', 'a', 'what', 's', 'have', 'd', 'fr', 'f', 'for', 'g', '', 'h', 'his', 'j', 'and', 'k', 'can', 'l', 'all', '\'', '', ''],
             ['', '', 'not', '','with', '', 'the', '', 'ent', '', 'ted', '', 'un', '', 'ould', '', 'I', '', 'ough','', 'ing', '', ''],
             ['', '', 'q', 'which', 'w', 'whe', 'e', 'ter', 'r', 'that', 't', '', 'y', 'ny', 'u', 'you', 'i', 'ou', 'o', 'ion', 'p', '', '']]


#helper functions
def map_keys (layout, finger_mappings)
  #creates a dictionary of key characters and their corresponding fingers and coordinates
  key_spacing = 9.5 #millimeters for all pressable locations on the keyboard
  
  #builds the keymap from the provided layout
  keymap = Hash.new{|hsh,key| hsh[key] = [] }
  0.upto(22) do |col|
    0.upto(6) do |row|
      #assign the character and finger to the key position
      finger = finger_mappings[row][col]
      keymap[[col * key_spacing, row * key_spacing]] = [layout[row][col], finger]
    end
  end
  return keymap
end

def collect_fingers (layout, finger_mappings)
  #creates a dictionary to look up the assigned finger based on the character
  fingers_to_keys = Hash.new{|hsh,key| hsh[key] = [] }
  
  layout.flatten.each_with_index do |char, idx|
    fingers_to_keys[char].push finger_mappings.flatten[idx] if char != "no" #filters out unmapped characters
  end
  return fingers_to_keys
end

def prep_text (text, layout, size, offset)
  # takes a given string of characters and filters it by the available characters in the provided layout
  # then 'chunks' any sets of characters that match combination keys in the provided layout. forx 'the' becomes a chunk
  # outputs a two dimensional list of combos and individual characters 

  sample = ""
  chunk_list = []

  0.upto(size) do |text_index|
    char = text[text_index + offset].to_s.downcase 

    if sample[0] == char
      sample[0] = ""
      next
    end

    #going to have a loop that runs to check successive letters which match a shortlist of combo letters until a combo is found or else it returns the character
    #until successive letters no longer match any combinations available in the layout
    shortlist = layout.flatten.select {|str| str.start_with?(char)}
    shortlist = shortlist.uniq.sort_by(&:length).reverse
    shortlist.each do |combo|
      #constructs a comparison window sample out of successive letters in the original text to check if we have a matching combo, if so then we add to the master list 
      combo.size.times do |combo_index|
        sample += text[text_index + offset + combo_index].to_s.downcase
      end
      if sample == combo
        chunk_list.append(combo)
        sample[0] = ""
        break
      else
        sample = ""
      end
    end
  end
  
  return chunk_list
end

def move_time (f, ki, kt)
  #time to move to key algorithm takes a finger (0-9), initial [x, y], and target position [x, y]


  #finger constants [lpinky, lring, lmiddle, lindex, lthumb, rthumb, rindex, rmiddle, rring, rpinky]
  #line equations are described from the bottom left key center (0,0) which is the origin
  slope_int = [[2.93,-16.14], [2.28,-47.06], [2.44, -98.33], [1.93, -114.07], [-0.61, 46], [0.61,-80.5], [-1.93, 289], [-2.44, 412.56],[-2.28, 429],[-2.93, 595.93]]
  finger_segment_radius = 50 #millimeters
  target_diameter = 12.6 #millimeters which is a circle drawn around the target key position


  #describes the spreading motion of your fingers
  abd_vel = [20, 12, 14, 21, 20, 36, 25, 18, 14, 19] #degrees per second of the MCP joint (base knuckle)
  abd_accel = [620, 590, 590, 570, 210, 610, 600, 590, 640, 580]  #degrees per second squared
  
  #distance formula for the amount of abduction displacement from an initial to target key center to angle of approach for a specific finger (f)
  abd_ki = ((-slope_int[f][0] * ki[0]) + ki[1] - slope_int[f][1])/Math.sqrt((slope_int[f][0])**2 + 1)
  abd_kt = ((-slope_int[f][0] * kt[0]) + kt[1] - slope_int[f][1])/Math.sqrt((slope_int[f][0])**2 + 1)
  abduction = (abd_kt - abd_ki).abs
  
  #function returns highest score if keys are too far apart for finger to reach
  if abduction > (2 * finger_segment_radius)
    return 1000
  end
  
  #cosine law to find the amount of abduction angular displacement (converted to degrees)
  theta_abd = Math.acos(((finger_segment_radius **2) + (finger_segment_radius **2) - (abduction **2))/(2*(finger_segment_radius**2))) * (180/Math::PI)
  
  #quadratic formula to find the abduction time from displacement, velocity, and acceleration
  time_abd = (-abd_vel[f] + Math.sqrt(abd_vel[f] ** 2 - (4 * (abd_accel[f]/2) * -theta_abd)))/(2*(abd_accel[f]/2))
  

  #describes the curling motion of your fingers
  flex_vel = [34, 32, 35, 33, 19, 32, 34, 46, 38, 31] #degrees per second of the PIP joint (middle knuckle)
  flex_accel = [370, 210, 250, 350, 300, 610, 400, 250, 270, 300] #degrees per second squared

  #find the x coordinate of the intersection point along the AOA from the initial position
  flex_ki_x = ((ki[0]/slope_int[f][0]) + ki[1] - slope_int[f][1])/(slope_int[f][0] + (1/slope_int[f][0]))
  flex_ki_y = (slope_int[f][0]*flex_ki_x + slope_int[f][1]) #find y from x
  
  #find the x coordinate of the intersection point along the AOA from the target position
  flex_kt_x = ((kt[0]/slope_int[f][0]) + kt[1] - slope_int[f][1])/(slope_int[f][0] + (1/slope_int[f][0]))
  flex_kt_y = (slope_int[f][0]*flex_kt_x + slope_int[f][1])
  
  # distance formula for the amount of flexion displacement from an initial to target key center to angle of approach
  flexion = Math.sqrt((flex_kt_x-flex_ki_x)**2 + (flex_kt_y - flex_ki_y)**2)
  
  #cosine law to find the amount of flexion angular displacement (converted to degrees)
  theta_flex = Math.acos((finger_segment_radius **2 + finger_segment_radius **2 - flexion **2)/(2*(finger_segment_radius**2)))* (180/Math::PI)
  
  #quadratic formula to find the flexion time from displacement, velocity, and acceleration
  time_flex = (-flex_vel[f] + Math.sqrt(flex_vel[f] ** 2 - (4 * (flex_accel[f]/2) * -theta_flex)))/(2*(flex_accel[f]/2))

  #compares and returns the largest of the two times
  #the total time for a finger to arrive at the target location will be the largest of the two times since they are independent events
  #rounds to three decminal places and converts to milisecond integer
  total_time = ([time_flex, time_abd].max.round(3) * 1000).to_i

  return total_time
end

def tally(movement_data)
  #takes in a sequence of finger moves and tallies the results of their frequencies and move times, represented by a two dimensional array 
  tally = []
  movement_data.sort! {|a, b| a[0] <=> b[0] } #sorts first by move category character set
  movement_data.each do |log|
    if tally.size == 0
      tally.append(log) #starts a frequency count of that move type
    else
      #if the same movement is done, ad the movement times and increase the count
      if tally[-1][0] == log[0] 
        tally[-1][2] += log[2]
        tally[-1][3] += log[3]
      else
        tally.append(log)
      end
    end
  end
  tally.sort! {|a, b| a[2] <=> b[2]} #sort by the highest accumulated movement time per move type
  tally.reverse!
  return tally
end

def type (sample_text, layout, debug)
  #finger starting positions list [lpinky, lring, lmiddle, lindex, lthumb, rthumb, rindex, rmiddle, rring, rpinky]
  finger_pos = [[19,39.5], [38,39.5], [57, 41], [76, 32.5], [76, 0], [133, 0], [133, 32.5], [152,41], [171,39.5], [190,39.5]]
  finger_names =["Left Pinky", "Left Ring", "Left Middle", "Left Index", "Left Thumb", "Right Thumb", "Right Index", "Right Middle", "Right Ring", "Right Pinky"]

  #time constants
  key_press_dur = 120 #mean time to hold down a key in milliseconds
  repeat_interval = 56 #in milliseconds. the difference in time between mean repeat iki of 176 and the key_press_dur

  #finger mappings from bottom to top row then by columns from left to right
  finger_mappings = [[0, 0, 0, 0, 1, 1, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5, 8, 8, 9, 9, 9, 9],
                     [0, 0, 0, 0, 1, 1, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5, 8, 8, 9, 9, 9, 9],
                     [0, 0, 0, 0, 1, 1, 2, 2, 3, 3, 3, 3, 6, 6, 6, 7, 7, 8, 8, 9, 9, 9, 9],
                     [0, 0, 0, 0, 1, 1, 2, 2, 3, 3, 3, 3, 6, 6, 6, 7, 7, 8, 8, 9, 9, 9, 9],
                     [0, 0, 0, 0, 1, 1, 2, 2, 3, 3, 3, 3, 6, 6, 6, 7, 7, 8, 8, 9, 9, 9, 9],
                     [0, 0, 0, 0, 1, 1, 2, 2, 3, 3, 3, 3, 6, 6, 6, 7, 7, 8, 8, 9, 9, 9, 9],
                     [0, 0, 0, 0, 1, 1, 2, 2, 3, 3, 3, 3, 6, 6, 6, 7, 7, 8, 8, 9, 9, 9, 9]]

  #map the target coordinates to the keys and fingers from the specified layout
  target_pos = map_keys(layout, finger_mappings)

  #compiles a hash of keys to fingers in the layout (including duplicates)
  fingers = collect_fingers(layout, finger_mappings)

  #initialise the reference variables
  move_times  = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  idle_times  = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  press_times = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  total_times = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0] #the time stamp of the last keypress for each finger
  movement_data = []
  key_count = sample_text.join.length
  last_finger_used = 0 #index of
  last_char_typed = ['','','','','','','','','','']

  #loop through all the characters in the sample
  sample_text.each_with_index do |char, index|
    next_char = sample_text[index + 1].to_s
    next_next_char = sample_text[index + 2].to_s

    if total_times.max == 0
      #the scenario for the first keypress of the sample
      #grabs the first matching finger value to the character being analyzed
      finger = fingers[char][0]
      
      #finds the movement time from its previous position to its target position
      mt = move_time(finger, finger_pos[finger], target_pos.key([char, finger]))
      
      #adds the times to their corresponding lists
      move_times[finger] += mt
      press_times[finger] += key_press_dur
      total_times[finger] += mt + key_press_dur

      if debug
        print "key: " + char + "\n"
        print "move times:  " + move_times.to_s + "\n"
        print "press times: " + press_times.to_s + "\n"
        print "idle times:  " + idle_times.to_s + "\n"
        print "total times: " + total_times.to_s + "\n"
        print "--------------" + "\n"
      end

    else
      #initializes a list of options for keypresses (this will have only one value if there is only one option to press that key)
      options = []

      fingers[char].each do |finger|
        #finds the movement time from that finger's previous position to its target position for this keypress
        mt = move_time(finger, finger_pos[finger], target_pos.key([char, finger]))

        #calculates how long this finger was waiting after its last keypress and once it moved to its new position to press this key
        idle_time = (total_times.max - mt - total_times[finger])
        
        if idle_time > 0
          #if it was idle before the keypress, add those times
          options.append([finger, mt, idle_time, (total_times[finger] + idle_time + mt + key_press_dur)])
        else
          #if it was not idle, that means it had no preparation time and there will be extra time between the keypresses
          
          if last_finger_used == finger
            #detecting if the same finger from last time is being used to press the key (same finger bigram)
            if mt == 0
              #if the finger does not need to move to a new position, that means it is a repeated keytroke. Add those times with the repeat penalty
              options.append([finger, repeat_interval, 0, (total_times[finger] + repeat_interval + mt + key_press_dur)])
            else
              #if the finger needs to move to a new position, that means it is a same finger bigram. Add those times
              options.append([finger, mt, 0, (total_times[finger] + mt + key_press_dur)])
            end
            
          else
            #if it's a different finger that didn't have time to prepare its keystroke. Add those times
            options.append([finger, mt, 0, (total_times[finger] + mt + key_press_dur)])
          end
        end
      end

      # out of the options of fingers, sort which option results in the lowest total time
      choice = options.sort {|a,b| a[3] <=> b[3]}
      choice = choice[0] #selects the best option
      finger = choice[0]

      #adds the times to their corresponding lists
      move_times[finger] += choice[1]
      idle_times[finger] += choice[2]
      total_times[finger] = choice[3]
      press_times[finger] += key_press_dur

      #here we are only concerned with logging the times for optimization where the fingers had no preparation time
      movement_data.append([last_char_typed[finger] + "_" + char, finger_names[finger], choice[1], 1]) if choice[2] <= 0 
      
      if debug
        print "key: " + char + "\n"
        print "move times:  " + move_times.to_s + "\n"
        print "press times: " + press_times.to_s + "\n"
        print "idle times:  " + idle_times.to_s + "\n"
        print "total times: " + total_times.to_s + "\n"
        print "--------------" + "\n"
      end
    end
    
    #updates the reference finger and character
    last_finger_used = finger
    last_char_typed[finger] = char
    
    #updates the resting position of that finger to the target key
    finger_pos[finger] = target_pos.key([char, finger])
  end  

  raw_time = total_times.max #total time to type this text
  cps = (key_count / (raw_time * 0.001)).round(2) #characters per second
  wpm = (cps * 12).round(2) #words per minute
  combined_finger_times = tally(movement_data)

  
  return wpm, combined_finger_times
end

# main loop
def run_full_test (size, layout, layout_name, output_flag)
  
  wpms = []
  results = []

  Dir.chdir("text_samples")
  Dir.glob('*.txt') do |filename|
    shorthand = filename[0..-5]
    text = File.read(filename)
    sample_text = prep_text(text, layout, size, 1500)
    sample = type(sample_text, layout, false)
    wpms.append(sample[0])
    results.append(sample[1])
  end

  puts "Average wpm for all " + layout_name + " " + "samples is: " + (wpms.inject(:+) / wpms.size).to_f.to_s
  results = tally(results.flatten(1))

  if output_flag
    #write the results to file
    output_dir = "test_results/"
    f = CSV.open((output_dir + "results.txt"), "w")
    f.add_row ["character set",
              "finger used",
              "total movement time",
              "frequency"
                ] #column headers
    
    results.each do |result|
      f.add_row(result)
    end
    f.close
    puts "output to: " + output_dir
  end

  #console based optimizer output to see where the 50 biggest pain points are with each layout design
  20.times do |i|
    print results[i]
    print "\n"
  end
end

# run_full_test(10000, combo_og, "old combination layout", false)

run_full_test(10000, combo_new, "latest", false)

