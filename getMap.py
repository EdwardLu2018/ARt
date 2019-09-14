from bs4 import BeautifulSoup
import datetime
import requests
import json
import io
from PIL import Image
import urllib3
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)



def make_soup(url):
    http = urllib3.PoolManager()
    r = http.request("GET", url)
    return BeautifulSoup(r.data,'lxml')


def spell_correct (artist):
	artist = artist.strip().replace (" ", "%20")
	url = "https://www.wikiart.org/en/Search/" + artist + "#!#filterName:Style_post-impressionism,resultType:masonry"
	soup = make_soup (url)
	divs = soup.find_all('a')
	for div in divs:
		print( (div.text))

def getMap(place):
	#takes in a list of places and gives out image places in io.bytes
	api_key = "AIzaSyA77bNJRtXVDm_SdTUihAixskEhUK8c98I"
	url = "https://maps.googleapis.com/maps/api/staticmap?"
	center = place
	zoom = 10
	r = requests.get(url + "center=" + center + "&zoom=" + str(zoom) + "&size=" + "400x400" + "&key=" + api_key) 

	byteCode = io.BytesIO(r.content)
	print(type(byteCode))

	return byteCode

getMap("Chicago")