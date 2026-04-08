class DeviceRegistrationModel {
  String terminalId;
  String facilityCode;
  String securityToken;

  DeviceRegistrationModel({
    required this.terminalId,
    required this.facilityCode,
    required this.securityToken,
  });

  // Converts the model to JSON for your API call
  Map<String, dynamic> toJson() {
    return {
      'terminal_id': terminalId,
      'facility_code': facilityCode,
      'security_token': securityToken,
    };
  }

  // If your API returns data about the registration, you'd parse it here
  factory DeviceRegistrationModel.fromJson(Map<String, dynamic> json) {
    return DeviceRegistrationModel(
      terminalId: json['terminal_id'] ?? '',
      facilityCode: json['facility_code'] ?? '',
      securityToken: json['security_token'] ?? '',
    );
  }
}
