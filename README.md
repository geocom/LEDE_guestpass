Development branch note consider this still in very alpha stage. Need to upload to GitHub to clone it onto the device to make sure it works. This at present is untested.

# LEDE Guest Password

This has been tested to work on openwrt(was LEDE) with ruby installed. You can find ruby in the packages list on any openwrt install.

This will generate a password from a list of words separated by a new line and set a new SSID with the date of generation so that devices will treat it as a new access point and can be setup to automatically run via Cron

**IMPORTANT!!!**

This code in no way separates your networks it does not setup any interfaces firewalls or Wi-Fi access points. If you use this make sure to setup firewalls and interfaces correctly.

**What Does It Do**

This will generate a password from a list of supplied words(supplied by a txt file, words must be separated by a new line see lists below for some examples) or random letters/numbers and set a new SSID with the date of generation so that devices will treat it as a new access point and can be setup to automatically run via Cron

**To Install**

Setup Wi-Fi network

Install ruby and git(optional see option 1 below) if not already installed via opkg or luci

ssh into your openwrt device

Option 1
`cd /overlay
git clone https://github.com/geocom/LEDE_guestpass.git`

Option 2

`mkdir /overlay/LEDE_guestpass`

copy password_setter into this directory

Both Option 1 & Option 2

Download a word list here a few options (Only required if using randword)

[GitHub first20hours/google-10000-english](https://github.com/first20hours/google-10000-english)

Lists only positive words

[GitHub english-words/words_alpha.txt](https://github.com/dwyl/english-words/blob/master/words_alpha.txt)

includes Swear Words so if you dont want to be putting swear words into your passwords do not use this list

Copy the list into the LEDE_guestpass directory and name it words.txt

Setup your config.json(see the bottom of this readme for all options

**Check that it all works**

Check that it works by running ruby password_setter.rb if it works then your good to go

**Cron Task(Scheduled Tasks)**

This will run the code daily at 2:30AM.

`30 2 * * * ruby /overlay/LEDE_guestpass/password_setter.rb >> /overlay/LEDE_guestpass/log.log 2>&1`

You should set this at a time where the Wi-Fi is not going to be used. The Wi-Fi interface is restarted so if your using your Wi-Fi at this time you may lose connectivity for a short time.

## config.json

example_config.json has some example JSON files. please only include 1 object below is the full list of all options

**ssid = The SSID of your guess network.**

This code does a check for the SSID it is important that your SSID is not a string that exists in another network you don't want to change

eg if you name your guest Wi-Fi "Wi-Fi" and another SSID as "Private Wi-Fi" both will be considered as a guest network however if you do Guest Wi-Fi and Wi-Fi it will only consider Guest Wi-Fi as a guest network

**mode = setter or clone**

Setter the programme will generate the password and set the password on the device its self.

In Clone mode the programme will download the password from another device and set the password on its self. This is only useful on networks with multiple access points

**Setter Only Options**

**password_type = randword or 4bytehex**

Select your password type at this time randword(e.g word-word-word-word) and 4bytehex(eg FFFF-FFFF-FFFF-FFFF) are supported

**password_block_count = integer**

Sets the number of blocks that the password is e.g word-word is 2 word-word-word-word is 4

**Clone Only Options**

**max_run_hours = integer**

set a maximum amount of time that the script will try and run to clone the password from another device recommended 1 hour

**protocol = http or https**

Chose between http or https. Openwrt supports https however the key is a self signed cert so there is no way for us to just approve the signature without a public key being installed on your device. To install the key download the public key from you setter device and add it to the certs file. After this set the certfile config to the cert path

If you use https you will need to download and reconfigure this every time the cert expires which should be 2 years based on the current signing length. You should only use https if you need to. The device may renew its cert without warning causing cloned devices to not update. In theory your network should be trusted anyway but if you don't trust your network or just want to ensure that the password cannot be changed by a man in the middle attack then you can use https just be aware that things may fail.

**Not required but options that exist**

**Wi-Fi_config["settype"] = filechange or nil**

Allows you to move to the old code that directly changes the wireless config. Not recommended but may be needed if you don't have the uci command(unlikely on openwrt)

**dry_run = true or false or nil**

Allows you to do a dry run good option for your first setup. This will still make the uci changes but wont commit them so you can check that your setup has worked.
