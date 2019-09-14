from bs4 import BeautifulSoup
import datetime
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
	
spell_correct ("pabl picass")