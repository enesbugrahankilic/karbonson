// lib/pages/rewards_main_page.dart
// Main Rewards Page - Entry point for all reward-related features

import 'package:flutter/material.dart';
import '../theme/theme_colors.dart';
import '../core/navigation/app_router.dart';
import '../widgets/page_templates.dart';

class RewardsMainPage extends StatelessWidget {
  const RewardsMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StandardAppBar(
        title: 'Ödüller',
        onBackPressed: () => Navigator.pop(context),
      ),
      body: PageBody(
        scrollable: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ödül Dünyasına Hoş Geldiniz',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Puanlarınızı kullanarak ödüller kazanın, kutular açın ve koleksiyonunuzu genişletin!',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Reward sections
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildRewardSectionCard(
                    context,
                    icon: Icons.store,
                    title: 'Ödül Mağazası',
                    description: 'Avatarlar, temalar ve özellikler satın alın',
                    color: Colors.blue,
                    onTap: () => Navigator.of(context).pushNamed(AppRoutes.rewardsShop),
                  ),
                  const SizedBox(height: 12),
                  _buildRewardSectionCard(
                    context,
                    icon: Icons.inventory,
                    title: 'Sahip Olunan Ödüller',
                    description: 'Kazandığınız ödülleri görüntüleyin',
                    color: Colors.purple,
                    onTap: () => Navigator.of(context).pushNamed(
                      AppRoutes.rewardsShop,
                      arguments: {'initialTab': 1},
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildRewardSectionCard(
                    context,
                    icon: Icons.inventory_2,
                    title: 'Kazanılan Kutular',
                    description: 'Açılmamış ödül kutularınızı yönetin',
                    color: Colors.orange,
                    onTap: () => Navigator.of(context).pushNamed(AppRoutes.wonBoxes),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardSectionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_ios, color: color, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}