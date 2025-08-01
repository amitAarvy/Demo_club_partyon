class EventModel {
  String clubUID;
  String clubID;
  String venueName;
  String title;
  String briefEvent;
  String artistName;
  List<String> entranceList;
  String genre;
  DateTime date;
  String startTime;
  String endTime;
  int duration;
  bool isHotPick;
  bool hasOffers;
  bool isSponsored;
  String organiserID;
  bool isActive;

  EventModel({
    required this.clubUID,
    required this.clubID,
    required this.venueName,
    required this.title,
    required this.briefEvent,
    required this.artistName,
    required this.entranceList,
    required this.genre,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.isHotPick,
    required this.hasOffers,
    required this.isSponsored,
    this.organiserID='',
    required this.isActive,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      clubUID: json['clubUID'],
      clubID: json['clubID'],
      venueName: json['venueName'],
      title: json['title'],
      briefEvent: json['briefEvent'],
      artistName: json['artistName'],
      entranceList: List<String>.from(json['entranceList']),
      genre: json['genre'],
      date: DateTime.parse(json['date']),
      startTime: json['startTime'],
      endTime: json['endTime'],
      duration: json['duration'],
      isHotPick: json['isHotPick'],
      hasOffers: json['hasOffers'],
      isSponsored: json['isSponsored'],
      organiserID: json['organiserID'],
      isActive: json['isActive'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clubUID': clubUID,
      'clubID': clubID,
      'venueName': venueName,
      'title': title,
      'briefEvent': briefEvent,
      'artistName': artistName,
      'entranceList': entranceList,
      'genre': genre,
      'date': date.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'duration': duration,
      'isHotPick': isHotPick,
      'hasOffers': hasOffers,
      'isSponsored': isSponsored,
      'organiserID': organiserID,
      'isActive': isActive,
    };
  }
}