enum AppDestination {
  library('/library'),
  connect('/connect'),
  playback('/playback'),
  settings('/settings');

  const AppDestination(this.path);

  final String path;
}
