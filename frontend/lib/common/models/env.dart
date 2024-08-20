// To parse this JSON data, do
//
//     final encryptionKeys = encryptionKeysFromJson(jsonString);

import 'dart:convert';

Env envFromJson(String str) => Env.fromJson(json.decode(str));

String envToJson(Env data) => json.encode(data.toJson());

class Env {
  String? server;
  String? key;
  String? iv;
  String? serverUrl;

  Env({
    this.server,
    this.key,
    this.iv,
    this.serverUrl,
  });

  Env copyWith({
    String? server,
    String? key,
    String? iv,
    String? serverUrl,
  }) =>
      Env(
        server: server ?? this.server,
        key: key ?? this.key,
        iv: iv ?? this.iv,
        serverUrl: serverUrl ?? this.serverUrl,
      );

  factory Env.fromJson(Map<String, dynamic> json) => Env(
        server: json["server"],
        key: json["key"],
        iv: json["iv"],
        serverUrl: json["server_url"],
      );

  Map<String, dynamic> toJson() => {
        "server": server,
        "key": key,
        "iv": iv,
        "server_url": serverUrl,
      };
}