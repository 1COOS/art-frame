enum AppDestination {
  library('/library'),
  connect('/connect'),
  networkConfig('/connect/network-config'),
  playback('/playback'),
  settings('/settings');

  const AppDestination(this.path);

  final String path;
}
