enum AppDestination {
  sources('/sources'),
  playback('/playback'),
  settings('/settings');

  const AppDestination(this.path);

  final String path;
}
