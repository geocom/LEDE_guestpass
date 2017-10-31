=begin

##Password Setter
## MIT License

Copyright (c) 2017 Geoff Evans

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

last_password = File.read("/www/luci-static/resources/rand_pass.txt").chomp
ssid          = File.read("/overlay/password_setter/ssid.txt").chomp
all_words     = File.read("/overlay/password_setter/words.txt").split("\n")

selected_words = []

(1..11).each do |word|
        selected_words << all_words[Random.rand(2005).round]
end
(1..7).each do |word|
        selected_words.delete_at(Random.rand(selected_words.count))
end
puts selected_words.join("-")

File.open("/www/luci-static/resources/rand_pass.txt", 'w') { |file| file.write(selected_words.join("-")) }

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