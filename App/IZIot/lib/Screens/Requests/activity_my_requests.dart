// screens/activity_my_requests.dart
import 'package:iziot/Data/Colors/App_Colors.dart';
import 'package:iziot/Data/Strings/Strings.dart';
import 'package:iziot/Models/Request/Paginated_Requests.dart';
import 'package:iziot/Models/Request/Request_Model.dart';
import 'package:iziot/Widget/MoneyFormat.dart';
import 'package:iziot/Widget/TopBar.dart';
import 'package:iziot/api/Requests/api_requests.dart';
import 'package:iziot/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../Widget/_MetaChip.dart';
import 'activity_requests_detail.dart';

class activity_my_requests extends StatefulWidget {
  const activity_my_requests({Key? key}) : super(key: key);

  @override
  State<activity_my_requests> createState() => _activity_my_requests_State();
}

class _activity_my_requests_State extends State<activity_my_requests> with SingleTickerProviderStateMixin {
  // ─── Theme helpers (mirrors activity_update_business.dart) ─────────────
  Color get _primary => App_Colors.Theme_Color;
  Color get _bgCard => Theme.of(context).splashColor;
  Color get _bgPage => Theme.of(context).scaffoldBackgroundColor;
  Color get _textMain => Theme.of(context).unselectedWidgetColor;
  Color get _textSub => Theme.of(context).disabledColor;

  // ─── Tab Controller ─────────────────────────────────────────────────────
  late TabController _tabController;
  int currentTab = 0;

  // ─── Data ───────────────────────────────────────────────────────────────
  late Future<Paginated_Requests?> _myRequestsFuture;
  late Future<Paginated_Requests?> _acceptedRequestsFuture;

  // ─── Filters ────────────────────────────────────────────────────────────
  String _myRequestsStatusFilter = ''; // '' means all, 'open', 'assigned', 'closed'

  // ─── Refresh Controllers ──────────────────────────────────────────────
  final GlobalKey<RefreshIndicatorState> _myRefreshKey = GlobalKey<RefreshIndicatorState>();
  final GlobalKey<RefreshIndicatorState> _acceptedRefreshKey = GlobalKey<RefreshIndicatorState>();

  // ─── Helpers ──────────────────────────────────────────────────────────
  bool get isRtl {
    final lang = Localizations.localeOf(context).languageCode;
    return lang == "fa" || lang == "ar";
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index != currentTab) {
        setState(() => currentTab = _tabController.index);
      }
    });
    _loadData();
  }

  void _loadData() {
    _myRequestsFuture = api_requests().GetMyRequests(
      context,
      status: _myRequestsStatusFilter.isEmpty ? null : _myRequestsStatusFilter,
    );
    _acceptedRequestsFuture = api_requests().GetMyAcceptedRequests(context);
  }

  Future<void> _refreshMyRequests() async {
    final future = api_requests().GetMyRequests(
      context,
      status: _myRequestsStatusFilter.isEmpty ? null : _myRequestsStatusFilter,
    );
    setState(() => _myRequestsFuture = future);
    await future;
  }

  Future<void> _refreshAcceptedRequests() async {
    final future = api_requests().GetMyAcceptedRequests(context);
    setState(() => _acceptedRequestsFuture = future);
    await future;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ─── Build ──────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appLocal = AppLocalizations.of(context)!;

    return SafeArea(
        child: Directionality(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: Scaffold(
            backgroundColor: _bgPage,
            body: Column(
              children: [
                TopBar(context, true),
                const SizedBox(height: 20),

                // ─── Tabs (same look as activity_update_business.dart) ───────
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 22),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildTabButton(
                          title: appLocal.my_requests,
                          icon: Icons.list_alt_rounded,
                          index: 0,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildTabButton(
                          title: appLocal.accepted,
                          icon: Icons.check_circle_outline_rounded,
                          index: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),

                // ─── Content ──────────────────────────────────────────────────
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildMyRequestsTab(theme, appLocal),
                      _buildAcceptedRequestsTab(theme, appLocal),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }

  // ==================== Tab Button (copied style) ====================
  Widget _buildTabButton({
    required String title,
    required IconData icon,
    required int index,
  }) {
    bool isActive = currentTab == index;
    return InkWell(
      onTap: () {
        setState(() => currentTab = index);
        _tabController.animateTo(index);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? _primary : _bgCard,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : _textSub,
              size: 24,
            ),
            const SizedBox(height: 5),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                color: isActive ? Colors.white : _textSub,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyRequestsTab(ThemeData theme, AppLocalizations appLocal) {
    return Column(
      children: [
        // Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        //   child: Row(
        //     children: [
        //       Text(
        //         appLocal.status,
        //         style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: theme.disabledColor),
        //       ),
        //       const SizedBox(width: 8),
        //       Expanded(
        //         child: SegmentedButton<String>(
        //           segments: [
        //             ButtonSegment(value: '', label: Text(appLocal.all)),
        //             ButtonSegment(value: 'open', label: Text(appLocal.open)),
        //             ButtonSegment(value: 'assigned', label: Text(appLocal.assigned)),
        //             ButtonSegment(value: 'closed', label: Text(appLocal.closed)),
        //           ],
        //           selected: {_myRequestsStatusFilter},
        //           onSelectionChanged: (Set<String> newSelection) {
        //             setState(() {
        //               _myRequestsStatusFilter = newSelection.first;
        //             });
        //             _refreshMyRequests();
        //           },
        //           style: SegmentedButton.styleFrom(
        //             backgroundColor: theme.scaffoldBackgroundColor,
        //             selectedBackgroundColor: theme.primaryColor.withOpacity(0.15),
        //             selectedForegroundColor: theme.primaryColor,
        //             foregroundColor: theme.disabledColor,
        //             side: BorderSide.none,
        //             elevation: 0,
        //           ),
        //         ),
        //       ),
        //     ],
        //   ),
        // ),

        Expanded(
          child: RefreshIndicator(
            key: _myRefreshKey,
            onRefresh: _refreshMyRequests,
            child: FutureBuilder<Paginated_Requests?>(
              future: _myRequestsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error_outline, size: 40, color: App_Colors.Red_Color),
                          const SizedBox(height: 8),
                          Text(
                            appLocal.have_an_error,
                            style: TextStyle(color: App_Colors.Red_Color, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _refreshMyRequests,
                            child: Text(appLocal.retry),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final requests = snapshot.data?.items ?? [];
                if (requests.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset("assets/icons/empty.png", width: 120),
                        const SizedBox(height: 8),
                        Text(
                          appLocal.no_requests_found,
                          style: TextStyle(fontSize: 14, color: theme.disabledColor),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: requests.length,
                  itemBuilder: (context, index) => _buildRequestItem(
                    context,
                    requests[index],
                    index,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAcceptedRequestsTab(ThemeData theme, AppLocalizations appLocal) {
    return RefreshIndicator(
      key: _acceptedRefreshKey,
      onRefresh: _refreshAcceptedRequests,
      child: FutureBuilder<Paginated_Requests?>(
        future: _acceptedRequestsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(strokeWidth: 2));
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, size: 40, color: App_Colors.Red_Color),
                    const SizedBox(height: 8),
                    Text(
                      appLocal.have_an_error,
                      style: TextStyle(color: App_Colors.Red_Color, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _refreshAcceptedRequests,
                      child: Text(appLocal.retry),
                    ),
                  ],
                ),
              ),
            );
          }

          final requests = snapshot.data?.items ?? [];
          if (requests.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset("assets/icons/empty.png", width: 120),
                  const SizedBox(height: 8),
                  Text(
                    appLocal.no_accepted_requests_yet,
                    style: TextStyle(fontSize: 14, color: theme.disabledColor),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: requests.length,
            itemBuilder: (context, index) => _buildRequestItem(
              context,
              requests[index],
              index,
            ),
          );
        },
      ),
    );
  }

  Widget _buildRequestItem(BuildContext context, Request_Model model, int index) {
    final theme = Theme.of(context);
    final appLocal = AppLocalizations.of(context)!;

    final amountText = model.amount_d != null
        ? (model.amount_d! == model.amount_d!.roundToDouble()
        ? model.amount_d!.toInt().toString()
        : model.amount_d!.toStringAsFixed(2))
        : null;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => activity_requests_detail(request: model),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      model.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.primaryColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StatusChip(
                    label: _statusLabel(model.status, appLocal),
                    color: _statusColor(model.status),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                model.description,
                style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  if (amountText != null)
                    MetaChip(icon: Icons.payments_rounded, label: MoneyFormatS(amountText), color: const Color(0xFF22C55E)),
                  if (model.city != null && model.city!.isNotEmpty)
                    MetaChip(icon: Icons.location_on_rounded, label: model.city!, color: theme.primaryColor),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.visibility_outlined, size: 14, color: theme.disabledColor),
                  const SizedBox(width: 2),
                  Text(model.viewsCount.toString(), style: TextStyle(fontSize: 11, color: theme.disabledColor)),
                  const SizedBox(width: 8),
                  Icon(Icons.forum_outlined, size: 14, color: theme.disabledColor),
                  const SizedBox(width: 2),
                  Text(model.responsesCount.toString(), style: TextStyle(fontSize: 11, color: theme.disabledColor)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case "open":
        return const Color(0xFF22C55E);
      case "assigned":
        return const Color(0xFF61a896);
      case "closed":
        return const Color(0xFF9CA3AF);
      default:
        return Colors.grey;
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
}

// ─── Status Chip ──────────────────────────────────────────────────────────
class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}