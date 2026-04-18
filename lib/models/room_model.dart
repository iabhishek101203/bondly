class RoomModel {
  final String id;
  final String title;
  final String host;
  final int participants;
  final bool isLive;

  RoomModel({
    required this.id,
    required this.title,
    required this.host,
    this.participants = 0,
    this.isLive = false,
  });

  factory RoomModel.fromMap(Map<String, dynamic> data, String documentId) {
    return RoomModel(
      id: documentId,
      title: data['title'] ?? '',
      host: data['host'] ?? '',
      participants: data['participants'] ?? 0,
      isLive: data['isLive'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'host': host,
      'participants': participants,
      'isLive': isLive,
    };
  }
}
