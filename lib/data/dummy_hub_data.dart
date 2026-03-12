import 'dart:math';
import '../model/jobhub_model.dart';
import '../model/hub_application_model.dart';
import '../model/notification_model.dart';
import '../model/rating_model.dart';
import '../model/work_session_model.dart';
import '../model/payment_proof_model.dart';
import '../model/job_history_model.dart';
import '../model/pocket_transaction_model.dart';
import '../model/bank_detail_model.dart';

/// In-memory dummy data for hubs, applications, notifications, ratings.
/// Used when [EnvConfig.useMockData] is true. Replace with API calls in services.
class DummyHubData {
  static int _hubIdCounter = 100;
  static int _appIdCounter = 1;
  static int _notifIdCounter = 1;
  static int _ratingIdCounter = 1;

  static final List<JobhubModel> _hubs = [];
  static final List<HubApplicationModel> _applications = [];
  static final List<NotificationModel> _notifications = [];
  static final List<RatingModel> _ratings = [];
  static final List<WorkSessionModel> _workSessions = [];
  static final List<PaymentProofModel> _paymentProofs = [];
  static final List<JobHistoryModel> _jobHistory = [];
  static final List<Map<String, dynamic>> _dummyUsers = [];
  static final Map<String, double> _pocketBalances = {};
  static final List<PocketTransactionModel> _pocketTransactions = [];
  static final List<BankDetailModel> _bankDetails = [];

  static int _sessionIdCounter = 1;
  static int _paymentIdCounter = 1;
  static int _historyIdCounter = 1;
  static int _pocketTxIdCounter = 1;
  static int _bankDetailIdCounter = 1;
  static bool _seeded = false;

  static void seed() {
    if (_seeded) return;
    _seeded = true;

    // Dummy users (simulate other users; current user comes from AuthProvider)
    _dummyUsers.addAll([
      {'id': '1', 'name': 'Alice', 'surname': 'Smith', 'email': 'alice@example.com', 'city': 'Johannesburg', 'latitude': -26.2041, 'longitude': 28.0473},
      {'id': '2', 'name': 'Bob', 'surname': 'Jones', 'email': 'bob@example.com', 'city': 'Cape Town', 'latitude': -33.9249, 'longitude': 18.4241},
      {'id': '3', 'name': 'Carol', 'surname': 'Williams', 'email': 'carol@example.com', 'city': 'Durban', 'latitude': -29.8587, 'longitude': 31.0218},
      {'id': '4', 'name': 'Dave', 'surname': 'Brown', 'email': 'dave@example.com', 'city': 'Pretoria', 'latitude': -25.7479, 'longitude': 28.2293},
    ]);

    // Seed hubs in different areas
    final hubTitles = [
      ('Web Development', 'Technology', 'Johannesburg', -26.2041, 28.0473, 2500),
      ('House Cleaning', 'Services', 'Cape Town', -33.9249, 18.4241, 350),
      ('Math Tutoring', 'Education', 'Pretoria', -25.7479, 28.2293, 300),
      ('Graphic Design', 'Creative', 'Durban', -29.8587, 31.0218, 1200),
      ('Plumbing', 'Construction', 'Johannesburg', -26.2050, 28.0480, 1500),
      ('Garden Maintenance', 'Services', 'Cape Town', -33.9300, 18.4200, 450),
      ('Mobile App Dev', 'Technology', 'Pretoria', -25.7480, 28.2300, 4500),
      ('Photography', 'Creative', 'Durban', -29.8600, 31.0200, 1800),
      ('Financial Consulting', 'Finance', 'Johannesburg', -26.2030, 28.0460, 3000),
      ('Marketing Strategy', 'Marketing', 'Cape Town', -33.9260, 18.4220, 2800),
      ('Electrical Work', 'Construction', 'Pretoria', -25.7460, 28.2280, 2000),
      ('Language Teaching', 'Education', 'Durban', -29.8570, 31.0220, 400),
    ];

    for (var i = 0; i < hubTitles.length; i++) {
      final t = hubTitles[i];
      _hubs.add(JobhubModel(
        id: _hubIdCounter++,
        title: t.$1,
        streetAddress: '${100 + i} Main St',
        country: 'South Africa',
        postalCode: '${1000 + i}',
        state: '',
        city: t.$3,
        latitude: t.$4.toString(),
        longitude: t.$5.toString(),
        category: t.$2,
        paymentType: i % 3 + 1,
        paymentAmount: t.$6.toDouble(),
        description: 'Dummy description for ${t.$1}.',
        requirements: 'Requirements: experience preferred.',
        jobStatus: i % 3 == 0 ? 2 : (i % 3 == 1 ? 3 : 1), // mix of available, in progress, completed
        registerId: (i % 4 + 1),
        dateCreated: DateTime.now().subtract(Duration(days: 10 - i)),
      ));
    }
  }

  static List<JobhubModel> getHubs() {
    seed();
    return List.unmodifiable(_hubs);
  }

  static List<JobhubModel> getAvailableHubs() {
    return getHubs().where((h) => h.isAvailable).toList();
  }

  /// Available hubs with closest first. If [userLat] or [userLng] is null, returns unsorted.
  static List<JobhubModel> getAvailableHubsSortedByDistance(double? userLat, double? userLng) {
    final list = getAvailableHubs();
    if (userLat == null || userLng == null) return list;
    final sorted = List<JobhubModel>.from(list);
    sorted.sort((a, b) {
      final latA = double.tryParse(a.latitude) ?? 0.0;
      final lngA = double.tryParse(a.longitude) ?? 0.0;
      final latB = double.tryParse(b.latitude) ?? 0.0;
      final lngB = double.tryParse(b.longitude) ?? 0.0;
      final dA = _haversineKm(userLat, userLng, latA, lngA);
      final dB = _haversineKm(userLat, userLng, latB, lngB);
      return dA.compareTo(dB);
    });
    return sorted;
  }

  /// Hub IDs that have a completed_full session (so they must not appear in active/ongoing lists).
  static Set<int> getHubIdsWithCompletedSession() {
    seed();
    return getWorkSessions()
        .where((s) => s.isCompletedFull)
        .map((s) => s.hubId)
        .toSet();
  }

  /// Hubs that are in progress and do not have a completed_full session (so completed work never appears here).
  static List<JobhubModel> getActiveHubs() {
    seed();
    final completedHubIds = getHubIdsWithCompletedSession();
    return getHubs()
        .where((h) => h.isInProgress && h.id != null && !completedHubIds.contains(h.id))
        .toList();
  }

  static JobhubModel? getHubById(int id) {
    try {
      return getHubs().firstWhere((h) => h.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<JobhubModel> getHubsByCategory(String category) {
    return getHubs().where((h) => h.category.toLowerCase() == category.toLowerCase()).toList();
  }

  /// Hubs created by this user (owner).
  static List<JobhubModel> getHubsByOwner(String userId) {
    return getHubs().where((h) => h.registerId?.toString() == userId).toList();
  }

  static List<JobhubModel> getHubsNear(double? userLat, double? userLng, double radiusKm) {
    final list = getHubs();
    if (userLat == null || userLng == null) return list;
    return list.where((h) {
      final lat = double.tryParse(h.latitude) ?? 0.0;
      final lng = double.tryParse(h.longitude) ?? 0.0;
      return _haversineKm(userLat, userLng, lat, lng) <= radiusKm;
    }).toList();
  }

  static double _haversineKm(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295;
    final a = 0.5 - cos((lat2 - lat1) * p) / 2 + cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // km
  }

  static JobhubModel addHub(JobhubModel hub) {
    seed();
    final newHub = JobhubModel(
      id: _hubIdCounter++,
      title: hub.title,
      streetAddress: hub.streetAddress,
      country: hub.country,
      postalCode: hub.postalCode,
      state: hub.state,
      city: hub.city,
      latitude: hub.latitude,
      longitude: hub.longitude,
      category: hub.category,
      paymentType: hub.paymentType,
      paymentAmount: hub.paymentAmount,
      description: hub.description,
      requirements: hub.requirements,
      jobStatus: hub.jobStatus ?? 1,
      registerId: hub.registerId,
      dateCreated: hub.dateCreated ?? DateTime.now(),
    );
    _hubs.add(newHub);
    return newHub;
  }

  static void updateHub(int id, JobhubModel hub) {
    final i = _hubs.indexWhere((h) => h.id == id);
    if (i >= 0) _hubs[i] = hub;
  }

  static void deleteHub(int id) {
    _hubs.removeWhere((h) => h.id == id);
  }

  // Applications
  static List<HubApplicationModel> getApplications() {
    seed();
    return List.unmodifiable(_applications);
  }

  static List<HubApplicationModel> getApplicationsForHub(int hubId) {
    return getApplications().where((a) => a.hubId == hubId).toList();
  }

  static List<HubApplicationModel> getApplicationsByUser(String userId) {
    return getApplications().where((a) => a.applicantUserId == userId).toList();
  }

  static HubApplicationModel? addApplication(int hubId, String applicantUserId, {String? message}) {
    seed();
    final app = HubApplicationModel(
      id: (_appIdCounter++).toString(),
      hubId: hubId,
      applicantUserId: applicantUserId,
      status: 'pending',
      message: message,
      createdAt: DateTime.now(),
    );
    _applications.add(app);
    return app;
  }

  static void respondToApplication(String applicationId, String status, {String? declineReason}) {
    final i = _applications.indexWhere((a) => a.id == applicationId);
    if (i >= 0) {
      final a = _applications[i];
      _applications[i] = HubApplicationModel(
        id: a.id,
        hubId: a.hubId,
        applicantUserId: a.applicantUserId,
        status: status,
        message: a.message,
        declineReason: status == 'rejected' ? declineReason : null,
        createdAt: a.createdAt,
        respondedAt: DateTime.now(),
      );
    }
  }

  static HubApplicationModel? getApplicationById(String id) {
    try {
      return getApplications().firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  // Notifications
  static List<NotificationModel> getNotificationsForUser(String userId) {
    seed();
    return _notifications.where((n) => n.toUserId == userId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  static int getUnreadCount(String userId) {
    return getNotificationsForUser(userId).where((n) => !n.read).length;
  }

  static void addNotification(NotificationModel n) {
    _notifications.add(n);
  }

  static void createApplicationReceivedNotification({
    required String toUserId,
    required String fromUserId,
    required int hubId,
    required String applicationId,
    required String hubTitle,
    required String applicantName,
  }) {
    addNotification(NotificationModel(
      id: (_notifIdCounter++).toString(),
      type: 'application_received',
      title: 'New application',
      body: '$applicantName applied to your hub "$hubTitle".',
      relatedHubId: hubId.toString(),
      relatedApplicationId: applicationId,
      fromUserId: fromUserId,
      toUserId: toUserId,
      read: false,
      createdAt: DateTime.now(),
    ));
  }

  static void createApplicationRespondedNotification({
    required String toUserId,
    required String type,
    required String hubTitle,
    required String applicationId,
    String? declineReason,
  }) {
    final body = type == 'application_accepted'
        ? 'Your application for "$hubTitle" was accepted.'
        : declineReason != null && declineReason.isNotEmpty
            ? 'Your application for "$hubTitle" was declined. Reason: $declineReason'
            : 'Your application for "$hubTitle" was declined.';
    addNotification(NotificationModel(
      id: (_notifIdCounter++).toString(),
      type: type,
      title: type == 'application_accepted' ? 'Application accepted' : 'Application declined',
      body: body,
      relatedApplicationId: applicationId,
      toUserId: toUserId,
      read: false,
      createdAt: DateTime.now(),
    ));
  }

  /// Remove "application_received" notifications for this application (employer accepted, so it no longer appears or counts).
  static void removeApplicationReceivedForApplication(String applicationId, String toUserId) {
    _notifications.removeWhere((n) =>
        n.type == 'application_received' &&
        n.relatedApplicationId == applicationId &&
        n.toUserId == toUserId);
  }

  static void markNotificationRead(String id) {
    final i = _notifications.indexWhere((n) => n.id == id);
    if (i >= 0) {
      final n = _notifications[i];
      _notifications[i] = NotificationModel(
        id: n.id,
        type: n.type,
        title: n.title,
        body: n.body,
        relatedHubId: n.relatedHubId,
        relatedApplicationId: n.relatedApplicationId,
        fromUserId: n.fromUserId,
        toUserId: n.toUserId,
        read: true,
        createdAt: n.createdAt,
      );
    }
  }

  // Dummy user profile for applicants
  static Map<String, dynamic>? getDummyUser(String userId) {
    seed();
    try {
      return _dummyUsers.firstWhere((u) => u['id'] == userId);
    } catch (_) {
      return null;
    }
  }

  // Ratings
  static List<RatingModel> getRatings() {
    seed();
    return List.unmodifiable(_ratings);
  }

  static List<RatingModel> getRatingsForUser(String userId) {
    return getRatings().where((r) => r.toUserId == userId).toList();
  }

  static RatingModel? addRating(RatingModel r) {
    seed();
    final newR = RatingModel(
      id: (_ratingIdCounter++).toString(),
      hubId: r.hubId,
      fromUserId: r.fromUserId,
      toUserId: r.toUserId,
      rating: r.rating,
      comment: r.comment,
      role: r.role,
      createdAt: r.createdAt,
    );
    _ratings.add(newR);
    return newR;
  }

  // Work sessions
  static List<WorkSessionModel> getWorkSessions() {
    seed();
    return List.unmodifiable(_workSessions);
  }

  static WorkSessionModel? getSessionByHubAndApplication(int hubId, String applicationId) {
    try {
      return _workSessions.firstWhere(
        (s) => s.hubId == hubId && s.applicationId == applicationId,
      );
    } catch (_) {
      return null;
    }
  }

  static WorkSessionModel? getSessionById(String id) {
    try {
      return _workSessions.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Active only: exclude completed_full so completed work does not appear in active/accepted hubs.
  static List<WorkSessionModel> getSessionsForWorker(String workerId) {
    return getWorkSessions()
        .where((s) => s.workerId == workerId && s.isActive && !s.isCompletedFull)
        .toList();
  }

  static List<WorkSessionModel> getSessionsForEmployer(String employerId) {
    return getWorkSessions()
        .where((s) => s.employerId == employerId && s.isActive && !s.isCompletedFull)
        .toList();
  }

  /// Get the work session for a hub (active only; excludes completed_full so completed work is not treated as active).
  static WorkSessionModel? getSessionByHubId(int hubId) {
    try {
      return getWorkSessions()
          .where((s) => s.isActive && !s.isCompletedFull)
          .firstWhere((s) => s.hubId == hubId);
    } catch (_) {
      return null;
    }
  }

  static WorkSessionModel? createSession({
    required int hubId,
    required String applicationId,
    required String workerId,
    required String employerId,
  }) {
    seed();
    final session = WorkSessionModel(
      id: (_sessionIdCounter++).toString(),
      hubId: hubId,
      applicationId: applicationId,
      workerId: workerId,
      employerId: employerId,
      status: 'pending_arrival',
    );
    _workSessions.add(session);
    return session;
  }

  static void updateSession(WorkSessionModel session) {
    final i = _workSessions.indexWhere((s) => s.id == session.id);
    if (i >= 0) _workSessions[i] = session;
  }

  static void setWorkerArrived(String sessionId, double lat, double lng) {
    final s = getSessionById(sessionId);
    if (s == null || !s.isPendingArrival) return;
    updateSession(WorkSessionModel(
      id: s.id,
      hubId: s.hubId,
      applicationId: s.applicationId,
      workerId: s.workerId,
      employerId: s.employerId,
      status: 'arrived_waiting_confirm',
      workerArrivedAt: DateTime.now(),
      lastWorkerLat: lat,
      lastWorkerLng: lng,
    ));
  }

  static void confirmWorkerArrival(String sessionId) {
    final s = getSessionById(sessionId);
    if (s == null || !s.isArrivedWaitingConfirm) return;
    updateSession(WorkSessionModel(
      id: s.id,
      hubId: s.hubId,
      applicationId: s.applicationId,
      workerId: s.workerId,
      employerId: s.employerId,
      status: 'in_progress',
      workerArrivedAt: s.workerArrivedAt,
      employerConfirmedArrivalAt: DateTime.now(),
      lastWorkerLat: s.lastWorkerLat,
      lastWorkerLng: s.lastWorkerLng,
    ));
  }

  static void setWorkerLeftArea(String sessionId) {
    final s = getSessionById(sessionId);
    if (s == null || !s.isInProgress) return;
    updateSession(WorkSessionModel(
      id: s.id,
      hubId: s.hubId,
      applicationId: s.applicationId,
      workerId: s.workerId,
      employerId: s.employerId,
      status: s.status,
      workerArrivedAt: s.workerArrivedAt,
      employerConfirmedArrivalAt: s.employerConfirmedArrivalAt,
      lastWorkerLat: s.lastWorkerLat,
      lastWorkerLng: s.lastWorkerLng,
      workerLeftAreaAt: DateTime.now(),
    ));
  }

  static void completeSession(String sessionId, String completionType) {
    final s = getSessionById(sessionId);
    if (s == null) return;
    updateSession(WorkSessionModel(
      id: s.id,
      hubId: s.hubId,
      applicationId: s.applicationId,
      workerId: s.workerId,
      employerId: s.employerId,
      status: completionType == 'full' ? 'completed_full' : 'completed_today',
      workerArrivedAt: s.workerArrivedAt,
      employerConfirmedArrivalAt: s.employerConfirmedArrivalAt,
      completedAt: DateTime.now(),
      completionType: completionType,
      lastWorkerLat: s.lastWorkerLat,
      lastWorkerLng: s.lastWorkerLng,
      workerLeftAreaAt: s.workerLeftAreaAt,
    ));
    // When job is fully completed, mark hub as completed so it leaves "Active/Ongoing" lists.
    if (completionType == 'full') {
      final hub = getHubById(s.hubId);
      if (hub != null && hub.id != null) {
        updateHub(hub.id!, JobhubModel(
          id: hub.id,
          title: hub.title,
          streetAddress: hub.streetAddress,
          country: hub.country,
          postalCode: hub.postalCode,
          state: hub.state,
          city: hub.city,
          latitude: hub.latitude,
          longitude: hub.longitude,
          category: hub.category,
          paymentType: hub.paymentType,
          paymentAmount: hub.paymentAmount,
          description: hub.description,
          requirements: hub.requirements,
          jobStatus: 3, // completed
          registerId: hub.registerId,
          dateCreated: hub.dateCreated,
          dateAccepted: hub.dateAccepted,
          dateFinished: DateTime.now(),
          review: hub.review,
          reviewRating: hub.reviewRating,
        ));
      }
    }
  }

  static void addNotificationForEmployer(String type, String employerId, String body, {String? hubId, String? sessionId}) {
    addNotification(NotificationModel(
      id: (_notifIdCounter++).toString(),
      type: type,
      title: type == 'worker_arrived' ? 'Worker has arrived' : type == 'worker_left_area' ? 'Worker left the area' : type,
      body: body,
      relatedHubId: hubId,
      toUserId: employerId,
      read: false,
      createdAt: DateTime.now(),
    ));
  }

  static void addNotificationForWorker(String type, String workerId, String body, {String? hubId, String? sessionId}) {
    addNotification(NotificationModel(
      id: (_notifIdCounter++).toString(),
      type: type,
      title: type == 'payment_sent' ? 'Payment proof submitted' : type == 'session_completed' ? 'Work completed' : type,
      body: body,
      relatedHubId: hubId,
      toUserId: workerId,
      read: false,
      createdAt: DateTime.now(),
    ));
  }

  // Payment proofs
  static List<PaymentProofModel> getPaymentProofs() {
    seed();
    return List.unmodifiable(_paymentProofs);
  }

  static PaymentProofModel? getPaymentProofBySession(String sessionId) {
    try {
      return _paymentProofs.firstWhere((p) => p.sessionId == sessionId);
    } catch (_) {
      return null;
    }
  }

  static PaymentProofModel? getPaymentProofByHub(int hubId) {
    try {
      return _paymentProofs.firstWhere((p) => p.hubId == hubId);
    } catch (_) {
      return null;
    }
  }

  static PaymentProofModel submitEmployerProof({
    required int hubId,
    required String sessionId,
    required double amount,
    required String proofDescription,
  }) {
    seed();
    var p = getPaymentProofBySession(sessionId);
    if (p != null) {
      final updated = PaymentProofModel(
        id: p.id,
        hubId: p.hubId,
        sessionId: p.sessionId,
        amount: p.amount,
        employerProofDescription: proofDescription,
        employerSubmittedAt: DateTime.now(),
        clientProofDescription: p.clientProofDescription,
        clientConfirmedAt: p.clientConfirmedAt,
      );
      final i = _paymentProofs.indexWhere((x) => x.sessionId == sessionId);
      if (i >= 0) _paymentProofs[i] = updated;
      return updated;
    }
    p = PaymentProofModel(
      id: (_paymentIdCounter++).toString(),
      hubId: hubId,
      sessionId: sessionId,
      amount: amount,
      employerProofDescription: proofDescription,
      employerSubmittedAt: DateTime.now(),
    );
    _paymentProofs.add(p);
    return p;
  }

  static PaymentProofModel? submitClientProof(String sessionId, String proofDescription) {
    final i = _paymentProofs.indexWhere((p) => p.sessionId == sessionId);
    if (i < 0) return null;
    final p = _paymentProofs[i];
    final updated = PaymentProofModel(
      id: p.id,
      hubId: p.hubId,
      sessionId: p.sessionId,
      amount: p.amount,
      employerProofDescription: p.employerProofDescription,
      employerSubmittedAt: p.employerSubmittedAt,
      clientProofDescription: proofDescription,
      clientConfirmedAt: DateTime.now(),
    );
    _paymentProofs[i] = updated;
    return updated;
  }

  // Job history (worker) – kept for backwards compatibility
  static List<JobHistoryModel> getJobHistoryForWorker(String workerId) {
    return getJobHistoryForUser(workerId, roleFilter: 'worker');
  }

  /// All completed jobs for user (as worker or employer). roleFilter: 'all' | 'worker' | 'employer'.
  static List<JobHistoryModel> getJobHistoryForUser(String userId, {String roleFilter = 'all'}) {
    seed();
    List<JobHistoryModel> list;
    switch (roleFilter) {
      case 'worker':
        list = _jobHistory.where((h) => h.workerId == userId).toList();
        break;
      case 'employer':
        list = _jobHistory.where((h) => h.employerId == userId).toList();
        break;
      default:
        list = _jobHistory.where((h) => h.workerId == userId || h.employerId == userId).toList();
    }
    list.sort((a, b) => b.completedAt.compareTo(a.completedAt));
    return list;
  }

  /// Paginated job history for user. Returns [list] (page of items) and [total] count for current filter.
  static Map<String, dynamic> getJobHistoryForUserPaginated(String userId, {String roleFilter = 'all', int page = 0, int pageSize = 10}) {
    final all = getJobHistoryForUser(userId, roleFilter: roleFilter);
    final total = all.length;
    final start = (page * pageSize).clamp(0, total);
    final end = (start + pageSize).clamp(0, total);
    final list = all.sublist(start, end);
    return {'list': list, 'total': total};
  }

  static JobHistoryModel addJobHistory({
    required int hubId,
    required String hubTitle,
    required String employerId,
    required String workerId,
    required double paymentAmount,
  }) {
    seed();
    final h = JobHistoryModel(
      id: (_historyIdCounter++).toString(),
      hubId: hubId,
      hubTitle: hubTitle,
      employerId: employerId,
      workerId: workerId,
      paymentAmount: paymentAmount,
      completedAt: DateTime.now(),
      paymentReceived: true,
      ratingGiven: false,
    );
    _jobHistory.add(h);
    return h;
  }

  static void markHistoryRatingGiven(String historyId) {
    final i = _jobHistory.indexWhere((h) => h.id == historyId);
    if (i >= 0) {
      final h = _jobHistory[i];
      _jobHistory[i] = JobHistoryModel(
        id: h.id,
        hubId: h.hubId,
        hubTitle: h.hubTitle,
        employerId: h.employerId,
        workerId: h.workerId,
        paymentAmount: h.paymentAmount,
        completedAt: h.completedAt,
        paymentReceived: h.paymentReceived,
        ratingGiven: true,
      );
    }
  }

  // ---------- App Pocket ----------
  static double getPocketBalance(String userId) {
    seed();
    return _pocketBalances[userId] ?? 0.0;
  }

  static void addPocketEarning(String userId, double amount, int hubId, [String? description]) {
    seed();
    final id = (_pocketTxIdCounter++).toString();
    _pocketTransactions.insert(0, PocketTransactionModel(
      id: id,
      userId: userId,
      type: 'earning',
      amount: amount,
      description: description ?? 'Job completed',
      referenceId: hubId.toString(),
      createdAt: DateTime.now(),
      status: 'completed',
    ));
    _pocketBalances[userId] = ( _pocketBalances[userId] ?? 0.0) + amount;
  }

  static void addPocketDeposit(String userId, double amount, [String? description]) {
    seed();
    final id = (_pocketTxIdCounter++).toString();
    _pocketTransactions.insert(0, PocketTransactionModel(
      id: id,
      userId: userId,
      type: 'deposit',
      amount: amount,
      description: description ?? 'Deposit to App Pocket',
      createdAt: DateTime.now(),
      status: 'completed',
    ));
    _pocketBalances[userId] = (_pocketBalances[userId] ?? 0.0) + amount;
  }

  static List<PocketTransactionModel> getPocketTransactions(String userId) {
    seed();
    return _pocketTransactions.where((t) => t.userId == userId).toList();
  }

  static List<BankDetailModel> getBankDetails(String userId) {
    seed();
    return _bankDetails.where((b) => b.userId == userId).toList();
  }

  static BankDetailModel? addBankDetail({
    required String userId,
    required String accountHolderName,
    required String bankName,
    required String accountNumber,
    required String branchCode,
    String? accountType,
  }) {
    seed();
    final id = (_bankDetailIdCounter++).toString();
    final b = BankDetailModel(
      id: id,
      userId: userId,
      accountHolderName: accountHolderName,
      bankName: bankName,
      accountNumber: accountNumber,
      branchCode: branchCode,
      accountType: accountType,
    );
    _bankDetails.add(b);
    return b;
  }

  static bool withdrawToBank(String userId, double amount, String bankDetailId) {
    seed();
    final balance = _pocketBalances[userId] ?? 0.0;
    if (amount <= 0 || amount > balance) return false;
    final id = (_pocketTxIdCounter++).toString();
    _pocketTransactions.insert(0, PocketTransactionModel(
      id: id,
      userId: userId,
      type: 'withdrawal',
      amount: amount,
      description: 'Withdrawal to bank',
      referenceId: bankDetailId,
      createdAt: DateTime.now(),
      status: 'completed',
    ));
    _pocketBalances[userId] = balance - amount;
    return true;
  }
}
