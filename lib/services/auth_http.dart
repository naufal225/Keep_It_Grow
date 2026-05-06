library auth_http;

import 'dart:convert';
import 'package:http/http.dart' as base_http;
import 'auth_service.dart';

export 'package:http/http.dart'
    show BaseResponse, MultipartFile, Response, StreamedResponse;

Future<base_http.Response> get(
  Uri url, {
  Map<String, String>? headers,
}) async {
  final response = await base_http.get(url, headers: headers);
  await AuthService.handleUnauthorizedResponse(response);
  return response;
}

Future<base_http.Response> post(
  Uri url, {
  Map<String, String>? headers,
  Object? body,
  Encoding? encoding,
}) async {
  final response = await base_http.post(
    url,
    headers: headers,
    body: body,
    encoding: encoding,
  );
  await AuthService.handleUnauthorizedResponse(response);
  return response;
}

Future<base_http.Response> put(
  Uri url, {
  Map<String, String>? headers,
  Object? body,
  Encoding? encoding,
}) async {
  final response = await base_http.put(
    url,
    headers: headers,
    body: body,
    encoding: encoding,
  );
  await AuthService.handleUnauthorizedResponse(response);
  return response;
}

Future<base_http.Response> delete(
  Uri url, {
  Map<String, String>? headers,
  Object? body,
  Encoding? encoding,
}) async {
  final response = await base_http.delete(
    url,
    headers: headers,
    body: body,
    encoding: encoding,
  );
  await AuthService.handleUnauthorizedResponse(response);
  return response;
}

class MultipartRequest extends base_http.MultipartRequest {
  MultipartRequest(super.method, super.url);

  @override
  Future<base_http.StreamedResponse> send() async {
    final response = await super.send();
    await AuthService.handleUnauthorizedResponse(response);
    return response;
  }
}
