// lib/modules/device_registration/models/device_registration_model.dart

class DeviceRegistrationModel {
  final String terminalId;
  final String facilityCode;
  final String securityToken;

  DeviceRegistrationModel({
    required this.terminalId,
    required this.facilityCode,
    required this.securityToken,
  });

  Map<String, dynamic> toJson() => {
        'terminalId': terminalId,
        'facilityCode': facilityCode,
        'securityToken': securityToken,
      };

  factory DeviceRegistrationModel.fromJson(Map<String, dynamic> json) =>
      DeviceRegistrationModel(
        terminalId: json['terminalId'],
        facilityCode: json['facilityCode'],
        securityToken: json['securityToken'],
      );
}