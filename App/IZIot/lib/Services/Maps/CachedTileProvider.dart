import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:path_provider/path_provider.dart';

class CachedTileProvider extends TileProvider {
  CachedTileProvider({
    this.maxDiskCacheAge = const Duration(days: 30),
    this.maxMemoryCacheEntries = 150, // کمی کاهش برای مدیریت بهتر رم
  });

  final Duration maxDiskCacheAge;
  final int maxMemoryCacheEntries;

  static const String _cacheVersion = 'v2';
  static final Map<String, Uint8List> _memoryCache = {};
  static final Map<String, Future<Uint8List>> _inFlight = {};
  static Directory? _cacheDir;

  // 🔥 CRITICAL FIX: استفاده از یک HttpClient مشترک برای Keep-Alive
  // این کار باعث می‌شود برای هر تایل، اتصال TCP/TLS جدید برقرار نشود
  // و تاخیر شبکه به شدت (چند صد میلی‌ثانیه برای هر تایل) کاهش یابد.
  static final HttpClient _sharedClient = HttpClient()
    ..maxConnectionsPerHost = 6 // محدود کردن درخواست‌های همزمان برای جلوگیری از فشار به سرور ۲ هسته‌ای
    ..idleTimeout = const Duration(seconds: 15);

  Future<Directory> _getCacheDir() async {
    if (_cacheDir != null) return _cacheDir!;
    final base = await getTemporaryDirectory();
    final dir = Directory('${base.path}/map_tile_cache_$_cacheVersion');
    if (!await dir.exists()) await dir.create(recursive: true);
    _cacheDir = dir;
    return dir;
  }

  // 🔥 CRITICAL FIX: حذف md5 (مصرف CPU بالا) و استفاده از جایگزینی کاراکتر (سرعت آنی)
  String _keyForUrl(String url) => url.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    final url = getTileUrl(coordinates, options);
    return _CachedTileImageProvider(url: url, owner: this);
  }

  Uint8List? _readFromMemory(String key) => _memoryCache[key];

  void _writeToMemory(String key, Uint8List bytes) {
    if (_memoryCache.length >= maxMemoryCacheEntries) {
      _memoryCache.remove(_memoryCache.keys.first);
    }
    _memoryCache[key] = bytes;
  }

  Future<Uint8List?> _readFromDisk(String key) async {
    try {
      final dir = await _getCacheDir();
      final file = File('${dir.path}/$key.tile');
      if (!await file.exists()) return null;

      final stat = await file.stat();
      if (DateTime.now().difference(stat.modified) > maxDiskCacheAge) {
        unawaited(file.delete().catchError((_) => file));
        return null;
      }

      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) {
        unawaited(file.delete().catchError((_) => file));
        return null;
      }
      return bytes;
    } catch (_) { return null; }
  }

  Future<void> _writeToDisk(String key, Uint8List bytes) async {
    try {
      final dir = await _getCacheDir();
      final finalFile = File('${dir.path}/$key.tile');
      final tmpFile = File('${dir.path}/$key.tile.tmp.${DateTime.now().microsecondsSinceEpoch}');
      await tmpFile.writeAsBytes(bytes, flush: true);
      await tmpFile.rename(finalFile.path);
    } catch (_) {}
  }

  Future<Uint8List> _fetchFromNetwork(String url) async {
    // 🔥 استفاده از کلاینت مشترک و عدم بستن آن!
    final request = await _sharedClient.getUrl(Uri.parse(url));
    request.headers.set(HttpHeaders.userAgentHeader, 'BzHub/1.0 (ir.izino.bzhub)');
    final response = await request.close();

    if (response.statusCode != 200) {
      throw HttpException('Tile fetch failed: HTTP ${response.statusCode} for $url');
    }
    return await consolidateHttpClientResponseBytes(response);
  }

  Future<Uint8List> _fetchAndCache(String url, String key) {
    final existing = _inFlight[key];
    if (existing != null) return existing;

    final future = () async {
      try {
        final bytes = await _fetchFromNetwork(url);
        _writeToMemory(key, bytes);
        await _writeToDisk(key, bytes);
        return bytes;
      } finally {
        _inFlight.remove(key);
      }
    }();

    _inFlight[key] = future;
    return future;
  }

  Future<void> _evict(String key) async {
    _memoryCache.remove(key);
    try {
      final dir = await _getCacheDir();
      final file = File('${dir.path}/$key.tile');
      if (await file.exists()) await file.delete();
    } catch (_) {}
  }

  static Future<void> clearAll() async {
    _memoryCache.clear();
    _inFlight.clear();
    try {
      final base = await getTemporaryDirectory();
      final dir = Directory('${base.path}/map_tile_cache_$_cacheVersion');
      if (await dir.exists()) await dir.delete(recursive: true);
      _cacheDir = null;
    } catch (_) {}
  }
}

class _CachedTileImageProvider extends ImageProvider<_CachedTileImageProvider> {
  const _CachedTileImageProvider({required this.url, required this.owner});

  final String url;
  final CachedTileProvider owner;

  @override
  Future<_CachedTileImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<_CachedTileImageProvider>(this);
  }

  @override
  ImageStreamCompleter loadImage(_CachedTileImageProvider key, ImageDecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadBytes(key, decode),
      scale: 1.0,
      debugLabel: url,
    );
  }

  Future<ui.Codec> _loadBytes(_CachedTileImageProvider key, ImageDecoderCallback decode) async {
    final cacheKey = owner._keyForUrl(url);

    final mem = owner._readFromMemory(cacheKey);
    if (mem != null) {
      try { return await decode(await ui.ImmutableBuffer.fromUint8List(mem)); }
      catch (_) { await owner._evict(cacheKey); }
    }

    final disk = await owner._readFromDisk(cacheKey);
    if (disk != null) {
      try {
        final codec = await decode(await ui.ImmutableBuffer.fromUint8List(disk));
        owner._writeToMemory(cacheKey, disk);
        return codec;
      } catch (_) { await owner._evict(cacheKey); }
    }

    final network = await owner._fetchAndCache(url, cacheKey);
    return decode(await ui.ImmutableBuffer.fromUint8List(network));
  }

  @override
  bool operator ==(Object other) => other is _CachedTileImageProvider && other.url == url;

  @override
  int get hashCode => url.hashCode;
}