// lib/pages/login_page.dart

import 'package:flutter/material.dart';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'board_game_page.dart';
import 'leaderboard_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _nicknameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Kapsamlı isim önerisi listesi
  final List<String> _availableNames = [
    // A
    'AtıkAzaltıcı', 'AğaçDikeni', 'ArıKoruyucu', 'AydınlıkGezegen', 'AtmosferSavunucusu',
    // B
    'BiyoDost', 'BilinçliGezgin', 'BarışçıDoğa', 'BitkiSever', 'BiyoEnerji',
    // C
    'CevreBilinci', 'CevreKoruyucu', 'CevreTeknolojisi', 'CevreciZihin', 'CevreKalkanı',
    // Ç
    'ÇevreDostu', 'ÇiçekKahramanı', 'ÇamKoruyucu', 'ÇevreGönüllüsü', 'ÇölYeşertici',
    // D
    'DoğaKoruyucu', 'DönüşümElçisi', 'DoğalDenge', 'DenizTemizliği', 'DamladaHayat',
    // E
    'EkoSavaşçı', 'EkoKartal', 'EkoGönüllü', 'EkoZihin', 'EkoYenilikçi',
    // F
    'FidanDikici', 'FotosentezGücü', 'FırtınaDostu', 'FosilsizGelecek', 'FilizEnerjisi',
    // G
    'GeriDönüşümcü', 'GezegenSavunucusu', 'GüneşEnerjisi', 'GelecekYeşil', 'GökYeşili',
    // Ğ
    'ĞüneşRüzgarı', 'ĞıdaZinciri', 'ĞökkuşağıProjesi', 'ĞüçlüDoğa', 'ĞelişimYeşili',
    // H
    'HavaKoruyucu', 'HayatKaynağı', 'HidroEnerji', 'HedefSıfırAtık', 'HuzurluGezegen',
    // I
    'IsıKoruyucu', 'IşıkElçisi', 'IlımanDoğa', 'IsıDengesi', 'IlıkYaşam',
    // İ
    'İklimKahramanı', 'İleriGeriDönüşüm', 'İnsancaGelecek', 'İklimBilinci', 'İyileşenDünya',
    // J
    'JeoEnerji', 'JeoIsıKaynağı', 'JeoBilimci', 'JeoDoğa', 'JeoSistem',
    // K
    'KarbonSıfır', 'KüreselDenge', 'KaynakKoruyucu', 'KarbonsuzGelecek', 'KorunanDoğa',
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
    'PlastikAvcısı', 'PanelEnerji', 'PozitifDoğa', 'PetrolsüzGelecek', 'PlanlıYaşam',
    // R
    'RüzgarKahramanı', 'RenkliGezegen', 'RefahYeşil', 'RahatDoğa', 'RüzgarDostu',
    // S
    'SıfırAtık', 'SuBekçisi', 'SürdürülebilirHayat', 'SuKoruyucu', 'SessizDoğa',
    // Ş
    'ŞeffafEnerji', 'ŞelaleKoruyucu', 'ŞarjlıDoğa', 'ŞifalıBitki', 'ŞekilYeşil',
    // T
    'ToprakSever', 'TemizEnerji', 'TÜBİTAK_Proje', 'TohumKoruyucu', 'TarımTeknoloji',
    // U
    'UmutYeşili', 'UyumluDoğa', 'UyananGezegen', 'UzayEkosistemi', 'UlaşılabilirEnerji',
    // Ü
    'ÜretkenEkosistem', 'ÜstEnerji', 'ÜçüncüYaşam', 'ÜmitDoğa', 'ÜrünDostu',
    // V
    'VerimliToprak', 'VizyonerDoğa', 'VarlıkGezegeni', 'VakitYeşil', 'VeriEnerjisi',
    // Y
    'YeşilAyak', 'YeşilIşık', 'YeşilYürek', 'YaşamKaynağı', 'YenilenebilirRuh',
    // Z
    'ZehirsizHayat', 'ZararsızDoğa', 'ZümrütGezegen', 'ZekaYeşili', 'ZenginDoğa'
  ];
  
  // Rastgele isim öneren metot
  void _suggestRandomName() {
    final random = Random();
    final suggestion = _availableNames[random.nextInt(_availableNames.length)];
    setState(() {
      _nicknameController.text = suggestion;
    });
  }

  @override
  void initState() {
    super.initState();
    // Sayfa açıldığında rastgele bir isim öner
    _suggestRandomName(); 
  }

  Future<void> _startGame() async {
    if (_formKey.currentState!.validate()) {
      final nickname = _nicknameController.text;
      try {
        // Anonim giriş yap
        final userCredential = await FirebaseAuth.instance.signInAnonymously();
        final user = userCredential.user;

        if (user != null) {
          // Kullanıcı bilgilerini Firestore'a kaydet
          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'nickname': nickname,
            'lastLogin': FieldValue.serverTimestamp(),
            'isAnonymous': true,
          }, SetOptions(merge: true));

          if (!context.mounted) return;

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => BoardGamePage(userNickname: nickname),
            ),
          );
        }
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Giriş yapılırken bir hata oluştu')),
        );
      }
    }
  }

  void _viewLeaderboard() {
    // Liderlik tablosuna takma ad göndermeye gerek yok, çünkü oyun bitmedi.
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LeaderboardPage()),
    );
  }
  
  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Karbon Hesaplama Oyunu'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(
                Icons.eco,
                size: 80,
                color: Color(0xFF4CAF50),
              ),
              const SizedBox(height: 20),
              const Text(
                'Oyuna Başla',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E88E5),
                ),
              ),
              const SizedBox(height: 30),
              
              // İsim Alanı
              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _nicknameController,
                  decoration: InputDecoration(
                    labelText: 'Takma Adınız (Nickname)',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.person),
                    suffixIcon: IconButton( // Öneri butonu
                      icon: const Icon(Icons.casino),
                      onPressed: _suggestRandomName,
                      tooltip: 'Rastgele isim öner',
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen bir takma ad girin';
                    }
                    if (value.length < 3) {
                      return 'Takma ad en az 3 karakter olmalı';
                    }
                    return null;
                  },
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Başlat Butonu
              ElevatedButton(
                onPressed: _startGame,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: const Color(0xFF4CAF50),
                ),
                child: const Text(
                  'Oyuna Başla',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              
              const SizedBox(height: 15),
              
              // Liderlik Tablosu Butonu
              TextButton(
                onPressed: _viewLeaderboard,
                child: const Text(
                  'Liderlik Tablosunu Gör',
                  style: TextStyle(color: Color(0xFF1E88E5), fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}