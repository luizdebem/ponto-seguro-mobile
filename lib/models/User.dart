class User {
  String _fullName;
  String _email;
  String _password;
  bool _isAdmin;

  User({String fullName, String email, String password, bool isAdmin}) {
    this._fullName = fullName;
    this._email = email;
    this._password = password;
    this._isAdmin = isAdmin;
  }

  String get fullName => _fullName;
  set fullName(String fullName) => _fullName = fullName;
  String get email => _email;
  set email(String email) => _email = email;
  String get password => _password;
  set password(String password) => _password = password;
  bool get isAdmin => _isAdmin;
  set isAdmin(bool isAdmin) => _isAdmin = isAdmin;

  User.fromJson(Map<String, dynamic> json) {
    _fullName = json['fullName'];
    _email = json['email'];
    _password = json['password'];
    _isAdmin = json['isAdmin'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['fullName'] = this._fullName;
    data['email'] = this._email;
    data['password'] = this._password;
    data['isAdmin'] = this._isAdmin;
    return data;
  }
}
