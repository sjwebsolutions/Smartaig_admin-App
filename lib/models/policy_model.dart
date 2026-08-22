class PolicyModel {
  final bool success;
  final PolicyData data;

  PolicyModel({
    required this.success,
    required this.data,
  });

  factory PolicyModel.fromJson(Map<String, dynamic> json) {
    return PolicyModel(
      success: json['success'] ?? false,
      data: PolicyData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.toJson(),
    };
  }
}

class PolicyData {
  final String termsOfUse;
  final String privacyPolicy;

  PolicyData({
    required this.termsOfUse,
    required this.privacyPolicy,
  });

  factory PolicyData.fromJson(Map<String, dynamic> json) {
    return PolicyData(
      termsOfUse: json['terms_of_use'] ?? '',
      privacyPolicy: json['privacy_policy'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'terms_of_use': termsOfUse,
      'privacy_policy': privacyPolicy,
    };
  }
}