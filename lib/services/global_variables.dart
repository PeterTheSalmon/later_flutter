/// Convenience class for values that rarely change and are used throughout the app
class Globals {
  static String? sharedUrl;

  /// A list of tips for use on the home page.
  /// The tips are displayed in a random order.
  static List<String> tipList = [
    "Click the menu in the bottom right for quick actions!",
    "Later is completely open source and free to use!",
    "You can also share the app with your friends!",
    "Check out the Mac app for a Mac version!",
    "You can use Later on the web, on desktop, or on mobile!",
    "Mmm tips",
    "Later supports keyboard shortcuts! Try ctrl/cmd + n to save a link.",
    "Later supports keyboard shortcuts! Try ctrl/cmd + shift + n to create a folder.",
    "Later supports keyboard shortcuts! Try ctrl/cmd + alt + n to save a link on your clipboard.",
  ];
}
