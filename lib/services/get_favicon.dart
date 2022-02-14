/// Strip a url of pages, and return the favicon url
/// Note that not all sites have a favicon, so an image may not load.
String getFavicon(String rootUrl) {
  final linkUri = Uri.parse(rootUrl);
  final faviconUri = "https://" + linkUri.host + "/favicon.ico";
  return faviconUri;
}
