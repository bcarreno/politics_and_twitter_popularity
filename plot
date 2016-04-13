#!/usr/bin/env ruby

require 'date'
require 'optparse'

def self.footer
<<EOT
      ]
  });
});
</script>
EOT
end

def header(div, title, height)
<<EOT
<div id="#{div}"></div>
<script>
$(function () {
  $('##{div}').highcharts({
      chart: {
          type: 'line',
          height: #{height}
      },
      title: {
          text: '#{title}'
      },
      xAxis: {
          type: 'datetime',
          dateTimeLabelFormats: { // don't display the dummy year
              month: '%e. %b',
              year: '%b'
          },
          title: {
              text: 'Date'
          }
      },
      yAxis: {
          type: 'linear',
          title: {
              text: 'Followers'
          }
      },
      tooltip: {
          headerFormat: '<b>{series.name}</b><br>',
          pointFormat: '{point.x:%e. %b}: {point.y:.2f} m'
      },

      plotOptions: {
         series: {
              marker: {
                  enabled: false
              }
          },
        spline: {
              marker: {
                  enabled: false
              }
          }
      },

      series: [
EOT
end

def logger(string)
  puts "- #{string}" if false
end

def js_date(date)
  [date.year, date.month - 1, date.day].join(', ')
end

def accept?(name, group)
  finalists = %w(sensanders tedcruz JebBush marcorubio RealBenCarson BernieSanders HillaryClinton realDonaldTrump)
  return unless finalists.include?(name)
  case group
  when "both"
    true
  when "high_group"
    %w(HillaryClinton realDonaldTrump).include?(name)
  when "low_group"
    !%w(HillaryClinton realDonaldTrump).include?(name)
  else
    raise "invalid option: #{ARGV[5]}"
  end
end

### MAIN

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: example.rb [options]"

  opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
    options[:verbose] = v
  end
  opts.on("-tTITLE", "--title=TITLE", "Graph title") do |value|
    options[:title] = value
  end
  opts.on("-gGROUP", "--group=GROUP", "Data group") do |value|
    options[:group] = value
  end
  opts.on("-iDIV", "--id=DIV", "div id") do |value|
    options[:id] = value
  end
  opts.on("-sSTEP", "--step=STEP", "How many days for each graph point") do |value|
    options[:step] = value.to_i
  end
  opts.on("-hHEIGHT", "--height=HEIGHT", "Graph height") do |value|
    options[:height] = value.to_i
  end
end.parse!

puts header options[:id], options[:title], options[:height]

followers = {}
File.readlines('twitter.log.full').each do |line|
  logger line
  name, date, time, count = line.split
  next if count.nil?
  date = Date.strptime(date, '%Y-%m-%d')

  logger [name, date, time, count]
  followers[name] = {} if followers[name].nil?
  followers[name][date] = count if followers[name][date].nil?
end

step = [1, options[:step].to_i].max
candidates_count = 0
followers.each do |name, collection|
  next unless accept?(name, options[:group])
  candidates_count += 1
  puts "{"
  puts %Q(name: "#{name}",)
  puts "data: ["
  puts collection.
    sort.
    each_with_index.
    select{ |x, i| i % step == 0 }.
    map{ |x, i| "  [Date.UTC(#{js_date(x[0])}, 12,0,0), #{x[1].to_i}]" }.
    join(",\n")
  separator = candidates_count < followers.keys.count ? ',' : ''
  puts "]}#{separator}"
end

puts footer
