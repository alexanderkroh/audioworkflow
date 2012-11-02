#!/bin/bash
#Need to know how to connect to the server before doing anything else

#sourcedir is the watch folder I will place thigns in to have this script process
sourcedir="/Users/rothd/Documents/testfolder/AUDIOTRANSFER/inprocessing"

#destwavdir is the folder where archival .wav files and their associated md5 will end up after processing by script, later will be written to LTO
destwavdir="/Users/rothd/Documents/testfolder/AudiotoLTO"

#destXMLdir is the folder where pbcore instantiation XML files will await upload to the BMAC database
destXMLdir="/Users/rothd/Documents/testfolder/Brown/instantiationsXML"

#destmp3dir is the folder where streaming audio files will reside to be accessed by BMAC
destmp3dir="/Users/rothd/Documents/testfolder/Brown/Proxies/Audio"

cd "$sourcedir"
for i in *.wav; do

#echo -e "Processing $i"

#embed md5 in bext header of .wav file, digest for info chunk only, i.e. audio stream PCM data only
#echo -e "\tRunning: bwfmetaedit --MD5-Embed $i"
bwfmetaedit --MD5-Embed "$i"

#generate md5 called originalfilename.wav.md5 and place it in the folder to be written to LTO
#echo -e "\tRunning: md5 -r $i > $destwavdir/$i.md5"
md5 -r "$i" > "$destwavdir/$i.md5"

#generate pbcore instantiation record for .wav file called originalfilename.wav.xml
#echo -e "\tRunning: mediainfo --Output=XML -–Language=raw -f $i > $i.xml"
mediainfo --Output=XML -–Language=raw -f "$i" > "$i.xml"
xsltproc http://www.avpreserve.com/metadata/mediainfo2pbcoreinstantiation.xsl "$i.xml" > "$destXMLdir/$i.xml"

#generate mp3 file from .wav, I'm totally guessing on the process for replacing .wav with .mp3, I just saw something that looked like it would work, I know, this is a disgraceful way to learn coding
#echo -e "\tRunning: ffmpeg -i $i -ab 256k -ar 44100 ${i%.*}.mp3"
ffmpeg -i "$i" -ab 256k -ar 44100 "${i%.*}.mp3"

#generate pbcore instantiation record for .mp3 file
#echo -e "\tRunning: mediainfo --Output=XML --Language=raw -f ${i%.*}.mp3 > ${i%.*}.mp3.xml"
mediainfo --Output=XML --Language=raw -f "${i%.*}.mp3" > "${i%.*}.mp3.xml" 
xsltproc http://www.avpreserve.com/metadata/mediainfo2pbcoreinstantiation.xsl "${i%.*}.mp3.xml" > "$destXMLdir/${i%.*}.mp3.xml"
#remove mediainfo files
#echo -e "\tRunning: rm *.xml"
rm *.xml

# move .mp3 and .wav files to their respective folders
#echo -e "\tRunning: mv ${i%.*}.mp3 $destmp3dir"
mv "${i%.*}.mp3" "$destmp3dir"
#echo -e "\tRunning: mv $i $destwavdir"
mv "$i" "$destwavdir"

#echo -e ""
done
