# LEDE Guest Password

This has been tested to work on LEDE with ruby installed. You can find ruby in the packages list on any LEDE install.

This will generate a password from a list of words separated by a new line and set a new SSID with the date of generation so that devices will treat it as a new access point and can be setup to automatically run via Cron 

**IMPORTANT!!!**

This code in no way separates your networks it does not setup any interfaces firewalls or wifi access points. If you use this make sure to setup firewalls and interfaces correctly.

**What Does It Do**

This will generate a password from a list of words separated by a new line and set a new SSID with the date of generation so that devices will treat it as a new access point and can be setup to automatically run via Cron 

**To Install**

Setup a wifi network **DO NOT SET THIS PASSWORD TO BE THE SAME AS OTHER NETWORKS OTHERWISE IT WILL CHANGE ALL YOUR WIFI PASSWORDS**

Install ruby if not already installed

* `mkdir /overlay/password_setter`
* Copy password_setter.rb to "/overlay/password_setter"
* Create a ssid.txt(nano or vi etc) file in /overlay/password_setter with your SSID that you want to use this script on.
* Create a words.txt list this contains all the words that will be randomly chosen by the script. You can find many different types of lists on the internet.
* Create a file in /www/luci-static/resources/ called rand_pass.txt this needs the password currently associated to your wifi network this file can be accessed from your network to get the password that has been generated it will also be how the next time the script is run we know what line to replace

Check that it works by running ruby password_setter.rb if it works then your good to go

**Cron Task(Scheduled Tasks)**

This will run the code daily at 2:30AM.

`30 2 * * * ruby /overlay/password_setter/gen_password.rb >> /overlay/password_setter/log.log 2>&1`

You should set this at a time where the wifi is not going to be used. The wifi interface is restarted so if your using your wifi at this time you may lose connectivity for a short time.
