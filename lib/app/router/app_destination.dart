enum AppDestination {
  home('/home'),
  gallery('/gallery'),
  settings('/settings');

  const AppDestination(this.path);

  final String path;
}
