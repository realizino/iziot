class User_Model {
  final int id;
  final String username;
  final String? password; // ممکن است در پاسخ نیاید
  final String name;
  final String family;
  final String phone;
  final String email;
  final String bio;
  final String loginToken;
  final String dateTime;
  final String userType;
  final String status;
  final String website;
  final String address;
  final String googleAuth;
  final int? profileImageFileId;
  final int? cityId;
  final String verify_check;

  // در صورت نیاز می‌توانید فیلدهای اضافی را نیز با ذکر منبع نگه دارید
  // اما برای تطابق با مدل جاوا، آن‌ها را حذف می‌کنیم.
  // اگر API آن‌ها را برمی‌گرداند، می‌توانید به انتها اضافه کنید.

  User_Model({
    required this.id,
    required this.username,
    this.password,
    required this.name,
    required this.family,
    required this.phone,
    required this.email,
    required this.bio,
    required this.loginToken,
    required this.dateTime,
    required this.userType,
    required this.status,
    required this.website,
    required this.address,
    required this.googleAuth,
    this.profileImageFileId,
    this.cityId,
    required this.verify_check,
  });

  factory User_Model.fromJson(Map<String, dynamic> json) {
    return User_Model(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      password: json['password'], // ممکن است null باشد
      name: json['name'] ?? '',
      family: json['family'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      bio: json['bio'] ?? '',
      loginToken: json['login_token'] ?? '',
      dateTime: json['date_time'] ?? '',
      userType: json['user_type'] ?? '',
      status: json['status'] ?? '',
      website: json['website'] ?? '',
      address: json['address'] ?? '',
      googleAuth: json['google_auth'] ?? '',
      verify_check: json['verify_check'] ?? '',
      profileImageFileId: json['profile_image_file_id'] != null
          ? int.tryParse(json['profile_image_file_id'].toString())
          : null,
      cityId: json['city_id'] != null
          ? int.tryParse(json['city_id'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      if (password != null) 'password': password,
      'name': name,
      'family': family,
      'phone': phone,
      'email': email,
      'bio': bio,
      'login_token': loginToken,
      'date_time': dateTime,
      'user_type': userType,
      'status': status,
      'website': website,
      'address': address,
      'google_auth': googleAuth,
      'verify_check': verify_check,
      if (profileImageFileId != null) 'profile_image_file_id': profileImageFileId,
      if (cityId != null) 'city_id': cityId,
    };
  }
}