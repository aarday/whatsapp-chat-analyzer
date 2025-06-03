# 📊 WhatsApp Chat Analyzer (Shiny App)

This project is a **Shiny web application** designed to analyze WhatsApp group chat history exported as `.txt` files. It enables users to explore message patterns, user activity, and other chat-related statistics through **interactive visualizations** and **summaries**. The app supports both **English** and **Turkish** interfaces.

---

## 🔧 Features (In Progress & Implemented)

- 📁 Upload `.txt` files exported from WhatsApp  
- 🌐 **Multilingual interface**: English EN and Turkish TR  
- 📊 Message frequency over time (daily timeline with peak detection)  
- 🧑‍🤝‍🧑 User-level activity stats (top senders, word usage, hourly activity)  
- 🧠 Most common words (with stopword filtering)  
- 🌥️ Word cloud generation (planned)  
- 😂 Emoji usage analysis (planned)  
- 📆 Time-based heatmaps (planned)  
- ✍️ Most used word per user  
- 🧍 Name mentions detection in messages  
- 🔍 Keyword & user filtering for focused analysis  
- 📈 Filtered results update visualizations accordingly  

---

## 📂 Exporting WhatsApp Chat Files

To use this app, export your WhatsApp chat via the mobile app as follows:

1. **WhatsApp > Chat > Export Chat**  
2. Choose **“Without Media”**  
3. Send the file to your computer  
4. Upload the exported `.txt` file into the app  

⚠️ Only `.txt` files in the default WhatsApp export format are supported.  
📌 **Maximum supported file size is 30MB**.

---

## 🚀 Getting Started (Local Development)

You can run the app locally using RStudio:

```r
library(shiny)
runGitHub("aarday/whatsapp-chat-analyzer")
```
Alternatively, you can also run the app online without installing anything using [shinyapps.io](https://aarday.shinyapps.io/whatsapp-chat-analyzer/).

---
```r
library(shiny)
library(tidyverse)
library(tidytext)
library(lubridate)
library(stringr)
```
## 🔒 Privacy Notice
This app processes your WhatsApp chat data only during your session.
No data is stored, saved, or sent to any external server. All analysis happens locally in a temporary runtime environment.

## 👉 Use the app only with chat files you are authorized to analyze.

## 🙏 Acknowledgements
This project was developed with assistance from ChatGPT by OpenAI, which supported both R programming and feature design during development.

## 📄 License
This project is licensed under the MIT License.
