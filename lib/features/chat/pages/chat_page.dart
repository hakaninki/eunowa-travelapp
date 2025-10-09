// lib/features/chat/pages/chat_page.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:travel_app/core/constants/app_colors.dart';
import 'package:travel_app/core/models/user_model.dart';
import 'package:travel_app/features/chat/providers/chat_providers.dart';
import 'package:travel_app/features/user/providers/user_provider.dart';

class ChatPage extends ConsumerStatefulWidget {
  final String otherUid;
  const ChatPage({super.key, required this.otherUid});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  String? _cid;
  String? _otherUid; // ✓✓ okundu kontrolü için
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final svc = ref.read(chatServiceProvider);
        final cid = await svc.openOrCreateConversation(widget.otherUid);
        if (!mounted) return;

        // cid "uidA_uidB" (sorted). me'ye göre diğer uid'i çıkar.
        final me = FirebaseAuth.instance.currentUser!;
        String extracted;
        if (cid.startsWith('${me.uid}_')) {
          extracted = cid.substring(me.uid.length + 1);
        } else if (cid.endsWith('_${me.uid}')) {
          extracted = cid.substring(0, cid.length - me.uid.length - 1);
        } else {
          extracted = widget.otherUid; // fallback
        }

        setState(() {
          _cid = cid;
          _otherUid = extracted;
        });

        // girişte unread sıfırlama (best-effort)
        await svc.markAllAsRead(cid);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to open chat: $e')),
        );
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty || _cid == null) return;
    final svc = ref.read(chatServiceProvider);
    await svc.sendMessage(cid: _cid!, text: text);
    _ctrl.clear();

    // küçük gecikme ile alta kaydır
    await Future.delayed(const Duration(milliseconds: 50));
    if (_scroll.hasClients) {
      _scroll.animateTo(
        _scroll.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    return DateFormat('HH:mm').format(dt.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    final userService = ref.watch(userServiceProvider);

    return FutureBuilder<UserModel?>(
      future: userService.getUserById(widget.otherUid),
      builder: (ctx, snap) {
        final title = snap.data?.username ?? 'Chat';
        return Scaffold(
          appBar: AppBar(
            title: Text(title),
            backgroundColor: AppColors.appBarPeach,
          ),
          body: (_cid == null)
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Expanded(
                      child: Consumer(
                        builder: (ctx, ref, _) {
                          final msgsAsync = ref.watch(messagesProvider(_cid!));
                          final me = FirebaseAuth.instance.currentUser;

                          return msgsAsync.when(
                            data: (msgs) {
                              // mesajlar geldikçe unread'ı sıfırla (best-effort)
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                ref.read(chatServiceProvider).markAllAsRead(_cid!);
                              });

                              return ListView.builder(
                                controller: _scroll,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 12,
                                ),
                                itemCount: msgs.length,
                                itemBuilder: (ctx, i) {
                                  final m = msgs[i];
                                  final isMine = m.fromUid == me?.uid;
                                  final time = _formatTime(m.createdAt);
                                  final isRead = isMine &&
                                      (_otherUid != null) &&
                                      (m.readBy.contains(_otherUid) == true);

                                  // Balon içeriği (hem Dismissible hem normalde kullanılacak)
                                  final bubble = Align(
                                    alignment: isMine
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                    child: GestureDetector(
                                      onLongPress: isMine
                                          ? () async {
                                              final ok = await showDialog<bool>(
                                                context: context,
                                                builder: (_) => AlertDialog(
                                                  title: const Text('Delete message?'),
                                                  content: const Text(
                                                      'This will delete the message for everyone.'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(context, false),
                                                      child: const Text('Cancel'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(context, true),
                                                      child: const Text('Delete'),
                                                    ),
                                                  ],
                                                ),
                                              );
                                              if (ok == true) {
                                                await ref
                                                    .read(chatServiceProvider)
                                                    .deleteMessage(_cid!, m.id);
                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(
                                                      content: Text('Message deleted'),
                                                    ),
                                                  );
                                                }
                                              }
                                            }
                                          : null,
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(vertical: 4),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: isMine
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withOpacity(0.15)
                                              : Colors.grey.shade200,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: isMine
                                              ? CrossAxisAlignment.end
                                              : CrossAxisAlignment.start,
                                          children: [
                                            Text(m.text),
                                            const SizedBox(height: 4),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  time,
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                                if (isMine) ...[
                                                  const SizedBox(width: 6),
                                                  Icon(
                                                    isRead
                                                        ? Icons.done_all // ✓✓
                                                        : Icons.check, // ✓
                                                    size: 16,
                                                    color: isRead
                                                        ? Colors.blue
                                                        : Colors.black45,
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );

                                  // Sadece kendi mesajlarımda kaydırarak sil
                                  if (isMine) {
                                    return Dismissible(
                                      key: ValueKey(m.id),
                                      direction: DismissDirection.endToStart,
                                      background: const SizedBox(),
                                      secondaryBackground: Container(
                                        alignment: Alignment.centerRight,
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        color: Colors.red.shade400,
                                        child: const Icon(Icons.delete, color: Colors.white),
                                      ),
                                      confirmDismiss: (_) async {
                                        return await showDialog<bool>(
                                              context: context,
                                              builder: (_) => AlertDialog(
                                                title: const Text('Delete message?'),
                                                content: const Text(
                                                    'This will delete the message for everyone.'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(context, false),
                                                    child: const Text('Cancel'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(context, true),
                                                    child: const Text('Delete'),
                                                  ),
                                                ],
                                              ),
                                            ) ??
                                            false;
                                      },
                                      onDismissed: (_) async {
                                        await ref
                                            .read(chatServiceProvider)
                                            .deleteMessage(_cid!, m.id);
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Message deleted'),
                                            ),
                                          );
                                        }
                                      },
                                      child: bubble,
                                    );
                                  }

                                  // Başkasının mesajı: sadece balon
                                  return bubble;
                                },
                              );
                            },
                            loading: () =>
                                const Center(child: CircularProgressIndicator()),
                            error: (e, _) => Center(child: Text('Error: $e')),
                          );
                        },
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _ctrl,
                                decoration: const InputDecoration(
                                  hintText: 'Message...',
                                  border: OutlineInputBorder(),
                                ),
                                onSubmitted: (_) => _send(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.send),
                              onPressed: _send,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
