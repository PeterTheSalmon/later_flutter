/// Returns a url with `https://` added if necessary
String checkUrlConventions({required String url}) {
  if (url.startsWith('http://') || url.startsWith('https://')) {
    return url;
  }
  return 'https://$url';
}
