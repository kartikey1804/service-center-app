import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/data_provider.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_button.dart';

class TechChatScreen extends StatefulWidget {
  final String chatId;

  const TechChatScreen({Key? key, required this.chatId}) : super(key: key);

  @override
  State<TechChatScreen> createState() => _TechChatScreenState();
}

class _TechChatScreenState extends State<TechChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage(DataProvider provider) {
    if (_messageController.text.trim().isEmpty) return;

    provider.addChatMessage(
      widget.chatId,
      'Mike Ross',
      _messageController.text.trim(),
    );
    _messageController.clear();
    provider.sendMockReply(widget.chatId); // Simulate a reply
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<DataProvider>(
          builder: (context, dataProvider, child) {
            final chat = dataProvider.chatConversations.firstWhere(
              (c) => c['id'] == widget.chatId,
            );
            final participants = (chat['participants'] as List<String>)
                .where((p) => p != 'Mike Ross')
                .join(', ');
            return Text('Chat with $participants');
          },
        ),
      ),
      body: Consumer<DataProvider>(
        builder: (context, dataProvider, child) {
          final chat = dataProvider.chatConversations.firstWhere(
            (c) => c['id'] == widget.chatId,
          );
          final messages = chat['messages'] as List<Map<String, dynamic>>;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message['sender'] == 'Mike Ross';
                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 8.0,
                        ),
                        decoration: BoxDecoration(
                          color: isMe
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Column(
                          crossAxisAlignment: isMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Text(
                              message['sender'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isMe
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              message['message'],
                              style: TextStyle(
                                color: isMe
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              message['time'],
                              style: TextStyle(
                                fontSize: 10.0,
                                color: isMe
                                    ? Theme.of(
                                        context,
                                      ).colorScheme.onPrimary.withOpacity(0.7)
                                    : Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant
                                          .withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _messageController,
                        label: 'Message',
                        hintText: 'Type your message...',
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    CustomButton(
                      text: 'Send',
                      onPressed: () => _sendMessage(dataProvider),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
