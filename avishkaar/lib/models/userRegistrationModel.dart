import 'dart:convert';

class Userregistrationmodel {
  String? userId;
  String? name;
  String? dob;
  String? phonenumber;
  String? profileimg;
  Userregistrationmodel({
    this.userId,
    this.name,
    this.dob,
    this.phonenumber,
    this.profileimg,
  });


  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};
  
    if(userId != null){
      result.addAll({'userId': userId});
    }
    if(name != null){
      result.addAll({'name': name});
    }
    if(dob != null){
      result.addAll({'dob': dob});
    }
    if(phonenumber != null){
      result.addAll({'phonenumber': phonenumber});
    }
    if(profileimg != null){
      result.addAll({'profileimg': profileimg});
    }
  
    return result;
  }

  factory Userregistrationmodel.fromMap(Map<String, dynamic> map) {
    return Userregistrationmodel(
      userId: map['userId'],
      name: map['name'],
      dob: map['dob'],
      phonenumber: map['phonenumber'],
      profileimg: map['profileimg'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Userregistrationmodel.fromJson(String source) => Userregistrationmodel.fromMap(json.decode(source));
}
