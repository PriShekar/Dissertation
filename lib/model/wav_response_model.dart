class WavResponseModel {
  final num? responseCode;
  final String? message;

  WavResponseModel({
    this.responseCode,
    this.message,
  });

  factory WavResponseModel.fromJson(Map<String, dynamic> json) {
    return WavResponseModel(
      responseCode: json['response_code'],
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() => {
        'response_code': responseCode,
        'message': message,
      };
}
