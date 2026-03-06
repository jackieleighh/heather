String windDirectionLabel(int degrees) {
  const labels = [
    'N', 'NNE', 'NE', 'ENE',
    'E', 'ESE', 'SE', 'SSE',
    'S', 'SSW', 'SW', 'WSW',
    'W', 'WNW', 'NW', 'NNW',
  ];
  final index = ((degrees % 360) / 22.5 + 0.5).floor() % 16;
  return labels[index];
}
