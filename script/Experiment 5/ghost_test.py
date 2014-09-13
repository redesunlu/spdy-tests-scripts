import ghost
import sqlite3

from BeautifulSoup import BeautifulSoup as bs
from os.path import exists


def connect_db():
    db = './results.sqlite'

    new_db = False
    if not exists(db):
        new_db = True
    conn = sqlite3.connect(db)
    c = conn.cursor()

    if new_db:
        sql = '''CREATE TABLE t_results_spdy_check(
                        country         text,
                        topk            text,
                        url             integer,
                        spdy            text);'''
        c.execute(sql)
        conn.commit()

    return conn, c


def save_data(c, conn, country, topk, url, spdy):
    sql = """INSERT INTO t_results_spdy_check
             VALUES ('{0}', '{1}', '{2}', '{3}');""".format(country, topk,
                                                            url, spdy)
    c.execute(sql)
    conn.commit()


def test_site(site):
    g = ghost.Ghost(wait_timeout=20, display=False)
    g.open("http://spdycheck.org/#{}".format(site))
    g.sleep(15)
    soup = bs(g.content)
    del g
    html_result = soup('div', {'id': 'banner'})[0]
    result = html_result.find('h2').text

    if '{} Does Not Support SPDY'.format(site) in result:
        return False
    elif '{} Supports SPDY'.format(site) in result:
        return True
    else:
        return None

conn, c = connect_db()

with open('list.txt') as list_file:
    lines = list_file.readlines()

    for line in lines:
        row = line[:-1].split(';')
        country_code = row[0]
        topk = row[1]
        url = row[2]
        print 'Checking: {} {} {}'.format(country_code, topk, url)
        result = test_site(url)
        if result is not None:
            if result:
                spdy = 'OK'
            else:
                spdy = 'Fail'
        else:
            spdy = 'Error'

        save_data(c, conn, country_code, topk, url, spdy)

