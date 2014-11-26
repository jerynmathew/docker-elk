import requests
from datetime import date, timedelta
import logging

log = logging.getLogger("Console")
log.setLevel(logging.DEBUG)
console = logging.StreamHandler()
console.setLevel(logging.DEBUG)
log.addHandler(console)


class Index(object):
    INDEX_NAME_PATTERN = "logstash-{}"
    name = None

    def __init__(self, date=None):
        self.name = self.INDEX_NAME_PATTERN.format(date.isoformat().replace("-", "."))
        self._date = date
        self._exists = None
        self._url = None
        self._deleted = False
        # log.debug("Index Name: {}".format(self.name))

    def exists(self):
        self._url = "http://88.198.37.199:9200/{}?pretty".format(self.name)

        try:
            resp = requests.head(self._url)

            self._exists = resp.ok
        except:
            log.exception("Exception while checking if Index exists. INDEX: {}".format(self.name))
            self._exists = False

        return self._exists

    def delete(self):
        if self._exists is None:
            self.exists()

        if self._exists and self._url:
            try:
                resp = requests.delete(self._url)
                if resp.ok and resp.json() and resp.json().get('acknowledged') is True:
                    log.info("Index: [{}]  -> Resp: {}".format(self.name, resp.json()))
                    self._deleted = True

                else:
                    log.error("Error while deleting. Index:{}, Code: {}, Msg: {}".format(self.name, resp.status_code, resp.content))

            except:
                log.exception("Exception while deleting Index. Index: {}".format(self.name))

        return self._deleted



def main():
    start = date(2014, 9, 30)
    end = date(2014, 10, 30)

    days = 0
    found = 0
    while start != end:
        index = Index(start)

        if index.exists():
            found += 1
            index.delete()
        days += 1

        start = start + timedelta(days=1)

    log.info("Started On {}".format(date(2013, 10, 01).isoformat()))
    log.info("Found {} Indices, in {} days".format(found, days))
    log.info("Ended On {}".format(end.isoformat()))


if __name__ == '__main__':
    main()
