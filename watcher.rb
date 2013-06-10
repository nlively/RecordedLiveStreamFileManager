#!/usr/bin/env ruby


gem 'activesupport'

require 'active_support/duration'
require 'active_support/core_ext/numeric/time'
require 'active_support/time_with_zone'
require 'active_support/core_ext/time/acts_like'
require 'active_support/core_ext/date_time/calculations'
require 'active_support/core_ext/date/calculations'
require 'active_support/core_ext/time/calculations'
require 'active_support/core_ext/time/conversions'
require 'active_support/core_ext/time/marshal'
require 'active_support/core_ext/time/publicize_conversion_methods'
require 'active_support/core_ext/time/zones'

base_dir = '/Users/livestream/Movies'
dest_dir = '/Users/livestream/Movies/processed'

extension = 'mp4'
offset = 1.hour

files = Dir.glob(base_dir + "/RecordedLiveStream*." + extension)

service_times = [
  { :dow => 0, :start => '11:00', :end => '13:30', :label => 'Sunday Morning', :namepart => 'sunday_morning' },
  { :dow => 0, :start => '18:00', :end => '20:30', :label => 'Sunday Evening', :namepart => 'sunday_evening' },
  { :dow => 2, :start => '19:00', :end => '21:30', :label => 'Tuesday Evening', :namepart => 'tuesday_evening' }
]

# Loop through all unprocessed files found in the folder
files.each do |file|

  timestamp = File.mtime(file)

  puts file
  start_of_week = timestamp.beginning_of_week(:sunday)
  
  filename_datepart = timestamp.strftime '%Y%m%d'
  filename_timepart = timestamp.strftime '%H%M'
  
  found = false
    
  service_times.each do |service_time|
    
    if timestamp.wday == service_time[:dow]
    
      start_time = Time.parse(service_time[:start]) - Time.now.beginning_of_day
      end_time = Time.parse(service_time[:end]) - Time.now.beginning_of_day

      start_date = start_of_week + service_time[:dow].days + start_time
      end_date = start_of_week + service_time[:dow].days + end_time
      
      if timestamp >= start_date - offset and timestamp <= end_date + offset
          
          found = true
      
          @filename_namepart = service_time[:namepart]
      
          break
      end
      
    end

  end
  
    if found
      filename = sprintf('%s_%s', filename_datepart, @filename_namepart)    
    else
      filename = sprintf('%s_%s', filename_datepart, filename_timepart) 
    end
    
    dest = sprintf('%s/%s', dest_dir, filename)
   
    dest_file = dest + '.' + extension
    i = 1
    loop do
      if File.exists(dest_file)
        dest_file = sprintf('%s_%2d.%s', dest, i, extension)
        i=i+1
      else
        File.rename(file, dest_file)
        break
      end
    end
    
    
    
    puts filename
    puts ''

  
end
