import 'dart:async';

import 'package:iziot/Data/Strings/Strings.dart';
import 'package:iziot/Models/Chat/Chat_Model.dart';
import 'package:iziot/Models/User/SaveUser_Model.dart';
import 'package:iziot/Screens/User/activity_display.dart';
import 'package:iziot/Widget/IOSCheck.dart';
import 'package:iziot/Widget/saveImageToGallery.dart';
import 'package:iziot/api/Chat/api_chat.dart';
import 'package:iziot/l10n/app_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart'; // Added for map preview
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:iziot/Widget/GetUserPosition.dart';

import '../../Server/Server.dart';
import 'activity_location_picker.dart';

class activity_chat extends StatefulWidget {
  final SaveUser_Model user_data;
  const activity_chat({Key? key, required this.user_data}) : super(key: key);

  @override
  State<activity_chat> createState() => _activity_chat_state();
}

class _activity_chat_state extends State<activity_chat> {
  List<Chat_Model> _messages = [];
  bool _isFirstLoad = true;
  bool _isSending = false;
  bool _isUploadingImage = false;
  bool _isWaiting = false;

  Timer? _timer;

  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();

  Chat_Model? _replyingTo;
  Chat_Model? _editingMessage;

  // Map app configuration - names will be localized when accessed
  List<MapApp> _getMapApps() {
    final loc = AppLocalizations.of(context)!;
    return [
      MapApp(
        loc.apple_maps,
        Icons.map_outlined,
        'maps://',
            (lat, lng) => 'maps://?q=$lat,$lng',
      ),
    ];
  }

  bool get _isRtl {
    final lang = Localizations.localeOf(context).languageCode;
    return lang == 'fa' || lang == 'ar';
  }

  String get _otherName =>
      '${widget.user_data.name} ${widget.user_data.family}'.trim();

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _markSeen();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) _loadMessages(silent: true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadMessages({bool silent = false}) async {
    if (!mounted) return;
    try {
      final data = await api_chat().GetChats(context);
      if (mounted) {
        setState(() {
          _messages = data;
          if (!silent) _isFirstLoad = false;
        });
        if (!silent) _scrollToBottom();
      }
    } catch (_) {
      if (mounted && !silent) setState(() => _isFirstLoad = false);
    }
  }

  Future<void> _markSeen() async => api_chat().MarkSeen(context);

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSend() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    _textController.clear();

    bool ok;

    if (_editingMessage != null) {
      ok = await api_chat().EditMessage(context, _editingMessage!.id, text);
      if (ok && mounted) {
        setState(() {
          final idx = _messages.indexWhere((m) => m.id == _editingMessage!.id);
          if (idx != -1) {
            _messages[idx] =
                _messages[idx].copyWith(content: text, is_edited: true);
          }
          _editingMessage = null;
        });
      }
    } else {
      ok = await api_chat()
          .AddNewChat(context, text, replyToId: _replyingTo?.id);
      if (ok && mounted) {
        setState(() => _replyingTo = null);
        await _loadMessages(silent: true);
        _scrollToBottom();
      }
    }

    if (mounted) setState(() => _isSending = false);
  }

  Future<void> _handleImagePick() async {
    final picker = ImagePicker();
    final picked =
    await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null || !mounted) return;

    setState(() => _isUploadingImage = true);

    final hash = await api_chat().UploadImage(context, picked.path);
    if (hash == null) {
      if (mounted) setState(() => _isUploadingImage = false);
      return;
    }

    final ok = await api_chat()
        .AddNewChatImage(context, hash, replyToId: _replyingTo?.id);
    if (ok && mounted) {
      setState(() => _replyingTo = null);
      await _loadMessages(silent: true);
      _scrollToBottom();
    }

    if (mounted) setState(() => _isUploadingImage = false);
  }

  Future<void> _handleSendLocation() async {
    final LatLng? picked = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(
        builder: (_) => const activity_location_picker(),
      ),
    );

    if (picked == null || !mounted) return;

    setState(() => _isUploadingImage = true);

    final locationText = 'LOCATION:${picked.latitude},${picked.longitude}';
    final ok = await api_chat().AddNewChat(
      context,
      locationText,
      replyToId: _replyingTo?.id,
    );

    if (ok && mounted) {
      setState(() => _replyingTo = null);
      await _loadMessages(silent: true);
      _scrollToBottom();
    }

    if (mounted) setState(() => _isUploadingImage = false);
  }

  void _showMessageMenu(Chat_Model msg) {
    if (msg.is_deleted) return;
    final loc = AppLocalizations.of(context)!;
    final isMe = msg.isMe;
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              _MenuTile(
                icon: Icons.reply_rounded,
                label: loc.reply,
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _replyingTo = msg;
                    _editingMessage = null;
                  });
                  _focusNode.requestFocus();
                },
              ),
              if (msg.isText && !_isLocationMessage(msg.content))
                _MenuTile(
                  icon: Icons.copy_rounded,
                  label: loc.copy,
                  onTap: () {
                    Navigator.pop(context);
                    Clipboard.setData(ClipboardData(text: msg.content));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(loc.copied),
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              if (isMe && msg.isText && !_isLocationMessage(msg.content))
                _MenuTile(
                  icon: Icons.edit_rounded,
                  label: loc.edit,
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _editingMessage = msg;
                      _replyingTo = null;
                      _textController.text = msg.content;
                    });
                    _focusNode.requestFocus();
                  },
                ),
              if (isMe)
                _MenuTile(
                  icon: Icons.delete_rounded,
                  label: loc.delete,
                  color: Colors.red,
                  onTap: () async {
                    Navigator.pop(context);
                    final ok =
                    await api_chat().DeleteMessage(context, msg.id);
                    if (ok && mounted) {
                      setState(() {
                        final idx =
                        _messages.indexWhere((m) => m.id == msg.id);
                        if (idx != -1) {
                          _messages[idx] = _messages[idx]
                              .copyWith(is_deleted: true, content: '');
                        }
                      });
                    }
                  },
                ),
              if (msg.isImage && msg.file_hash != null)
                _MenuTile(
                  icon: Icons.download_rounded,
                  label: loc.save,
                  onTap: () {
                    Navigator.pop(context);
                    saveImageToGallery(
                        context,
                        '${Server.Root_Address}/File/${msg.file_hash}');
                  },
                ),
              if (msg.isText && _isLocationMessage(msg.content))
                _MenuTile(
                  icon: Icons.navigation_rounded,
                  label: loc.open_in_map,
                  onTap: () {
                    Navigator.pop(context);
                    final coords = _parseLocation(msg.content);
                    if (coords != null) {
                      _showMapOptions(coords.$1, coords.$2);
                    }
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isLocationMessage(String content) =>
      content.startsWith('LOCATION:');

  (double, double)? _parseLocation(String content) {
    try {
      final raw = content.replaceFirst('LOCATION:', '');
      final parts = raw.split(',');
      if (parts.length != 2) return null;
      final lat = double.parse(parts[0]);
      final lng = double.parse(parts[1]);
      return (lat, lng);
    } catch (_) {
      return null;
    }
  }

  Future<List<MapApp>> _getInstalledMapApps(double lat, double lng) async {
    List<MapApp> installed = [];
    final mapApps = _getMapApps();

    for (var app in mapApps) {
      // Skip Apple Maps on Android
      if (app.name == AppLocalizations.of(context)!.apple_maps && Theme.of(context).platform != TargetPlatform.iOS) {
        continue;
      }

      // Check using actual deep link with coordinates
      final deepLink = Uri.parse(app.getUrl(lat, lng));
      if (await canLaunchUrl(deepLink)) {
        installed.add(app);
      }
    }

    return installed;
  }

  void _showMapOptions(double lat, double lng) async {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    List<MapApp> installedApps = await _getInstalledMapApps(lat, lng);

    if (!mounted) return;
    Navigator.pop(context);

    if (installedApps.isEmpty) {
      _launchGoogleMaps(lat, lng);
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                loc.open_location_in,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.unselectedWidgetColor,
                ),
              ),
              const SizedBox(height: 16),
              ...installedApps.map((app) => _MapOptionTile(
                icon: app.icon,
                label: app.name,
                onTap: () {
                  Navigator.pop(ctx);
                  _launchMapApp(app, lat, lng);
                },
              )),
              _MapOptionTile(
                icon: Icons.map_rounded,
                label: loc.google_maps,
                onTap: () {
                  Navigator.pop(ctx);
                  _launchGoogleMaps(lat, lng);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchMapApp(MapApp app, double lat, double lng) async {
    final url = Uri.parse(app.getUrl(lat, lng));

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      _launchGoogleMaps(lat, lng);
    }
  }

  Future<void> _launchGoogleMaps(double lat, double lng) async {
    // Try geo: URI first (works on most Android devices)
    final geoUri = Uri.parse('geo:$lat,$lng?q=$lat,$lng');
    if (await canLaunchUrl(geoUri)) {
      await launchUrl(geoUri, mode: LaunchMode.externalApplication);
      return;
    }

    // Try Google Maps app scheme on iOS
    final iosUri = Uri.parse('comgooglemaps://?q=$lat,$lng');
    if (await canLaunchUrl(iosUri)) {
      await launchUrl(iosUri, mode: LaunchMode.externalApplication);
      return;
    }

    // Fallback to web URL
    final webUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (await canLaunchUrl(webUri)) {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.cloud_not_open_map)),
        );
      }
    }
  }

  // Fixed full-screen image viewer - no border radius, proper layout
  void _showFullImage(String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              SizedBox.expand(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Center(
                    child: CachedNetworkImage(
                      imageUrl: url,
                      fit: BoxFit.contain,
                      placeholder: (_, __) => const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                      errorWidget: (_, __, ___) => const Center(
                        child: Icon(Icons.broken_image, color: Colors.white, size: 60),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                right: 20,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                left: 20,
                child: IconButton(
                  icon: const Icon(Icons.download_rounded, color: Colors.white, size: 28),
                  onPressed: () => saveImageToGallery(context, url),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.splashColor,
      body: Stack(
        children: [
          Column(
            children: [
              _buildTopBar(theme),
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        'assets/Images/chat_background.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                    _isFirstLoad
                        ? Center(
                      child: CircularProgressIndicator(
                          color: theme.primaryColor,
                          strokeWidth: 2),
                    )
                        : _messages.isEmpty
                        ? _buildEmptyState(theme)
                        : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      itemCount: _messages.length,
                      itemBuilder: (_, i) => Directionality(
                        textDirection: TextDirection.ltr,
                        child: _buildBubble(_messages[i]),
                      ),
                    ),
                  ],
                ),
              ),
              if (_replyingTo != null) _buildReplyBanner(),
              if (_editingMessage != null) _buildEditBanner(),
              _buildInputBar(theme),
            ],
          ),

          if (_isUploadingImage)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 3),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context)!.uploading,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

          if (_isWaiting)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 3),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context)!.please_wait,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTopBar(ThemeData theme) {
    final isIOS = IOSCheck();

    Widget avatar() {
      final fallback = CircleAvatar(
        radius: 18,
        backgroundColor: theme.primaryColor.withOpacity(0.15),
        child:
        Icon(Icons.person_rounded, color: theme.primaryColor, size: 18),
      );

      if (widget.user_data.profile_image.isEmpty) return fallback;

      return ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: isIOS
            ? Image.network(
          '${Server.Root_Address}/File/${widget.user_data.profile_image}',
          width: 36,
          height: 36,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => fallback,
        )
            : CachedNetworkImage(
          imageUrl:
          '${Server.Root_Address}/File/${widget.user_data.profile_image}',
          width: 36,
          height: 36,
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) => fallback,
        ),
      );
    }

    return SafeArea(
      bottom: false,
      child: Container(
        width: double.infinity,
        height: 70,
        color: theme.splashColor,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: 20,
              left: 20,
              child: InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(20),
                child: Icon(
                  Icons.keyboard_arrow_left,
                  size: 28,
                  color: theme.secondaryHeaderColor,
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: widget.user_data.username.isNotEmpty
                      ? () {
                    setState(() => _isWaiting = true);
                    Strings.DeepLink = widget.user_data.username;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => activity_display()),
                    );
                    setState(() => _isWaiting = false);
                  }
                      : null,
                  child: avatar(),
                ),
                const SizedBox(width: 10),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.45,
                  ),
                  child: Text(
                    _otherName.isEmpty
                        ? AppLocalizations.of(context)!.uUnknown
                        : _otherName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: theme.unselectedWidgetColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset("assets/icons/coffe.png", height: 160),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context)!.chat_is_empty,
            style:
            TextStyle(fontSize: 13, color: theme.unselectedWidgetColor),
          ),
        ],
      ),
    );
  }

  Widget _buildBubble(Chat_Model msg) {
    final theme = Theme.of(context);
    final isMe = msg.isMe;
    final bubbleColor = isMe ? theme.primaryColor : theme.cardColor;
    final textColor = isMe ? Colors.white : theme.unselectedWidgetColor;

    final isLocation = msg.isText && _isLocationMessage(msg.content);

    return _SwipeToReply(
      onReply: msg.is_deleted
          ? null
          : () {
        setState(() {
          _replyingTo = msg;
          _editingMessage = null;
        });
        _focusNode.requestFocus();
      },
      isMe: isMe,
      child: GestureDetector(
        onLongPress: () => _showMessageMenu(msg),
        child: Padding(
          padding: EdgeInsets.only(
            top: 2,
            bottom: 2,
            left: isMe ? (isLocation ? 8 : 48) : 4,
            right: isMe ? 4 : (isLocation ? 8 : 48),
          ),
          child: Align(
            alignment:
            isMe ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              constraints: isLocation
                  ? BoxConstraints(
                  maxWidth:
                  MediaQuery.of(context).size.width * 0.72)
                  : null,
              padding: (msg.isImage || isLocation)
                  ? const EdgeInsets.all(4)
                  : const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isMe ? 18 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Directionality(
                textDirection:
                _isRtl ? TextDirection.rtl : TextDirection.ltr,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (msg.reply_to_id != null &&
                        msg.reply_to_content != null)
                      _buildReplyPreview(msg, isMe, textColor),
                    if (msg.is_deleted)
                      _buildDeletedContent(isMe, textColor)
                    else if (isLocation)
                      _buildLocationContent(msg, isMe, textColor)
                    else if (msg.isImage)
                        _buildImageContent(msg)
                      else
                        _buildTextContent(msg, textColor),
                    const SizedBox(height: 3),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: _buildFooter(msg, isMe, textColor),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReplyPreview(Chat_Model msg, bool isMe, Color textColor) {
    final theme = Theme.of(context);
    final iMyReply = msg.reply_to_sender == '1';

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: isMe
            ? Colors.white.withOpacity(0.18)
            : theme.primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border(
          left: BorderSide(
            color:
            isMe ? Colors.white.withOpacity(0.7) : theme.primaryColor,
            width: 3,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            iMyReply ? AppLocalizations.of(context)!.you : _otherName,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isMe ? Colors.white : theme.primaryColor,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            msg.reply_to_content ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style:
            TextStyle(fontSize: 12, color: textColor.withOpacity(0.75)),
          ),
        ],
      ),
    );
  }

  Widget _buildDeletedContent(bool isMe, Color textColor) {
    return Text(
      '🚫 ${AppLocalizations.of(context)!.message_deleted}',
      style: TextStyle(
        fontSize: 13,
        fontStyle: FontStyle.italic,
        color: textColor.withOpacity(0.6),
      ),
    );
  }

  Widget _buildTextContent(Chat_Model msg, Color textColor) {
    return Text(
      msg.content,
      style: TextStyle(fontSize: 14, height: 1.4, color: textColor),
    );
  }

  Widget _buildLocationContent(Chat_Model msg, bool isMe, Color textColor) {
    final coords = _parseLocation(msg.content);
    if (coords == null) {
      return Text(AppLocalizations.of(context)!.loca,
          style: TextStyle(fontSize: 14, color: textColor));
    }

    final lat = coords.$1;
    final lng = coords.$2;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _showMapOptions(lat, lng),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: 260,
          height: 140,
          child: Stack(
            children: [
              // Use FlutterMap to accurately center the map on the destination
              Positioned.fill(
                child: FlutterMap(
                  options: MapOptions(
                    center: LatLng(lat, lng),
                    zoom: 15.0,
                    // Disable interactions so it behaves like a static preview image
                    interactiveFlags: InteractiveFlag.none,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: Server.Root_Address +
                          '/tile/proxy.php?layer=standard&z={z}&x={x}&y={y}',
                      userAgentPackageName: 'ir.izino.bzhub',
                      maxNativeZoom: 18,
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(lat, lng),
                          width: 40,
                          height: 40,
                          builder: (_) => const Icon(
                            Icons.location_pin,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // "Open in map" overlay at the bottom
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.navigation_rounded,
                          color: Colors.white, size: 13),
                      const SizedBox(width: 4),
                      Text(
                        AppLocalizations.of(context)!.open_in_map,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageContent(Chat_Model msg) {
    if (msg.file_hash == null) {
      return const Padding(padding: EdgeInsets.all(8), child: Text('📷'));
    }

    final url = '${Server.Root_Address}/File/${msg.file_hash}';

    return GestureDetector(
      onTap: () => _showFullImage(url),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: CachedNetworkImage(
          imageUrl: url,
          width: 220,
          fit: BoxFit.cover,
          placeholder: (_, __) => const SizedBox(
            height: 140,
            width: 220,
            child:
            Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
          errorWidget: (_, __, ___) =>
          const Icon(Icons.broken_image_rounded, size: 40),
        ),
      ),
    );
  }

  Widget _buildFooter(Chat_Model msg, bool isMe, Color textColor) {
    final faint = textColor.withOpacity(0.55);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (msg.is_edited)
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Text(
              AppLocalizations.of(context)!.edited,
              style: TextStyle(
                  fontSize: 10,
                  fontStyle: FontStyle.italic,
                  color: faint),
            ),
          ),
        Text(_formatTime(msg.date),
            style: TextStyle(fontSize: 10, color: faint)),
        if (isMe) ...[
          const SizedBox(width: 3),
          Icon(
            msg.seen == 1 ? Icons.done_all_rounded : Icons.done_rounded,
            size: 13,
            color: msg.seen == 1 ? Colors.lightBlueAccent : faint,
          ),
        ],
      ],
    );
  }

  Widget _buildReplyBanner() {
    final theme = Theme.of(context);
    final msg = _replyingTo!;
    final loc = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(
            top: BorderSide(color: theme.primaryColor.withOpacity(0.2))),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 36,
            decoration: BoxDecoration(
              color: theme.primaryColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  loc.replying_to,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor),
                ),
                const SizedBox(height: 2),
                Text(
                  msg.is_deleted
                      ? '🚫 ${loc.message_deleted}'
                      : msg.isImage
                      ? loc.photo
                      : _isLocationMessage(msg.content)
                      ? loc.loca
                      : msg.content,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 12,
                      color: theme.unselectedWidgetColor),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close_rounded,
                size: 20, color: theme.unselectedWidgetColor),
            onPressed: () => setState(() => _replyingTo = null),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildEditBanner() {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(
            top: BorderSide(color: Colors.orange.withOpacity(0.3))),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 36,
            decoration: BoxDecoration(
              color: Color(0XFF61a896),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.of(context)!.editing_message,
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0XFF61a896)),
                ),
                const SizedBox(height: 2),
                Text(
                  _editingMessage!.content,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 12,
                      color: theme.unselectedWidgetColor),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close_rounded,
                size: 20, color: theme.unselectedWidgetColor),
            onPressed: () => setState(() {
              _editingMessage = null;
              _textController.clear();
            }),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar(ThemeData theme) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: theme.splashColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (_editingMessage == null) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: InkWell(
                  onTap: _handleImagePick,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(Icons.image_rounded,
                        color: theme.primaryColor, size: 24),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: InkWell(
                  onTap: _handleSendLocation,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(Icons.location_on_rounded,
                        color: theme.primaryColor, size: 24),
                  ),
                ),
              ),
            ],
            const SizedBox(width: 2),
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 120),
                decoration: BoxDecoration(
                  color: theme.splashColor,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _textController,
                  focusNode: _focusNode,
                  textDirection:
                  _isRtl ? TextDirection.rtl : TextDirection.ltr,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  style: TextStyle(
                      fontSize: 14, color: theme.unselectedWidgetColor),
                  decoration: InputDecoration(
                    hintText:
                    AppLocalizations.of(context)!.type_a_message,
                    hintStyle: TextStyle(
                        fontSize: 14,
                        color: theme.unselectedWidgetColor
                            .withOpacity(0.45)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _isSending ? null : _handleSend,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: theme.primaryColor.withOpacity(0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: _isSending
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
                    : Icon(
                  _editingMessage != null
                      ? Icons.check_rounded
                      : Icons.send_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return dateStr;
    }
  }
}

class _SwipeToReply extends StatefulWidget {
  final Widget child;
  final VoidCallback? onReply;
  final bool isMe;

  const _SwipeToReply({
    Key? key,
    required this.child,
    required this.isMe,
    this.onReply,
  }) : super(key: key);

  @override
  State<_SwipeToReply> createState() => _SwipeToReplyState();
}

class _SwipeToReplyState extends State<_SwipeToReply>
    with SingleTickerProviderStateMixin {
  double _drag = 0;
  bool _triggered = false;

  static const double _threshold = 60;
  static const double _maxDrag = 80;

  void _onHorizontalUpdate(DragUpdateDetails d) {
    if (widget.onReply == null) return;

    final delta = d.delta.dx;
    final isValidDirection = widget.isMe ? delta < 0 : delta > 0;

    if (!isValidDirection && _drag == 0) return;

    setState(() {
      _drag = (_drag + delta).clamp(
        widget.isMe ? -_maxDrag : 0,
        widget.isMe ? 0 : _maxDrag,
      );
    });

    if (!_triggered && _drag.abs() >= _threshold) {
      _triggered = true;
      HapticFeedback.lightImpact();
    }
  }

  void _onHorizontalEnd(DragEndDetails _) {
    if (_triggered && widget.onReply != null) {
      widget.onReply!();
    }
    setState(() {
      _drag = 0;
      _triggered = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconOpacity = (_drag.abs() / _threshold).clamp(0.0, 1.0);

    return GestureDetector(
      onHorizontalDragUpdate: _onHorizontalUpdate,
      onHorizontalDragEnd: _onHorizontalEnd,
      behavior: HitTestBehavior.translucent,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Align(
              alignment: widget.isMe
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.only(
                  left: widget.isMe ? 0 : 4,
                  right: widget.isMe ? 4 : 0,
                ),
                child: Opacity(
                  opacity: iconOpacity,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.reply_rounded,
                      size: 18,
                      color: theme.primaryColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
          AnimatedContainer(
            duration: _drag == 0
                ? const Duration(milliseconds: 200)
                : Duration.zero,
            curve: Curves.easeOut,
            transform: Matrix4.translationValues(_drag, 0, 0),
            child: widget.child,
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).unselectedWidgetColor;
    return ListTile(
      dense: true,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: c.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: c, size: 18),
      ),
      title: Text(label,
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w500, color: c)),
      onTap: onTap,
    );
  }
}

class _MapOptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MapOptionTile({
    Key? key,
    required this.icon,
    required this.label,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: theme.primaryColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: theme.primaryColor, size: 22),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: theme.unselectedWidgetColor,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: theme.unselectedWidgetColor.withOpacity(0.5)),
      onTap: onTap,
    );
  }
}

class MapApp {
  final String name;
  final IconData icon;
  final String scheme;
  final String Function(double lat, double lng) getUrl;

  const MapApp(this.name, this.icon, this.scheme, this.getUrl);
}