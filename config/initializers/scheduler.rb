require 'rufus-scheduler'


# Let's use the rufus-scheduler singleton
#
s = Rufus::Scheduler.singleton


# Stupid recurrent task...
#
#s.every '24h' do

s.every '24h', :first_in => '1s' do

  puts "Starting Scraping"

  locations = []
  Location.all.each do |location |
    loc_obj = {}
    loc_obj['id'] = location.id
    airports = location.airports
    time_stamp = Airport.where(location_id: location.id).maximum(:created_at)
    puts time_stamp.class
    if time_stamp == nil
      time_stamp = Time.new(2000)
    end
    loc_obj['timestamp'] = time_stamp
    locations.push(loc_obj)
  end

  locations.sort! { |x, y| x['timestamp'] <=> y['timestamp'] }

  puts locations.to_s

  locations.each do | loc_obj |

    location = Location.find(loc_obj['id'])

    url = 'https://skyvector.com' + location.link
    page = Nokogiri::HTML(open(url))

    i = 0
    page.css('tr a').each do | link |
      if i == 0
        puts "first"
        i = 1
        next
      end
      #puts link.attribute('href')
      airport = link.attribute('href')
      new_url = "https://skyvector.com/" + airport
      new_page = Nokogiri::HTML(open(new_url))

      symbol = new_page.css('#titlebgleftg')[0].content
      name = new_page.css('#titlebgright')[0].content

      puts name
      puts symbol



      airport = Airport.where(name: name, symbol: symbol).first_or_initialize

      puts airport.id

      if airport.name.include?("Heliport")
        airport.airport_type = "H"
        puts "NOT ADDING"
        next
      else
        airport.airport_type = "A"
      end

      airport.location_id = location.id



      first = true

      new_page.css('th').each  do |header|

          if header.content == "Sectional Chart:"
            sectional = header.next_sibling.content
            airport.sectional = sectional
            airport.save

          end

          if header.content == "Airport Use:"
            puts header.next_sibling.content
            use = header.next_sibling.content.downcase

            if !use.include?('public')
              puts 'PRIVATE - NOT ADDING ' + airport.name
              break
            end
          end

          airport.save

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



end
