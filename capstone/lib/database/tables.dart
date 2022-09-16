import 'package:drift/drift.dart';
part 'tables.g.dart';

// Generate database code
// flutter packages pub run build_runner build

int schemaVersionGlobal = 11;

class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 6, max: 32)();
  TextColumn get content => text().named('body')();
  IntColumn get category => integer().nullable()();
}

@DriftDatabase(tables: [Users])
class PatientsDatabase extends _$PatientsDatabase {
  PatientsDatabase(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => schemaVersionGlobal;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (migrator, from, to) async {},
      );

  //Queries can go here
}
