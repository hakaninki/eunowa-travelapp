import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:travel_app/features/chat/models/conversation_model.dart';
import 'package:travel_app/features/chat/models/message_model.dart';

class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String conversationIdFor(String a, String b) {
    final pair = [a, b]..sort();
    return '${pair[0]}_${pair[1]}';
  }

  DocumentReference<Map<String, dynamic>> _convoRef(String cid) =>
      _db.collection('conversations').doc(cid);

  CollectionReference<Map<String, dynamic>> _messagesCol(String cid) =>
      _convoRef(cid).collection('messages');

  Future<String> openOrCreateConversation(String otherUid) async {
  final me = FirebaseAuth.instance.currentUser;
  if (me == null) throw Exception('Not signed in');

  final pair = [me.uid, otherUid]..sort();
  final cid = '${pair[0]}_${pair[1]}';

  // lastAt YAZMA! sadece ilk kurulum verileri
  await _convoRef(cid).set({
    'participants': pair,
    'unread': {pair[0]: 0, pair[1]: 0},
  }, SetOptions(merge: true));

  return cid;
}


  Future<void> sendMessage({required String cid, required String text}) async {
  final me = FirebaseAuth.instance.currentUser;
  if (me == null) throw Exception('Not signed in');
  final trimmed = text.trim();
  if (trimmed.isEmpty) return;

  // otherUid’i güvenli bul:
  // 1) Önce hızlı yol: cid me.uid ile başlıyor/bitiyor mu?
  String otherUid;
  if (cid.startsWith('${me.uid}_')) {
    otherUid = cid.substring(me.uid.length + 1);
  } else if (cid.endsWith('_${me.uid}')) {
    otherUid = cid.substring(0, cid.length - me.uid.length - 1);
  } else {
    // 2) Fallback: dokümanı okuyup participants’tan çıkar (participant olduğun için read iznin var)
    try {
      final snap = await _convoRef(cid).get();
      final parts = List<String>.from(snap.data()?['participants'] ?? const []);
      otherUid = parts.firstWhere((u) => u != me.uid, orElse: () => me.uid);
    } catch (_) {
      otherUid = me.uid; // en kötü durumda increment boşa gitmesin
    }
  }

  final now = FieldValue.serverTimestamp();
  final batch = _db.batch();
  final msgRef = _messagesCol(cid).doc();

  // mesajı yaz
  batch.set(msgRef, {
    'fromUid': me.uid,
    'text': trimmed,
    'createdAt': now,
    'readBy': [me.uid],
  });

  // convo meta + unread sayaçlarını güncelle
  batch.update(_convoRef(cid), {
    'lastMessage': trimmed,
    'lastAt': now,
    'unread.$otherUid': FieldValue.increment(1),
    'unread.${me.uid}': 0,
  });

  await batch.commit();
}

  /// Stream my conversations (client-side sort by lastAt desc; no index needed).
  Stream<List<ConversationModel>> watchMyConversations(String myUid) {
    return _db
        .collection('conversations')
        .where('participants', arrayContains: myUid)
        .snapshots()
        .map((snap) {
          final list = snap.docs
              .map((d) => ConversationModel.fromMap(d.id, d.data()))
              .toList();
          list.sort((a, b) {
            final da = a.lastAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            final db = b.lastAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            return db.compareTo(da); // desc
          });
          return list;
        });
  }

  Stream<List<MessageModel>> watchMessages(String cid) {
    return _messagesCol(cid)
        .orderBy('createdAt', descending: false)
        .limit(200)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => MessageModel.fromMap(d.id, d.data()))
              .toList(),
        );
  }

  Future<void> markAllAsRead(String cid) async {
    final me = FirebaseAuth.instance.currentUser;
    if (me == null) return;

    final q = await _messagesCol(
      cid,
    ).orderBy('createdAt', descending: true).limit(50).get();

    final batch = _db.batch();
    for (final d in q.docs) {
      final data = d.data();
      final readBy = List<String>.from(data['readBy'] ?? const []);
      if (!readBy.contains(me.uid)) {
        batch.update(d.reference, {
          'readBy': FieldValue.arrayUnion([me.uid]),
        });
      }
    }
    // unread’ı sıfırla
    batch.update(_convoRef(cid), {'unread.${me.uid}': 0});

    await batch.commit();
  }

  Future<void> deleteMessage(String cid, String mid) async {
    await _messagesCol(cid).doc(mid).delete();
  }

  Future<void> deleteConversation(String cid) async {
    // alt mesajları sil
    while (true) {
      final qs = await _messagesCol(cid).limit(300).get();
      if (qs.docs.isEmpty) break;
      final batch = _db.batch();
      for (final d in qs.docs) {
        batch.delete(d.reference);
      }
      await batch.commit();
    }
    await _convoRef(cid).delete();
  }
}
