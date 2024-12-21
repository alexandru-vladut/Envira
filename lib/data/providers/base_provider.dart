import 'dart:async';

import 'package:flutter/material.dart';

class BaseProvider<T> extends ChangeNotifier {
  final Stream<List<T>> Function({String? fieldName, String? value}) _streamFunction;
  List<T> _items = [];  

  // A subscription to the stream
  StreamSubscription<List<T>>? subscription;
  // A completer to signal when initial data is loaded
  Completer<void> initializationCompleter = Completer<void>();

  BaseProvider(this._streamFunction);

  List<T> get items => _items;

  // Start listening to the stream with optional filtering
  void startListening({String? fieldName, String? value}) {
    subscription = _streamFunction(fieldName: fieldName, value: value).listen((itemList) {
      _items = itemList;
      if (!initializationCompleter.isCompleted) {
        initializationCompleter.complete(); // Completes the future once we get initial data
      }
      notifyListeners(); // Notify listeners so UI can update
    });
  }

  // Stop listening to the stream
  void stopListening() {
    _items = [];
    subscription?.cancel();
    notifyListeners();
  }

  @override
  void dispose() {
    subscription?.cancel(); // Ensure subscription is cancelled on dispose
    super.dispose();
  }
}
