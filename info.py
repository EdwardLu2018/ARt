from bs4 import BeautifulSoup
import datetime
import urllib3
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)


class webscraper(object):

	def make_soup(url):
	    http = urllib3.PoolManager()
	    r = http.request("GET", url)
	    return BeautifulSoup(r.data,'lxml')

	#input a string which is the product
	@staticmethod
	def soup_from_artist (artist):
		artist = artist.strip().replace(" ", "-");
		url =  "https://www.wikiart.org/en/" + artist
		soup = webscraper.make_soup (url)
		return (soup)

	@staticmethod
	def get_titles (soup, numimgs):
		imgs = soup.find_all ('img')
		titles = []
		for i in imgs[0:numimgs]:
			titles.append(i.get ('title'))
		return titles
	@staticmethod
	def get_srcs (soup, numimgs):
		imgs = soup.find_all ('img')
		srcs = []
		for i in imgs[0:numimgs]:
			srcs.append(i.get ('src'))
		return srcs
	@staticmethod
	def get_description (soup):
		para = soup.p.text
		per_ind = para.find (".")
		sent = para[0:per_ind + 1]
		return (sent)
	@staticmethod
	def get_info_dict (artist):
		d = dict()
		soup = webscraper.soup_from_artist (artist)
		numimgs = 4
		d["titles"] = webscraper.get_titles (soup, numimgs)
		d["srcs"] = webscraper.get_srcs(soup, numimgs)
		d["description"] = webscraper.get_description (soup)
		return (d)
				
print (webscraper.get_info_dict ("pablo picasso"))

