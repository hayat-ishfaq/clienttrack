import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/invoice_model.dart';
import '../domain/models/line_item_model.dart';
import '../../auth/data/auth_repository.dart';

final invoiceRepositoryProvider = Provider<InvoiceRepository>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return InvoiceRepository(auth, FirebaseFirestore.instance);
});

final invoicesStreamProvider = StreamProvider<List<InvoiceModel>>((ref) {
  final repo = ref.watch(invoiceRepositoryProvider);
  return repo.streamInvoices();
});

final clientInvoicesStreamProvider =
    StreamProvider.family<List<InvoiceModel>, String>((ref, clientId) {
  final repo = ref.watch(invoiceRepositoryProvider);
  return repo.streamInvoicesForClient(clientId);
});

final needsFollowUpStreamProvider = StreamProvider<List<InvoiceModel>>((ref) {
  final repo = ref.watch(invoiceRepositoryProvider);
  return repo.streamNeedsFollowUp();
});

final invoiceByIdProvider =
    FutureProvider.family<InvoiceModel?, String>((ref, id) {
  final repo = ref.watch(invoiceRepositoryProvider);
  return repo.getInvoice(id);
});

class InvoiceRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  InvoiceRepository(this._auth, this._firestore);

  String? get _uid => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>>? get _invoicesCollection {
    final uid = _uid;
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid).collection('invoices');
  }

  Stream<List<InvoiceModel>> streamInvoices() {
    final collection = _invoicesCollection;
    if (collection == null) {
      return Stream.value(kSeedInvoices);
    }

    return collection
        .orderBy('issueDate', descending: true)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return kSeedInvoices;
      }
      return snapshot.docs
          .map((doc) => InvoiceModel.fromFirestore(doc))
          .toList();
    });
  }

  Stream<List<InvoiceModel>> streamInvoicesForClient(String clientId) {
    final collection = _invoicesCollection;
    if (collection == null) {
      return Stream.value(
        kSeedInvoices.where((inv) => inv.clientId == clientId).toList(),
      );
    }

    return collection
        .where('clientId', isEqualTo: clientId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return kSeedInvoices.where((inv) => inv.clientId == clientId).toList();
      }
      return snapshot.docs
          .map((doc) => InvoiceModel.fromFirestore(doc))
          .toList();
    });
  }

  Stream<List<InvoiceModel>> streamNeedsFollowUp() {
    return streamInvoices().map((invoices) {
      return invoices.where((inv) => inv.isOverdue).toList();
    });
  }

  Future<InvoiceModel?> getInvoice(String id) async {
    final collection = _invoicesCollection;
    if (collection == null) {
      return kSeedInvoices.firstWhere(
        (inv) => inv.id == id,
        orElse: () => kSeedInvoices.first,
      );
    }

    final doc = await collection.doc(id).get();
    if (!doc.exists) {
      return kSeedInvoices.cast<InvoiceModel?>().firstWhere(
            (inv) => inv?.id == id,
            orElse: () => null,
          );
    }
    return InvoiceModel.fromFirestore(doc);
  }

  Future<String> addInvoice(InvoiceModel invoice) async {
    final collection = _invoicesCollection;
    if (collection == null) return invoice.id;

    final docRef = await collection.add(invoice.toMap());
    return docRef.id;
  }

  Future<void> updateInvoice(InvoiceModel invoice) async {
    final collection = _invoicesCollection;
    if (collection == null) return;

    await collection.doc(invoice.id).set(invoice.toMap(), SetOptions(merge: true));
  }

  Future<void> updateInvoiceStatus(String invoiceId, InvoiceStatus status) async {
    final collection = _invoicesCollection;
    if (collection == null) return;

    final updates = <String, dynamic>{
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (status == InvoiceStatus.paid) {
      updates['paidAt'] = FieldValue.serverTimestamp();
    }

    await collection.doc(invoiceId).update(updates);
  }

  Future<void> recordReminderSent(String invoiceId) async {
    final collection = _invoicesCollection;
    if (collection == null) return;

    await collection.doc(invoiceId).update({
      'lastReminderSentAt': FieldValue.serverTimestamp(),
      'reminderCount': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteInvoice(String id) async {
    final collection = _invoicesCollection;
    if (collection == null) return;

    await collection.doc(id).delete();
  }
}

// Default rich seed invoices for preview & follow-ups
final kSeedInvoices = <InvoiceModel>[
  InvoiceModel(
    id: 'inv-1023',
    invoiceNumber: '#1023',
    clientId: 'c1',
    clientName: 'Alex Rivera',
    clientEmail: 'alex@studioarc.com',
    clientPhone: '+1 (555) 234-5678',
    projectId: 'p1',
    projectTitle: 'Brand Identity Design',
    status: InvoiceStatus.overdue,
    items: const [
      LineItemModel(
        id: 'li-1',
        description: 'Brand Identity Discovery & Moodboard',
        category: 'Design',
        amount: 1200.0,
      ),
      LineItemModel(
        id: 'li-2',
        description: 'Primary & Secondary Logo Guidelines',
        category: 'Branding',
        amount: 1400.0,
      ),
      LineItemModel(
        id: 'li-3',
        description: 'Stationery & Social Kit',
        category: 'Collateral',
        amount: 600.0,
      ),
    ],
    subtotal: 3200.0,
    taxRate: 0.10,
    taxAmount: 320.0,
    discountAmount: 0.0,
    totalAmount: 3520.0,
    amountPaid: 0.0,
    issueDate: DateTime.now().subtract(const Duration(days: 28)),
    dueDate: DateTime.now().subtract(const Duration(days: 14)),
    notes: 'Payment is past due. Please settle via direct transfer.',
    paymentTerms: 'Net 14',
    lastReminderSentAt: DateTime.now().subtract(const Duration(days: 2)),
    reminderCount: 2,
  ),
  InvoiceModel(
    id: 'inv-1024',
    invoiceNumber: '#1024',
    clientId: 'c2',
    clientName: 'Sarah Chen',
    clientEmail: 'sarah.c@techflow.io',
    clientPhone: '+1 (555) 987-6543',
    projectId: 'p2',
    projectTitle: 'Mobile App Wireframes',
    status: InvoiceStatus.sent,
    items: const [
      LineItemModel(
        id: 'li-4',
        description: 'Checkout Flow Wireframes',
        category: 'UI/UX',
        amount: 1850.0,
      ),
    ],
    subtotal: 1850.0,
    taxRate: 0.0,
    taxAmount: 0.0,
    discountAmount: 0.0,
    totalAmount: 1850.0,
    amountPaid: 0.0,
    issueDate: DateTime.now().subtract(const Duration(days: 4)),
    dueDate: DateTime.now().add(const Duration(days: 10)),
    paymentTerms: 'Net 14',
  ),
  InvoiceModel(
    id: 'inv-1022',
    invoiceNumber: '#1022',
    clientId: 'c3',
    clientName: 'Marcus Thorne',
    clientEmail: 'm.thorne@greenhorizon.org',
    clientPhone: '+1 (555) 456-7890',
    projectId: 'p3',
    projectTitle: 'Sustainability Dashboard',
    status: InvoiceStatus.paid,
    items: const [
      LineItemModel(
        id: 'li-5',
        description: 'ESG Analytics Dashboard Frontend',
        category: 'Engineering',
        amount: 4500.0,
      ),
    ],
    subtotal: 4500.0,
    taxRate: 0.0,
    taxAmount: 0.0,
    discountAmount: 0.0,
    totalAmount: 4500.0,
    amountPaid: 4500.0,
    issueDate: DateTime.now().subtract(const Duration(days: 35)),
    dueDate: DateTime.now().subtract(const Duration(days: 20)),
    paidAt: DateTime.now().subtract(const Duration(days: 21)),
    paymentTerms: 'Net 15',
  ),
  InvoiceModel(
    id: 'inv-1021',
    invoiceNumber: '#1021',
    clientId: 'c4',
    clientName: 'Elena Rodriguez',
    clientEmail: 'elena@vibemedia.co',
    clientPhone: '+1 (555) 321-7654',
    status: InvoiceStatus.overdue,
    items: const [
      LineItemModel(
        id: 'li-6',
        description: 'Short-Form Motion Graphics Package',
        category: 'Video',
        amount: 1250.0,
      ),
    ],
    subtotal: 1250.0,
    taxRate: 0.0,
    taxAmount: 0.0,
    discountAmount: 0.0,
    totalAmount: 1250.0,
    amountPaid: 0.0,
    issueDate: DateTime.now().subtract(const Duration(days: 20)),
    dueDate: DateTime.now().subtract(const Duration(days: 5)),
    paymentTerms: 'Net 15',
    lastReminderSentAt: DateTime.now().subtract(const Duration(days: 1)),
    reminderCount: 1,
  ),
];
