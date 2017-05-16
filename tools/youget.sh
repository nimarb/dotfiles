#!/bin/bash

# basic command to get music from youtube videos through youtube-dl

youtube-dl -f bestaudio --extract-audio --audio-format mp3 --audio-quality 0 --add-metadata $1

#-o %\(title\)-%\(format\).%\(ext\)
