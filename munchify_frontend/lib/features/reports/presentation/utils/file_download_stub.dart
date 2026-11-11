import 'dart:typed_data';

/// Non-web platforms: the Excel export is a Web Admin feature only.
void downloadFile(Uint8List bytes, String fileName) {
  throw UnsupportedError('Tải file chỉ hỗ trợ trên Web.');
}
