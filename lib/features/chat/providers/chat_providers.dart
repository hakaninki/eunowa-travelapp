import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:travel_app/features/chat/services/chat_service.dart';
import 'package:travel_app/features/chat/models/conversation_model.dart';
import 'package:travel_app/features/chat/models/message_model.dart';

final chatServiceProvider = Provider<ChatService>((ref) => ChatService());

// ✅ Auth state reaktif
final authStateProvider =
    StreamProvider<User?>((ref) => FirebaseAuth.instance.authStateChanges());

// ✅ Benim konuşmalarım (auth’a bağlı)
final myConversationsProvider =
    StreamProvider.autoDispose<List<ConversationModel>>((ref) {
  final auth = ref.watch(authStateProvider);
  final svc = ref.watch(chatServiceProvider);

  return auth.when(
    data: (user) {
      if (user == null) return const Stream.empty();
      return svc.watchMyConversations(user.uid);
    },
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
  );
});

final messagesProvider =
    StreamProvider.autoDispose.family<List<MessageModel>, String>((ref, cid) {
  final svc = ref.watch(chatServiceProvider);
  return svc.watchMessages(cid);
});

/// ✅ AppBar rozeti için toplam unread
final unreadTotalProvider = StreamProvider.autoDispose<int>((ref) {
  // myConversationsProvider zaten auth’a bağlı; direkt onu dinle
  return ref.watch(myConversationsProvider.stream).map((convos) {
    final me = FirebaseAuth.instance.currentUser;
    final myUid = me?.uid ?? '';
    int sum = 0;
    for (final c in convos) {
      sum += c.unreadFor(myUid);
    }
    return sum;
  });
});
