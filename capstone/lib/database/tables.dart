import 'dart:convert';

import 'package:capstone/pages/RecordResponse.dart';
import 'package:drift/drift.dart';
import 'package:flutter/cupertino.dart' hide Table;
export 'platform/shared.dart';
part 'tables.g.dart';

// Generate database code
// flutter packages pub run build_runner build --delete-conflicting-outputs

int schemaVersionGlobal = 11;

// return null if no more ids or not found
String? determineNextId(currentId) {
  try {
    int currentIndex = 0;
    for (String key in responses.keys) {
      if (key == currentId) {
        break;
      }
      currentIndex++;
    }
    return responses.keys.toList()[currentIndex + 1];
  } catch (e) {
    return null;
  }
}

String? determinePrevId(currentId) {
  try {
    int currentIndex = 0;
    for (String key in responses.keys) {
      if (key == currentId) {
        break;
      }
      currentIndex++;
    }
    return responses.keys.toList()[currentIndex - 1];
  } catch (e) {
    return null;
  }
}

Map<String, Map<String, String>> responses = {
  "Feelings": {
    "0": "How are you doing today?",
    "1": "Do you know where you are?",
    "2": "Do you know what year it is? ",
    "3": "Do you know what season it is? ",
    "4": "Do you remember the time when <insert pleasant memory cue>?",
    "5": "How many children do you have? ",
    "6": "Do you have a spouse? What is their name?",
    "9":
        "Are you feeling scared? Afraid? Tell me more about how you are feeling.",
    "10": "Do you like to read?",
    "11": "Today is <insert date> ",
    "12": "It is the year <insert year>",
    "14": "You are in <insert name of hospital> ",
    "15": "You are in the hospital because you are sick. ",
    "16": "You must be feeling very scared right now. ",
    "17": "Tell me about your friends in school.",
    "18": "Tell me about your children.",
  },
  "Weather": {
    "13": "It is <season> now",
  },
  "Questions": {
    "7": "Where do you live? ",
    "8": "What are your hobbies?",
  },
  "Idle": {"idle": "Record an Idle Head"}
};

String? findResponseId(String id) {
  for (String category in responses.keys) {
    if (responses[category]![id] != null) {
      return responses[category]![id]!;
    }
  }
}

class MapInColumnConverter extends TypeConverter<Map<String, String>, String> {
  const MapInColumnConverter();
  @override
  Map<String, String> fromSql(String fromDb) {
    return Map<String, String>.from(json.decode(fromDb));
  }

  @override
  String toSql(Map<String, String> value) {
    return json.encode(value);
  }
}

class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 0)();
  TextColumn get description => text().withLength(min: 0)();
  // Recordings are stored as a Map<String, String>
  TextColumn get recordings => text().map(const MapInColumnConverter())();
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

  Future<User> getUser(int userID) {
    return (select(users)..where((user) => user.id.equals(userID))).getSingle();
  }

  Stream<User> watchUser(int userID) {
    return (select(users)..where((user) => user.id.equals(userID)))
        .watchSingle();
  }

  Future deleteUser(int id) async {
    User user = await getUser(id);
    Map<String, String> recordings = user.recordings;
    for (String recordingKey in recordings.keys) {
      try {
        await deleteVideo(null, recordings[recordingKey] ?? "");
      } catch (e) {
        debugPrint(e.toString());
      }
    }
    return (delete(users)..where((user) => user.id.equals(id))).go();
  }
}
