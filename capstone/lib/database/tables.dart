import 'package:drift/drift.dart';
export 'platform/shared.dart';
part 'tables.g.dart';

// Generate database code
// flutter packages pub run build_runner build --delete-conflicting-outputs

int schemaVersionGlobal = 11;

class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 6, max: 32)();
  TextColumn get description => text().named('body')();
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
  Stream<List<User>>? watchUsers() {
    return select(users).watch();
  }

  Future createOrUpdateUser(User user) {
    return into(users).insertOnConflictUpdate(user);
  }
}
