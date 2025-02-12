class User {
  String? id;
  String? name;
  String? password;
  String? confirmpassword;
  String? email;


  User({this.name, this.password, this.email,this.confirmpassword});



  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map["name"] = name;
    map["password"] = password;
    map["confirmpassword"] = confirmpassword;
    map["email"] = email;
    return map;
  }

  User.fromJson(dynamic json){
    name = json["name"];
    password = json["password"];
    confirmpassword = json["confirmpassword"];
    email = json["email"];
  }
}