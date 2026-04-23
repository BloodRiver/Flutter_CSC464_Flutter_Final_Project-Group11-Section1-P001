import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';

class UserSaveError implements Exception {
  final String message;
  UserSaveError(this.message);

  @override
  String toString() => message;
}

class User {
  late final String? firstName, lastName;
  late final String? email;
  late String? password;
  late final DateTime? dateJoined;
  DateTime? lastLoggedIn;
  String? id;
  static final _db = FirebaseFirestore.instance;
  static const String _collectionName = "users";

  User({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.password,
    this.dateJoined,
    this.lastLoggedIn,
  });

  User.create({
    required this.firstName,
    required this.lastName,
    required String email,
    required String password,
  }) {
    this.email = email.toLowerCase();
    this.password = User._hashPassword(password);
    this.dateJoined = DateTime.now();
  }

  static String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  void setPassword(String password) =>
      this.password = User._hashPassword(password);
  bool checkPassword(String password) {
    return this.password == User._hashPassword(password);
  }

  static Future<User?> findUserByEmail({required String email}) async {
    QuerySnapshot result = await User._db
        .collection(User._collectionName)
        .where('email', isEqualTo: email.toLowerCase())
        .limit(1)
        .get();

    if (result.docs.isNotEmpty) {
      var userData = result.docs.first.data() as Map<String, dynamic>;

      User loadedUser = User(
        id: result.docs.first.id,
        firstName: userData['firstName'],
        lastName: userData['lastName'],
        email: userData['email'],
        password: userData['password'],
        dateJoined: (userData['dateJoined'] as Timestamp?)?.toDate(),
        lastLoggedIn: (userData['lastLoggedIn'] as Timestamp?)?.toDate(),
      );

      return loadedUser;
    }
    return null;
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = Map<String, dynamic>();

    map['firstName'] = this.firstName;
    map['lastName'] = this.lastName;
    map['email'] = this.email;
    map['password'] = this.password;
    map['dateJoined'] = this.dateJoined;
    map['lastLoggedIn'] = this.lastLoggedIn;

    return map;
  }

  Future<void> saveNew() async {
    final existingUser = await User.findUserByEmail(email: this.email!);
    if (existingUser != null) {
      throw UserSaveError("User already exists.");
    }

    DocumentReference docRef = await User._db
        .collection(User._collectionName)
        .add(this.toMap());
    this.id = docRef.id;
  }

  Future<void> updateLogin() async {
    DocumentReference userRef = User._db
        .collection(User._collectionName)
        .doc(this.id!);

    await userRef.update({'lastLoggedIn': DateTime.now()});
  }
}

class ChatMessage {
  late String id;
  final bool ai;
  final String messageContent;
  final DateTime timeSent;
  bool saved = false;

  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _collectionName = "chat_messages";

  ChatMessage({
    required this.ai,
    required this.messageContent,
    required this.timeSent,
  });

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = Map<String, dynamic>();

    map['ai'] = ai;
    map['messageContent'] = messageContent;
    map['timeSent'] = timeSent;

    return map;
  }

  Future<void> save() async {
    if (!saved) {
      DocumentReference docRef = await ChatMessage._db
          .collection(ChatMessage._collectionName)
          .add(this.toMap());

      this.id = docRef.id;
      saved = true;
    }
  }
}

class Conversation {
  late String id;
  List<ChatMessage> _messages = [];
  final String userId;
  final DateTime dateCreated;

  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _collectionName = "conversations";

  Conversation({required this.userId, required this.dateCreated});

  List<String> convertMessagesToIds() {
    List<String> messageIds = [];

    for (ChatMessage eachMessage in _messages) {
      messageIds.add(eachMessage.id);
    }

    return messageIds;
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = Map<String, dynamic>();

    List<String> messageIds = convertMessagesToIds();

    map['userId'] = userId;
    map['dateCreated'] = dateCreated;
    map['messages'] = messageIds;

    return map;
  }

  Future<void> addMessage(ChatMessage newMessage) async {
    _messages.add(newMessage);
    await newMessage.save();

    await Conversation._db
        .collection(Conversation._collectionName)
        .doc(this.id)
        .update({'messages': convertMessagesToIds()});
  }

  Future<void> saveNew() async {
    DocumentReference docRef = await Conversation._db
        .collection(Conversation._collectionName)
        .add(this.toMap());

    this.id = docRef.id;
  }

  bool get isEmpty {
    return _messages.isEmpty;
  }

  int get length {
    return _messages.length;
  }

  ChatMessage getByIndex(int index) {
    return _messages[index];
  }
}
