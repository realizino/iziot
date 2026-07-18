import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iziot/Screens/Device/activity_add_device.dart';
import 'package:iziot/Screens/Device/activity_hub_edit.dart';
import 'package:iziot/Widget/HomeTopBar.dart';
import 'package:iziot/Widget/SideMenu.dart';
import '../Models/Hub/Hub_Model.dart';
import '../api/Hub/api_hub.dart';

class activity_home extends StatefulWidget
{
  const activity_home({Key? key}) : super(key: key);

  @override
  State<activity_home> createState() => _activity_home_state();
}

class _activity_home_state extends State<activity_home>
{
  List<Hub_Model> _hubs = [];
  bool _isLoading = true;

  @override
  void initState()
  {
    super.initState();
    _loadHubs();
  }

  Future<void> _loadHubs() async
  {
    setState(() { _isLoading = true; });

    var hubs = await api_hub().GetHubs(context);

    if (!mounted) return;

    setState(() {
      _hubs = hubs;
      _isLoading = false;
    });
  }

  Color _statusColor(String status)
  {
    if (status == "Enable") return Color(0XFF77BC23);
    if (status == "Poor") return Color(0XFFEF6C00);
    return Color(0XFFFF0000);
  }

  IconData _modelIcon(String iotModel)
  {
    final model = iotModel.toUpperCase();
    if (model.contains("CAM")) return Icons.videocam_rounded;
    return Icons.memory_rounded;
  }

  @override
  Widget build(BuildContext context)
  {
    return SafeArea(
        child: Scaffold(
          backgroundColor: Theme.of(context).splashColor,
          endDrawer: SideMenu(),
          body: Column(
            children: [

              //Get Topbar
              HomeTopBar(context)
              ,
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadHubs,
                  color: Theme.of(context).primaryColor,
                  child: _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : (_hubs.isEmpty)
                      ? _buildEmptyState()
                      : _buildHubGrid(),
                ),
              )

            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              _showAddDeviceOptionsSheet(context);
            },
            backgroundColor: Theme.of(context).primaryColor,
            child: Icon(Icons.add, color: Colors.white),
          ),
        )
    );
  }

  Widget _buildEmptyState()
  {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.18),
        Icon(Icons.dns_outlined, size: 80, color: Color(0XFFCCCCCC)),
        SizedBox(height: 16),
        Center(
          child: Text(
            "No devices found",
            style: TextStyle(color: Theme.of(context).unselectedWidgetColor, fontSize: 15),
          ),
        ),
        SizedBox(height: 6),
        Center(
          child: Text(
            "Tap + to add your first device",
            style: TextStyle(color: Color(0XFF9C9B9D), fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildHubGrid()
  {
    return GridView.builder(
      padding: EdgeInsets.all(14),
      itemCount: _hubs.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.86,
      ),
      itemBuilder: (context, index) {
        final hub = _hubs[index];
        final statusColor = _statusColor(hub.status);

        return GestureDetector(
          onTap: () {
            // TODO: define what happens on regular tap (e.g. open device details/live view)
          },
          onLongPress: () {
            HapticFeedback.mediumImpact();
            _showHubActionsSheet(hub);
          },
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: Offset(0, 3)),
              ],
            ),
            child: Stack(
              children: [

                // Status dot, top-right corner
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: statusColor.withOpacity(0.5), blurRadius: 5)],
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(_modelIcon(hub.iotModel), color: statusColor, size: 24),
                      ),

                      Spacer(),

                      Text(
                        hub.title.isNotEmpty ? hub.title : "Untitled Device",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "SN: ${hub.serialNumber}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11, color: Color(0XFF9C9B9D)),
                      ),
                      SizedBox(height: 6),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          hub.iotType,
                          style: TextStyle(fontSize: 10, color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600),
                        ),
                      ),

                    ],
                  ),
                ),

              ],
            ),
          ),
        );
      },
    );
  }

  //Long-press action sheet: Edit / Copy Token / Delete
  void _showHubActionsSheet(Hub_Model hub)
  {
    final bool supportsToken = hub.iotModel.toUpperCase().contains("PROTOCOL");

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).splashColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              Container(
                margin: EdgeInsets.only(top: 10, bottom: 10),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Color(0XFFCCCCCC),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: Text(
                  hub.title.isNotEmpty ? hub.title : "Untitled Device",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0XFF9C9B9D)),
                ),
              ),

              ListTile(
                leading: Icon(Icons.edit_outlined, color: Theme.of(context).unselectedWidgetColor),
                title: Text("Edit"),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  var result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => activity_hub_edit(hub: hub)),
                  );
                  if (result == true) {
                    _loadHubs();
                  }
                },
              ),

              ListTile(
                enabled: supportsToken,
                leading: Icon(
                  Icons.content_copy_outlined,
                  color: supportsToken ? Theme.of(context).unselectedWidgetColor : Color(0XFFCCCCCC),
                ),
                title: Text(
                  "Copy Token",
                  style: TextStyle(color: supportsToken ? null : Color(0XFFCCCCCC)),
                ),
                onTap: !supportsToken ? null : () async {
                  Navigator.pop(sheetContext);
                  await _copyHubToken(hub);
                },
              ),

              ListTile(
                leading: Icon(Icons.delete_outline, color: Colors.red),
                title: Text("Delete", style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _confirmDeleteHub(hub);
                },
              ),

              SizedBox(height: 10),

            ],
          ),
        );
      },
    );
  }

  Future<void> _copyHubToken(Hub_Model hub) async
  {
    String? token = await api_hub().GetHubToken(context, hub.id);

    if (!mounted) return;

    if (token != null && token.isNotEmpty)
    {
      await Clipboard.setData(ClipboardData(text: token));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Token copied to clipboard")),
      );
    }
  }

  void _confirmDeleteHub(Hub_Model hub)
  {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text("Delete Device"),
          content: Text("Are you sure you want to delete \"${hub.title.isNotEmpty ? hub.title : hub.serialNumber}\"? This action cannot be undone."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                bool success = await api_hub().DeleteHub(context, hub.id);
                if (success) {
                  _loadHubs();
                }
              },
              child: Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  //Bottom sheet with the 2 add-device options
  void _showAddDeviceOptionsSheet(BuildContext context)
  {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).splashColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              Container(
                margin: EdgeInsets.only(top: 10, bottom: 10),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Color(0XFFCCCCCC),
                  borderRadius: BorderRadius.circular(10),
                ),
              )
              ,
              ListTile(
                leading: Icon(Icons.qr_code_scanner, color: Theme.of(context).unselectedWidgetColor),
                title: Text("Scan QR Code"),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Open QR scanner screen
                },
              )
              ,
              ListTile(
                leading: Icon(Icons.edit_note, color: Theme.of(context).unselectedWidgetColor),
                title: Text("Add Manually"),
                onTap: () async {
                  Navigator.pop(context);
                  var result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => activity_add_device()),
                  );
                  if (result == true) {
                    _loadHubs();
                  }
                },
              )
              ,
              SizedBox(height: 10)

            ],
          ),
        );
      },
    );
  }

}