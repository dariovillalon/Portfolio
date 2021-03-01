import scrapy

class QuotesSpider(scrapy.Spider):
    name = "rock"

    def start_requests(self):
        
        letters = "0ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        urls = ["http://www.rock.com.ar/bios/pornombre/" + c + ".shtml" for c in letters]
        
        for url in urls:
            yield scrapy.Request(url=url, callback=self.parse)

    def parse(self, response):
        
        for artists in response.css("p").extract():
            yield {
                    'artist.name': artists.css(".clearfix a::text").extract(),
                    'artist.url': artists.css(".clearfix a::attr(href)").extract(),
                    }
            