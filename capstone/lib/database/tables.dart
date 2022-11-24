import 'package:drift/drift.dart';
export 'platform/shared.dart';
part 'tables.g.dart';

// Generate database code
// flutter packages pub run build_runner build --delete-conflicting-outputs

int schemaVersionGlobal = 11;

class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 0)();
  TextColumn get description => text().withLength(min: 0)();
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

  Future deleteUser(int id) {
    return (delete(users)..where((user) => user.id.equals(id))).go();
  }
}
