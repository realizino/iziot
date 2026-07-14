import 'dart:async';

import 'package:iziot/Models/User/SaveUser_Model.dart';
import 'package:iziot/Screens/Chat/activity_chat.dart';
import 'package:iziot/Screens/User/activity_display.dart';
import 'package:iziot/Data/Strings/Strings.dart';
import 'package:iziot/api/Chat/api_chat.dart';
import 'package:iziot/api/Contact/api_contact.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Server/Server.dart';
import '../l10n/app_localizations.dart';

class SaveLayout extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SaveLayout_State();
}

class SaveLayout_State extends State<SaveLayout> {

  // ─── State ───────────────────────────────────────────────────────────────────
  String searchValue = "";
  bool chatWait      = false;
  bool unsaveWait    = false;
  bool isLoading     = true;
  bool isSearching   = false;

  List<SaveUser_Model> _saveList   = [];
  List<SaveUser_Model> _searchList = [];

  Timer? _debounce;

  final TextEditingController searchController = TextEditingController();

  // ─── Helpers ─────────────────────────────────────────────────────────────────
  bool get isRtl {
    final lang = Localizations.localeOf(context).languageCode;
    return lang == "fa" || lang == "ar";
  }

  bool get isSearchMode => searchValue.isNotEmpty;

  // ─── Lifecycle ───────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _loadSaveList();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  // ─── Data ────────────────────────────────────────────────────────────────────
  Future<void> _loadSaveList() async {
    setState(() => isLoading = true);

    final list = await api_contact().GetAllSave(context);

    if (!mounted) return;

    setState(() {
      _saveList = list;
      isLoading = false;
    });
  }

  Future<void> _refreshSaveList() async {
    await _loadSaveList();
  }

  Future<void> _onSearchChanged(String value) async {
    final query = value.trim();

    setState(() => searchValue = query);

    if (_debounce?.isActive ?? false) _debounce!.cancel();

    if (query.isEmpty) {
      setState(() {
        _searchList  = [];
        isSearching  = false;
      });
      return;
    }

    // Show searching indicator immediately while waiting debounce
    setState(() => isSearching = true);

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final results = await api_contact().SearchUsers(context, query);

      if (!mounted) return;

      setState(() {
        _searchList = results;
        isSearching = false;
      });
    });
  }

  // ─── Build ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final displayList = isSearchMode ? _searchList : _saveList;

    return Column(
      children: [

        // ─── Search bar ──────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Directionality(
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            child: TextField(
              controller: searchController,
              onChanged: _onSearchChanged,
              onSubmitted: (_) => FocusScope.of(context).unfocus(),
              textInputAction: TextInputAction.search,
              style: TextStyle(
                fontSize: 14,
                color: theme.unselectedWidgetColor,
              ),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.search,
                hintStyle: TextStyle(
                  fontSize: 13,
                  color: theme.unselectedWidgetColor,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: theme.unselectedWidgetColor,
                  size: 20,
                ),
                suffixIcon: searchValue.isEmpty
                    ? null
                    : IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: theme.unselectedWidgetColor,
                    size: 20,
                  ),
                  onPressed: () {
                    searchController.clear();
                    _onSearchChanged("");
                  },
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
                fillColor: theme.splashColor,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.primaryColor, width: 1.4),
                ),
              ),
            ),
          ),
        ),

        // ─── Search loading indicator bar ────────────────────────────────────
        if (isSearching)
          LinearProgressIndicator(
            color: theme.primaryColor,
            backgroundColor: theme.primaryColor.withOpacity(0.1),
            minHeight: 2,
          ),

        // ─── List ────────────────────────────────────────────────────────────
        Expanded(
          child: isLoading
              ? Center(
            child: CircularProgressIndicator(
              color: theme.primaryColor,
              strokeWidth: 2,
            ),
          )
              : isSearching
              ? _SearchingState()
              : RefreshIndicator(
            color: theme.primaryColor,
            backgroundColor: theme.cardColor,
            onRefresh: _refreshSaveList,
            child: displayList.isEmpty
                ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                Center(child: _EmptyState()),
              ],
            )
                : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 24),
              itemCount: displayList.length,
              itemBuilder: (context, i) => _UserItem(displayList[i]),
            ),
          ),
        ),

      ],
    );
  }


  Widget _EmptyStateScrollable() {
    final theme = Theme.of(context);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset("assets/icons/empty.png", width: 160),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)!.listisempty,
              style: TextStyle(
                fontSize: 13,
                color: theme.unselectedWidgetColor,
              ),
            ),
          ],
        ),
      ],
    );
  }


  // ─── Searching state ──────────────────────────────────────────────────────────
  Widget _SearchingState() {
    final theme = Theme.of(context);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: 6,
      itemBuilder: (context, i) => Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            // Avatar skeleton
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: theme.splashColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            // Text skeleton
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 13,
                    width: 120,
                    decoration: BoxDecoration(
                      color: theme.splashColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 11,
                    width: 80,
                    decoration: BoxDecoration(
                      color: theme.splashColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Empty state ──────────────────────────────────────────────────────────────
  Widget _EmptyState() {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset("assets/icons/empty.png", width: 160),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context)!.listisempty,
            style: TextStyle(
              fontSize: 13,
              color: theme.unselectedWidgetColor,
            ),
          ),
        ],
      ),
    );
  }

  // ─── User list item ───────────────────────────────────────────────────────────
  Widget _UserItem(SaveUser_Model model) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            Strings.DeepLink = model.username;
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => activity_display()));
          },
          onLongPress: () => _showContextMenu(context, model),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Avatar
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Image.network(
                    Server.Root_Address+"/File/${model.profile_image}",
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.person_rounded,
                          color: theme.primaryColor, size: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${model.name} ${model.family}",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        model.phone,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ),
                // Arrow
                Icon(Icons.chevron_right_rounded,
                    color: theme.textTheme.bodySmall?.color, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Context menu ─────────────────────────────────────────────────────────────
  Future<void> _showContextMenu(BuildContext context, SaveUser_Model model) {
    final theme = Theme.of(context);

    return showDialog(
      context: context,
      barrierColor: const Color(0x66000000),
      builder: (_) => Dialog(
        backgroundColor: theme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // User info
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Image.network(
                      Server.Root_Address+"/File/${model.profile_image}",
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.person_rounded,
                            color: theme.primaryColor, size: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${model.name} ${model.family}",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                        Text(
                          "@${model.username}",
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              const Divider(height: 1, color: Color(0xFFEEEEEE)),
              const SizedBox(height: 12),

              // Call
              _DialogBtn(
                icon: Icons.call_rounded,
                label: AppLocalizations.of(context)!.call,
                color: const Color(0xFF22C55E),
                onTap: () {
                  Navigator.pop(context);
                  launchUrl(Uri(scheme: 'tel', path: model.phone));
                },
              ),
              const SizedBox(height: 8),

              // Chat
              StatefulBuilder(
                builder: (ctx, setLocal) => _DialogBtn(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: AppLocalizations.of(context)!.chat,
                  color: const Color(0xFF3B82F6),
                  loading: chatWait,
                  onTap: () async {
                    setLocal(() => chatWait = true);

                    await api_chat().GetChatRoomId(context, model.username);

                    if (!mounted) return;

                    setLocal(() => chatWait = false);
                    Navigator.pop(context);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => activity_chat(user_data: model),
                      ),
                    );
                  },
                ),
              ),

              // Unsave — only shown for the saved-contacts list.
              // Search results aren't necessarily saved, so this action
              // doesn't apply to them.
              if (!isSearchMode) ...[
                const SizedBox(height: 8),
                StatefulBuilder(
                  builder: (ctx, setLocal) => _DialogBtn(
                    icon: Icons.bookmark_remove_outlined,
                    label: AppLocalizations.of(context)!.unsave,
                    color: Colors.red,
                    loading: unsaveWait,
                    onTap: () async {
                      setLocal(() => unsaveWait = true);

                      await api_contact().GetRemoveSave(context, model.username);

                      if (!mounted) return;

                      setLocal(() => unsaveWait = false);

                      if (Navigator.canPop(context)) Navigator.pop(context);

                      await _refreshSaveList();
                    },
                  ),
                ),
              ],

            ],
          ),
        ),
      ),
    );
  }
}

// ─── Dialog button ────────────────────────────────────────────────────────────
class _DialogBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool loading;

  const _DialogBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: ElevatedButton(
        onPressed: loading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: loading
            ? const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 1.8),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}