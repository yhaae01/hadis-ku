final RegExp _arabicChars = RegExp(r'[\u0600-\u06FF]');
final RegExp _arabicDiacritics = RegExp(r'[\u0640\u064B-\u065F\u0670\u06D6-\u06ED]');

/// Menormalkan teks agar pencarian tetap cocok meski pengguna tidak
/// menuliskan harakat atau memakai varian huruf Arab yang berbeda.
String normalizeForSearch(String input) {
  var text = input.toLowerCase().trim();

  if (!_arabicChars.hasMatch(text)) return text;

  text = text
      .replaceAll(_arabicDiacritics, '')
      .replaceAll(RegExp('[أإآٱ]'), 'ا')
      .replaceAll('ى', 'ي')
      .replaceAll('ة', 'ه')
      .replaceAll('ؤ', 'و')
      .replaceAll('ئ', 'ي');

  return text;
}
