#!/usr/bin/env ruby

require 'date'
require 'byebug'

def self.footer
<<EOT
      ]
  });
});
</script>
EOT
end

def header(div, title, height, scale_type)
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
          type: '#{scale_type}',
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

def accept?(name)
  finalists = %w(sensanders tedcruz JebBush marcorubio RealBenCarson BernieSanders HillaryClinton realDonaldTrump)
  return unless finalists.include?(name)
  case ARGV[5]
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

puts header ARGV[0], ARGV[1], ARGV[3], ARGV[4]

followers = {}
File.readlines('twitter.log').each do |line|
  logger line
  name, date, time, count = line.split
  next if count.nil?
  date = Date.strptime(date, '%Y-%m-%d')

  logger [name, date, time, count]
  followers[name] = {} if followers[name].nil?
  followers[name][date] = count if followers[name][date].nil?
end

offsets = {}
followers.each do |name, collection|
  offsets[name] = ARGV[4] == 'logarithmic' ? collection.sort[0][1].to_i : 0
end

step = [1, ARGV[2].to_i].max
candidates_count = 0
followers.each do |name, collection|
  next unless accept?(name)
  candidates_count += 1
  puts "{"
  puts %Q(name: "#{name}",)
  puts "data: ["
  puts collection.
    sort.
    each_with_index.
    select{ |x, i| i % step == 0 }.
    map{ |x, i| "  [Date.UTC(#{js_date(x[0])}, 12,0,0), #{x[1].to_i-offsets[name]}]" }.
    join(",\n")
  separator = candidates_count < followers.keys.count ? ',' : ''
  puts "]}#{separator}"
end

puts footer
