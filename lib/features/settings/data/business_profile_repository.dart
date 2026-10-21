import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/business_profile_model.dart';
import '../../auth/data/auth_repository.dart';

final businessProfileRepositoryProvider = Provider<BusinessProfileRepository>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return BusinessProfileRepository(auth, FirebaseFirestore.instance);
});

final businessProfileStreamProvider = StreamProvider<BusinessProfileModel>((ref) {
  final repo = ref.watch(businessProfileRepositoryProvider);
  return repo.streamProfile();
});

class BusinessProfileRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  BusinessProfileRepository(this._auth, this._firestore);

  String? get _uid => _auth.currentUser?.uid;

  Stream<BusinessProfileModel> streamProfile() {
    final uid = _uid;
    if (uid == null) {
      return Stream.value(_kDefaultProfile);
    }

    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists) {
        return _kDefaultProfile.copyWith(uid: uid);
      }
      return BusinessProfileModel.fromFirestore(doc);
    });
  }

  Future<BusinessProfileModel> getProfile() async {
    final uid = _uid;
    if (uid == null) return _kDefaultProfile;

    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) {
      return _kDefaultProfile.copyWith(uid: uid);
    }
    return BusinessProfileModel.fromFirestore(doc);
  }

  Future<void> updateProfile(BusinessProfileModel profile) async {
    final uid = _uid;
    if (uid == null) return;

    await _firestore.collection('users').doc(uid).set(
          profile.toMap(),
          SetOptions(merge: true),
        );
  }
}

final _kDefaultProfile = BusinessProfileModel(
  uid: 'default-user',
  fullName: 'Sarah Johnson',
  businessName: 'Brightside Cafe',
  email: 'sarah@brightside.cafe',
  phone: '+1 (555) 234-5678',
  address: '742 Evergreen Terrace, Portland, OR 97204',
  website: 'https://brightside.cafe',
  currencyCode: 'USD',
  currencySymbol: '\$',
  paymentTerms: 'Net 15',
  taxNumber: 'TAX-8829-US',
  bankDetails: 'Chase Bank • Account: **** 4892 • Routing: **** 1029',
);
