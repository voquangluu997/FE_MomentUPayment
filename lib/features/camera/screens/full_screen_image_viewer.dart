import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';

class FullScreenImageViewer extends StatefulWidget {
  final String imageUrl;
  final String heroTag;

  const FullScreenImageViewer({
    super.key,
    required this.imageUrl,
    required this.heroTag,
  });

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  bool _isDownloading = false;

  Future<void> _saveToGallery(BuildContext context) async {
    if (_isDownloading) return;

    setState(() => _isDownloading = true);
    // Thay đổi logic lấy AppColor theme tùy theo cấu trúc dự án của bạn
    // final appColors = Theme.of(context).brightness == Brightness.dark
    //     ? const AppColorTheme.dark()
    //     : const AppColorTheme.light();

    try {
      // 1. Kiểm tra và yêu cầu quyền lưu trữ
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        await Gal.requestAccess();
      }

      // 2. Tải ảnh từ URL
      final response = await http.get(Uri.parse(widget.imageUrl));
      final bytes = response.bodyBytes;

      final tempDir = await getTemporaryDirectory();
      final String fileName =
          'moment_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(bytes);

      // 3. Lưu vào Album
      await Gal.putImage(file.path, album: 'Moment U Payment');

      if (mounted) {
        // AppToast.showSuccess(context, "Đã lưu khoảnh khắc vào thư viện máy! ✨", appColors);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Đã lưu khoảnh khắc vào thư viện máy! ✨"),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // AppToast.showError(context, "Lưu ảnh thất bại, vui lòng thử lại!", appColors);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Lưu ảnh thất bại, vui lòng thử lại!")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.92),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: CircleAvatar(
                backgroundColor: Colors.black26,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 18,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 8.0, bottom: 8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: Colors.black26,
                  child: TextButton.icon(
                    onPressed: () => _saveToGallery(context),
                    icon: _isDownloading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.download_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                    label: Text(
                      _isDownloading ? "Đang lưu..." : "Lưu ảnh",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Nền ảnh mờ phía sau để tạo chiều sâu
          Positioned.fill(
            child: Image.network(
              widget.imageUrl,
              fit: BoxFit.cover,
              color: Colors.black45,
              colorBlendMode: BlendMode.darken,
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
              child: Container(color: Colors.transparent),
            ),
          ),
          // Interactive Viewer (Phóng to/Thu nhỏ) kèm Hero Animation
          Center(
            child: InteractiveViewer(
              clipBehavior: Clip.none,
              minScale: 1.0,
              maxScale: 4.0,
              child: Hero(
                tag: widget.heroTag,
                child: Image.network(widget.imageUrl, fit: BoxFit.contain),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
