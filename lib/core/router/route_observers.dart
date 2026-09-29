import 'package:flutter/material.dart';

/// RouteObservers مركزية — بتتسجّل في GoRouter مرة واحدة.
///
/// كل screen بيستخدم الـ observer المناسب له في didChangeDependencies().
/// وُجد هذا الملف لإزالة P1: core/router كان بيستورد من feature screens.
final RouteObserver<ModalRoute<void>> nutritionRouteObserver =
    RouteObserver<ModalRoute<void>>();

final RouteObserver<ModalRoute<void>> progressRouteObserver =
    RouteObserver<ModalRoute<void>>();
