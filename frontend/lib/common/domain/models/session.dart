class Session {
  final String? server;
  final String? username;
  final String? publicId;
  final String? jwt;
  final bool? isAdmin;
  final String? role;
  final int? credit;
  final int? timeUnits;
  final String? contact;
  final String? tutoring;

  Session({
    this.server,
    this.username,
    this.publicId,
    this.jwt,
    this.isAdmin,
    this.role,
    this.credit,
    this.timeUnits,
    this.contact,
    this.tutoring,
  });

  Session copyWith({
    String? server,
    String? username,
    String? publicId,
    String? jwt,
    bool? isAdmin,
    String? role,
    int? credit,
    int? timeUnits,
    String? contact,
    String? tutoring,
  }) =>
      Session(
        server: server ?? this.server,
        username: username ?? this.username,
        publicId: publicId ?? this.publicId,
        jwt: jwt ?? this.jwt,
        isAdmin: isAdmin ?? this.isAdmin,
        role: role ?? this.role,
        credit: credit ?? this.credit,
        timeUnits: timeUnits ?? this.timeUnits,
        contact: contact ?? this.contact,
        tutoring: tutoring ?? this.tutoring,
      );

  factory Session.fromJson(final Map<String, dynamic> json) => Session(
        server: json["server"],
        username: json["name"],
        publicId: json["public_id"],
        jwt: json["token"],
        isAdmin: json["admin"],
        role: json["role"],
        credit: json["credit"],
        timeUnits: json["time_units"],
        contact: json["contact"],
        tutoring: json["tutoring"],
      );

  Map<String, dynamic> toJson() => {
        "server": server,
        "name": username,
        "public_id": publicId,
        "token": jwt,
        "admin": isAdmin,
        "role": role,
        "credit": credit,
        "time_units": timeUnits,
        "contact": contact,
        "tutoring": tutoring,
      };

  bool get isAuthenticated => username != null && jwt != null;
}
