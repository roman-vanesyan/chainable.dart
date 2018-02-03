import 'dart:async';

typedef dynamic Handler<T>(T context, Function next);

class _Cursor {
  int index = 0;
  int lastIndex = -1;
}

class Chainable<T> {
  final List<Handler<T>> _chain;
  final int _size;

  Chainable(List<Handler<T>> chain)
      : this._chain = chain,
        this._size = chain.length;

  Future<void> call(T context) {
    final cursor = new _Cursor();
    return _do(cursor, context);
  }

  Future<void> _do(_Cursor cursor, T context) async {
    if (_size <= cursor.index) {
      return null;
    }

    if (cursor.index <= cursor.lastIndex) {
      return new Future.error(new Exception('Closure called twice!'));
    }

    final func = _chain[cursor.index];
    cursor.lastIndex = cursor.index;
    cursor.index++;

    return func(context, () => _do(cursor, context));
  }
}
