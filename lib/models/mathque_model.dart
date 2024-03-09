// To parse this JSON data, do
//
//     final mathqueModel = mathqueModelFromJson(jsonString);

import 'dart:convert';

List<MathqueModel> mathqueModelFromJson(String str) => List<MathqueModel>.from(
    json.decode(str).map((x) => MathqueModel.fromJson(x)));

String mathqueModelToJson(List<MathqueModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class MathqueModel {
  String que;
  String ans;

  MathqueModel({
    required this.que,
    required this.ans,
  });

  factory MathqueModel.fromJson(Map<String, dynamic> json) => MathqueModel(
        que: json["que"],
        ans: json["ans"],
      );

  Map<String, dynamic> toJson() => {
        "que": que,
        "ans": ans,
      };
}
