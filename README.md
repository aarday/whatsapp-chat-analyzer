# WhatsApp Chat Analyzer (Shiny App)

This project is a Shiny web application designed to analyze WhatsApp chat history exported as `.txt` files. It allows users to explore message patterns, user activity, and other chat-related statistics through interactive visualizations and summaries.

## 🔧 Features (Planned & In Progress)

- 📁 Upload `.txt` files exported from WhatsApp
- 📊 Message frequency over time
- 🧑‍🤝‍🧑 User-level activity stats
- 🧠 Most common words
- 🌐 Word cloud generation
- 😂 Emoji usage analysis
- 📆 Time-based heatmaps

## 📂 Exporting WhatsApp Chat Files

To use this app, export your WhatsApp chat via the app as follows:

- **WhatsApp > Chat > Export Chat**  
- Choose **"Without Media"**
- Send the file to your computer and upload the `.txt` file in the app

> ⚠️ Only `.txt` files in the default WhatsApp export format are supported.

## 🚀 Getting Started (Local Development)

You can run the app locally in RStudio:

```r
library(shiny)
runGitHub("aarday/whatsapp-chat-analyzer")
```

Make sure you have the required R packages installed. A DESCRIPTION or renv.lock file will be added in future versions to help manage dependencies.

🔒 Privacy Notice
This app processes your WhatsApp chat data only during your session. No data is stored, saved, or sent to any external server. All analysis happens in a temporary runtime environment.

Use the app only with chat files you are authorized to analyze.

📄 License
This project is licensed under the MIT License.


