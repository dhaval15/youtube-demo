class YoutubeSearchResult {
  final String id;
  final String title;
  final String description;
  final String channelTitle;
  final String thumbnail;

  YoutubeSearchResult({
    this.id,
    this.title,
    this.description,
    this.channelTitle,
    this.thumbnail,
  });

  factory YoutubeSearchResult.fromJson(dynamic json) => YoutubeSearchResult(
        id: json['id']['videoId'],
        title: json['snippet']['title'],
        description: json['snippet']['description'],
        channelTitle: json['snippet']['channelTitle'],
        thumbnail: json['snippet']['thumbnails']['default']['url'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'channelTitle': channelTitle,
        'thumbnail': thumbnail
      };

  @override
  String toString() => this.toJson().toString();
}
