// activity_requests_detail.dart
import 'package:iziot/Data/Colors/App_Colors.dart';
import 'package:iziot/Data/Strings/Strings.dart';
import 'package:iziot/Models/Request/Request_Model.dart';
import 'package:iziot/Screens/User/activity_display.dart';
import 'package:iziot/Widget/MoneyFormat.dart';
import 'package:iziot/Widget/TopBar.dart';
import 'package:iziot/api/Requests/api_requests.dart';
import 'package:iziot/api/User/api_user.dart';
import 'package:iziot/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:latlong2/latlong.dart';

import '../../Models/User/SaveUser_Model.dart';
import '../../Server/Server.dart';
import '../../Widget/GetUserPosition.dart';
import '../../Widget/_MetaChip.dart';
import '../../api/Chat/api_chat.dart';
import '../Chat/activity_chat.dart';
import 'activity_requests_edit.dart';

class activity_requests_detail extends StatefulWidget {
  final Request_Model request;

  const activity_requests_detail({Key? key, required this.request}) : super(key: key);

  @override
  State<activity_requests_detail> createState() => _activity_requests_detail_State();
}

class _activity_requests_detail_State extends State<activity_requests_detail>
{
  late Request_Model _request;

  bool _isWaiting = false;

  // Tracks which action is currently in-flight, so only that button shows
  // a spinner while the rest of the page stays interactive/visible.
  String? _loadingAction;

  final MapController _mapController = MapController();

  bool get isRtl {
    final lang = Localizations.localeOf(context).languageCode;
    return lang == "fa" || lang == "ar";
  }

  int get _currentUserId => Strings.UserData.id ?? 0;
  bool get _isOwner => _request.hostUserId == _currentUserId;
  bool get _isClient => _request.clientUserId == _currentUserId;
  bool get _isBusy => _loadingAction != null;

  // NOTE: assumes Request_Model exposes nullable String `lat` / `lng` fields,
  // same pattern as Business_Model. Adjust the field names below if yours differ.
  double? get _lat => double.tryParse(_request.lat.toString() ?? "");
  double? get _lng => double.tryParse(_request.lng.toString() ?? "");
  bool get _hasLocation => _lat != null && _lng != null && (_lat != 0 || _lng != 0);

  @override
  void initState() {
    super.initState();
    _request = widget.request;
  }

  Future<void> _refreshDetail() async {
    final updated = await api_requests().GetRequestById(context, _request.id);
    if (updated != null && mounted) {
      setState(() => _request = updated);
    }
  }

  // ─── Actions ────────────────────────────────────────────────────────────
  Future<void> _accept() async {
    setState(() => _loadingAction = "accept");
    final ok = await api_requests().AcceptRequest(context, _request.id);
    if (mounted) setState(() => _loadingAction = null);
    if (ok) {
      await _refreshDetail();
      _showToast(AppLocalizations.of(context)!.request_accept);
    }
  }

  Future<void> _cancelAssignment() async {
    setState(() => _loadingAction = "cancel");
    final ok = await api_requests().CancelAssignment(context, _request.id);
    if (mounted) setState(() => _loadingAction = null);
    if (ok) {
      await _refreshDetail();
      _showToast(AppLocalizations.of(context)!.cancel_assignment);
    }
  }

  Future<void> _close() async {
    setState(() => _loadingAction = "close");
    final ok = await api_requests().CloseRequest(context, _request.id);
    if (mounted) setState(() => _loadingAction = null);
    if (ok) {
      await _refreshDetail();
      _showToast(AppLocalizations.of(context)!.request_close);
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(AppLocalizations.of(context)!.delete_request),
        content: Text(AppLocalizations.of(context)!.are_you_sure),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalizations.of(context)!.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _loadingAction = "delete");
    final ok = await api_requests().DeleteRequest(context, _request.id);
    if (mounted) setState(() => _loadingAction = null);
    if (ok && mounted) {
      Navigator.pop(context, true);
    }
  }

  void _edit() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => activity_requests_edit(request: _request)),
    ).then((refresh) {
      if (refresh == true) _refreshDetail();
    });
  }

  void _rate({required bool asHost}) => _showFeedbackDialog(asHost: asHost);

  void _showToast(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      gravity: ToastGravity.BOTTOM,
      toastLength: Toast.LENGTH_SHORT,
      textColor: Colors.white,
      fontSize: 14,
    );
  }


  Widget _PersonRow(BuildContext context,user_id,label,name,rating)
  {
    final theme = Theme.of(context);
    final initial = name.isNotEmpty ? name[0].toUpperCase() : "?";

    return InkWell(
      onTap: (){
        if(user_id != Strings.UserData.id){
          api_user().GetUserById(context, user_id.toString()).then((user) async {
            setState(() { _isWaiting = true; });

            await api_chat().GetChatRoomId(context, user!.username);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => activity_chat(
                  user_data: SaveUser_Model(
                    id: user!.id,
                    name: user!.name,
                    family: user.family,
                    username: user.username,
                    phone: user.phone,
                    profile_image: user.image,
                  ),
                ),
              ),
            );
            setState(() { _isWaiting = false; });

          });
        }

      },
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: theme.primaryColor.withOpacity(0.12),
            child: Text(initial, style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 11, color: theme.disabledColor)),
                const SizedBox(height: 2),
                Text(name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: theme.textTheme.bodyLarge?.color)),
              ],
            ),
          ),
          if (rating != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_rounded, size: 14, color: Color(0xFFF59E0B)),
                  const SizedBox(width: 2),
                  Text(rating.toString(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFF59E0B))),
                ],
              ),
            ),
        ],
      ),
    );
  }


  // ─── Feedback Dialog ────────────────────────────────────────────────────
  Future<void> _showFeedbackDialog({required bool asHost}) async {
    final reportController = TextEditingController();
    int selectedRate = 5;

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setLocal) {
          bool isLoading = false;
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            title: Text(asHost ? AppLocalizations.of(context)!.rate_client : AppLocalizations.of(context)!.rate_host),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    final star = i + 1;
                    return IconButton(
                      onPressed: () => setLocal(() => selectedRate = star),
                      icon: Icon(
                        star <= selectedRate ? Icons.star_rounded : Icons.star_outline_rounded,
                        color: const Color(0xFFF59E0B),
                        size: 32,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: reportController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.optienal_comment,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: Text(AppLocalizations.of(context)!.cancel)),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                  setLocal(() => isLoading = true);
                  final ok = asHost
                      ? await api_requests().SubmitHostFeedback(
                    context,
                    id: _request.id,
                    rate: selectedRate,
                    report: reportController.text.trim().isEmpty ? null : reportController.text.trim(),
                  )
                      : await api_requests().SubmitClientFeedback(
                    context,
                    id: _request.id,
                    rate: selectedRate,
                    report: reportController.text.trim().isEmpty ? null : reportController.text.trim(),
                  );
                  if (!mounted) return;
                  setLocal(() => isLoading = false);
                  if (ok) {
                    Navigator.pop(ctx);
                    await _refreshDetail();
                    _showToast(AppLocalizations.of(context)!.feed_back_submit);
                  }
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: isLoading
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(AppLocalizations.of(context)!.submit),
              ),
            ],
          );
        },
      ),
    );
  }

  // ─── Helpers ────────────────────────────────────────────────────────────
  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Color _statusColor(String status) {
    switch (status) {
      case "open":
        return const Color(0xFF22C55E);
      case "assigned":
        return const Color(0xFFF59E0B);
      case "closed":
        return const Color(0xFF9CA3AF);
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case "open":
        return Icons.lock_open_rounded;
      case "assigned":
        return Icons.bolt_rounded;
      case "closed":
        return Icons.check_circle_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  String _statusLabel(String status, AppLocalizations appLocal) {
    switch (status) {
      case "open":
        return appLocal.open;
      case "assigned":
        return appLocal.assigned;
      case "closed":
        return appLocal.closed;
      default:
        return status;
    }
  }

  String _personName(Map<String, dynamic>? person, int fallbackId, AppLocalizations appLocal) {
    if (person == null) return "${appLocal.user} #$fallbackId";
    return (person["username"] ?? person["name"] ?? "${appLocal.user} #$fallbackId").toString();
  }

  // ─── Build ──────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appLocal = AppLocalizations.of(context)!;
    final statusColor = _statusColor(_request.status);

    return SafeArea(
        child: Directionality(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: Stack(
              children: [

                Column(
                  children: [
                    TopBar(context, true),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _TitleCard(
                              title: _request.title,
                              language: _request.language,
                              statusLabel: _statusLabel(_request.status, appLocal),
                              statusIcon: _statusIcon(_request.status),
                              statusColor: statusColor,
                              views: _request.viewsCount,
                              responses: _request.responsesCount,
                              amount: _request.amount_d,
                              showMenu: _isOwner && _request.isOpen,
                              onEdit: _edit,
                              onDelete: _delete,
                            ),
                            const SizedBox(height: 12),

                            _InfoCard(
                              icon: Icons.description_rounded,
                              title: appLocal.description,
                              child: Text(
                                _request.description,
                                style: TextStyle(fontSize: 14, color: theme.textTheme.bodyLarge?.color, height: 1.6),
                              ),
                            ),
                            const SizedBox(height: 12),

                            _InfoCard(
                              icon: Icons.info_outline_rounded,
                              title: appLocal.details,
                              child: _InfoRowGroup(
                                rows: [
                                  _InfoRowData(
                                    icon: Icons.payments_rounded,
                                    color: const Color(0xFF22C55E),
                                    label: appLocal.amount,
                                    value: _request.amount != null ? "${MoneyFormat(_request.amount_d!)} ${Strings.currencyForLanguage(_request.language)}" : appLocal.not_specified,
                                  ),
                                  _InfoRowData(
                                    icon: Icons.location_on_rounded,
                                    color: theme.primaryColor,
                                    label: appLocal.city,
                                    value: _request.city ?? appLocal.not_specified,
                                  ),
                                  _InfoRowData(
                                    icon: Icons.language_rounded,
                                    color: const Color(0xFF8B5CF6),
                                    label: appLocal.lang,
                                    value: _request.language,
                                  ),
                                  _InfoRowData(
                                    icon: Icons.category_rounded,
                                    color: const Color(0xFFEC4899),
                                    label: appLocal.keywords,
                                    value: _request.keywords ?? appLocal.none,
                                  ),
                                  _InfoRowData(
                                    icon: Icons.people_rounded,
                                    color: const Color(0xFF3B82F6),
                                    label: appLocal.community,
                                    value: _request.community ?? appLocal.none,
                                  ),
                                  _InfoRowData(
                                    icon: Icons.calendar_today_rounded,
                                    color: const Color(0xFFF59E0B),
                                    label: appLocal.expire,
                                    value: _request.expiresAt != null ? _formatDate(_request.expiresAt!) : appLocal.no_expiry,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),

                            _InfoCard(
                              icon: Icons.groups_rounded,
                              title: appLocal.people,
                              child: Column(
                                children: [
                                  _PersonRow(
                                    context,
                                    _request.hostUserId,
                                    appLocal.host,
                                    _personName(_request.host, _request.hostUserId, appLocal),
                                    _request.hostRate,
                                  ),
                                  if (_request.clientUserId != null) ...[
                                    const Divider(height: 18),
                                    _PersonRow(
                                      context,
                                      _request.clientUserId,
                                      appLocal.client,
                                      _personName(_request.client, _request.clientUserId!, appLocal),
                                      _request.clientRate,
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            // ─── Location (only shown if the request has coordinates) ───
                            if (_hasLocation) ...[
                              const SizedBox(height: 12),
                              _buildLocationCard(appLocal),
                            ],

                            // Extra bottom space so content never hides behind the sticky bar
                            // const SizedBox(height: 90),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
                ,
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
            bottomNavigationBar: (!_isWaiting)?_buildBottomBar(theme, appLocal):SizedBox(height: 0,width: 0,),
          ),
        )
    );
  }

  // ─── Location card (same map pattern as activity_business_display.dart) ──
  Widget _buildLocationCard(AppLocalizations appLocal) {
    final lat = _lat!;
    final lng = _lng!;

    return _InfoCard(
      icon: Icons.map_rounded,
      title: appLocal.location,
      child: SizedBox(
        height: 220,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: LatLng(lat, lng),
              zoom: 16.0,
            ),
            children: [
              TileLayer(
                urlTemplate: Server.Root_Address + '/tile/proxy.php?layer=standard&z={z}&x={x}&y={y}',
                userAgentPackageName: 'ir.izino.bzhub',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(lat, lng),
                    width: 50,
                    height: 50,
                    builder: (_) => Icon(Icons.location_pin, color: App_Colors.Theme_Color, size: 40),
                  ),
                  Marker(
                    point: LatLng(UserPosition.Loc_Lat, UserPosition.Loc_Lng),
                    width: 40,
                    height: 40,
                    builder: (_) => Icon(Icons.gps_fixed, color: App_Colors.Blue_Color, size: 26),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Sticky bottom action bar ──────────────────────────────────────────
  Widget? _buildBottomBar(ThemeData theme, AppLocalizations appLocal) {
    Widget? primary;
    Widget? secondary;

    if (_request.isOpen && !_isOwner) {
      primary = _BarButton(
        label: appLocal.accept_request,
        icon: Icons.check_circle_rounded,
        color: const Color(0xFF22C55E),
        loading: _loadingAction == "accept",
        disabled: _isBusy,
        onTap: _accept,
      );
    } else if (_request.isAssigned && _isOwner) {
      primary = _BarButton(
        label: appLocal.close_request,
        icon: Icons.task_alt_rounded,
        color: const Color(0xFF3B82F6),
        loading: _loadingAction == "close",
        disabled: _isBusy,
        onTap: _close,
      );
      secondary = _BarButton(
        label: appLocal.cancel_assignment,
        icon: Icons.undo_rounded,
        color: const Color(0xFFF59E0B),
        outlined: true,
        loading: _loadingAction == "cancel",
        disabled: _isBusy,
        onTap: _cancelAssignment,
      );
    } else if (_request.isAssigned && _isClient) {
      primary = _BarButton(
        label: appLocal.cancel_assignment,
        icon: Icons.undo_rounded,
        color: const Color(0xFFF59E0B),
        loading: _loadingAction == "cancel",
        disabled: _isBusy,
        onTap: _cancelAssignment,
      );
    } else if (_request.isClosed && _isClient && _request.clientRate == null) {
      primary = _BarButton(
        label: appLocal.rate_host,
        icon: Icons.star_rounded,
        color: const Color(0xFFF59E0B),
        loading: _loadingAction == "rate",
        disabled: _isBusy,
        onTap: () => _rate(asHost: false),
      );
    } else if (_request.isClosed && _isOwner && _request.hostRate == null) {
      primary = _BarButton(
        label: appLocal.rate_client,
        icon: Icons.star_rounded,
        color: const Color(0xFFF59E0B),
        loading: _loadingAction == "rate",
        disabled: _isBusy,
        onTap: () => _rate(asHost: true),
      );
    }

    if (primary == null) return null;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        decoration: BoxDecoration(
          color: theme.cardColor,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, -3))],
        ),
        child: Row(
          children: [
            if (secondary != null) ...[
              Expanded(flex: 2, child: secondary),
              const SizedBox(width: 10),
              Expanded(flex: 3, child: primary),
            ] else
              Expanded(child: primary),
          ],
        ),
      ),
    );
  }
}

// ─── Title Card ────────────────────────────────────────────────────────────
class _TitleCard extends StatelessWidget {
  final String title;
  final String language;
  final String statusLabel;
  final IconData statusIcon;
  final Color statusColor;
  final int views;
  final int responses;
  final double? amount;
  final bool showMenu;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TitleCard({
    required this.title,
    required this.language,
    required this.statusLabel,
    required this.statusIcon,
    required this.statusColor,
    required this.views,
    required this.responses,
    this.amount,
    required this.showMenu,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appLocal = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [statusColor.withOpacity(0.10), theme.cardColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 13, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      statusLabel,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: statusColor),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (showMenu)
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert_rounded, color: theme.disabledColor),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  onSelected: (value) {
                    if (value == "edit") onEdit();
                    if (value == "delete") onDelete();
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: "edit",
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 18, color: theme.primaryColor),
                          const SizedBox(width: 10),
                          Text(appLocal.edit),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: "delete",
                      child: Row(
                        children: [
                          const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red),
                          const SizedBox(width: 10),
                          Text(appLocal.delete, style: const TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: theme.textTheme.titleLarge?.color,
              height: 1.3,
            ),
          ),
          if (amount != null) ...[
            const SizedBox(height: 8),
            MetaChip(icon: Icons.payments_rounded, label: "${MoneyFormat(amount!)} ${Strings.currencyForLanguage(language)}", color: const Color(0xFF22C55E)),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.visibility_rounded, size: 15, color: theme.disabledColor),
              const SizedBox(width: 4),
              Text(views.toString(), style: TextStyle(fontSize: 12, color: theme.disabledColor)),
              const SizedBox(width: 14),
              Icon(Icons.forum_rounded, size: 15, color: theme.disabledColor),
              const SizedBox(width: 4),
              Text(responses.toString(), style: TextStyle(fontSize: 12, color: theme.disabledColor)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Generic Info Card Wrapper ──────────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _InfoCard({required this.icon, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 17, color: theme.primaryColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: theme.primaryColor),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

// ─── Info Row (icon-in-circle style, fixes the fixed-width i18n bug) ───────
class _InfoRowData {
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  const _InfoRowData({required this.icon, required this.color, required this.label, required this.value});
}

class _InfoRowGroup extends StatelessWidget {
  final List<_InfoRowData> rows;
  const _InfoRowGroup({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < rows.length; i++) ...[
          if (i > 0) const Divider(height: 18),
          _InfoRow(data: rows[i]),
        ],
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final _InfoRowData data;
  const _InfoRow({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(color: data.color.withOpacity(0.12), shape: BoxShape.circle),
          child: Icon(data.icon, size: 16, color: data.color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(data.label, style: TextStyle(fontSize: 11.5, color: theme.disabledColor, fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(
                data.value,
                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: theme.textTheme.bodyLarge?.color),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Person Row (avatar + name + rating) ───────────────────────────────────
// class _PersonRow extends StatelessWidget {
//   final int? user_id;
//   final String label;
//   final String name;
//   final int? rating;
//
//   const _PersonRow({this.user_id,required this.label, required this.name, this.rating});
//
//   @override
//   Widget build(BuildContext context) {
//
//   }
// }



// ─── Sticky bottom bar button ────────────────────────────────────────────
class _BarButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool outlined;
  final bool loading;
  final bool disabled;
  final VoidCallback onTap;

  const _BarButton({
    required this.label,
    required this.icon,
    required this.color,
    this.outlined = false,
    this.loading = false,
    this.disabled = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = disabled && !loading;

    final child = loading
        ? SizedBox(
      width: 18,
      height: 18,
      child: CircularProgressIndicator(strokeWidth: 2, color: outlined ? color : Colors.white),
    )
        : Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 17, color: outlined ? color : Colors.white),
        const SizedBox(width: 7),
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: outlined ? color : Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    return SizedBox(
      height: 48,
      child: outlined
          ? OutlinedButton(
        onPressed: isDisabled ? null : onTap,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color.withOpacity(isDisabled ? 0.35 : 1)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: child,
      )
          : ElevatedButton(
        onPressed: isDisabled ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          disabledBackgroundColor: color.withOpacity(0.45),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: child,
      ),
    );
  }
}