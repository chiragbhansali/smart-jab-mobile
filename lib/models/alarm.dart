class Alarm {
  int id;
  String pincode;
  String districtId;
  String districtName;
  String isOn;
  String eighteenPlus;
  String fortyfivePlus;
  String covaxin;
  String covishield;
  String dose1;
  String dose2;
  int minAvailable;
  int radius;

  Alarm(
      {this.id,
      this.pincode,
      this.districtId,
      this.districtName,
      this.isOn,
      this.eighteenPlus,
      this.fortyfivePlus,
      this.covaxin,
      this.covishield,
      this.dose1,
      this.dose2,
      this.minAvailable,
      this.radius});

  Map<String, dynamic> toMap() => {
        "id": id,
        "pincode": pincode,
        "districtId": districtId,
        "districtName": districtName,
        "isOn": isOn,
        "eighteenPlus": eighteenPlus,
        "fortyfivePlus": fortyfivePlus,
        "covaxin": covaxin,
        "covishield": covishield,
        "minAvailable": minAvailable,
        "radius": radius,
        "dose1": dose1,
        "dose2": dose2
      };

  factory Alarm.fromMap(Map<String, dynamic> json) => new Alarm(
      id: json["id"],
      pincode: json['pincode'],
      districtId: json['districtId'],
      districtName: json['districtName'],
      isOn: json['isOn'],
      eighteenPlus: json['eighteenPlus'],
      fortyfivePlus: json['fortyfivePlus'],
      covaxin: json['covaxin'],
      covishield: json['covishield'],
      dose1: json['dose1'],
      dose2: json['dose2'],
      minAvailable: json['minAvailable'],
      radius: json['radius']);
}
