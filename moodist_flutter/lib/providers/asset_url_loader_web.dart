// 仅用于 Web：通过 Blob + 正确 MIME 生成 Object URL，避免 Format error (Code 4)
// ignore: uri_does_not_exist
import 'dart:html' as html;

import 'package:flutter/services.dart';

final _urlCache = <String, String>{};

/// 返回用于播放的 Object URL，带正确 MIME。同一 path 会复用已创建的 URL。
Future<String?> getAssetAudioUrl(String assetPath) async {
  if (_urlCache.containsKey(assetPath)) return _urlCache[assetPath];
  final bytes = await rootBundle.load(assetPath);
  final list = bytes.buffer.asUint8List();
  final ext = assetPath.toLowerCase().split('.').last;
  final mime = ext == 'mp3' ? 'audio/mpeg' : ext == 'wav' ? 'audio/wav' : 'audio/mpeg';
  final blob = html.Blob([list], mime);
  final url = html.Url.createObjectUrlFromBlob(blob);
  _urlCache[assetPath] = url;
  return url;
}

void revokeAssetAudioUrl(String url) {
  try {
    html.Url.revokeObjectUrl(url);
  } catch (_) {}
  _urlCache.removeWhere((_, v) => v == url);
}

void revokeAllAssetAudioUrls() {
  for (final url in _urlCache.values.toList()) {
    try {
      html.Url.revokeObjectUrl(url);
    } catch (_) {}
  }
  _urlCache.clear();
}
