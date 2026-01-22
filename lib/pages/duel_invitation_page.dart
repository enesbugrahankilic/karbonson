import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/page_templates.dart';
import 'duel_page.dart';

class DuelInvitationPage extends StatefulWidget {
  const DuelInvitationPage({super.key});

  @override
  State<DuelInvitationPage> createState() => _DuelInvitationPageState();
}

class _DuelInvitationPageState extends State<DuelInvitationPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> _invitations = [];
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

      setState(() {
        _invitations = snapshot.docs.map((doc) => doc.data()).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StandardAppBar(
        title: const Text('Düello Davetleri'),
        onBackPressed: () => Navigator.pop(context),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadInvitations,
            tooltip: 'Yenile',
          ),
        ],
      ),
      body: PageBody(
        scrollable: true,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _invitations.isEmpty
                ? _buildEmptyState()
                : _buildInvitationsList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.mail_outline, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 24),
          Text('Henüz davet yok',
              style: Theme.of(context).textTheme.headlineSmall),
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
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(invitation['inviterNickname'] ?? 'Bilinmeyen',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(invitation['message'] ?? '',
                    style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => _rejectInvitation(invitation),
                      child: const Text('Reddet', style: TextStyle(color: Colors.red)),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () => _acceptInvitation(invitation),
                      child: const Text('Kabul Et'),
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

  Future<void> _acceptInvitation(Map<String, dynamic> invitation) async {
    try {
      await FirebaseFirestore.instance
          .collection('duel_invitations')
          .doc(invitation['id'])
          .update({'status': 'accepted'});

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const DuelPage()),
        );
      }
    } catch (e) {
      _showError('Davet kabul edilirken hata: $e');
    }
  }

  Future<void> _rejectInvitation(Map<String, dynamic> invitation) async {
    try {
      await FirebaseFirestore.instance
          .collection('duel_invitations')
          .doc(invitation['id'])
          .update({'status': 'declined'});

      setState(() {
        _invitations.removeWhere((inv) => inv['id'] == invitation['id']);
      });
    } catch (e) {
      _showError('Davet reddedilirken hata: $e');
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }
}
