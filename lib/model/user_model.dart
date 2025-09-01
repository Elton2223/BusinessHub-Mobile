class UserModel {
  final String? id;
  final String? name;
  final String? surname;
  final String? email;
  final String? profilePhoto;
  final int? ratings;
  final int? phoneNumber;
  final String? streetAddress;
  final String? city;
  final String? state;
  final String? postalCode;
  final String? country;
  final String? identificationDoc;
  final double? latitude;
  final double? longitude;
  final String? password;
  final bool? isAdmin;

  UserModel({
    this.id,
    this.name,
    this.surname,
    this.email,
    this.profilePhoto,
    this.ratings,
    this.phoneNumber,
    this.streetAddress,
    this.city,
    this.state,
    this.postalCode,
    this.country,
    this.identificationDoc,
    this.latitude,
    this.longitude,
    this.password,
    this.isAdmin,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString(),
      name: json['name'],
      surname: json['surname'],
      email: json['email'],
      profilePhoto: json['profile_photo'],
      ratings: json['ratings'],
      phoneNumber: json['phone_number']?.toInt(),
      streetAddress: json['street_address'],
      city: json['city'],
      state: json['state'],
      postalCode: json['postal_code'],
      country: json['country'],
      identificationDoc: json['identification_doc'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      password: json['password'],
      isAdmin: json['isAdmin'] ?? json['is_admin'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'surname': surname,
      'email': email,
      'profile_photo': profilePhoto,
      'ratings': ratings,
      'phone_number': phoneNumber,
      'street_address': streetAddress,
      'city': city,
      'state': state,
      'postal_code': postalCode,
      'country': country,
      'identification_doc': identificationDoc,
      'latitude': latitude,
      'longitude': longitude,
      'password': password,
      'isAdmin': isAdmin,
    };
  }

  // Getter for full name
  String get fullName {
    final name = this.name ?? '';
    final surname = this.surname ?? '';
    return '$name $surname'.trim();
  }

  // Check if user is admin (ID 2 or has admin flag)
  bool get isAdminUser {
    print('🔍 UserModel.isAdminUser: id=$id, isAdmin=$isAdmin');
    final isAdminUser = id == '2' || isAdmin == true;
    print('🔍 UserModel.isAdminUser: result=$isAdminUser');
    return isAdminUser;
  }
}
