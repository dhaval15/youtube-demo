import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_shimmer/flutter_shimmer.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../utils/debounce_textfield.dart';
import '../models.dart';
import 'bloc.dart';
import 'search_result_tile.dart';

class SearchScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).canvasColor,
        elevation: 1,
        title: DebounceTextField(
          onChanged: (text) {
            context.bloc<SearchBloc>().add(SearchQueryEvent(text));
          },
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.search,
              color: Theme.of(context).iconTheme.color,
            ),
            border: InputBorder.none,
          ),
        ),
      ),
      body: Container(
        child: BlocBuilder<SearchBloc, SearchState>(
            builder: (BuildContext context, SearchState state) {
          switch (state.update) {
            case SearchStateUpdate.empty:
              return buildSearchHint(context);
            case SearchStateUpdate.loading:
              return buildLoading(context);
            case SearchStateUpdate.resultsFound:
              return buildList(context, state.results);
            case SearchStateUpdate.networkError:
              return buildNetworkErrorHint(context, state.cachedResults.keys);
            case SearchStateUpdate.apiError:
              return buildApiErrorHint(context);
          }
          return null;
        }),
      ),
    );
  }

  Widget buildApiErrorHint(BuildContext context) => ListTile(
        title: Text('Api Error'),
      );

  Widget buildList(BuildContext context, List<YoutubeSearchResult> results) =>
      ListView.separated(
        itemCount: results.length,
        separatorBuilder: (context, _) => Divider(),
        itemBuilder: (context, index) =>
            SearchResultTile(result: results[index]),
      );

  Widget buildLoading(BuildContext context) => ListView.builder(
        itemCount: 10,
        itemBuilder: (context, _) => ListTileShimmer(),
      );

  Widget buildNetworkErrorHint(
          BuildContext context, Iterable<String> cachedQueries) =>
      ListTile(
        leading: SvgPicture.asset(
          'assets/no-signal.svg',
          fit: BoxFit.fitHeight,
          height: 48,
        ),
        title: Text('No Internet Connection \nSaved Queries : '),
        subtitle: Text(cachedQueries.join(', ')),
      );

  Widget buildSearchHint(BuildContext context) => ListTile(
        leading: SvgPicture.asset(
          'assets/yt.svg',
          fit: BoxFit.fitHeight,
          height: 48,
        ),
        title: Text('Type to search'),
      );
}

