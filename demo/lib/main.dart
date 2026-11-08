/// A demo messaging application to be shown in the generated screenshots,
/// nothing too fancy here.
library;

import 'package:material_ui/material_ui.dart';

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
          'Macbeth',
          _macbethChat.last.split('\n\n').last,
          unread: selectedUserName != 'Macbeth',
          selected: selectedUserName == 'Macbeth',
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

    return ColoredBox(
      color: ColorScheme.of(context).surfaceContainer,
      child: Column(
        children: [
          Expanded(
            child: SafeArea(
              top: false,
              bottom: false,
              child: ListView(
                reverse: true,
                padding: const EdgeInsets.all(16),
                children: _getMessages(context).reversed.toList(),
              ),
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

  List<Widget> _getMessages(BuildContext context) {
    final messages = <Widget>[];
    for (var i = 0; i < _macbethChat.length; ++i) {
      final sentByMe = i.isEven;
      final lines = _macbethChat[i].split('\n\n');
      for (final line in lines) {
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
                line,
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
      subtitle: Text(
        lastMessage,
        style: TextStyle(fontWeight: fontWeight),
        maxLines: 2,
      ),
      onTap: () {
        Navigator.pushNamed(context, '/chat/${userName.toLowerCase()}');
      },
      selected: selected,
      selectedTileColor: ColorScheme.of(context).surfaceContainer,
    );
  }
}

final _borderColor = Colors.grey.shade300;

const _macbethChat = [
  '''That which hath made them drunk hath made me bold; what hath quench'd them hath given me fire

Hark! Peace!

It was the owl that shriek'd, the fatal bellman, which gives the stern'st good-night. He is about it

The doors are open; and the surfeited grooms do mock their charge with snores: I have drugg'd their possets

That death and nature do contend about them, whether they live or die''',
  "Who's there? what, ho!",
  '''Alack, I am afraid they have awaked

And 'tis not done. The attempt and not the deed confounds us

Hark! I laid their daggers ready; He could not miss 'em

Had he not resembled my father as he slept, I had done't''',
  '[Enter Macbeth]',
  'My husband!',
  'I have done the deed. Didst thou not hear a noise?',
  '''I heard the owl scream and the crickets cry.

Did not you speak?''',
  'When?',
  'Now',
  'As I descended?',
  'Ay',
  '''Hark!

Who lies i' the second chamber?''',
  'Donalbain',
  'This is a sorry sight',
  '''A foolish thought

to say a sorry sight''',
  '''There's one did laugh in's sleep, and one cried 'Murder!' that they did wake each other

I stood and heard them: But they did say their prayers, and address'd them again to sleep''',
  'There are two lodged together',
  '''One cried 'God bless us!' and 'Amen' the other

As they had seen me with these hangman's hands

Listening their fear, I could not say 'Amen,' when they did say 'God bless us!' ''',
];
