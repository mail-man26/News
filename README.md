# My News App
This Application is a simple implementation of a real time news app using newsapi

# Flutter News App

A Flutter app that displays news articles from various categories and allows users to bookmark their favorite articles.


## Introduction

This Flutter app fetches news articles using the [NewsAPI](https://newsapi.org/) service. It provides a user-friendly interface to read news articles, search for articles, view detailed content in a WebView, and bookmark favorite articles for later reading.

## Setup

### NewsAPI Key

1. Sign up on the [NewsAPI website](https://newsapi.org/) to obtain an API key.
2. Replace `"YOUR_API_KEY"` in the `lib/news_page.dart` file with your actual NewsAPI key.

### Dependencies

This app uses the following Flutter packages:

- [news_api_flutter_package](https://pub.dev/packages/news_api_flutter_package): A Flutter package to interact with the NewsAPI service.
- [shared_preferences](https://pub.dev/packages/shared_preferences): For storing bookmarked articles.
- [webview_flutter](https://pub.dev/packages/webview_flutter): For displaying article content in a WebView.
- [flutter_launcher_icons](https://pub.dev/packages/flutter_launcher_icons): For generating launcher icons.

To install the dependencies, run:

```bash
flutter pub get

CLONE this app
Then in terminal run,

flutter pub get
flutter run
