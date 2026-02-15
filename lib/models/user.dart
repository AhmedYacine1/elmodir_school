import 'package:isar/isar.dart';

part 'user.g.dart';

@collection
class User {
  Id? id;
  
  @Index(unique: true)
  String username;
  
  String passwordHash;
  String role; // admin, accountant, staff
  
  User({
    this.id,
    required this.username,
    required this.passwordHash,
    required this.role,
  });
}