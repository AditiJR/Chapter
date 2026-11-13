// This is an enhanced enum

enum MyNavigatorRoute {
  splash("/", "splash"),
  onboarding("/onboarding", "onboarding"),
  signIn("/sign-in", "sign-in"),
  signUp("/sign-up", "sign-up"),
  resetPassword("/reset-password", "reset-password"),
  resetLinkSent("/reset-link-sent", "reset-link-sent"),
  permissions("/permissions", "permissions"),
  library("/library", "library"),
  libraryEmpty("empty", "library-empty"),
  shelfDetail("shelf/:id", "shelf-detail"),
  search("/search", "search"),
  scan("/scan", "scan"),
  bookDetails("/book/:title", "book-details"),
  friends("/friends", "friends"),
  messages("/messages", "messages"),
  chat("/chat/:name", "chat"),
  friendProfile("/friend/:name", "friend-profile"),
  notifications("/notifications", "notifications"),
  settings("/settings", "settings"),
  editProfile("/edit-profile", "edit-profile"),
  editTopFive("/edit-top-5", "edit-top-5"),
  premium("/premium", "premium"),
  profile("/profile", "profile");

  const MyNavigatorRoute(this.path, this.name);

  final String path;
  final String name;
}
