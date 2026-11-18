class User {
  final int id;
  final String firstName;
  final String lastName;
  final String? email;
  final String? phone;
  final String? nationality;
  final String role;
  final String? profilePhoto;
  final DateTime? createdAt;

  const User({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.email,
    this.phone,
    this.nationality,
    this.role = 'guest',
    this.profilePhoto,
    this.createdAt,
  });

  String get fullName => '$firstName $lastName';

  factory User.fromJson(Map<String, dynamic> j) => User(
        id: j['id'] as int,
        firstName: j['first_name'] as String? ?? '',
        lastName: j['last_name'] as String? ?? '',
        email: j['email'] as String?,
        phone: j['phone'] as String?,
        nationality: j['nationality'] as String?,
        role: j['role'] as String? ?? 'guest',
        profilePhoto: j['profile_photo'] as String?,
        createdAt: j['created_at'] != null
            ? DateTime.tryParse(j['created_at'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone': phone,
        'nationality': nationality,
        'role': role,
        'profile_photo': profilePhoto,
      };

  User copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? nationality,
    String? profilePhoto,
  }) =>
      User(
        id: id,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        nationality: nationality ?? this.nationality,
        role: role,
        profilePhoto: profilePhoto ?? this.profilePhoto,
        createdAt: createdAt,
      );
}
