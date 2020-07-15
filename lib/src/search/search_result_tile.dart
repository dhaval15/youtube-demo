import 'package:flutter/material.dart';

import '../models.dart';

class SearchResultTile extends StatelessWidget {
  final YoutubeSearchResult result;

  const SearchResultTile({Key key, this.result}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Image.network(result.thumbnail),
      title: Text(
        result.title,
        maxLines: 1,
      ),
      isThreeLine: true,
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 4),
          Text(
            result.description,
            style: Theme.of(context)
                .textTheme
                .subtitle1
                .copyWith(color: Colors.black87.withAlpha(150)),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          SizedBox(height: 4),
          Text(
            result.channelTitle,
            maxLines: 1,
            style: Theme.of(context)
                .textTheme
                .subtitle1
                .copyWith(color: Colors.black87.withAlpha(150)),
          ),
        ],
      ),
    );
  }
}
