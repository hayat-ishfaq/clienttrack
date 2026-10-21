import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/client_model.dart';
import '../../auth/data/auth_repository.dart';

final clientRepositoryProvider = Provider<ClientRepository>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return ClientRepository(auth, FirebaseFirestore.instance);
});

final clientsStreamProvider = StreamProvider<List<ClientModel>>((ref) {
  final repo = ref.watch(clientRepositoryProvider);
  return repo.streamClients();
});

final clientByIdProvider = FutureProvider.family<ClientModel?, String>((ref, id) {
  final repo = ref.watch(clientRepositoryProvider);
  return repo.getClient(id);
});

class ClientRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  ClientRepository(this._auth, this._firestore);

  String? get _uid => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>>? get _clientsCollection {
    final uid = _uid;
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid).collection('clients');
  }

  Stream<List<ClientModel>> streamClients() {
    final collection = _clientsCollection;
    if (collection == null) {
      // Yield default mock data if unauthenticated for seamless preview
      return Stream.value(kSeedClients);
    }

    return collection
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return kSeedClients;
      }
      return snapshot.docs
          .map((doc) => ClientModel.fromFirestore(doc))
          .toList();
    });
  }

  Future<ClientModel?> getClient(String id) async {
    final collection = _clientsCollection;
    if (collection == null) {
      return kSeedClients.firstWhere(
        (c) => c.id == id,
        orElse: () => kSeedClients.first,
      );
    }

    final doc = await collection.doc(id).get();
    if (!doc.exists) {
      return kSeedClients.cast<ClientModel?>().firstWhere(
            (c) => c?.id == id,
            orElse: () => null,
          );
    }
    return ClientModel.fromFirestore(doc);
  }

  Future<String> addClient(ClientModel client) async {
    final collection = _clientsCollection;
    if (collection == null) return client.id;

    final docRef = await collection.add(client.toMap());
    return docRef.id;
  }

  Future<void> updateClient(ClientModel client) async {
    final collection = _clientsCollection;
    if (collection == null) return;

    await collection.doc(client.id).set(client.toMap(), SetOptions(merge: true));
  }

  Future<void> deleteClient(String id) async {
    final collection = _clientsCollection;
    if (collection == null) return;

    await collection.doc(id).delete();
  }

  Future<void> toggleStar(String id, bool hasStar) async {
    final collection = _clientsCollection;
    if (collection == null) return;

    await collection.doc(id).update({
      'hasStar': hasStar,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}

// Default rich seed data for offline / preview states
final kSeedClients = <ClientModel>[
  ClientModel(
    id: 'c1',
    name: 'Alex Rivera',
    company: 'Studio Arc',
    role: 'Creative Director',
    email: 'alex@studioarc.com',
    phone: '+1 (555) 234-5678',
    status: ClientStatus.active,
    website: 'https://studioarc.com',
    address: '142 Market St, San Francisco, CA',
    notes: 'Key brand partner. Monthly retainer client.',
    projectCount: 3,
    hasStar: true,
    createdAt: DateTime.now().subtract(const Duration(days: 60)),
    updatedAt: DateTime.now().subtract(const Duration(days: 2)),
  ),
  ClientModel(
    id: 'c2',
    name: 'Sarah Chen',
    company: 'TechFlow Inc.',
    role: 'Product Manager',
    email: 'sarah.c@techflow.io',
    phone: '+1 (555) 987-6543',
    status: ClientStatus.pending,
    website: 'https://techflow.io',
    address: '88 King St, Austin, TX',
    notes: 'New contract pending sign-off.',
    projectCount: 1,
    hasStar: false,
    createdAt: DateTime.now().subtract(const Duration(days: 14)),
    updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
  ),
  ClientModel(
    id: 'c3',
    name: 'Marcus Thorne',
    company: 'Green Horizon',
    role: 'VP Operations',
    email: 'm.thorne@greenhorizon.org',
    phone: '+1 (555) 456-7890',
    status: ClientStatus.active,
    website: 'https://greenhorizon.org',
    address: '500 Pine St, Seattle, WA',
    notes: 'Q4 mobile app redesign underway.',
    projectCount: 4,
    hasStar: true,
    createdAt: DateTime.now().subtract(const Duration(days: 120)),
    updatedAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
  ClientModel(
    id: 'c4',
    name: 'Elena Rodriguez',
    company: 'Vibe Media',
    role: 'Founder & CEO',
    email: 'elena@vibemedia.co',
    phone: '+1 (555) 321-7654',
    status: ClientStatus.active,
    website: 'https://vibemedia.co',
    address: '12 Ocean Blvd, Miami, FL',
    notes: 'Annual social media campaign assets.',
    projectCount: 2,
    hasStar: false,
    createdAt: DateTime.now().subtract(const Duration(days: 45)),
    updatedAt: DateTime.now().subtract(const Duration(days: 3)),
  ),
  ClientModel(
    id: 'c5',
    name: 'David Kim',
    company: 'Apex Design',
    role: 'Lead Architect',
    email: 'david@apexdesign.com',
    phone: '+1 (555) 654-3210',
    status: ClientStatus.inactive,
    website: 'https://apexdesign.com',
    address: '22 Elm St, Chicago, IL',
    notes: 'Project completed in August. Awaiting new fiscal budget.',
    projectCount: 1,
    hasStar: false,
    createdAt: DateTime.now().subtract(const Duration(days: 180)),
    updatedAt: DateTime.now().subtract(const Duration(days: 30)),
  ),
];
