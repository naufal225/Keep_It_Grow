import '../../services/constants.dart';

class AvatarHelper {
  static String getAvatarUrl(String? avatarPath) {
    if (avatarPath == null || avatarPath.isEmpty) {
      return '';
    }
    
    // Jika sudah full URL, return langsung
    if (avatarPath.startsWith('http')) {
      return avatarPath;
    }
    
    // Jika relative path, gabungkan dengan storage base
    return '${ServiceConstants.storageBase}/${avatarPath.replaceFirst('storage/', '')}';
  }
}