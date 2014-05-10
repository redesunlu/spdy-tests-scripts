Experiment 5
=========

Requeriments
--------------
This experiment has a few dependences that must be installed before start using.
###Dependences

####Packages
* [Google Chrome] or [Chromium Browser]
* [TShark]
* [NodeJS]

####Node Modules
* [PhantomJS]
* [Chrome-Har-Capturer]
* System

####Python Package
* [Scapy]

####Installation
This instruction are for Ubuntu or other Debian-based distros.

First we need install a needed packages.
```bash
sudo apt-get install tshark chromium-browser nodejs npm
```
Next install a nodejs modules required.
```bash
sudo npm install -g phantomjs
npm install system chrome-har-capturer
```
Then install Scapy.
```bash
wget http://www.secdev.org/projects/scapy/files/scapy-latest.tar.gz
tar -zxvf scapy-latest.tar.gz
cd scapy-2.1.0
sudo ./setup.py install
```

Usage
--------------
```bash
./exp5.sh
```

TODO



[Google Chrome]: https://www.google.com/chrome/browser/
[Chromium Browser]: http://www.chromium.org/Home
[TShark]: http://www.wireshark.org/docs/man-pages/tshark.html
[NodeJS]: http://nodejs.org/
[PhantomJS]: http://phantomjs.org/
[Chrome-Har-Capturer]: https://github.com/cyrus-and/chrome-har-capturer
[Scapy]: http://www.secdev.org/projects/scapy/
