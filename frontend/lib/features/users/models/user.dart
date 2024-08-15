class User {
  final bool admin;
  final String? contact;
  final int credit;
  final String name;
  final String publicId;
  final String role;
  final int timeUnits;
  final String? tutoring;

  User({
    required this.admin,
    this.contact,
    required this.credit,
    required this.name,
    required this.publicId,
    required this.role,
    required this.timeUnits,
    this.tutoring,
  });

  User copyWith({
    bool? admin,
    String? contact,
    int? credit,
    String? name,
    String? publicId,
    String? role,
    int? timeUnits,
    String? tutoring,
  }) {
    return User(
      admin: admin ?? this.admin,
      contact: contact ?? this.contact,
      credit: credit ?? this.credit,
      name: name ?? this.name,
      publicId: publicId ?? this.publicId,
      role: role ?? this.role,
      timeUnits: timeUnits ?? this.timeUnits,
      tutoring: tutoring ?? this.tutoring,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      admin: json['admin'],
      contact: json['contact'],
      credit: json['credit'],
      name: json['name'],
      publicId: json['publicId'],
      role: json['role'],
      timeUnits: json['timeUnits'],
      tutoring: json['tutoring'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'admin': admin,
      'contact': contact,
      'credit': credit,
      'name': name,
      'publicId': publicId,
      'role': role,
      'timeUnits': timeUnits,
      'tutoring': tutoring,
    };
  }
}
