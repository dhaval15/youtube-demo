class Response<T> {
  final T data;
  final error;

  Response._(this.data, this.error);

  factory Response.success(T data) => Response._(data, null);

  factory Response.failure(error) => Response._(null, error);

  bool get isSuccessful => error == null;
}
