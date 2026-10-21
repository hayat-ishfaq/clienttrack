import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/project_model.dart';
import '../../auth/data/auth_repository.dart';

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return ProjectRepository(auth, FirebaseFirestore.instance);
});

final projectsStreamProvider = StreamProvider<List<ProjectModel>>((ref) {
  final repo = ref.watch(projectRepositoryProvider);
  return repo.streamProjects();
});

final clientProjectsStreamProvider =
    StreamProvider.family<List<ProjectModel>, String>((ref, clientId) {
  final repo = ref.watch(projectRepositoryProvider);
  return repo.streamProjectsForClient(clientId);
});

final projectByIdProvider =
    FutureProvider.family<ProjectModel?, String>((ref, id) {
  final repo = ref.watch(projectRepositoryProvider);
  return repo.getProject(id);
});

class ProjectRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  ProjectRepository(this._auth, this._firestore);

  String? get _uid => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>>? get _projectsCollection {
    final uid = _uid;
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid).collection('projects');
  }

  Stream<List<ProjectModel>> streamProjects() {
    final collection = _projectsCollection;
    if (collection == null) {
      return Stream.value(kSeedProjects);
    }

    return collection
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return kSeedProjects;
      }
      return snapshot.docs
          .map((doc) => ProjectModel.fromFirestore(doc))
          .toList();
    });
  }

  Stream<List<ProjectModel>> streamProjectsForClient(String clientId) {
    final collection = _projectsCollection;
    if (collection == null) {
      return Stream.value(
        kSeedProjects.where((p) => p.clientId == clientId).toList(),
      );
    }

    return collection
        .where('clientId', isEqualTo: clientId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return kSeedProjects.where((p) => p.clientId == clientId).toList();
      }
      return snapshot.docs
          .map((doc) => ProjectModel.fromFirestore(doc))
          .toList();
    });
  }

  Future<ProjectModel?> getProject(String id) async {
    final collection = _projectsCollection;
    if (collection == null) {
      return kSeedProjects.firstWhere(
        (p) => p.id == id,
        orElse: () => kSeedProjects.first,
      );
    }

    final doc = await collection.doc(id).get();
    if (!doc.exists) {
      return kSeedProjects.cast<ProjectModel?>().firstWhere(
            (p) => p?.id == id,
            orElse: () => null,
          );
    }
    return ProjectModel.fromFirestore(doc);
  }

  Future<String> addProject(ProjectModel project) async {
    final collection = _projectsCollection;
    if (collection == null) return project.id;

    final docRef = await collection.add(project.toMap());
    return docRef.id;
  }

  Future<void> updateProject(ProjectModel project) async {
    final collection = _projectsCollection;
    if (collection == null) return;

    await collection.doc(project.id).set(project.toMap(), SetOptions(merge: true));
  }

  Future<void> deleteProject(String id) async {
    final collection = _projectsCollection;
    if (collection == null) return;

    await collection.doc(id).delete();
  }
}

// Default rich seed projects for preview & offline
final kSeedProjects = <ProjectModel>[
  ProjectModel(
    id: 'p1',
    clientId: 'c1',
    clientName: 'Studio Arc',
    title: 'Brand Identity Design',
    description: 'Complete brand guidelines, design system, and vector asset generation.',
    status: ProjectStatus.inProgress,
    rateType: RateType.fixed,
    budget: 3200.0,
    deadline: DateTime.now().add(const Duration(days: 3)),
    progressPct: 0.65,
    autoInvoicingEnabled: true,
    createdAt: DateTime.now().subtract(const Duration(days: 20)),
    updatedAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
  ProjectModel(
    id: 'p2',
    clientId: 'c2',
    clientName: 'TechFlow Inc.',
    title: 'Mobile App Wireframes',
    description: 'High-fidelity Figma wireframes and user interaction flows for mobile checkout.',
    status: ProjectStatus.planning,
    rateType: RateType.hourly,
    budget: 1850.0,
    deadline: DateTime.now().add(const Duration(days: 15)),
    progressPct: 0.18,
    autoInvoicingEnabled: true,
    createdAt: DateTime.now().subtract(const Duration(days: 10)),
    updatedAt: DateTime.now().subtract(const Duration(days: 2)),
  ),
  ProjectModel(
    id: 'p3',
    clientId: 'c3',
    clientName: 'Green Horizon',
    title: 'Sustainability Dashboard',
    description: 'Analytics portal tracking corporate carbon offsets and ESG metrics.',
    status: ProjectStatus.completed,
    rateType: RateType.fixed,
    budget: 4500.0,
    deadline: DateTime.now().subtract(const Duration(days: 7)),
    progressPct: 1.0,
    autoInvoicingEnabled: true,
    createdAt: DateTime.now().subtract(const Duration(days: 45)),
    updatedAt: DateTime.now().subtract(const Duration(days: 7)),
  ),
  ProjectModel(
    id: 'p4',
    clientId: 'c4',
    clientName: 'Vibe Media',
    title: 'Social Video Pack',
    description: '12 short-form animated video templates for social ad rollouts.',
    status: ProjectStatus.onHold,
    rateType: RateType.fixed,
    budget: 1200.0,
    deadline: DateTime.now().add(const Duration(days: 25)),
    progressPct: 0.40,
    autoInvoicingEnabled: false,
    createdAt: DateTime.now().subtract(const Duration(days: 30)),
    updatedAt: DateTime.now().subtract(const Duration(days: 12)),
  ),
];
