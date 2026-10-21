import 'enums.dart';

class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.hasBusiness = false,
    this.isDemo = false,
  });

  final String id;
  final String name;
  final String email;
  final String? avatarUrl;

  /// True once the platform account has completed business onboarding.
  final bool hasBusiness;

  /// True only for the local "explore with demo data" session.
  final bool isDemo;

  factory AppUser.fromJson(Map<String, dynamic> j) => AppUser(
    id: J.s(j['id']),
    name: J.s(j['name']),
    email: J.s(j['email']),
    avatarUrl: j['avatar_url'] as String?,
    hasBusiness: J.b(j['has_business']),
  );

  AppUser copyWith({bool? hasBusiness}) => AppUser(
    id: id,
    name: name,
    email: email,
    avatarUrl: avatarUrl,
    hasBusiness: hasBusiness ?? this.hasBusiness,
    isDemo: isDemo,
  );
}

/// Platform session returned by the backend after login/register/google.
class AuthSession {
  const AuthSession({required this.token, required this.user, this.expiresAt});

  /// Platform session token issued by the Orvex backend. Never a Google token.
  final String token;
  final AppUser user;
  final DateTime? expiresAt;

  factory AuthSession.fromJson(Map<String, dynamic> j) => AuthSession(
    token: J.s(j['token']),
    user: AppUser.fromJson(Map<String, dynamic>.from(j['user'] as Map? ?? {})),
    expiresAt: j['expires_at'] == null ? null : J.dt(j['expires_at']),
  );
}
