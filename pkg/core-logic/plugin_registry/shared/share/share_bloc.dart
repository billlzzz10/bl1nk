import 'package:flutter/foundation.dart';

// Placeholder BLoC classes while AppFlowy dependencies are decoupled

class ViewPB {
  const ViewPB({
    required this.id,
    this.name = '',
    this.layout = ViewLayoutPB.Document,
  });
  
  final String id;
  final String name;
  final ViewLayoutPB layout;
}

enum ViewLayoutPB {
  Document,
  Grid,
  Board,
  Calendar,
}

class ShareBloc extends ChangeNotifier {
  ShareBloc({required this.view});
  
  final ViewPB view;
  bool isLoading = false;
  String? error;

  void share() {
    // Placeholder implementation
    isLoading = true;
    notifyListeners();
  }

  void export() {
    // Placeholder implementation
    isLoading = true;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}