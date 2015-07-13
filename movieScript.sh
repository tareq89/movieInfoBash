#!/bin/bash

getMovieDescription(){
	local html=$1

	movieDescriptionPrefix='<p itemprop="description">'
	movieDescriptionSuffix='</p>'

	movieDescription="$(echo $html | grep -oP '<p itemprop="description">(.*?)</p>')"
	movieDescription="${movieDescription#$movieDescriptionPrefix}"
	movieDescription="${movieDescription%$movieDescriptionSuffix}"

	echo $movieDescription
	echo "<td>" >> output.html
	echo $movieDescription >> output.html
	echo "</td>" >> output.html
}

getMovieRating(){
	local html=$1

	movieRatingPrefix='<span itemprop="ratingValue">'
	movieRatingSuffix='</span>'

	movieRating="$(echo $html | grep -oP '<span itemprop="ratingValue">(.*?)</span>')"
	movieRating="${movieRating#$movieRatingPrefix}"
	movieRating="${movieRating%$movieRatingSuffix}"

	echo $movieRating
	echo "<td>" >> output.html
	echo $movieRating >> output.html
	echo "</td>" >> output.html
}

getMovieName(){
	local html=$1

	movieNamePrefix='<h1 class="header"> <span class="itemprop" itemprop="name">'
	movieNameSuffix='</span>'

	movieName="$(echo $html | grep -oP '<h1 class="header"> <span class="itemprop" itemprop="name">(.*?)</span>')"
	movieName="${movieName#$movieNamePrefix}"
	movieName="${movieName%$movieNameSuffix}"
	
	echo $movieName
	echo "<td>" >> output.html
	echo $movieName >> output.html
	echo "</td>" >> output.html
}

getMovieGenre(){
	local html=$1

	movieGenrePrefix='<span class="itemprop" itemprop="genre">'
	movieGenreSuffix='</span>'

	movieGenre="$(echo $html | grep -oP '<span class="itemprop" itemprop="genre">(.*?)</span>')"

	movieGenre="${movieGenre#$movieGenrePrefix}"
	movieGenre="${movieGenre%$movieGenreSuffix}"
	
	# echo $movieGenre
	echo "<td>" >> output.html
	echo $movieGenre >> output.html
	echo "</td>" >> output.html
}


getMoviePageLink(){
	local movieName=$1	
	host='http://imdb.com'
	fileNamePrefix="/home/tareq.aziz/movies/"

	movieName="${movieName#$fileNamePrefix}"						
	movieName="$(echo $movieName | tr '.' ' ')"	
	movieName="$(echo $movieName | tr ' ' '+')"	

	html=$(wget http://www.imdb.com/find?q=$movieName -q -O -)

	link="$(echo $html | grep -oP '<table class="findList"> <tr class="findResult odd"> <td class="primary_photo"> <a href="/title/(.*?)" >?')"	


	linkPrefix='<table class="findList"> <tr class="findResult odd"> <td class="primary_photo"> <a href="'
	linkSuffix='" >'

	link="${link#$linkPrefix}"		
	link="${link%$linkSuffix}"
	link=$host$link

	echo "**********************************************************************"
	echo $movieName  "------------------>"   $link

	html=$(wget "$link" -q -O -)

	echo "<tr>" >> output.html
	getMovieName "$html"
	getMovieGenre "$html"
	getMovieRating "$html"
	getMovieDescription "$html"
	echo "</tr>" >> output.html
	echo "**********************************************************************"
	echo ""
	echo ""
	echo ""
}



# Main program
upperHtml=$(cat upper.html)
lowerHtml=$(cat lower.html)
echo $upperHtml >> output.html


for movie in /home/tareq.aziz/movies/*
do
	movie="$(echo $movie | awk '{print tolower($0)}')"
	if [ "$(echo $movie  | grep -oP  '((/home/tareq.aziz/movies/(.*?))((\d\d\d\d)))')"  ]	
	then
		movieName="$(echo $movie  | grep -oP  '((/home/tareq.aziz/movies/(.*?))((\d\d\d\d)))')"
		getMoviePageLink "$movieName"
		
	else
		movieName="$(echo $movie  | grep -oP  '((/home/tareq.aziz/movies/(.*)))')"	
		getMoviePageLink "$movieName"
	fi	
done	
echo $lowerHtml >> output.html
