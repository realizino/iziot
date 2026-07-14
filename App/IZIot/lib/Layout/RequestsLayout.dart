import 'package:iziot/Data/Colors/App_Colors.dart';
import 'package:iziot/Data/Strings/Strings.dart';
import 'package:iziot/Models/Request/Paginated_Requests.dart';
import 'package:iziot/Models/Request/Request_Model.dart';
import 'package:iziot/Widget/MoneyFormat.dart';
import 'package:iziot/api/Requests/api_requests.dart';
import 'package:iziot/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../Components/ComponentsAds.dart';
import '../Screens/Requests/activity_requests_detail.dart';
import '../Screens/Requests/activity_requests_edit.dart';
import '../Widget/_MetaChip.dart';

class RequestsLayout extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => RequestsLayout_State();
}

class RequestsLayout_State extends State<RequestsLayout> {
  late Future<Paginated_Requests?> _requestsFuture;

  // ─── RTL Support ─────────────────────────────────────────────────────────
  bool get isRtl {
    final lang = Localizations.localeOf(context).languageCode;
    return lang == "fa" || lang == "ar";
  }

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  void _loadRequests() {
    _requestsFuture = api_requests().GetRequestsList(context);
  }

  Future<void> _refreshRequests() async {
    final future = api_requests().GetRequestsList(context);
    setState(() => _requestsFuture = future);
    await future;
  }

  void _goToDetail(Request_Model request) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => activity_requests_detail(request: request),
      ),
    ).then((refresh) {
      if (refresh == true) _refreshRequests();
    });
  }

  void _openAddDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => activity_requests_edit(),
      ),
    ).then((refresh) {
      if (refresh == true) _refreshRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appLocal = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Directionality(
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: _refreshRequests,
              child: FutureBuilder<Paginated_Requests?>(
                future: _requestsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: theme.primaryColor,
                        strokeWidth: 2,
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.error_outline, size: 48, color: App_Colors.Red_Color),
                            const SizedBox(height: 12),
                            Text(
                              appLocal.have_an_error,
                              style: TextStyle(fontSize: 14, color: App_Colors.Red_Color),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => setState(() => _loadRequests()),
                              child: Text(appLocal.retry),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final requests = snapshot.data?.items ?? [];

                  if (requests.isEmpty) {
                    return _EmptyState();
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 100, top: 8),
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      final isFirst = index == 0;
                      final showAd = Strings.UserData.blue_check == "0" && isFirst;

                      if (showAd) {
                        return Column(
                          children: [
                            _RequestItem(
                              model: requests[index],
                              index: index,
                              onTap: () => _goToDetail(requests[index]),
                            ),
                            Componentsads(),
                          ],
                        );
                      }
                      return _RequestItem(
                        model: requests[index],
                        index: index,
                        onTap: () => _goToDetail(requests[index]),
                      );
                    },
                  );
                },
              ),
            ),

            // ─── FAB ──────────────────────────────────────────────────────
            Positioned(
              bottom: 16,
              right: 20,
              child: FloatingActionButton(
                onPressed: _openAddDialog,
                backgroundColor: theme.primaryColor,
                elevation: 2,
                child: const Icon(Icons.add, color: Colors.white, size: 28),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Empty State ─────────────────────────────────────────────────────────
  Widget _EmptyState() {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset("assets/icons/empty.png", width: 160),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context)!.no_requests_yet,
            style: TextStyle(
              fontSize: 14,
              color: theme.unselectedWidgetColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.tap_to_create_your_first_request,
            style: TextStyle(
              fontSize: 12,
              color: theme.disabledColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ─── Request Item ────────────────────────────────────────────────────────
  Widget _RequestItem({
    required Request_Model model,
    required int index,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final appLocal = AppLocalizations.of(context)!;
    final statusColor = _statusColor(model.status);

    final amountText = model.amount_d != null
        ? (model.amount_d! == model.amount_d!.roundToDouble()
        ? model.amount_d!.toInt().toString()
        : model.amount_d!.toStringAsFixed(2))
        : null;

    return Container(
      margin: EdgeInsets.only(
        left: 16,
        right: 16,
        top: index == 0 ? 16 : 8,
        bottom: 8,
      ),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                model.title,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: theme.textTheme.titleMedium?.color ?? theme.primaryColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            _StatusChip(label: _statusLabel(model.status, appLocal), color: statusColor),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          model.description,
                          style: TextStyle(fontSize: 12.5, height: 1.4, color: theme.textTheme.bodySmall?.color),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
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
                            Icon(Icons.visibility_rounded, size: 14, color: theme.disabledColor),
                            const SizedBox(width: 3),
                            Text(model.viewsCount.toString(), style: TextStyle(fontSize: 11, color: theme.disabledColor)),
                            const SizedBox(width: 10),
                            Icon(Icons.forum_rounded, size: 14, color: theme.disabledColor),
                            const SizedBox(width: 3),
                            Text(model.responsesCount.toString(), style: TextStyle(fontSize: 11, color: theme.disabledColor)),
                            const Spacer(),
                            Icon(Icons.chevron_right_rounded, size: 18, color: theme.disabledColor),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Status Helpers ──────────────────────────────────────────────────────
  Color _statusColor(String status) {
    switch (status) {
      case "open":
        return const Color(0xFF22C55E);
      case "assigned":
        return const Color(0xFFF59E0B);
      case "closed":
        return const Color(0xFF9CA3AF);
      default:
        return const Color(0xFF9CA3AF);
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
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}