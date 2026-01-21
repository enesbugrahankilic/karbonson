// lib/pages/rewards_main_page.dart
// Main Rewards Page - Entry point for all reward-related features

import 'package:flutter/material.dart';
import '../theme/theme_colors.dart';
import '../core/navigation/app_router.dart';

class RewardsMainPage extends StatelessWidget {
  const RewardsMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;

    return Scaffold(
      backgroundColor: ThemeColors.getCardBackground(context),
      appBar: AppBar(
        title: const Text('Ödüller'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Ödül Dünyasına Hoş Geldiniz',
                style: TextStyle(
                  color: ThemeColors.getText(context),
                  fontSize: isSmallScreen ? 20.0 : 24.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: isSmallScreen ? 8.0 : 12.0),
              Text(
                'Puanlarınızı kullanarak ödüller kazanın, kutular açın ve koleksiyonunuzu genişletin!',
                style: TextStyle(
                  color: ThemeColors.getSecondaryText(context),
                  fontSize: isSmallScreen ? 14.0 : 16.0,
                ),
              ),
              SizedBox(height: isSmallScreen ? 24.0 : 32.0),

              // Reward sections
              Expanded(
                child: GridView.count(
                  crossAxisCount: isSmallScreen ? 1 : 2,
                  mainAxisSpacing: isSmallScreen ? 16.0 : 20.0,
                  crossAxisSpacing: isSmallScreen ? 16.0 : 20.0,
                  childAspectRatio: isSmallScreen ? 1.2 : 1.1,
                  children: [
                    _buildRewardSection(
                      context,
                      icon: Icons.store,
                      title: 'Ödül Mağazası',
                      description: 'Avatarlar, temalar ve özellikler satın alın',
                      gradient: LinearGradient(
                        colors: [
                          ThemeColors.getPrimaryButtonColor(context),
                          ThemeColors.getAccentButtonColor(context),
                        ],
                      ),
                      onTap: () => Navigator.of(context).pushNamed(AppRoutes.rewardsShop),
                    ),
                    _buildRewardSection(
                      context,
                      icon: Icons.inventory,
                      title: 'Sahip Olunan Ödüller',
                      description: 'Kazandığınız ödülleri görüntüleyin',
                      gradient: LinearGradient(
                        colors: [
                          Colors.purple,
                          Colors.pink,
                        ],
                      ),
                      onTap: () => Navigator.of(context).pushNamed(
                        AppRoutes.rewardsShop,
                        arguments: {'initialTab': 1}, // Inventory tab
                      ),
                    ),
                    _buildRewardSection(
                      context,
                      icon: Icons.inventory_2,
                      title: 'Kazanılan Kutular',
                      description: 'Açılmamış ödül kutularınızı yönetin',
                      gradient: LinearGradient(
                        colors: [
                          Colors.orange,
                          Colors.amber,
                        ],
                      ),
                      onTap: () => Navigator.of(context).pushNamed(AppRoutes.wonBoxes),
                    ),
                  ],
                ),
              ),

              // Reward type indicators
              SizedBox(height: isSmallScreen ? 16.0 : 20.0),
              _buildRewardTypeIndicators(context, isSmallScreen),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRewardSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required LinearGradient gradient,
    required VoidCallback onTap,
  }) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(isSmallScreen ? 12.0 : 16.0),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: isSmallScreen ? 48.0 : 64.0,
              color: Colors.white,
            ),
            SizedBox(height: isSmallScreen ? 12.0 : 16.0),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: isSmallScreen ? 16.0 : 18.0,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isSmallScreen ? 6.0 : 8.0),
            Text(
              description,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: isSmallScreen ? 12.0 : 14.0,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardTypeIndicators(BuildContext context, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
      decoration: BoxDecoration(
        color: ThemeColors.getCardBackground(context),
        borderRadius: BorderRadius.circular(isSmallScreen ? 12.0 : 16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ödül Türleri',
            style: TextStyle(
              color: ThemeColors.getText(context),
              fontSize: isSmallScreen ? 16.0 : 18.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: isSmallScreen ? 12.0 : 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTypeIndicator(
                context,
                icon: Icons.person,
                label: 'Avatar',
                color: Colors.blue,
                isSmallScreen: isSmallScreen,
              ),
              _buildTypeIndicator(
                context,
                icon: Icons.palette,
                label: 'Tema',
                color: Colors.purple,
                isSmallScreen: isSmallScreen,
              ),
              _buildTypeIndicator(
                context,
                icon: Icons.star,
                label: 'Özellik',
                color: Colors.orange,
                isSmallScreen: isSmallScreen,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeIndicator(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required bool isSmallScreen,
  }) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(isSmallScreen ? 8.0 : 12.0),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.3), width: 2),
          ),
          child: Icon(
            icon,
            color: color,
            size: isSmallScreen ? 20.0 : 24.0,
          ),
        ),
        SizedBox(height: isSmallScreen ? 4.0 : 6.0),
        Text(
          label,
          style: TextStyle(
            color: ThemeColors.getText(context),
            fontSize: isSmallScreen ? 10.0 : 12.0,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}