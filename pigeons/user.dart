import 'package:pigeon/pigeon.dart';

class User {
  final String userId;
  final String? name;
  final String? email;
  final bool? isActive;
  final bool? isLocked;
  final bool? isOnboarded;
  final String? centerName;
  final String? centerId;
  final String? machineName;
  final String? machineId;
  final String? failedAttempts;
  final String? errorMessage;

  User({
    required this.userId,
    this.name,
    this.email,
    this.isActive,
    this.isLocked,
    this.isOnboarded,
    this.centerName,
    this.centerId,
    this.machineName,
    this.machineId,
    this.failedAttempts,
    this.errorMessage,
  });
}

@HostApi()
abstract class UserApi {
  User getUser(String username);
}
