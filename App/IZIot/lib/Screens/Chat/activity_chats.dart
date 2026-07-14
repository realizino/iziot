import 'dart:async';

import 'package:iziot/Models/User/SaveUser_Model.dart';
import 'package:iziot/Widget/TopBar.dart';
import 'package:iziot/api/Chat/api_chat.dart';
import 'package:iziot/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import '../../Data/Strings/Strings.dart';
import '../../Models/Chat/ChatList_Model.dart';
import '../../Server/Server.dart';
import 'activity_chat.dart';

class activity_chats extends StatefulWidget {
  @override
  State<activity_chats> createState() => _activity_chats_state();
}

class _activity_chats_state extends State<activity_chats> {
  List<ChatList_Model> _chats = [];
  bool _isFirstLoad = true;
  Timer? _timer;

  bool get _isRtl {
    final lang = Localizations.localeOf(context).languageCode;
    return lang == 'fa' || lang == 'ar';
  }

  @override
  void initState() {
    super.initState();
    _loadChatList();
    // FIX: was 5 min — 30 s is better for a chat app
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) _loadChatList();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadChatList() async {
    if (!mounted) return;
    try {
      final data = await api_chat().GetChatList(context);
      if (mounted) {
        setState(() {
          _chats = data;
          _isFirstLoad = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isFirstLoad = false);
    }
  }

  Future<bool> _confirmDelete(ChatList_Model model) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.delete_chat),
        content: Text(AppLocalizations.of(context)!.delete_chat_confirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              AppLocalizations.of(context)!.delete,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return false;

    final ok = await api_chat().DeleteChat(context, model.id);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.error_at_connection)),
      );
    }
    return ok;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return WillPopScope(
        child: SafeArea(
          child: Scaffold(
            backgroundColor: theme.splashColor,
            body: Column(
              children: [
                TopBar(context, true),
                Expanded(
                  child: _isFirstLoad
                      ? Center(
                    child: CircularProgressIndicator(
                      color: theme.primaryColor,
                      strokeWidth: 2,
                    ),
                  )
                      : _chats.isEmpty
                      ? _buildEmptyState(theme)
                      : RefreshIndicator(
                    onRefresh: _loadChatList,
                    child: ListView.separated(
                      itemCount: _chats.length,
                      separatorBuilder: (_, __) =>
                      const Divider(height: 1, indent: 78),
                      itemBuilder: (_, i) => _buildChatItem(_chats[i]),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        onWillPop: () async {
          Strings.Chat_Id = "";
          return true;
        }
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/icons/empty.png',
            height: 160,
            width: 250,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context)!.chat_is_empty,
            style: TextStyle(fontSize: 13, color: theme.unselectedWidgetColor),
          ),
        ],
      ),
    );
  }

  Widget _buildChatItem(ChatList_Model model) {
    final theme = Theme.of(context);

    // FIX: subtitle preview — handle image/file messages gracefully
    String subtitle;
    if (model.last_text.isEmpty) {
      subtitle = '';
    } else if (model.last_text.startsWith('{')) {
      subtitle = '📎';
    } else if (model.last_text.startsWith('📷')) {
      subtitle = model.last_text;
    } else {
      subtitle = model.last_text.length > 30
          ? '${model.last_text.substring(0, 30)}…'
          : model.last_text;
    }

    if(model.last_text.isEmpty){
      return SizedBox();
    }

    return Dismissible(
      key: ValueKey(model.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(model),
      onDismissed: (_) {
        setState(() => _chats.removeWhere((c) => c.id == model.id));
      },
      background: Container(
        color: Colors.red,
        alignment: _isRtl ? Alignment.centerLeft : Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      child: ListTile(
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: _buildAvatar(model),
        title: Text(
          model.name.isEmpty
              ? AppLocalizations.of(context)!.uUnknown
              : '${model.name} ${model.family}'.trim(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: theme.unselectedWidgetColor,
          ),
        ),
        subtitle: Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 12, color: theme.unselectedWidgetColor),
        ),
        onTap: () {
          Strings.Chat_Id = model.id.toString();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => activity_chat(
                user_data: SaveUser_Model(
                  id: model.id,
                  name: model.name,
                  family: model.family,
                  username: model.username,
                  phone: '',
                  profile_image: model.profile_image,
                ),
              ),
            ),
          ).then((_) => _loadChatList()); // FIX: refresh list when returning
        },
      ),
    );
  }

  Widget _buildAvatar(ChatList_Model model) {
    final theme = Theme.of(context);
    final fallback = Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.12),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(Icons.person_rounded, color: theme.primaryColor, size: 24),
    );

    if (model.profile_image.isEmpty) return fallback;

    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: Image.network(
        '${Server.Root_Address}/File/${model.profile_image}',
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
      ),
    );
  }
}