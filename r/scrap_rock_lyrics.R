setwd("D:/Google Drive/portfolio/r")


install.packages('rvest')
library(rvest)
library(RCurl)

website <- "http://www.rock.com.ar"

letters.url <- paste("http://www.rock.com.ar/bios/pornombre/", LETTERS, ".shtml", sep  = "")


checkStatuslinks <- function(urls) {
  
  idx <- unlist(lapply(urls, url.exists))
  urls[idx]
}

letters.url <- checkStatuslinks(letters.url)

getArtistsUrls <- function(url) { 
  
  url.parsed <- read_html(url)
  artists.urls <- url.parsed %>% 
    html_nodes(".clearfix a") %>%
    html_attr("href")
  artists.urls <- paste(website, artists.urls, sep = "")
  
  idx <- grepl("artistas", artists.urls)
  main.artists.urls <- artists.urls[idx]
  main.artists.urls
}

ll <- lapply(letters.url, getArtistsUrls)
artists.urls <- do.call(c, ll)
artists.urls <- checkStatuslinks(artists.urls)

getAlbumsUrls <- function(url) { 
  
  url.parsed <- read_html(url)
  albums.urls <- url.parsed %>% 
    html_nodes("#contenedor a") %>%
    html_attr("href")
  
  unique(albums.urls[grepl("/discos", albums.urls)])
}

ll2 <- lapply(artists.urls, getAlbumsUrls)
albums.urls <- do.call(c, ll2)
albums.urls <- gsub("http://www.rock.com.ar", "", albums.urls)
albums.urls <- paste("http://www.rock.com.ar", albums.urls, sep = "")
albums.urls <- checkStatuslinks(albums.urls)

#Ahora tengo todos los links en albums.urls

getLyrics <- function(url) {
  
  
    url.parsed <- read_html(url)
    
    lyrics <- url.parsed %>% 
      html_nodes("p") %>%
      html_text() 
    
    lyrics
 
}

getAlbumInfo <- function(url) {
  
  if(url.exists(url)) { 
    url.parsed <- read_html(url)
    
    artist.name <- url.parsed %>% 
      html_nodes("a+ a") %>%
      html_text() %>%
      iconv(to = "latin1")
    
    year <- url.parsed %>% 
      html_nodes(".anio") %>%
      html_text()
      
    album.name <- url.parsed %>% 
      html_nodes(".subtitle") %>%
      html_text() 
      
    songs.names <- url.parsed %>% 
      html_nodes(".nombre-letra") %>%
      html_text() 
    
    songs.urls <- url.parsed %>% 
      html_nodes(".nombre-letra") %>%
      html_attr("href") 
    
    songs.urls <- paste(website, songs.urls, sep = "")
    
    df <- data.frame(artist = artist.name, album = album.name,
                     year = year, song.name = songs.names, 
                     lyric.url = songs.urls, stringsAsFactors = FALSE)
    
    df
  }
}


all.dfs <- lapply(albums.urls, getAlbumInfo)

df <- lapply(all.dfs, as.data.frame)


####################################
