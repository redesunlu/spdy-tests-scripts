# -*- coding: utf-8 -*-

"""
    Alexa TOP-K scrapper
"""

import re
import urllib2
from BeautifulSoup import BeautifulSoup


TOPK = 500
SITES_PER_PAGE = 25


COUNTRIES = [('Argentina', 'AR'),
             ('Bolivia', 'BO'),
             ('Brasil', 'BR'),
             ('Chile', 'CL'),
             ('Uruguay', 'UY'),
             ('Paraguay', 'PY')]

#COUNTRIES = [('USA', 'US'),
#             ('Japon', 'JP')]

URL_COUNTRY = "http://www.alexa.com/topsites/countries;{0}/{1}"


pages = [i for i in range(TOPK / SITES_PER_PAGE)]
re_counter = re.compile('<div class="count">(\d+)</div>')
re_url = re.compile('<a href="/siteinfo/(.+)">')

with open('list.txt', 'w') as file:
    for country, code in COUNTRIES:
        print "Processing {}".format(country)
        for page in pages:
            soup = BeautifulSoup(urllib2.urlopen(
                URL_COUNTRY.format(page, code)).read())

            for element in soup('li', {'class': 'site-listing'}):
                counter = re_counter.findall(str(element))[0]
                url = re_url.findall(str(element))[0]
                print "{} - {} - {} -".format(country, counter, url)
                file.write("{};{};{};\n".format(code, counter, url))
                file.flush()
