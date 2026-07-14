import 'package:iziot/Data/Colors/App_Colors.dart';
import 'package:iziot/Data/Strings/Strings.dart';
import 'package:iziot/Screens/Business/activity_update_business.dart' hide activity_create_business;
import 'package:iziot/Screens/Business/activity_create_business.dart';
import 'package:iziot/Widget/TopBar.dart';
import 'package:iziot/l10n/app_localizations.dart';
import 'package:iziot/main.dart';
import 'package:flutter/material.dart';

import '../../Models/Business/Business_Model.dart';
import '../../api/Bueiness/api_business.dart';

class activity_business extends StatefulWidget {
  const activity_business({super.key});

  @override
  State<activity_business> createState() => _ActivityBusinessState();
}

class _ActivityBusinessState extends State<activity_business> {
  // Theme shortcuts
  Color get _primary => App_Colors.Theme_Color;
  Color get _bgCard => Theme.of(context).splashColor;
  Color get _bgPage => Theme.of(context).scaffoldBackgroundColor;
  Color get _textMain => Theme.of(context).unselectedWidgetColor;
  Color get _textSub => Theme.of(context).disabledColor;

  bool get isRtl {
    final lang = Localizations.localeOf(context).languageCode;
    return lang == "fa" || lang == "ar";
  }

  late Future<List<Business_Model>> _businessFuture;

  @override
  void initState() {
    super.initState();
    _businessFuture = api_business().GetBusinessList(context);
  }

  void _refreshList() {
    setState(() {
      _businessFuture = api_business().GetBusinessList(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: _bgPage,
          body: Column(
            children: [
              TopBar(context, true),
              Expanded(
                child: FutureBuilder<List<Business_Model>>(
                  future: _businessFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: _primary,
                          strokeWidth: 2,
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset("assets/images/error.png", width: 150),
                            const SizedBox(height: 10),
                            Text(
                              AppLocalizations.of(context)!.error_when_read_data,
                              style: TextStyle(color: _textSub, fontSize: 12),
                            ),
                          ],
                        ),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              "assets/icons/empty.png",
                              height: 160,
                              width: 250,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              AppLocalizations.of(context)!.not_have_any_business,
                              style: TextStyle(color: _textMain, fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            InkWell(
                              onTap: _navigateToCreateBusiness,
                              child: Text(
                                AppLocalizations.of(context)!.create_new_business,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final businesses = snapshot.data!;

                    return RefreshIndicator(
                      onRefresh: () async => _refreshList(),
                      child: ListView.builder(
                        itemCount: businesses.length,
                        padding: const EdgeInsets.only(top: 7, bottom: 80),
                        itemBuilder: (context, index) {
                          return _BusinessItem(model: businesses[index]);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _navigateToCreateBusiness,
            backgroundColor: _primary,
            elevation: 3,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Future<void> _navigateToCreateBusiness() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const activity_create_business()),
    );

    if (result == true) {
      _refreshList();
    }
  }

  // ====================== Business Item ======================
  Widget _BusinessItem({required Business_Model model}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      child: Material(
        color: _bgCard,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => activity_update_business(model: model),
              ),
            );

            if (result == true) {
              _refreshList();
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Business Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 80,
                    height: 80,
                    color: _bgPage,
                    child: model.image.isEmpty
                        ? Icon(Icons.store_rounded, size: 36, color: _textSub)
                        : Image.network(
                      model.image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Icon(Icons.store_rounded, size: 36, color: _textSub),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Information
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        model.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: _textMain,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        model.address.isEmpty
                            ? AppLocalizations.of(context)!.not_have_address
                            : model.address,
                        style: TextStyle(fontSize: 12, color: _textSub),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),

                      // Status & Subscription
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: model.status == "1"
                                  ? const Color(0xFF22C55E).withOpacity(0.1)
                                  : Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              model.status == "1"
                                  ? AppLocalizations.of(context)!.active
                                  : AppLocalizations.of(context)!.deactive,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: model.status == "1"
                                    ? const Color(0xFF22C55E)
                                    : Colors.red,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.workspace_premium_outlined,
                                    size: 11, color: _primary),
                                const SizedBox(width: 3),
                                Text(
                                  model.subscribe_type,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: _primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Working Hours
                      Row(
                        children: [
                          Icon(Icons.access_time_rounded, size: 12, color: _textSub),
                          const SizedBox(width: 4),
                          Text(
                            "${model.open_at} ${AppLocalizations.of(context)!.until} ${model.close_at}",
                            style: TextStyle(fontSize: 11, color: _textSub),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Arrow
                Icon(
                  // (MyApp.language == "fa" || MyApp.language == "ar") ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
                  Icons.chevron_right_rounded,
                  color: _textSub,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}