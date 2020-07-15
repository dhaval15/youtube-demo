import 'dart:async';
import 'dart:collection';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_shimmer/flutter_shimmer.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'api.dart' as Api;
import 'package:youtube/src/models.dart';
import 'debounce_textfield.dart';

class SearchEvent {}

class SearchQueryEvent extends SearchEvent {
  final String query;

  SearchQueryEvent(this.query);
}

enum SearchStateEvent { empty, loading, resultsFound, networkError, apiError }

class SearchState {
  final SearchStateEvent event;
  final Map<String, List<YoutubeSearchResult>> cachedResults;
  final List<YoutubeSearchResult> results;
  final String currentQuery;

  SearchState({
    this.event = SearchStateEvent.empty,
    Map<String, List<YoutubeSearchResult>> cachedResults,
    this.results,
    this.currentQuery,
  }) : cachedResults = cachedResults ?? HashMap();
}

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final Connectivity connectivity = Connectivity();
  SearchBloc() : super(SearchState());

  @override
  Stream<SearchState> mapEventToState(SearchEvent event) async* {
    if (event is SearchQueryEvent && event.query != state.currentQuery) {
      if (event.query.length > 3) {
        final connection = await connectivity.checkConnectivity();
        yield SearchState(
          event: SearchStateEvent.loading,
          results: null,
          cachedResults: state.cachedResults,
          currentQuery: event.query,
        );
        if (connection != ConnectivityResult.none) {
          final response = await Api.search(event.query);
          if (response.isSuccessful) {
            print(response.error);
            yield SearchState(
              event: SearchStateEvent.resultsFound,
              results: response.data,
              cachedResults: state.cachedResults..[event.query] = response.data,
              currentQuery: event.query,
            );
          } else {
            yield SearchState(
              event: SearchStateEvent.apiError,
              results: null,
              cachedResults: state.cachedResults..[event.query] = response.data,
              currentQuery: event.query,
            );
          }
        } else {
          final results = state.cachedResults[event.query];
          yield SearchState(
            event: results != null
                ? SearchStateEvent.resultsFound
                : SearchStateEvent.networkError,
            results: results,
            cachedResults: state.cachedResults,
            currentQuery: event.query,
          );
        }
      } else {
        yield SearchState(
          event: SearchStateEvent.empty,
          results: null,
          cachedResults: state.cachedResults,
          currentQuery: event.query,
        );
      }
    }
  }
}

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
          switch (state.event) {
            case SearchStateEvent.empty:
              return buildSearchHint(context);
            case SearchStateEvent.loading:
              return buildLoading(context);
            case SearchStateEvent.resultsFound:
              return buildList(context, state.results);
            case SearchStateEvent.networkError:
              return buildNetworkErrorHint(context, state.cachedResults.keys);
            case SearchStateEvent.apiError:
              return buildApiErrorHint(context);
          }
          return null;
        }),
      ),
    );
  }

  Widget buildList(BuildContext context, List<YoutubeSearchResult> results) =>
      ListView.separated(
        itemCount: results.length,
        separatorBuilder: (context, _) => Divider(),
        itemBuilder: (context, index) =>
            SearchResultTile(result: results[index]),
      );

  Widget buildSearchHint(BuildContext context) => ListTile(
        leading: SvgPicture.asset(
          'assets/yt.svg',
          fit: BoxFit.fitHeight,
          height: 48,
        ),
        title: Text('Type to search'),
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

  Widget buildApiErrorHint(BuildContext context) => ListTile(
        title: Text('Api Error'),
      );
}

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
