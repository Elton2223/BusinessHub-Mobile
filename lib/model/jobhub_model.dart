class JobhubModel {
  final int? id;
  final String title;
  final String streetAddress;
  final String country;
  final String postalCode;
  final String state;
  final String city;
  final String latitude;
  final String longitude;
  final String category;
  final int paymentType;
  final double paymentAmount;
  final String? description;
  final String? requirements;
  final int? jobStatus;
  final int? registerId;
  final DateTime? dateCreated;
  final DateTime? dateAccepted;
  final DateTime? dateFinished;
  final String? review;
  final int? reviewRating;

  JobhubModel({
    this.id,
    required this.title,
    required this.streetAddress,
    required this.country,
    required this.postalCode,
    required this.state,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.category,
    required this.paymentType,
    required this.paymentAmount,
    this.description,
    this.requirements,
    this.jobStatus,
    this.registerId,
    this.dateCreated,
    this.dateAccepted,
    this.dateFinished,
    this.review,
    this.reviewRating,
  });

  factory JobhubModel.fromJson(Map<String, dynamic> json) {
    return JobhubModel(
      id: json['id'],
      title: json['title'] ?? '',
      streetAddress: json['street_address'] ?? '',
      country: json['country'] ?? '',
      postalCode: json['postal_code'] ?? '',
      state: json['state'] ?? '',
      city: json['city'] ?? '',
      latitude: json['latitude'] ?? '',
      longitude: json['longitude'] ?? '',
      category: json['category'] ?? '',
      paymentType: json['paymentType'] ?? 0,
      paymentAmount: (json['paymentAmount'] ?? 0).toDouble(),
      description: json['description'],
      requirements: json['requirements'],
      jobStatus: json['jobStatus'],
      registerId: json['registerId'],
      dateCreated: json['dateCreated'] != null 
          ? DateTime.parse(json['dateCreated']) 
          : null,
      dateAccepted: json['dateAccepted'] != null 
          ? DateTime.parse(json['dateAccepted']) 
          : null,
      dateFinished: json['dateFinished'] != null 
          ? DateTime.parse(json['dateFinished']) 
          : null,
      review: json['review'],
      reviewRating: json['reviewRating'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'street_address': streetAddress,
      'country': country,
      'postal_code': postalCode,
      'state': state,
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
      'category': category,
      'paymentType': paymentType,
      'paymentAmount': paymentAmount,
      'description': description,
      'requirements': requirements,
      'jobStatus': jobStatus,
      'registerId': registerId,
      'dateCreated': dateCreated?.toIso8601String(),
      'dateAccepted': dateAccepted?.toIso8601String(),
      'dateFinished': dateFinished?.toIso8601String(),
      'review': review,
      'reviewRating': reviewRating,
    };
  }

  // Helper methods
  String get fullAddress => '$streetAddress, $city, $state, $country';
  
  /// Label for payment: amount is always the total for the whole work, not per hour.
  String get paymentTypeText {
    switch (paymentType) {
      case 1:
        return 'Total for job';
      case 2:
        return 'Fixed (total)';
      case 3:
        return 'Project (total)';
      default:
        return 'Unknown';
    }
  }

  String get jobStatusText {
    switch (jobStatus) {
      case 1:
        return 'Available';
      case 2:
        return 'In Progress';
      case 3:
        return 'Completed';
      default:
        return 'Unknown';
    }
  }

  bool get isAvailable => jobStatus == 1;
  bool get isInProgress => jobStatus == 2;
  bool get isCompleted => jobStatus == 3;

  String get formattedPaymentAmount {
    return 'R${paymentAmount.toStringAsFixed(2)}';
  }

  String get categoryIcon {
    switch (category.toLowerCase()) {
      case 'technology':
        return '💻';
      case 'arts & design':
        return '🎨';
      case 'business':
        return '💼';
      case 'environment':
        return '🌱';
      case 'marketing':
        return '📢';
      default:
        return '🏢';
    }
  }
}
