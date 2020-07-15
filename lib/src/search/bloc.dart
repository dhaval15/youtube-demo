import 'dart:collection';

import 'package:connectivity/connectivity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../api.dart' as Api;
import '../models.dart';

class SearchEvent {}

class SearchQueryEvent extends SearchEvent {
  final String query;

  SearchQueryEvent(this.query);
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
          update: SearchStateUpdate.loading,
          results: null,
          cachedResults: state.cachedResults,
          currentQuery: event.query,
        );
        if (connection != ConnectivityResult.none) {
          final response = await Api.search(event.query);
          if (response.isSuccessful) {
            yield SearchState(
              update: SearchStateUpdate.resultsFound,
              results: response.data,
              cachedResults: state.cachedResults..[event.query] = response.data,
              currentQuery: event.query,
            );
          } else {
            yield SearchState(
              update: SearchStateUpdate.apiError,
              results: null,
              cachedResults: state.cachedResults..[event.query] = response.data,
              currentQuery: event.query,
            );
          }
        } else {
          final results = state.cachedResults[event.query];
          yield SearchState(
            update: results != null
                ? SearchStateUpdate.resultsFound
                : SearchStateUpdate.networkError,
            results: results,
            cachedResults: state.cachedResults,
            currentQuery: event.query,
          );
        }
      } else {
        yield SearchState(
          update: SearchStateUpdate.empty,
          results: null,
          cachedResults: state.cachedResults,
          currentQuery: event.query,
        );
      }
    }
  }
}

enum SearchStateUpdate { empty, loading, resultsFound, networkError, apiError }

class SearchState {
  final SearchStateUpdate update;
  final Map<String, List<YoutubeSearchResult>> cachedResults;
  final List<YoutubeSearchResult> results;
  final String currentQuery;

  SearchState({
    this.update = SearchStateUpdate.empty,
    Map<String, List<YoutubeSearchResult>> cachedResults,
    this.results,
    this.currentQuery,
  }) : cachedResults = cachedResults ?? HashMap();
}
