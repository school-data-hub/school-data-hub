class MatrixCredentials {
  final String url;
  final String matrixToken;
  final String policyToken;
  final List<String> compulsorayRooms;

  MatrixCredentials(
      {required this.url,
      required this.matrixToken,
      required this.policyToken,
      required this.compulsorayRooms});

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'matrixToken': matrixToken,
      'policyToken': policyToken,
    };
  }

  factory MatrixCredentials.fromJson(Map<String, dynamic> json) {
    return MatrixCredentials(
      url: json['url'] as String,
      matrixToken: json['matrixToken'] as String,
      policyToken: json['policyToken'] as String,
      compulsorayRooms: json['compulsorayRooms'] as List<String>,
    );
  }
}
