class UserModel {
  final String operatorId;
  final String terminalId;
  final String token;

  UserModel({
    required this.operatorId,
    required this.terminalId,
    required this.token,
  });

  // Example factory for parsing JSON from a real API later
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      operatorId: json['operator_id'],
      terminalId: json['terminal_id'],
      token: json['token'],
    );
  }
}