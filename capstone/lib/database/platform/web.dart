// web.dart
import 'package:drift/web.dart';
import 'package:capstone/database/tables.dart';

PatientsDatabase constructDb() {
  return PatientsDatabase(WebDatabase('db', logStatements: false));
}
