from bs4 import BeautifulSoup
import datetime
import requests
import json
import io
from PIL import Image
import urllib3
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)


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