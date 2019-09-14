from bs4 import BeautifulSoup
import datetime
import urllib3
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)


from spellchecker import SpellChecker



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

	def get_birth_place (soup):
		birth = soup.find_all (itemprop="birthPlace")[0].text
		return (birth)

	def spell_correct (artist):
		spell = SpellChecker()
		first_last = artist.split (" ")
		for ind in range (0, len(first_last)):
			first_last [ind] = spell.correction (first_last [ind])
		a = ""
		for name in first_last:
			a+= name + " "
		return (a.strip())


	@staticmethod
	def get_info_dict (artist):
		artist = webscraper.spell_correct (artist)
		d = dict()
		soup = webscraper.soup_from_artist (artist)
		numimgs = 5
		d['birth_place'] = webscraper.get_birth_place (soup)
		d["titles"] = webscraper.get_titles (soup, numimgs)
		d["srcs"] = webscraper.get_srcs(soup, numimgs)
		d["description"] = webscraper.get_description (soup)
		if d["titles"] == []:
			d["artist_found"] = False
		else:
			d["artist_found"] = True
		return d

				
print (webscraper.get_info_dict ("pablo picass"))

