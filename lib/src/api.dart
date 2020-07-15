import 'dart:io';

import 'models.dart';
import 'package:http/http.dart' as http;
import 'response.dart';
import 'dart:convert' as convert;

const GOOGLE_APIS = 'www.googleapis.com';
const API_KEY = 'Paste your api key here';

Uri searchUrl(dynamic options) =>
    Uri.https(GOOGLE_APIS, 'youtube/v3/search', options);

Future<Response<List<YoutubeSearchResult>>> search(
  String query, {
  int maxResults = 10,
  String nextPageToken,
}) async {
  final url = searchUrl({
    'q': query,
    'key': API_KEY,
    'maxResults': maxResults.toString(),
    'nextPageToken': nextPageToken,
    'part': 'snippet',
  });
  try {
    final response =
        await http.get(url, headers: {'Accept': 'application/json'});
    if (response.statusCode == 200) {
      final records = convert.jsonDecode(response.body)['items'];

      final results = records
          .map((record) => YoutubeSearchResult.fromJson(record))
          .toList()
          .cast<YoutubeSearchResult>();
      return Response.success(results);
    } else {
      return Response.failure('ApiError');
    }
  } on SocketException {
    return Response.failure('NetworkError');
  }
}
