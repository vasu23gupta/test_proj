class AppUser {
  String name;
  int level;
  int points;
  int nextLevelAt;

  //AppUser({this.name,this.level,this.points,this.nextLevelAt})

  AppUser(Map<String, dynamic> json){
    this.level=json['level'];
    this.points=json['points'];
    this.nextLevelAt=json['nextLevelAt'];
    this.name=json['username'];
  }  
}
