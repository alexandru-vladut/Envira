class AppConfig {
  static const String appName = 'Finexa';
  static const int authTokenRefreshInterval = 60; // seconds
  static const bool emailVerificationEnabled = true;
  static const bool pinCodeEnabled = false;
  static const String geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');
  static const String barcodeLookupApiKey = String.fromEnvironment('BARCODE_LOOKUP_API_KEY');
  static const double recyclingPointsRadiusKm = 0.5;
  static const List<String> demoAccountEmails = [
    'alex@gmail.com',
    'robert@gmail.com',
    'maria@gmail.com',
    'mihai@gmail.com',
    'ioana@gmail.com',
    'raul@gmail.com',
    'andrei@gmail.com'
  ];
}

class NewsConfig {
  static const String apiKey = String.fromEnvironment('NEWS_API_KEY');

  static const List<String> top30Sources = [
    'abc-news', 'abc-news-au', 'al-jazeera-english', 'associated-press', 'axios',
    'bbc-news', 'bloomberg', 'business-insider', 'cbc-news', 'cbs-news', 'cnn',
    'financial-post', 'fortune', 'fox-news', 'google-news', 'msnbc', 'nbc-news',
    'newsweek', 'national-geographic', 'new-scientist', 'politico', 'reuters',
    'the-globe-and-mail', 'the-hill', 'the-huffington-post', 'the-verge',
    'the-wall-street-journal', 'the-washington-post', 'time', 'usa-today'
  ];
  static const List<String> top60Sources = [
    ...top30Sources,
    'independent', 'the-times-of-india', 'the-hindu', 'the-jerusalem-post', 'the-irish-times',
    'le-monde', 'les-echos', 'die-zeit', 'der-tagesspiegel', 'focus', 'spiegel-online',
    'svenska-dagbladet', 'aftenposten', 'ansa', 'buzzfeed', 'engadget', 'techcrunch', 'ars-technica',
    'bbc-sport', 'cnn-es', 'el-mundo', 'la-repubblica', 'wired', 'national-review', 'mashable',
    'globo', 'infobae', 'news-com-au', 'new-york-magazine', 'vice-news'
  ];
  static String sourceParam = top60Sources.join(',');

  static DateTime fromDate = DateTime.now().subtract(const Duration(days: 7));
  static DateTime toDate = DateTime.now();
}
