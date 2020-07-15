import 'dart:async';
import 'dart:collection';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_shimmer/flutter_shimmer.dart';
import 'api.dart' as Api;
import 'package:youtube/src/models.dart';
import 'debounce_textfield.dart';

class SearchEvent {}

class SearchQueryEvent extends SearchEvent {
  final String query;

  SearchQueryEvent(this.query);
}

enum SearchStateEvent { empty, loading, resultsFound, networkError }

class SearchState {
  final SearchStateEvent event;
  final Map<String, List<YoutubeSearchResult>> cachedResults;
  final List<YoutubeSearchResult> results;

  SearchState({
    this.event = SearchStateEvent.empty,
    Map<String, List<YoutubeSearchResult>> cachedResults,
    this.results,
  }) : cachedResults = cachedResults ?? HashMap();
}

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final Connectivity connectivity = Connectivity();
  SearchBloc() : super(SearchState());

  @override
  Stream<SearchState> mapEventToState(SearchEvent event) async* {
    if (event is SearchQueryEvent) {
      if (event.query.length > 3) {
        final connection = await connectivity.checkConnectivity();
        yield SearchState(
          event: SearchStateEvent.loading,
          results: null,
          cachedResults: state.cachedResults,
        );
        if (connection != ConnectivityResult.none) {
          final response = await Api.search(event.query);
          yield SearchState(
            event: SearchStateEvent.resultsFound,
            results: response.data,
            cachedResults: state.cachedResults..[event.query] = response.data,
          );
        } else {
          final results = state.cachedResults[event.query];
          yield SearchState(
            event: results != null
                ? SearchStateEvent.resultsFound
                : SearchStateEvent.networkError,
            results: results,
            cachedResults: state.cachedResults,
          );
        }
      } else {
        yield SearchState(
          event: SearchStateEvent.empty,
          results: null,
          cachedResults: state.cachedResults,
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

  Widget buildSearchHint(BuildContext context) =>
      ListTile(title: Text('Type to search'));

  Widget buildLoading(BuildContext context) => ListView.builder(
        itemCount: 10,
        itemBuilder: (context, _) => ListTileShimmer(),
      );

  Widget buildNetworkErrorHint(
          BuildContext context, Iterable<String> cachedQueries) =>
      ListTile(
        title: Text('No Internet Connection \nSaved Queries : '),
        subtitle: Text(cachedQueries.join(', ')),
      );
}

class SearchResultTile extends StatelessWidget {
  final YoutubeSearchResult result;

  const SearchResultTile({Key key, this.result}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Image.network(result.thumbnail),
      title: Text(result.title),
    );
  }
}
