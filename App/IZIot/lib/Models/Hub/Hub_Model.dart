class Hub_Model
{
  int id;
  String title;
  String serialNumber;
  String iotModel;
  String iotType;
  String status;
  String permission;
  String createdAt;
  String updatedAt;
  String lat;
  String lng;
  String attribute;
  String timezone;
  String defaultResolution;
  String adminMobile;
  String ipAddress;
  String url;
  String username;

  Hub_Model({
    this.id = 0,
    this.title = '',
    this.serialNumber = '',
    this.iotModel = '',
    this.iotType = '',
    this.status = '',
    this.permission = '',
    this.createdAt = '',
    this.updatedAt = '',
    this.lat = '',
    this.lng = '',
    this.attribute = '',
    this.timezone = '',
    this.defaultResolution = '',
    this.adminMobile = '',
    this.ipAddress = '',
    this.url = '',
    this.username = '',
  });

  factory Hub_Model.fromJson(Map<String, dynamic> json)
  {
    return Hub_Model(
      id: json['id'] ?? 0,
      title: json['title']?.toString() ?? '',
      serialNumber: json['serial_number']?.toString() ?? '',
      iotModel: json['iot_model']?.toString() ?? '',
      iotType: json['iot_type']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      permission: json['permission']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      lat: json['lat']?.toString() ?? '',
      lng: json['lng']?.toString() ?? '',
      attribute: json['attribute']?.toString() ?? '',
      timezone: json['timezone']?.toString() ?? '',
      defaultResolution: json['default_resolution']?.toString() ?? '',
      adminMobile: json['admin_mobile']?.toString() ?? '',
      ipAddress: json['ip_address']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
    );
  }

  static List<Hub_Model> fromJsonList(List<dynamic> jsonList)
  {
    return jsonList.map((item) => Hub_Model.fromJson(item)).toList();
  }
}