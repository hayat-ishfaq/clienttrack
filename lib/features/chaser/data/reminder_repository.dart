import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/reminder_log_model.dart';
import '../../invoices/data/invoice_repository.dart';
import '../../auth/data/auth_repository.dart';

final reminderRepositoryProvider = Provider<ReminderRepository>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  final invoiceRepo = ref.watch(invoiceRepositoryProvider);
  return ReminderRepository(auth, FirebaseFirestore.instance, invoiceRepo);
});

final invoiceRemindersStreamProvider =
    StreamProvider.family<List<ReminderLogModel>, String>((ref, invoiceId) {
  final repo = ref.watch(reminderRepositoryProvider);
  return repo.streamRemindersForInvoice(invoiceId);
});

class ReminderRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final InvoiceRepository _invoiceRepository;

  ReminderRepository(this._auth, this._firestore, this._invoiceRepository);

  String? get _uid => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>>? get _remindersCollection {
    final uid = _uid;
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid).collection('reminder_logs');
  }

  Stream<List<ReminderLogModel>> streamRemindersForInvoice(String invoiceId) {
    final collection = _remindersCollection;
    if (collection == null) {
      return Stream.value([]);
    }

    return collection
        .where('invoiceId', isEqualTo: invoiceId)
        .orderBy('sentAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ReminderLogModel.fromFirestore(doc))
          .toList();
    });
  }

  Future<void> logReminder(ReminderLogModel log) async {
    final collection = _remindersCollection;
    final uid = _uid;

    if (collection != null) {
      await collection.add(log.toMap());
    }

    // Update invoice counters
    await _invoiceRepository.recordReminderSent(log.invoiceId);

    // Increment global share metric on user root doc
    if (uid != null) {
      try {
        await _firestore.collection('users').doc(uid).update({
          'reminderSharesCount': FieldValue.increment(1),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } catch (_) {}
    }
  }
}
