import 'package:hive/hive.dart';
// part 'database.g.dart';

@HiveType(typeId: 1)
class SongsModel {
  @HiveField(0)
  String title;

  @HiveField(1)
  String uri;

  @HiveField(2)
  int id;

  SongsModel({required this.title, required this.uri, required this.id});
}
