
library(twitteR)
library(tidyverse)
library(tidytext)
library(widyr) #correlation
library(wordcloud)

# Other useful libraries to look at
#library("openssl")
#library("httpuv")
#library(ROAuth)
#library(plyr)
#library(tm)
#library(tibble)
#library(stringr)


api_key <- 'x'
api_secret <- 'x'

access_token <- 'x'
access_token_secret <- 'x'

#auth_setup
setup_twitter_oauth(api_key,api_secret,access_token,access_token_secret)




#grab tweets
tweets1 = searchTwitter('from:Walmart', n = 200)
tweets2 = searchTwitter('@Walmart', n = 200)
tweets3 = searchTwitter('Walmart', n = 5000, lang = "en") 

#tweets4 = search_tweets("Walmart", n = 2000, lang = "en", full_text = TRUE)

#transform into data frame
tweets.df1 <- twListToDF(tweets1) 
tweets.df2 <- twListToDF(tweets2) 
tweets.df3 <- twListToDF(tweets3) 

#only tweets text column
#tweets1 = tweets.df1[,1]
#tweets2 = tweets.df2[,1]
#tweets3 = tweets.df3[,1]


#name and tweet column
tweet1 <- tweets.df3 %>% select(screenName,text)  %>% distinct(text, .keep_all = TRUE)


# clean tweet
tweet1[] <- lapply(tweet1, function(x)(gsub("http\\S+\\s*","" , x))) #url
tweet1[] <- lapply(tweet1, gsub, pattern = "*:", replacement ="") #colon for @ removal
tweet1[] <- lapply(tweet1, function(x)(gsub("@[[:alnum:]]*","" , x))) #remove all @words

#remove entire hashtag
tweet1[] <- lapply(tweet1, function(x)(gsub("#[[:alnum:]]*","" , x))) 
#remove just hashtag
tweet1[] <- lapply(tweet1, function(x)(gsub("#","" , x)))

#view tweets
tweet1[]


#Brocken down words
review_words <- tweet1 %>%
  unnest_tokens(output = word, input = text) %>%
  anti_join(stop_words, by = "word") %>%
  filter(str_detect(word, "[:alpha:]")) %>%
  filter(word != "rt") %>%
  distinct()

#words frequency
users_who_mention = review_words %>%
  dplyr::count(word, name = "users_n", sort = TRUE) %>%
  filter(users_n > 7)
  

#word correlation
word_correlation <- review_words %>%
  semi_join(users_who_mention, by = "word") %>%
  pairwise_cor(item = word, feature = screenName) %>%
  filter(correlation > 0.4)



#network plot
library(igraph)
library(ggraph)
graph_from_data_frame(d= word_correlation,
                vertices = users_who_mention %>%
                semi_join(word_correlation, by = c("word" = "item1"))) %>%
  ggraph(layout = "fr") +
  geom_edge_link() +
  geom_node_point() +
  geom_node_text(aes(color = users_n, label = name), repel = TRUE)
  



#function version
generate_word_graph <- function(review_words, minimum_users_n = 7,minimum_correlation = 0.4 ){
  users_who_mention = review_words %>%
    dplyr::count(word, name = "users_n", sort = TRUE) %>%
    filter(users_n > minimum_users_n) %>%
    filter(word != "rt") %>%
    filter(word != "https") %>%
    filter(word != "t.co") 
  
  
  word_correlation <- review_words %>%
    semi_join(users_who_mention, by = "word") %>%
    pairwise_cor(item = word, feature = screenName) %>%
    filter(correlation > minimum_correlation)
  
  graph_from_data_frame(d= word_correlation,
                        vertices = users_who_mention %>%
                          semi_join(word_correlation, by = c("word" = "item1"))) %>%
    ggraph(layout = "fr") +
    geom_edge_link() +
    geom_node_point() +
    geom_node_text(aes(color = users_n, label = name), repel = TRUE)
}

# run function
review_words %>%
  generate_word_graph(minimum_users_n = 7, minimum_correlation = 0.4)



#wordcloud
library(RColorBrewer)
review_words %>%
  dplyr::count(word, sort = TRUE) %>%
  filter(word != "walmart") %>%
  with(wordcloud(word,n, scale = c(4,1), min.freq = 7, max.words = 40,colors=brewer.pal(8, "Dark2")))

  
#sentiment wordcloud of negative and positive words
library("textdata")

get_sentiments("afinn")
get_sentiments("bing")
get_sentiments("nrc")

library("reshape2")
  review_words %>%
  inner_join(get_sentiments("afinn")) %>%
  inner_join(get_sentiments("bing")) %>%
  inner_join(get_sentiments("nrc")) %>%
  dplyr::count(word, sentiment, sort = TRUE) %>%
  acast(word ~ sentiment, value.var = 'n', fill = 0) %>%
  comparison.cloud( scale = c(4,1), colors = c("red", "blue"),max.words = 50)



#review ratio
  rev_ratio <- review_words %>%
    inner_join(get_sentiments("afinn")) %>%
    inner_join(get_sentiments("bing")) %>%
    inner_join(get_sentiments("nrc")) %>%
    dplyr::count(word, sentiment, sort = TRUE)

postive_rev <- subset(rev_ratio, sentiment == "positive")
negative_rev <- subset(rev_ratio, sentiment == "negative")

positive_score <- aggregate(n ~ sentiment, data= postive_rev, sum)
negative_score <- aggregate(n ~ sentiment, data= negative_rev, sum)
 
score_ratio <- (positive_score$n/(negative_score$n + positive_score$n))

score_ratio
