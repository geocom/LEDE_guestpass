=begin

##Password Setter
## MIT License

Copyright (c) 2017-2021 Geoff Evans

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

If you add any code or make changes to this file you may add your name to the code thanks section below

Code Thanks(People Who Have Shaped This File)
* Geoff Evans(@geocom)

=end


require 'json'

wifi_config = JSON.parse(File.read("#{Dir.pwd}/config.json"))

last_password = File.read("/www/luci-static/resources/rand_pass.txt").chomp
ssid          = wifi_config["ssid"].chomp

start_time = Time.now

if wifi_config["mode"] == "clone"
  require 'net/http'

  code_complete = false
  while code_complete == false do
    ##Download from setting router
    if wifi_config["protocol"] == "https"
      uri = URI("https://#{wifi_config["address"]}/www/luci-static/resources/rand_pass.txt")
      Net::HTTP.start(uri.host, uri.port, :cert => "#{Dir.pwd}/#{wifi_config["certfile"]}", :use_ssl => true) do |http|
        request = Net::HTTP::Get.new uri
        data = http.request request # Net::HTTPResponse object
      end
    else
      uri = URI("http://#{wifi_config["address"]}/www/luci-static/resources/rand_pass.txt")
      data = Net::HTTP.get_response(uri) # => String
    end
    ##Process the data
    if data.code == 200 && not data.body != last_password
        code_complete = true
        new_password = data.body.strip
    else
      if (start_time + wifi_config["max_run_hours"].hours)  <= Time.now
        raise "Timeout Reached"
      end
      sleep 5
    end
  end

elsif wifi_config["mode"] == "setter"
  selected_words = []
  if wifi_config["password_type"] = "randword"
    all_words     = File.read("#{Dir.pwd}/words.txt").split("\n")

    (1..(wifi_config["password_block_count"].to_i * 2)).each do |word|
      selected_words << all_words[Random.rand(all_words.count).round]
    end
    (1..wifi_config["password_block_count"].to_i).each do |word|
      selected_words.delete_at(Random.rand(selected_words.count))
    end
  elsif wifi_config["password_type"] == "4bytehex"
    (1..wifi_config["password_block_count"].to_i).each do |index|
      selected_words = SecureRandom.hex(2)
    end
  end
  new_password = selected_words.join("-")
end

puts new_password

File.open("/www/luci-static/resources/rand_pass.txt", 'w') { |file| file.write(new_password) }

if wifi_config["settype"] == "filechange"
  ##Set the password and ssid by changing the wireless file. Recommed you use uci unless you dont have uci
  new_wifi_file = []

  File.read("/etc/config/wireless").split("\n").each do |line|
          if line.include?("option key '#{last_password}'")
              new_wifi_file << "      		option key '#{selected_words.join("-")}'"
          elsif line.include?("option ssid '#{ssid}")
          	new_wifi_file << "      		option ssid '#{ssid} #{Time.now.strftime("%d/%m/%y")}'"
          else
              new_wifi_file << line
          end
  end

  `cp -f /etc/config/wireless /etc/config/wireless.backup`

  File.open("/etc/config/wireless", 'w') { |file| file.write(new_wifi_file.join("\n")) }

  `wifi down; wifi up;`

  File.open("/www/luci-static/resources/rand_ssid.txt", 'w') { |file| file.write("#{ssid} #{Time.now.strftime("%d/%m/%y")}") }
else
  #set the password and ssid using uci
  i = 0
  while true do
    cmd = `uci get wireless.@wifi-iface[#{i}].ssid`
    if cmd.include?("uci: Entry not found") == true
      #no more entries so can break out
      break
    elsif cmd.include?(ssid) == true
      `uci set wireless.@wifi-iface[#{i}].ssid='#{ssid} #{Time.now.strftime("%d/%m/%y")}'`
      `uci set wireless.@wifi-iface[#{i}].key='#{new_password}'`
    end
    i = i + 1
  end
  if not wifi_config["dry_run"] == "true"
    #set it live unless we are set to do a dry run. It is a good idea to do so on your first run so that you can revert if there is a config issue
    `uci commit wireless`
    `luci-reload`
  end
  File.open("/www/luci-static/resources/rand_ssid.txt", 'w') { |file| file.write("#{ssid} #{Time.now.strftime("%d/%m/%y")}") }
end
