import 'package:keep_it_grow/services/constants.dart';

String buildStorageUrl(String url) {
  if (url.isEmpty) {
    return '';
  }

  if (url.startsWith('http://') || url.startsWith('https://')) {
    return url;
  }

  final normalizedBase = ServiceConstants.storageBase.endsWith('/')
      ? ServiceConstants.storageBase
      : '${ServiceConstants.storageBase}/';

  var normalizedPath = url.trim();

  if (normalizedPath.startsWith('/')) {
    normalizedPath = normalizedPath.substring(1);
  }

  if (normalizedPath.startsWith('storage/')) {
    normalizedPath = normalizedPath.substring('storage/'.length);
  }

  return '$normalizedBase$normalizedPath';
}
