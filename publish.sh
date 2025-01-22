#!/bin/sh
hugo
rsync -avr --progress public/* serverprofis:sites/innenreisebegleitung.de/
