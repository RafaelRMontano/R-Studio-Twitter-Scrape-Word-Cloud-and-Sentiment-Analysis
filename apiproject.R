library(twitteR)
library("openssl")
library("httpuv")
library(tidyverse)
library(tidytext)
library(widyr)
library(wordcloud)

library(ROAuth)
library(plyr)
library(tm)
library(tibble)
library(stringr)


api_key <- 'cFUyQlVt96xGsSqKL9GYI8KZY'
api_secret <- 'xffQ2I9bbXlPbcfZ5LKrUwr6tLGZLqfz17S1XYwRv2WPexlvuT'

access_token <- '2290595287-Q9qzeAx7WJwqhcppFhemvbFYXZOtAS1nmxPeJti'
access_token_secret <- 'TWjtHGgfF3d1Qzi874o3jz24Vx5WMx9YCfHfskmksGCsG'


setup_twitter_oauth(api_key,api_secret,access_token,access_token_secret)
#auth_setup_default()


install.packages("textdata")
library("textdata")

get_sentiments("afinn")
get_sentiments("bing")
get_sentiments("nrc")


#grab tweets
tweets_tjm = searchTwitter('from:tjmaxx', n = 50)
tweets_tjm1 = searchTwitter('@tjmaxx', n = 200)
tweets_tjm2 = searchTwitter('bestbuy', n = 500, lang = "en")
#tweets_tjm3 = search_tweets("bestbuy", n = 2000, lang = "en", full_text = TRUE)

2#transform into data frame
tweets.df <- twListToDF(tweets_tjm)
tweets.df2 <- twListToDF(tweets_tjm1)
tweets.df3 <- twListToDF(tweets_tjm2)

#only tweets column
tweets_tjm = tweets_tjm[,1]
tweets_tjm1 = tweets_tjm1[,1]
tweets_tjm2 = tweets_tjm2[,1]

#also only tweets column data drame
#tweets1 <- tweets.df3[,1, drop = FALSE]


#name and tweet colum
tweet1 <- tweets.df3 %>% select(screenName,text)


# clean up
#names(tweets_tjm3)
#look_user <- lookup_users(tweets_tjm3$user_id)





#url
url_regex <- "http[s]?://(?:[a-zA-Z]|[0-9]|[$-_@.&+]|[!*\\(\\),]|(?:%[0-9a-fA-F][0-9a-fA-F]))+"
tweet1 <- tweet1 %>%
  mutate(text = str_remove_all(text, regex(str_c("\\b","[[:punct:]]", "\\b", collapse = '|'), ignore_case = T)))

#tweet1[] <- lapply(tweet1, function(x)(gsub("@\\S+","" , x)))
#tweet1[] <- lapply(tweet1, function(x)(gsub("[[:punct:]]","" , x)))
tweet1[] <- lapply(tweet1, function(x)(gsub("http\\S+\\s*","" , x))) #url
tweet1[] <- lapply(tweet1, gsub, pattern = "*:", replacement ="") #colon for @ removal
tweet1[] <- lapply(tweet1, function(x)(gsub("@[[:alnum:]]*","" , x))) #remove all @words

#remove entire hastag or just hastag
tweet1[] <- lapply(tweet1, function(x)(gsub("#[[:alnum:]]*","" , x))) 
tweet1[] <- lapply(tweet1, function(x)(gsub("#","" , x)))


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
  filter(users_n > 10)
  



#word corrrelation
word_correlation <- review_words %>%
  semi_join(users_who_mention, by = "word") %>%
  pairwise_cor(item = word, feature = screenName) %>%
  filter(correlation > 0.6)




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
  



#function
generate_word_graph <- function(review_words, minimum_users_n = 10,minimum_correlation = 0.2 ){
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

review_words %>%
  generate_word_graph(minimum_users_n = 20, minimum_correlation = 0.6)

#wordcloud
library(RColorBrewer)
review_words %>%
  dplyr::count(word, sort = TRUE) %>%
  with(wordcloud(word,n, scale = c(4,1), min.freq = 2, max.words = 50,colors=brewer.pal(8, "Dark2")))

  

library("reshape2")
  review_words %>%
  inner_join(get_sentiments("afinn")) %>%
  inner_join(get_sentiments("bing")) %>%
  inner_join(get_sentiments("nrc")) %>%
  dplyr::count(word, sentiment, sort = TRUE) %>%
  acast(word ~ sentiment, value.var = 'n', fill = 0) %>%
  comparison.cloud( scale = c(4,1), colors = c("red", "blue"),max.words = 100)


  
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
