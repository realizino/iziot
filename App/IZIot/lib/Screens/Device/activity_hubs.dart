import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../Models/Hub/Hub_Model.dart';
import '../../Widget/TopBar.dart';
import '../../api/Hub/api_hub.dart';
import 'activity_add_device.dart';
import 'activity_hub_edit.dart';

class activity_hubs extends StatefulWidget
{
  const activity_hubs({Key? key}) : super(key: key);

  @override
  State<activity_hubs> createState() => _activity_hubs_state();
}

class _activity_hubs_state extends State<activity_hubs>
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

  IconData _statusIcon(String status)
  {
    if (status == "Enable") return Icons.check_circle;
    if (status == "Poor") return Icons.donut_small;
    return Icons.cancel;
  }

  @override
  Widget build(BuildContext context)
  {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).splashColor,
        body: Column(
          children: [

            TopBar(context, true),

            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadHubs,
                color: Theme.of(context).primaryColor,
                child: _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : (_hubs.isEmpty)
                    ? _buildEmptyState()
                    : _buildHubList(),
              ),
            ),

          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            var result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => activity_add_device()),
            );
            if (result == true) {
              _loadHubs();
            }
          },
          backgroundColor: Theme.of(context).primaryColor,
          child: Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildEmptyState()
  {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        Icon(Icons.dns_outlined, size: 80, color: Color(0XFFCCCCCC)),
        SizedBox(height: 16),
        Center(
          child: Text(
            "No devices found",
            style: TextStyle(color: Theme.of(context).unselectedWidgetColor, fontSize: 15),
          ),
        ),
      ],
    );
  }

  Widget _buildHubList()
  {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      itemCount: _hubs.length,
      itemBuilder: (context, index) {
        final hub = _hubs[index];

        return Card(
          margin: EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () async {
              var result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => activity_hub_edit(hub: hub)),
              );
              if (result == true) {
                _loadHubs();
              }
            },
            child: Padding(
              padding: EdgeInsets.all(14),
              child: Row(
                children: [

                  Icon(_statusIcon(hub.status), color: _statusColor(hub.status), size: 26),
                  SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hub.title.isNotEmpty ? hub.title : "Untitled Device",
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "SN: ${hub.serialNumber}",
                          style: TextStyle(fontSize: 12, color: Color(0XFF9C9B9D)),
                        ),
                        SizedBox(height: 2),
                        Text(
                          hub.iotType,
                          style: TextStyle(fontSize: 12, color: Color(0XFF9C9B9D)),
                        ),
                      ],
                    ),
                  ),

                  Icon(Icons.keyboard_arrow_right, color: Theme.of(context).unselectedWidgetColor),

                ],
              ),
            ),
          ),
        );
      },
    );
  }

}