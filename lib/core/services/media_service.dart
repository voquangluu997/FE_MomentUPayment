import 'package:image_picker/image_picker.dart';

class MediaService {
  final ImagePicker _picker = ImagePicker();

  /// ✨ Hàm mở Camera để chụp ảnh trực tiếp
  Future<XFile?> takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1080, // Giới hạn chiều rộng ảnh để giảm dung lượng khi upload
        maxHeight: 1080,
        imageQuality: 85, // Nén chất lượng ảnh xuống 85% giúp mượt mà hơn
      );
      return photo;
    } catch (e) {
      print('Lỗi khi mở camera rùi: $e');
      return null;
    }
  }

  /// ✨ Hàm mở Album/Thư viện ảnh để chọn ảnh có sẵn
  Future<XFile?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      print('Lỗi khi mở thư viện ảnh rùi: $e');
      return null;
    }
  }
}
