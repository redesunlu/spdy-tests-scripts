# -*- coding: utf-8 -*-

# This script generate a csv table from a har capture passed by parameter.
# Usage:
#       python resources_table.py har_file csv_file
# Table row format:
#       ----------------------------
#       | Name | Type | Size | URL |
#       ----------------------------

from json import load
from sys import argv


json_filename = argv[1]
output_filename = argv[2]

json_file = open(json_filename)
json_data = load(json_file)

resources = []
total_size = 0
n_resources = 0
for entry in json_data['log']['entries']:
    url = entry['request']['url']
    # Getting a last part of resource URL as name
    name = url.split('/')[-1]
    # Filtering parameters in resource name
    name = name.split('?')[0]
    if name == '':
        name = '-'
    size = entry['response']['content']['size']
    mimetype = entry['response']['content']['mimeType']
    type = mimetype.split('/')[1]
    resources.append((name, type, size, url))
    n_resources += 1
    total_size += size

theader = """Number of Resources;{0}
Total Size (Bytes);{1}\n
Detail
Name;Type;Size (Bytes);URL\n""".format(n_resources, total_size)
table = ""
for (name, type, size, url) in resources:
    table += "{0};{1};{2};{3}\n".format(name, type, size, url)

csv = open(output_filename, 'w')
csv.write(theader + table)
csv.close()
