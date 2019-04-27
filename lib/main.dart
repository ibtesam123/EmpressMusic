import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import './pages/SplashPage.dart';
import './scoped_models/MainModel.dart';
import './pages/HomePage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  final MainModel _model =MainModel();

  @override
  Widget build(BuildContext context) {
    return ScopedModel<MainModel>(
      model: _model,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        routes: <String, WidgetBuilder>{
          '/': (BuildContext context) => SplashPage(),
          '/HomePage': (BuildContext context) => HomePage(),
        },
      ),
    );
  }
}
