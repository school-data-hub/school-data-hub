import 'dart:io';

import 'package:http/http.dart' as http;

enum MatrixRequestType {
  synapse,
  corporal,
}

class MatrixApiClient {
  final String baseUrl;
  final String synapseToken;
  final String corporalToken;

  // Private constructor
  MatrixApiClient._privateConstructor({
    required this.baseUrl,
    required this.synapseToken,
    required this.corporalToken,
  });

  // Static instance
  static MatrixApiClient? _instance;

  // Factory constructor
  factory MatrixApiClient({
    required String baseUrl,
    required String synapseToken,
    required String corporalToken,
  }) {
    _instance ??= MatrixApiClient._privateConstructor(
      baseUrl: baseUrl,
      synapseToken: synapseToken,
      corporalToken: corporalToken,
    );
    return _instance!;
  }

  Future<http.Response> get({
    required String endpoint,
    required MatrixRequestType requestType,
  }) async {
    final jwtToken =
        requestType == MatrixRequestType.synapse ? synapseToken : corporalToken;
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
    );
    return response;
  }

  Future<http.Response> post({
    required String endpoint,
    required MatrixRequestType requestType,
    String? data,
  }) async {
    final jwtToken =
        requestType == MatrixRequestType.synapse ? synapseToken : corporalToken;
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
      body: data,
    );
    return response;
  }

  Future<http.Response> patch({
    required String endpoint,
    required MatrixRequestType requestType,
    String? data,
  }) async {
    final jwtToken =
        requestType == MatrixRequestType.synapse ? synapseToken : corporalToken;
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await http.patch(
      url,
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
      body: data,
    );
    return response;
  }

  Future<http.Response> delete({
    required String endpoint,
    required MatrixRequestType requestType,
    String? body,
  }) async {
    final jwtToken =
        requestType == MatrixRequestType.synapse ? synapseToken : corporalToken;
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
      body: body,
    );
    return response;
  }

  Future<http.Response> put({
    required String endpoint,
    required MatrixRequestType requestType,
    String? data,
  }) async {
    final jwtToken =
        requestType == MatrixRequestType.synapse ? synapseToken : corporalToken;
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
      body: data,
    );
    return response;
  }

  Future<http.StreamedResponse> putFile({
    required String endpoint,
    required MatrixRequestType requestType,
    required File file,
  }) async {
    final jwtToken =
        requestType == MatrixRequestType.synapse ? synapseToken : corporalToken;
    final url = Uri.parse('$baseUrl$endpoint');
    final request = http.MultipartRequest('PUT', url)
      ..headers['Authorization'] = 'Bearer $jwtToken'
      ..files.add(await http.MultipartFile.fromPath(
        'file',
        file.path,
      ));
    final response = await request.send();
    return response;
  }
}
