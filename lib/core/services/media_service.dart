import 'package:image_picker/image_picker.dart';
import '../utils/app_logger.dart';

class MediaService {
  final ImagePicker _picker = ImagePicker();
  bool _isPicking = false;

  /// ✨ Hàm mở Camera để chụp ảnh trực tiếp
  Future<XFile?> takePhoto() async {
    if (_isPicking) {
      AppLogger.w(
        'MediaService',
        'Camera request skipped: another request is in progress',
      );
      return null;
    }

    _isPicking = true;
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1080, // Giới hạn chiều rộng ảnh để giảm dung lượng khi upload
        maxHeight: 1080,
        imageQuality: 85, // Nén chất lượng ảnh xuống 85% giúp mượt mà hơn
      );
      return photo;
    } catch (e, st) {
      AppLogger.e('MediaService', e, st);
      return null;
    } finally {
      _isPicking = false;
    }
  }

  /// ✨ Hàm mở Album/Thư viện ảnh để chọn ảnh có sẵn
  Future<XFile?> pickImageFromGallery() async {
    if (_isPicking) {
      AppLogger.w(
        'MediaService',
        'Gallery request skipped: another request is in progress',
      );
      return null;
    }

    _isPicking = true;
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );
      return image;
    } catch (e, st) {
      AppLogger.e('MediaService', e, st);
      return null;
    } finally {
      _isPicking = false;
    }
  }
}
