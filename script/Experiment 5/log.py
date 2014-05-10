#!/usr/bin/python

import sqlite3

from os.path import exists, join
from sys import argv

RESULTS_DIR = './results'
HAR_DIR = RESULTS_DIR + '/har'
PCAP_DIR = RESULTS_DIR + '/cap'

db = './results.db'

new_db = False
if not exists(db):
    new_db = True
conn = sqlite3.connect(db)
c = conn.cursor()

if new_db:
    sql = '''CREATE TABLE t_results_exp3(
                    site            text,
                    method          text,
                    run             integer,
                    file            text,
                    start           text,
                    finish          text,
                    ipadress        text,
                    rtt             float,
                    tow             float,
                    onContentLoad   float,
                    onLoad          float);'''
    c.execute(sql)
    conn.commit()

if '--log' in argv:
    site = argv[2]
    method = argv[3]
    run = argv[4]
    file = argv[5]
    start = argv[6].replace('-', ' ')
    finish = argv[7].replace('-', ' ')
    ipadress = argv[8]
    rtt = argv[9]
    sql = """INSERT INTO t_results_exp3
             VALUES ('{0}', '{1}', '{2}', '{3}', '{4}', '{5}', '{6}',
                     {7}, null, null, null);""".format(site, method,
                                                       run, file,
                                                       start, finish,
                                                       ipadress, rtt)
    c.execute(sql)
    conn.commit()
elif '--parse' in argv:
    from os import system, remove
    from json import load
    from tow import calc_tow

    sql = """SELECT file
             FROM t_results_exp3
             WHERE  tow is null
             AND    onContentLoad is null
             AND    onLoad is null"""
    c.execute(sql)
    files = c.fetchall()
    for file in files:
        json_data = open(join(HAR_DIR, file[0] + '.har'))
        data = load(json_data)
        json_data.close()
        oncontentload = data['log']['pages'][0]['pageTimings']['onContentLoad']
        onload = data['log']['pages'][0]['pageTimings']['onLoad']
        system('tshark -F libpcap -w {0}.pcap -r {0}.cap'.format(join(PCAP_DIR, file[0])))
        tow = calc_tow(join(PCAP_DIR, file[0] + '.pcap')) * 1000
        remove('{0}.pcap'.format(join(PCAP_DIR, file[0])))

        sql = '''UPDATE t_results_exp3
                 SET tow = {0},
                     onContentLoad = {1},
                     onLoad = {2}
                 WHERE file = '{3}';'''.format(tow, oncontentload, onload,
                                               file[0])
        c.execute(sql)
    conn.commit()
else:
    print("Error. Bad Arguments")

conn.close()
