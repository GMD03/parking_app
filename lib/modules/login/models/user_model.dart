// lib/modules/login/models/user_model.dart

class UserModel {
  final String operatorId;
  final String terminalId;
  final String token;

  UserModel({
    required this.operatorId,
    required this.terminalId,
    required this.token,
  });

  Map<String, dynamic> toJson() => {
        'operatorId': operatorId,
        'terminalId': terminalId,
        'token': token,
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        operatorId: json['operatorId'],
        terminalId: json['terminalId'],
        token: json['token'],
      );
}