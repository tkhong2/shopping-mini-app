import 'package:flutter/foundation.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';

class ProfileProvider extends ChangeNotifier {
  final GetProfileUseCase getProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;

  ProfileProvider({
    required this.getProfileUseCase,
    required this.updateProfileUseCase,
  });

  UserProfileEntity? _profile;
  bool _isLoading = false;
  String? _error;

  UserProfileEntity? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadProfile(String userId) async {
    _setLoading(true);
    _clearError();

    final result = await getProfileUseCase(GetProfileParams(userId: userId));

    result.fold(
      (failure) => _setError(failure.message),
      (profile) => _setProfile(profile),
    );

    _setLoading(false);
  }

  Future<void> updateProfile(UserProfileEntity profile) async {
    _setLoading(true);
    _clearError();

    final result = await updateProfileUseCase(UpdateProfileParams(profile: profile));

    result.fold(
      (failure) => _setError(failure.message),
      (updatedProfile) => _setProfile(updatedProfile),
    );

    _setLoading(false);
  }

  void _setProfile(UserProfileEntity profile) {
    _profile = profile;
    notifyListeners();
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
    notifyListeners();
  }

  void clearProfile() {
    _profile = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}