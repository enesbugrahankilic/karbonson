// lib/pages/duel_invitation_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/friendship_service.dart';
import '../theme/theme_colors.dart';
import '../widgets/home_button.dart';
import 'duel_page.dart';

class DuelInvitationPage extends StatefulWidget {
  const DuelInvitationPage({super.key});

  @override
  State<DuelInvitationPage> createState() => _DuelInvitationPageState();
}

class _DuelInvitationPageState extends State<DuelInvitationPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FriendshipService _friendshipService = FriendshipService();

  List<Invitation> _invitations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInvitations();
  }

  Future<void> _loadInvitations() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      final snapshot = await FirebaseFirestore.instance
          .collection('duel_invitations')
          .where('inviteeId', isEqualTo: currentUser.uid)
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .get();

      final invitations = snapshot.docs.map((doc) {
        final data = doc.data();
        return Invitation(
          id: doc.id,
          inviterId: data['inviterId'] ?? '',
          inviterNickname: data['inviterNickname'] ?? '',
          inviteeId: data['inviteeId'] ?? '',
          inviteeNickname: data['inviteeNickname'] ?? '',
          roomId: data['roomId'] ?? '',
          message: data['message'] ?? '',
          createdAt: (data['createdAt'] as Timestamp).toDate(),
        );
      }).toList();

      setState(() {
        _invitations = invitations;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Davetler yüklenirken hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _acceptInvitation(Invitation invitation) async {
    try {
      // Update invitation status
      await FirebaseFirestore.instance
          .collection('duel_invitations')
          .doc(invitation.id)
          .update({'status': 'accepted'});

      // Navigate to duel page
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const DuelPage(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Davet kabul edilirken hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _rejectInvitation(Invitation invitation) async {
    try {
      // Update invitation status
      await FirebaseFirestore.instance
          .collection('duel_invitations')
          .doc(invitation.id)
          .update({'status': 'declined'});

      // Remove from local list
      setState(() {
        _invitations.removeWhere((inv) => inv.id == invitation.id);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Davet reddedildi'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Davet reddedilirken hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const HomeButton(),
        title: const Text('Düello Davetleri'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadInvitations,
            tooltip: 'Yenile',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: ThemeColors.getGradientColors(context),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _invitations.isEmpty
                  ? _buildEmptyState()
                  : _buildInvitationsList(),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.mail_outline,
            size: 100,
            color: ThemeColors.getSecondaryText(context),
          ),
          const SizedBox(height: 24),
          Text(
            'Henüz davet yok',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: ThemeColors.getText(context),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Arkadaşlarınız size düello daveti gönderdiğinde burada görünecek',
            style: TextStyle(
              fontSize: 16,
              color: ThemeColors.getSecondaryText(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInvitationsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _invitations.length,
      itemBuilder: (context, index) {
        final invitation = _invitations[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: ThemeColors.getCardBackground(context),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: ThemeColors.getGreen(context),
                      child: Text(
                        invitation.inviterNickname
                            .substring(0, 1)
                            .toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            invitation.inviterNickname,
                            style: TextStyle(
                              color: ThemeColors.getText(context),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'sizi düello davet ediyor',
                            style: TextStyle(
                              color: ThemeColors.getSecondaryText(context),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: ThemeColors.getGreen(context),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'YENİ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ThemeColors.getDialogContentBackground(context),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.security,
                        color: ThemeColors.getGreen(context),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Oda Kodu: ${invitation.roomId}',
                        style: TextStyle(
                          color: ThemeColors.getText(context),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  invitation.message,
                  style: TextStyle(
                    color: ThemeColors.getSecondaryText(context),
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _rejectInvitation(invitation),
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Reddet'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () => _acceptInvitation(invitation),
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Kabul Et'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeColors.getGreen(context),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class Invitation {
  final String id;
  final String inviterId;
  final String inviterNickname;
  final String inviteeId;
  final String inviteeNickname;
  final String roomId;
  final String message;
  final DateTime createdAt;

  Invitation({
    required this.id,
    required this.inviterId,
    required this.inviterNickname,
    required this.inviteeId,
    required this.inviteeNickname,
    required this.roomId,
    required this.message,
    required this.createdAt,
  });
}
