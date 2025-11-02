/// A demo messaging application to be shown in the generated screenshots,
/// nothing too fancy here.
library;

import 'dart:math';

import 'package:flutter/material.dart';

class DemoHomePage extends StatelessWidget {
  const DemoHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        shape: Border(bottom: BorderSide(color: _borderColor, width: 1)),
      ),
      body: MediaQuery.sizeOf(context).width >= 600
          ? Row(
              children: [
                SizedBox(width: 300, child: _RecentChatsList()),
                Container(color: _borderColor, width: 1),
                Expanded(child: _OpenChat(null)),
              ],
            )
          : _RecentChatsList(),
    );
  }
}

class DemoChatPage extends StatelessWidget {
  final String userName;

  const DemoChatPage({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with $userName'),
        shape: Border(bottom: BorderSide(color: _borderColor, width: 1)),
      ),
      body: MediaQuery.sizeOf(context).width >= 600
          ? Row(
              children: [
                SizedBox(width: 300, child: _RecentChatsList(userName)),
                Container(color: _borderColor, width: 1),
                Expanded(child: _OpenChat(userName)),
              ],
            )
          : _OpenChat(userName),
    );
  }
}

class _RecentChatsList extends StatelessWidget {
  const _RecentChatsList([this.selectedUserName]);
  final String? selectedUserName;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _ChatListTile(
          'Jane',
          'This is message number 30.',
          unread: selectedUserName != 'Jane',
          selected: selectedUserName == 'Jane',
        ),
        _ChatListTile('John', 'Let\'s catch up on Monday.'),
        _ChatListTile('Bob', 'Did you see the game last night?', unread: true),
        for (var i = 0; i < 3; ++i) ...[
          _ChatListTile('Alice', 'Good night!'),
          _ChatListTile('Charlie', 'haha thanks'),
          _ChatListTile('Pete', 'Perfect'),
          _ChatListTile('Zoe', 'See you soon!'),
          _ChatListTile('Liam', 'On my way.'),
          _ChatListTile('Emma', 'That sounds great!'),
          _ChatListTile('Olivia', 'I will call you later.'),
        ],
      ],
    );
  }
}

class _OpenChat extends StatelessWidget {
  const _OpenChat(this.userName);
  final String? userName;

  @override
  Widget build(BuildContext context) {
    if (userName == null) {
      return const Center(
        child: Text(
          'Select a chat to start messaging',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    final random = Random(31415);
    return ColoredBox(
      color: ColorScheme.of(context).surfaceContainer,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              reverse: true,
              padding: const EdgeInsets.all(16),
              children: _getMessages(context, random).reversed.toList(),
            ),
          ),
          SafeArea(
            minimum: const EdgeInsets.all(8.0),
            child: Row(
              spacing: 8,
              children: [
                Expanded(
                  child: TextField(
                    enabled: true,
                    decoration: InputDecoration(
                      hintText: 'What would you like to say to $userName?',
                      filled: true,
                      fillColor: ColorScheme.of(context).onPrimary,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      constraints: const BoxConstraints.tightFor(height: 48),
                    ),
                  ),
                ),
                IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: ColorScheme.of(context).onPrimary,
                    foregroundColor: ColorScheme.of(context).primary,
                    fixedSize: const Size(48, 48),
                  ),
                  icon: const Icon(Icons.send),
                  onPressed: () {},
                  onLongPress: () => _showSendOptions(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _getMessages(BuildContext context, Random random) {
    final messages = <Widget>[];
    for (var i = 0; i < 30; ++i) {
      final sentByMe = random.nextBool();
      messages.add(
        Align(
          alignment: sentByMe
              ? AlignmentDirectional.centerEnd
              : AlignmentDirectional.centerStart,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: sentByMe
                  ? ColorScheme.of(context).primaryContainer
                  : ColorScheme.of(context).surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'This is message number ${i + 1}.',
              style: TextStyle(
                color: sentByMe
                    ? ColorScheme.of(context).onPrimaryContainer
                    : ColorScheme.of(context).onSurfaceVariant,
              ),
            ),
          ),
        ),
      );
    }
    return messages;
  }

  void _showSendOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          alignment: Alignment.bottomRight,
          insetPadding: const EdgeInsets.all(8),
          content: Material(
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.send),
                  title: const Text('Send Now'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.schedule),
                  title: const Text('Schedule Send'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ChatListTile extends StatelessWidget {
  final String userName;
  final String lastMessage;
  final bool unread;
  final bool selected;

  const _ChatListTile(
    this.userName,
    this.lastMessage, {
    this.unread = false,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final fontWeight = unread ? FontWeight.bold : FontWeight.normal;
    return ListTile(
      leading: CircleAvatar(child: Text(userName[0])),
      title: Text(userName, style: TextStyle(fontWeight: fontWeight)),
      subtitle: Text(lastMessage, style: TextStyle(fontWeight: fontWeight)),
      onTap: () {
        Navigator.pushNamed(context, '/chat/${userName.toLowerCase()}');
      },
      selected: selected,
      selectedTileColor: ColorScheme.of(context).surfaceContainer,
    );
  }
}

final _borderColor = Colors.grey.shade300;
