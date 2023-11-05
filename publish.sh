#!/bin/sh
hugo
rsync -avr --progress public/* root@euserv2-web:/var/www/headstrong/
