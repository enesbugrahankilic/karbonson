// lib/services/nickname_service.dart
// Service for generating and suggesting environmental-themed nicknames

class NicknameService {
  static const List<String> _availableNames = [
    // A
    'AtıkAzaltıcı', 'AğaçDikeni', 'ArıKoruyucu', 'AydınlıkGezegen',
    'AtmosferSavunucusu',
    // B
    'BiyoDost', 'BilinçliGezgin', 'BarışçıDoğa', 'BitkiSever', 'BiyoEnerji',
    // C
    'CevreBilinci', 'CevreKoruyucu', 'CevreTeknolojisi', 'CevreciZihin',
    'CevreKalkanı',
    // Ç
    'ÇevreDostu', 'ÇiçekKahramanı', 'ÇamKoruyucu', 'ÇevreGönüllüsü',
    'ÇölYeşertici',
    // D
    'DoğaKoruyucu', 'DönüşümElçisi', 'DoğalDenge', 'DenizTemizliği',
    'DamladaHayat',
    // E
    'EkoSavaşçı', 'EkoKartal', 'EkoGönüllü', 'EkoZihin', 'EkoYenilikçi',
    // F
    'FidanDikici', 'FotosentezGücü', 'FırtınaDostu', 'FosilsizGelecek',
    'FilizEnerjisi',
    // G
    'GeriDönüşümcü', 'GezegenSavunucusu', 'GüneşEnerjisi', 'GelecekYeşil',
    'GökYeşili',
    // H
    'HavaKoruyucu', 'HayatKaynağı', 'HidroEnerji', 'HedefSıfırAtık',
    'HuzurluGezegen',
    // I
    'IsıKoruyucu', 'IşıkElçisi', 'IlımanDoğa', 'IsıDengesi', 'IlıkYaşam',
    // İ
    'İklimKahramanı', 'İleriGeriDönüşüm', 'İnsancaGelecek', 'İklimBilinci',
    'İyileşenDünya',
    // J
    'JeoEnerji', 'JeoIsıKaynağı', 'JeoBilimci', 'JeoDoğa', 'JeoSistem',
    // K
    'KarbonSıfır', 'KüreselDenge', 'KaynakKoruyucu', 'KarbonsuzGelecek',
    'KorunanDoğa',
    // L
    'LikitGüneş', 'LambaEnerji', 'LojistikYeşil', 'LiderEko', 'LimonYeşili',
    // M
    'MaviGezegen', 'MikroEkosistem', 'MilliEnerji', 'MaviDalga', 'ModernDoğa',
    // N
    'NefesAlanDünya', 'NemDostu', 'NesilYeşil', 'NadirEkosistem', 'NoktaAtık',
    // O
    'OrmanKralı', 'OkyanusDostu', 'OrganikRuh', 'OrmanBekçisi', 'OzonKoruyucu',
    // Ö
    'ÖncüDoğa', 'ÖzgürGezegen', 'ÖrtüBitkisi', 'ÖzenliYaşam', 'ÖmrüYeşil',
    // P
    'PlastikAvcısı', 'PanelEnerji', 'PozitifDoğa', 'PetrolsüzGelecek',
    'PlanlıYaşam',
    // R
    'RüzgarKahramanı', 'RenkliGezegen', 'RefahYeşil', 'RahatDoğa',
    'RüzgarDostu',
    // S
    'SıfırAtık', 'SuBekçisi', 'SürdürülebilirHayat', 'SuKoruyucu', 'SessizDoğa',
    // Ş
    'ŞeffafEnerji', 'ŞelaleKoruyucu', 'ŞarjlıDoğa', 'ŞifalıBitki', 'ŞekilYeşil',
    // T
    'ToprakSever', 'TemizEnerji', 'TÜBİTAK_Proje', 'TohumKoruyucu',
    'TarımTeknoloji',
    // U
    'UmutYeşili', 'UyumluDoğa', 'UyananGezegen', 'UzayEkosistemi',
    'UlaşılabilirEnerji',
    // Ü
    'ÜretkenEkosistem', 'ÜstEnerji', 'ÜçüncüYaşam', 'ÜmitDoğa', 'ÜrünDostu',
    // V
    'VerimliToprak', 'VizyonerDoğa', 'VarlıkGezegeni', 'VakitYeşil',
    'VeriEnerjisi',
    // Y
    'YeşilAyak', 'YeşilIşık', 'YeşilYürek', 'YaşamKaynağı', 'YenilenebilirRuh',
    // Z
    'ZehirsizHayat', 'ZararsızDoğa', 'ZümrütGezegen', 'ZekaYeşili', 'ZenginDoğa'
  ];

  /// Get a random nickname suggestion based on current time
  /// Uses milliseconds since epoch for deterministic "randomness"
  static String getRandomSuggestion() {
    final randomIndex =
        DateTime.now().millisecondsSinceEpoch % _availableNames.length;
    return _availableNames[randomIndex];
  }

  /// Get multiple random nickname suggestions
  /// Returns a list of unique suggestions
  static List<String> getMultipleSuggestions({int count = 5}) {
    final suggestions = <String>[];
    final usedIndices = <int>{};

    // Use current time plus iteration for more randomness
    int baseTime = DateTime.now().millisecondsSinceEpoch;

    while (suggestions.length < count &&
        usedIndices.length < _availableNames.length) {
      final randomIndex =
          (baseTime + suggestions.length * 1000) % _availableNames.length;

      if (!usedIndices.contains(randomIndex)) {
        usedIndices.add(randomIndex);
        suggestions.add(_availableNames[randomIndex]);
      }
    }

    return suggestions;
  }

  /// Get all available nickname suggestions
  static List<String> getAllAvailableNames() {
    return List.unmodifiable(_availableNames);
  }

  /// Check if a nickname exists in the suggestion list
  static bool isInSuggestionList(String nickname) {
    return _availableNames.contains(nickname);
  }

  /// Get suggestions filtered by starting letter
  static List<String> getSuggestionsByLetter(String letter) {
    return _availableNames.where((name) => name.startsWith(letter)).toList();
  }

  /// Get a specific number of suggestions starting with a given letter
  static List<String> getFilteredSuggestions(String letter, {int count = 3}) {
    final filtered = getSuggestionsByLetter(letter);
    final suggestions = <String>[];

    // Use time-based indexing for "random" selection
    int baseTime = DateTime.now().millisecondsSinceEpoch;

    for (int i = 0; i < filtered.length && suggestions.length < count; i++) {
      final index = (baseTime + i * 500) % filtered.length;
      if (!suggestions.contains(filtered[index])) {
        suggestions.add(filtered[index]);
      }
    }

    return suggestions;
  }
}
