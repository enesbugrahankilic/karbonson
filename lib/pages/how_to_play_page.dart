// lib/pages/how_to_play_page.dart
import 'package:flutter/material.dart';
import '../widgets/page_templates.dart';
import '../theme/theme_colors.dart';

class HowToPlayPage extends StatelessWidget {
  HowToPlayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StandardAppBar(
        title: const Text('Nasıl Oynanır?'),
        onBackPressed: () => Navigator.pop(context),
      ),
      body: PageBody(
        scrollable: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(title: 'Masa Oyunu'),
            _buildSectionDescription(
                '25 karelik bir tahtada ilerleyerek bitişe ulaşın.'),
            const SizedBox(height: 12),
            _buildInfoCard(
              Icons.casino,
              'Zar At',
              'Butona basarak 1-3 arasında zar atın',
              Colors.green,
            ),
            const SizedBox(height: 8),
            _buildInfoCard(
              Icons.grid_on,
              'Kareler',
              'Quiz, Bonus (+5 sn) ve Ceza (-5 sn, -5 puan) kareleri',
              Colors.blue,
            ),
            const SizedBox(height: 8),
            _buildInfoCard(
              Icons.shield,
              'Koruma',
              'İlk 2 turda ceza kareleri etki etmez',
              Colors.purple,
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Düello Modu'),
            _buildSectionDescription(
                '2 oyuncu arasinda hizli cevap yarisi!'),
            _buildInfoCard(
              Icons.timer,
              'Sure',
              'Her soru icin 15 saniye',
              Colors.orange,
            ),
            _buildInfoCard(
              Icons.star,
              'Puanlama',
              'Dogru cevap: 10 puan + hiz bonusu',
              Colors.amber,
            ),
            _buildInfoCard(
              Icons.emoji_events,
              'Kazanma',
              'Ilk 3 dogru cevap veren kazanir',
              Colors.red,
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Cok Oyunculu'),
            _buildSectionDescription(
                'Arkadaslarinizla gercek zamanli oynayin!'),
            _buildInfoCard(
              Icons.group,
              'Oda Sistemi',
              'Oda kodu olusturup arkadaslarinizi davet edin',
              Colors.teal,
            ),
            _buildInfoCard(
              Icons.live_tv,
              'Izleyici Modu',
              'Baska oyunlari canli izleyebilirsiniz',
              Colors.indigo,
            ),
            const SizedBox(height: 24),
            _buildTipsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSectionDescription(String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        description,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildInfoCard(
      IconData icon, String title, String description, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ipuclari',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildTipRow('Quiz sorularini cozerek hizlanin'),
            _buildTipRow('Cevre bilginizi artirin'),
            _buildTipRow('Her soru icin sure tutum'),
            _buildTipRow('Arkadaslarinizla pratik yapin'),
          ],
        ),
      ),
    );
  }

  Widget _buildTipRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.lightbulb, color: Colors.amber, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
