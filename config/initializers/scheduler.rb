require 'rufus-scheduler'

#["Dimensions", "Surface", "Weight Limits", "Edge Lighting", "Coordinates",
#{}"Elevation", "Gradient", "Traffic Pattern", "Runway Heading",
#{}"Displaced Threshold", "Markings", "Glide Slope Indicator", "REIL",
#{}"Obstacles", "Declared Distances", "Approach Lights", "RVR Equipment", "Centerline Lights"]

# Let's use the rufus-scheduler singleton
#
s = Rufus::Scheduler.singleton


# Stupid recurrent task...
#
#s.every '24h' do

s.every '24h', :first_in => '1s' do

  puts "Starting Scraping"
  things = []

  url = 'https://skyvector.com/airports/United%20States/California'
  #
  page = Nokogiri::HTML(open(url))
  #puts page.css('th')   # => Nokogiri::HTML::Document
  i = 0
  page.css('tr a').each do | link |
    if i == 0
      puts "first"
      i = 1
      next
    end
    #puts link.attribute('href')
    airport = link.attribute('href')
    puts airport
    new_url = "https://skyvector.com/" + airport
    new_page = Nokogiri::HTML(open(new_url))

    symbol = new_page.css('#titlebgleftg')[0].content
    name = new_page.css('#titlebgright')[0].content

    puts name
    puts symbol

    airport = Airport.where(name: name, symbol: symbol).first_or_create

    puts airport.id

    first = true

    new_page.css('th').each  do |header|

        if header.content == "Sectional Chart:"
          sectional = header.next_sibling.content
          airport.sectional = sectional
          airport.save

        end

        if header.content.start_with?("Runway ") && !header.content.include?("Heading")

          runway = Runway.where(name: header.content, number: header.content.split(' ')[1],airport_id: airport.id).first_or_create
          #puts header.content
          #r = Runway.new(name: header.content, number: header.content.split(' ')[1],airport_id: airport.id)

          #puts runway

          puts "RUNWAY " + header.content.split(' ')[1]


          header.parent.parent.css('tr').each do | runway_row |

            if runway_row.css('th').length == 0
              next
            end

            key = runway_row.css('th')[0].content.gsub(':', '')
            if key.start_with?("Runway ") && !key.include?("Heading")
              next
            end

            key = key.downcase.gsub(' ', '_')

            #puts "KEY = " + key

            value = ""
            if first || runway_row.css('td').length == 1
              value = runway_row.css('td')[0].content.gsub("\n", '').gsub(/\s+/, ' ')
              #puts "VALUE = " + value

            else
              value = runway_row.css('td')[1].content.gsub("\n", '').gsub(/\s+/, ' ')
              #puts "VALUE = " + value
            end

            runway[key] = value

            end

            runway.save

          end

          first = !first
        end
    end
end
