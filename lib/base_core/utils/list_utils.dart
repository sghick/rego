typedef FilterCondition<T> = dynamic Function(T obj);

extension ListExt<T> on List<T> {
  List<S> filter<S>(FilterCondition<T> condition) {
    List<S> list = [];
    forEach((e) {
      dynamic result = condition(e);
      if (result != null) {
        list.add(result);
      }
    });
    return list;
  }
}
