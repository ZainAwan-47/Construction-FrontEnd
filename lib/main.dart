import 'package:flutter/material.dart';
import 'app.dart';
import 'state/app_state.dart';

void main() {
  // Initialize the lightweight state container
  final appState = AppState();
  
  runApp(ConstructionApp(appState: appState));
}