# youtube

Sample app showcasing youtube search functionality

## Getting Started

edit lib/src/api.dart and put api key for youtube. 

```dart
...

import 'dart:convert' as convert;

const GOOGLE_APIS = 'www.googleapis.com';
const API_KEY = 'Paste your api key here';

Uri searchUrl(dynamic options) =>
    Uri.https(GOOGLE_APIS, 'youtube/v3/search', options);


...
