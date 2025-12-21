// lib/pages/multiplayer_lobby_page.dart

import 'package:flutter/material.dart';
import 'room_management_page.dart';

class MultiplayerLobbyPage extends StatefulWidget {
  final String userNickname;

  const MultiplayerLobbyPage({super.key, required this.userNickname});

  @override
  State<MultiplayerLobbyPage> createState() => _MultiplayerLobbyPageState();
}

class _MultiplayerLobbyPageState extends State<MultiplayerLobbyPage> {
  @override
  Widget build(BuildContext context) {
    return RoomManagementPage(userNickname: widget.userNickname);
  }
}
