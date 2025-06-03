library(shiny)
library(tidyverse)
library(tidytext)
library(lubridate)
library(stringr)

options(shiny.maxRequestSize = 30 * 1024^2)  # 30 MB

ui <- fluidPage(
  titlePanel("WhatsApp Chat Analyzer"),
  
  sidebarLayout(
    sidebarPanel(
      fileInput("file1", "Please upload your WhatsApp chat file in .txt format:", accept = c(".txt")),
      textInput("keyword", "Keyword to search in messages:", placeholder = "e.g., love, hello"),
      selectInput("lang", "Stopword Language:", choices = c("Turkish", "English", "Both"), selected = "Both"),
      uiOutput("userSelectUI")
    ),
    
    mainPanel(
      tabsetPanel(id = "mainTabs",
                  
                  tabPanel("General",
                           tabsetPanel(
                             tabPanel("Word Frequency", plotOutput("wordFreqPlot")),
                             tabPanel("Top Message Senders", tableOutput("topUsersTable")),
                             tabPanel("Messages Over Time", plotOutput("messagesOverTimePlot")),
                             tabPanel("Message Length Analysis",
                                      verbatimTextOutput("avgMsgLength"),
                                      plotOutput("msgLengthHist")),
                             tabPanel("Activity by Hour", plotOutput("activeHoursPlot")),
                             tabPanel("Top Words by User", tableOutput("topWordsByUser")),
                             tabPanel("Name Mention Analysis", tableOutput("nameMentionTable"))
                           )
                  ),
                  
                  tabPanel("Filtered",
                           tabsetPanel(
                             tabPanel("Messages",
                                      h4("Message filter by keyword and user"),
                                      tableOutput("filteredMessages")
                             ),
                             tabPanel("Word Frequency",
                                      h4("Word Frequency (Selected User)"),
                                      plotOutput("filteredWordFreq")
                             ),
                             tabPanel("Messages Over Time",
                                      h4("Messages Over Time (User and/or Keyword)"),
                                      plotOutput("filteredTimeSeries")
                             )
                           )
                  )
                  
      )
    )
  )
)

server <- function(input, output, session) {
  
  stop_words_tr <- c("ve", "veya", "ile", "de", "da", "ki", "bu", "şu", "o", "bir", "çok", "az",
                     "daha", "en", "ne", "mi", "mı", "mu", "mü", "gibi", "için", "ama", "fakat",
                     "çünkü", "ancak", "ya", "hem", "ben", "sen", "biz", "siz", "onlar", "kendi",
                     "her", "hiç", "herkes", "kimse", "neden", "nasıl", "nereye", "nerede",
                     "ne zaman", "zaten", "hep", "şey", "şimdi", "bile", "ise", "yani", "lakin",
                     "üzere", "madem", "hala", "sanki", "yine", "artık", "biraz", "bazı",
                     "tüm", "herhangi", "tam", "hemen", "o kadar", "çok fazla", "keşke", "diye", "bi",
                     "değil","bunu","var","yok")
  
  stop_words_en <- stop_words %>% filter(lexicon == "snowball") %>% pull(word)
  
  stop_words_combined <- reactive({
    lang <- input$lang
    words <- character()
    if (lang %in% c("Turkish", "Both")) words <- c(words, stop_words_tr)
    if (lang %in% c("English", "Both")) words <- c(words, stop_words_en)
    tibble(word = unique(words))
  })
  
  chat_df <- reactive({
    req(input$file1)
    lines <- readLines(input$file1$datapath, encoding = "UTF-8")
    message_lines <- lines[grepl("^\\d{2}\\.\\d{2}\\.\\d{4} \\d{2}:\\d{2} - .*?:", lines)]
    
    df <- tibble(raw = message_lines) %>%
      mutate(
        date = str_extract(raw, "^\\d{2}\\.\\d{2}\\.\\d{4}"),
        time = str_extract(raw, "\\d{2}:\\d{2}"),
        datetime = as.POSIXct(paste(date, time), format = "%d.%m.%Y %H:%M"),
        user = str_match(raw, "- (.*?):")[,2],
        message = str_replace(raw, ".*?: ", "")
      ) %>%
      select(datetime, user, message) %>%
      filter(
        !str_detect(message, regex("gruba katıldı|gruptan ayrıldı|medya dahil edilmedi|bu mesaj silindi|mesaj iletilmedi|gönderilmedi", ignore_case = TRUE)),
        !is.na(user)
      )
    
    df
  })
  
  output$userSelectUI <- renderUI({
    df <- chat_df()
    users <- sort(unique(df$user))
    selectInput("selectedUser", "Select User:", choices = c("All", users))
  })
  
  output$wordFreqPlot <- renderPlot({
    df <- chat_df()
    words <- df %>% unnest_tokens(word, message)
    
    clean_words <- words %>% anti_join(stop_words_combined(), by = "word")
    word_freq <- clean_words %>% count(word, sort = TRUE) %>% slice_max(n, n = 20)
    
    ggplot(word_freq, aes(x = reorder(word, n), y = n)) +
      geom_col(fill = "steelblue") +
      coord_flip() +
      labs(title = "Top Frequent Words (Stop Words Removed)", x = "Word", y = "Frequency") +
      theme_minimal()
  })
  
  output$topUsersTable <- renderTable({
    chat_df() %>%
      count(user, sort = TRUE) %>%
      head(20)
  })
  
  output$messagesOverTimePlot <- renderPlot({
    df <- chat_df()
    daily_counts <- df %>%
      mutate(date = as.Date(datetime)) %>%
      count(date)
    
    top_days <- daily_counts %>% arrange(desc(n)) %>% slice_head(n = 3)
    
    ggplot(daily_counts, aes(x = date, y = n)) +
      geom_line(color = "darkgreen") +
      geom_point(data = top_days, aes(x = date, y = n), color = "red", size = 3) +
      geom_text(data = top_days, aes(label = format(date, "%d.%m")), vjust = -1, color = "red", size = 3.5) +
      labs(title = "Daily Message Count (Top 3 Days)", x = "Date", y = "Message Count") +
      theme_minimal()
  })
  
  output$avgMsgLength <- renderText({
    avg_length <- chat_df() %>%
      mutate(word_count = str_count(message, "\\S+")) %>%
      summarise(avg = mean(word_count)) %>%
      pull(avg)
    
    paste0("Average message length (word count): ", round(avg_length, 2))
  })
  
  output$msgLengthHist <- renderPlot({
    lengths <- chat_df() %>%
      mutate(word_count = str_count(message, "\\S+")) %>%
      pull(word_count)
    
    ggplot(tibble(lengths = lengths), aes(x = lengths)) +
      geom_histogram(binwidth = 1, fill = "coral", color = "black") +
      labs(title = "Message Length Distribution", x = "Word Count", y = "Number of Messages") +
      theme_minimal()
  })
  
  output$activeHoursPlot <- renderPlot({
    hourly_counts <- chat_df() %>%
      mutate(hour = hour(datetime)) %>%
      count(hour)
    
    ggplot(hourly_counts, aes(x = hour, y = n)) +
      geom_col(fill = "darkorange") +
      scale_x_continuous(breaks = 0:23) +
      labs(title = "Activity by Hour", x = "Hour", y = "Message Count") +
      theme_minimal()
  })
  
  output$topWordsByUser <- renderTable({
    df <- chat_df() %>%
      unnest_tokens(word, message) %>%
      anti_join(stop_words_combined(), by = "word") %>%
      count(user, word, sort = TRUE) %>%
      group_by(user) %>%
      slice_max(n, n = 1, with_ties = FALSE) %>%
      ungroup() %>%
      arrange(desc(n)) %>%
      select(User = user, `Most Used Word` = word, Frequency = n)
  })
  
  output$nameMentionTable <- renderTable({
    df <- chat_df()
    users_firstnames <- tolower(sapply(strsplit(unique(df$user), " "), `[`, 1))
    
    df %>%
      mutate(
        message_words = str_extract_all(tolower(message), "\\b\\w+\\b"),
        user_firstname = tolower(sapply(strsplit(user, " "), `[`, 1))
      ) %>%
      rowwise() %>%
      mutate(
        mentioned_names = list(intersect(message_words, users_firstnames))
      ) %>%
      unnest(mentioned_names) %>%
      filter(mentioned_names != user_firstname) %>%
      ungroup() %>%
      count(Mentioner = user, Mentioned = mentioned_names, sort = TRUE) %>%
      group_by(Mentioner) %>%
      slice_max(n, n = 3, with_ties = FALSE) %>%
      ungroup()
  })
  
  output$filteredMessages <- renderTable({
    df <- chat_df()
    
    if (input$selectedUser != "All") {
      df <- df %>% filter(user == input$selectedUser)
    }
    
    if (input$keyword != "") {
      df <- df %>% filter(str_detect(message, fixed(input$keyword, ignore_case = TRUE)))
    }
    
    df %>%
      mutate(Date = format(datetime, "%d.%m.%Y %H:%M")) %>%
      select(Date, User = user, Message = message) %>%
      head(100)
  })
  
  output$filteredWordFreq <- renderPlot({
    df <- chat_df()
    
    if (input$selectedUser != "All") {
      df <- df %>% filter(user == input$selectedUser)
    }
    
    if (input$keyword != "") {
      df <- df %>% filter(str_detect(message, fixed(input$keyword, ignore_case = TRUE)))
    }
    
    words <- df %>% unnest_tokens(word, message)
    clean_words <- words %>% anti_join(stop_words_combined(), by = "word")
    word_freq <- clean_words %>% count(word, sort = TRUE) %>% slice_max(n, n = 20)
    
    ggplot(word_freq, aes(x = reorder(word, n), y = n)) +
      geom_col(fill = "purple") +
      coord_flip() +
      labs(title = "Filtered Word Frequency", x = "Word", y = "Frequency") +
      theme_minimal()
  })
  
  output$filteredTimeSeries <- renderPlot({
    df <- chat_df()
    
    if (input$selectedUser != "All") {
      df <- df %>% filter(user == input$selectedUser)
    }
    
    if (input$keyword != "") {
      df <- df %>% filter(str_detect(message, fixed(input$keyword, ignore_case = TRUE)))
    }
    
    daily_counts <- df %>%
      mutate(date = as.Date(datetime)) %>%
      count(date)
    
    ggplot(daily_counts, aes(x = date, y = n)) +
      geom_line(color = "blue") +
      labs(title = "Filtered Messages Over Time", x = "Date", y = "Message Count") +
      theme_minimal()
  })
}

shinyApp(ui = ui, server = server)
