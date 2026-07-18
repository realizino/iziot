import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iziot/Widget/LocationMapPicker.dart';
import 'package:iziot/Widget/TopBar.dart';

import '../../api/Hub/api_hub.dart';

class activity_add_device extends StatefulWidget
{
  const activity_add_device({Key? key}) : super(key: key);

  @override
  State<activity_add_device> createState() => _activity_add_device_state();
}

class _activity_add_device_state extends State<activity_add_device>
{
  final _formKey = GlobalKey<FormState>();

  bool _isSubmitting = false;

  final TextEditingController _serialNumberController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _adminNumberController = TextEditingController();
  final TextEditingController _ipAddressController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  double _selectedLat = 45.421347149780544;
  double _selectedLng = -75.71034537140704;

  String _iotType = "STAND";
  String _iotModel = "ESP32CAM";
  String _status = "Enable";
  String _resolution = "640×480";
  String? _timezone;

  final List<String> _iotTypes = ["STAND", "MOBILE"];

  final Map<String, String> _iotModels = {
    "ESP32CAM": "ESP32-Cam",
    "ESP32CAMNEWPROTOCOL": "ESP32-Cam - New Protocol",
    "ESP32": "ESP32",
    "ESP32NEWPROTOCOL": "ESP32 - New Protocol",
  };

  final List<String> _statuses = ["Enable", "Disable"];

  final List<String> _resolutions = [
    "96×96","176×144","240×176","320×240","400×296",
    "640×480","800×600","1024×768","1280×1024","1600×1200"
  ];

  final Map<String, bool> _attributes = {
    "Thermometer": false,
    "Air quality": false,
    "Rotate": false,
    "RealTime": false,
    "Neo M6 (GPS)": false,
    "SIM800C GSM GPRS MOD53": false,
  };

  @override
  void dispose()
  {
    _serialNumberController.dispose();
    _titleController.dispose();
    _adminNumberController.dispose();
    _ipAddressController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context)
  {
    final bool showResolution = _iotModel.startsWith("ESP32CAM");
    final bool showLocation = _iotType == "STAND";

    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).splashColor,
        body: Column(
          children: [

            TopBar(context, true),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text(
                        "Add New IoT Device",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).unselectedWidgetColor,
                        ),
                      ),
                      SizedBox(height: 20),

                      _buildTextField(
                        controller: _serialNumberController,
                        label: "Serial Number",
                        icon: Icons.confirmation_number_outlined,
                      ),

                      _buildTextField(
                        controller: _titleController,
                        label: "Title",
                        icon: Icons.title,
                      ),

                      _buildDropdown(
                        label: "IoT Type",
                        value: _iotType,
                        items: _iotTypes,
                        onChanged: (val) {
                          setState(() { _iotType = val!; });
                        },
                      ),

                      _buildDropdown(
                        label: "IoT Model",
                        value: _iotModel,
                        items: _iotModels.keys.toList(),
                        displayLabels: _iotModels,
                        onChanged: (val) {
                          setState(() { _iotModel = val!; });
                        },
                      ),

                      _buildDropdown(
                        label: "Timezone",
                        value: _timezone,
                        items: const [
                          "UTC", "Asia/Tehran", "Europe/Berlin",
                          "Europe/London", "America/New_York",
                        ],
                        hint: "Select timezone",
                        onChanged: (val) {
                          setState(() { _timezone = val; });
                        },
                      ),

                      _buildDropdown(
                        label: "Status",
                        value: _status,
                        items: _statuses,
                        onChanged: (val) {
                          setState(() { _status = val!; });
                        },
                      ),

                      if (showResolution)
                        _buildDropdown(
                          label: "Resolution",
                          value: _resolution,
                          items: _resolutions,
                          onChanged: (val) {
                            setState(() { _resolution = val!; });
                          },
                        ),

                      _buildTextField(
                        controller: _adminNumberController,
                        label: "Admin Number",
                        icon: Icons.phone_android,
                      ),

                      SizedBox(height: 16),
                      Text(
                        "Attributes",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).unselectedWidgetColor,
                        ),
                      ),
                      ..._attributes.keys.map((key) {
                        return CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          title: Text(key, style: TextStyle(fontSize: 14)),
                          value: _attributes[key],
                          onChanged: (val) {
                            setState(() { _attributes[key] = val ?? false; });
                          },
                        );
                      }).toList(),

                      SizedBox(height: 8),

                      _buildTextField(
                        controller: _ipAddressController,
                        label: "IP Address",
                        icon: Icons.router_outlined,
                      ),

                      // Not every device requires credentials
                      _buildTextField(
                        controller: _usernameController,
                        label: "Username (optional)",
                        icon: Icons.person_outline,
                        required: false,
                      ),

                      _buildTextField(
                        controller: _passwordController,
                        label: "Password (optional)",
                        icon: Icons.lock_outline,
                        obscure: true,
                        required: false,
                      ),

                      if (showLocation) ...[
                        SizedBox(height: 16),
                        Text(
                          "Location",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).unselectedWidgetColor,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Drag the map to position the marker on your device's location",
                          style: TextStyle(fontSize: 12, color: Color(0XFF9C9B9D)),
                        ),
                        SizedBox(height: 10),
                        LocationMapPicker(
                          initialLat: _selectedLat,
                          initialLng: _selectedLng,
                          onLocationChanged: (lat, lng) {
                            _selectedLat = lat;
                            _selectedLng = lng;
                          },
                        ),
                      ],

                      SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _isSubmitting ? null : _submitForm,
                          child: _isSubmitting
                              ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                              : Text("Add Device", style: TextStyle(fontSize: 15)),
                        ),
                      ),

                      SizedBox(height: 20),

                    ],
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

  Future<void> _submitForm() async
  {
    if (!_formKey.currentState!.validate()) return;

    setState(() { _isSubmitting = true; });

    final List<String> selectedAttributes = _attributes.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    var result = await api_hub().AddHub(
      context,
      serialNumber: _serialNumberController.text.trim(),
      title: _titleController.text.trim(),
      iotType: _iotType,
      iotModel: _iotModel,
      status: _status,
      resolution: _iotModel.startsWith("ESP32CAM") ? _resolution : null,
      adminNumber: _adminNumberController.text.trim(),
      ipAddress: _ipAddressController.text.trim(),
      username: _usernameController.text.trim(),
      password: _passwordController.text.trim(),
      lat: _selectedLat.toString(),
      lng: _selectedLng.toString(),
      timezone: _timezone,
      attributes: selectedAttributes,
    );

    if (!mounted) return;

    setState(() { _isSubmitting = false; });

    if (result["success"] == true)
    {
      Navigator.pop(context, true);
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    bool required = true,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator: (value) {
          if (required && (value == null || value.trim().isEmpty)) {
            return "$label is required";
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    Map<String, String>? displayLabels,
    String? hint,
    required void Function(String?) onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        hint: hint != null ? Text(hint) : null,
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(displayLabels != null ? displayLabels[item]! : item),
          );
        }).toList(),
        onChanged: onChanged,
        validator: (val) {
          if (val == null || val.isEmpty) {
            return "Please select $label";
          }
          return null;
        },
      ),
    );
  }

}