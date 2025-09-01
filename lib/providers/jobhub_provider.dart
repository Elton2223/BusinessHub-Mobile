import 'package:flutter/foundation.dart';
import '../model/jobhub_model.dart';
import '../services/jobhub_service.dart';

class JobhubProvider with ChangeNotifier {
  List<JobhubModel> _allJobhubs = [];
  List<JobhubModel> _availableJobhubs = [];
  List<JobhubModel> _activeJobhubs = [];
  List<JobhubModel> _completedJobhubs = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<JobhubModel> get allJobhubs => _allJobhubs;
  List<JobhubModel> get availableJobhubs => _availableJobhubs;
  List<JobhubModel> get activeJobhubs => _activeJobhubs;
  List<JobhubModel> get completedJobhubs => _completedJobhubs;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get jobhubs by category
  List<JobhubModel> getJobhubsByCategory(String category) {
    return _allJobhubs.where((jobhub) => 
      jobhub.category.toLowerCase() == category.toLowerCase()
    ).toList();
  }

  // Get unique categories
  List<String> get uniqueCategories {
    return _allJobhubs.map((jobhub) => jobhub.category).toSet().toList();
  }

  // Load all jobhubs
  Future<void> loadAllJobhubs() async {
    _setLoading(true);
    _clearError();

    try {
      final jobhubs = await JobhubService.getAllJobhubs();
      _allJobhubs = jobhubs;
      _categorizeJobhubs();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Load available jobhubs only
  Future<void> loadAvailableJobhubs() async {
    _setLoading(true);
    _clearError();

    try {
      final jobhubs = await JobhubService.getAvailableJobhubs();
      _availableJobhubs = jobhubs;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Load active jobhubs only
  Future<void> loadActiveJobhubs() async {
    _setLoading(true);
    _clearError();

    try {
      final jobhubs = await JobhubService.getActiveJobhubs();
      _activeJobhubs = jobhubs;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Load jobhubs by category
  Future<void> loadJobhubsByCategory(String category) async {
    _setLoading(true);
    _clearError();

    try {
      final jobhubs = await JobhubService.getJobhubsByCategory(category);
      // Update the specific category in all jobhubs
      _allJobhubs.removeWhere((jobhub) => 
        jobhub.category.toLowerCase() == category.toLowerCase()
      );
      _allJobhubs.addAll(jobhubs);
      _categorizeJobhubs();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Create new jobhub
  Future<bool> createJobhub(JobhubModel jobhub) async {
    _setLoading(true);
    _clearError();

    try {
      final newJobhub = await JobhubService.createJobhub(jobhub);
      _allJobhubs.add(newJobhub);
      _categorizeJobhubs();
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update jobhub
  Future<bool> updateJobhub(int id, JobhubModel jobhub) async {
    _setLoading(true);
    _clearError();

    try {
      await JobhubService.updateJobhub(id, jobhub);
      
      // Update in local list
      final index = _allJobhubs.indexWhere((j) => j.id == id);
      if (index != -1) {
        _allJobhubs[index] = jobhub;
        _categorizeJobhubs();
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete jobhub
  Future<bool> deleteJobhub(int id) async {
    _setLoading(true);
    _clearError();

    try {
      await JobhubService.deleteJobhub(id);
      
      // Remove from local lists
      _allJobhubs.removeWhere((j) => j.id == id);
      _categorizeJobhubs();
      notifyListeners();
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Refresh all data
  Future<void> refreshData() async {
    await loadAllJobhubs();
  }

  // Search jobhubs
  List<JobhubModel> searchJobhubs(String query) {
    if (query.isEmpty) return _allJobhubs;
    
    return _allJobhubs.where((jobhub) =>
      jobhub.title.toLowerCase().contains(query.toLowerCase()) ||
      jobhub.category.toLowerCase().contains(query.toLowerCase()) ||
      jobhub.city.toLowerCase().contains(query.toLowerCase()) ||
      jobhub.description?.toLowerCase().contains(query.toLowerCase()) == true
    ).toList();
  }

  // Private helper methods
  void _categorizeJobhubs() {
    _availableJobhubs = _allJobhubs.where((j) => j.isAvailable).toList();
    _activeJobhubs = _allJobhubs.where((j) => j.isInProgress).toList();
    _completedJobhubs = _allJobhubs.where((j) => j.isCompleted).toList();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  // Clear all data
  void clearData() {
    _allJobhubs.clear();
    _availableJobhubs.clear();
    _activeJobhubs.clear();
    _completedJobhubs.clear();
    _error = null;
    notifyListeners();
  }
}
