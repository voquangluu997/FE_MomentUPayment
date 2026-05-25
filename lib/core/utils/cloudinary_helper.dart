class CloudinaryHelper {
  /// 📐 Sinh ảnh Thumbnail vuông (150x150), nén tự động, đổi đuôi sang .webp siêu nhẹ cho màn hình danh sách
  static String getThumbnailUrl(String originalUrl) {
    if (originalUrl.isEmpty) return '';
    if (!originalUrl.contains('res.cloudinary.com')) return originalUrl;

    return originalUrl.replaceFirst(
      '/upload/',
      '/upload/c_thumb,w_150,h_150,g_auto,f_auto,q_auto/',
    );
  }

  /// 📸 Tối ưu ảnh gốc (vẫn giữ nguyên kích thước lớn nhưng giảm dung lượng file xuống tối đa) khi xem chi tiết
  static String getOptimizedOriginalUrl(String originalUrl) {
    if (originalUrl.isEmpty) return '';
    if (!originalUrl.contains('res.cloudinary.com')) return originalUrl;

    return originalUrl.replaceFirst('/upload/', '/upload/f_auto,q_auto/');
  }
}
