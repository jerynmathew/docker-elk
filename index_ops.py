import arrow
import click
import requests
from datetime import date, timedelta
import logging
from humanize import intword, naturalsize

log = logging.getLogger("Console")
log.setLevel(logging.DEBUG)
console = logging.StreamHandler()
console.setLevel(logging.DEBUG)
log.addHandler(console)


ES_INDEX_URL = "http://88.198.37.199:9200/{}?pretty"
ES_INDEX_STATS_URL = "http://88.198.37.199:9200/{}/_stats"
INDEX_NAME_PATTERN = "logstash-{}"


class Index(object):
    name = None

    def __init__(self, date=None):
        self.name = INDEX_NAME_PATTERN.format(date.isoformat().replace("-", "."))
        self._date = date
        self._exists = None
        self._url = None
        self._deleted = False
        self._stats = None
        # log.debug("Index Name: {}".format(self.name))

    def exists(self):
        self._url = ES_INDEX_URL.format(self.name)

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
                    log.info("Deleting Index: [{}]  -> Resp: {}".format(self.name, resp.json()))
                    self._deleted = True

                else:
                    log.error("Error while deleting. Index:{}, Code: {}, Msg: {}".format(self.name, resp.status_code, resp.content))

            except:
                log.exception("Exception while deleting Index. Index: {}".format(self.name))

        return self._deleted

    def show_stats(self):
        url = ES_INDEX_STATS_URL.format(self.name)

        if self._exists is None:
            self.exists()

        if self._exists:
            try:
                resp = requests.get(url)
                if resp.ok and resp.json():
                    self._stats = {
                        'index': self.name,
                        'docs_count': resp.json().get('indices').get(self.name).get('total').get('docs').get('count'),
                        'docs_size': resp.json().get('indices').get(self.name).get('total').get('store').get('size_in_bytes')
                    }
                    log.info("Index Stats: [{}]. Docs: {}, Size: {}".format(self.name, intword(self._stats['docs_count']), 
                                                                      naturalsize(self._stats['docs_size'])))

                else:
                    log.error("Error while fetching stats. Index:{}, Code: {}, Msg: {}".format(self.name, resp.status_code, resp.content))
            except:
                log.exception("Exception while fetching stats. Index: {}".format(self.name))

        return self._stats


@click.group()
def cli():
    pass

@cli.command()
@click.argument("start")
@click.argument("end")
def stats(start, end):
    try:
        start_date = arrow.get(start, "YYYY-MM-DD")
        end_date = arrow.get(end, "YYYY-MM-DD")
        cur_date = start_date

        days = 0
        found = 0
        total_docs = 0
        total_size = 0
        while cur_date.date() != end_date.date():
            index = Index(cur_date.date())

            if index.exists():
                found += 1
                result = index.show_stats()
                total_docs += result['docs_count']
                total_size += result['docs_size']

            days += 1
            cur_date = cur_date.replace(days=+1)

        click.echo("Details regarding Indices from [{}] -> [{}]".format(start_date.format("MMM DD, YYYY"), end_date.format("MMM DD, YYYY")))
        click.echo("Found {} Indices, in {} days".format(found, days))
        click.echo("Total Docs Found: {}".format(intword(total_docs)))
        click.echo("Total Size estimated: {}".format(naturalsize(total_size)))

    except arrow.parser.ParserError:
        log.error("Exception while parsing Start/End dates")
        click.echo("Start/End dates in Incorrect format! Please enter Dates in ISO-Format: YYYY-MM-DD")


@cli.command()
@click.argument("start")
@click.argument("end")
def delete(start, end):
    try:
        start_date = arrow.get(start, "YYYY-MM-DD")
        end_date = arrow.get(end, "YYYY-MM-DD")
        cur_date = start_date

        days = 0
        found = 0
        total_docs = 0
        total_size = 0
        while cur_date.date() != end_date.date():
            index = Index(cur_date.date())

            if index.exists():
                found += 1
                result = index.show_stats()
                total_docs += result['docs_count']
                total_size += result['docs_size']
                
                index.delete()

            days += 1
            cur_date = cur_date.replace(days=+1)

        click.echo("Details regarding Indices from [{}] -> [{}]".format(start_date.format("MMM DD, YYYY"), end_date.format("MMM DD, YYYY")))
        click.echo("Found {} Indices, in {} days".format(found, days))
        click.echo("Total Docs deleted: {}".format(intword(total_docs)))
        click.echo("Total Size freed: {}".format(naturalsize(total_size)))

    except arrow.parser.ParserError:
        log.error("Exception while parsing Start/End dates")
        click.echo("Start/End dates in Incorrect format! Please enter Dates in ISO-Format: YYYY-MM-DD")


if __name__ == '__main__':
    cli()
