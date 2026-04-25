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
        dateJoined: (userData['dateJoined'] as Timestamp).toDate(),
        lastLoggedIn: (userData['lastLoggedIn'] as Timestamp).toDate(),
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

    await userRef.update({'lastLoggedIn': FieldValue.serverTimestamp()});
  }

  @override
  String toString() {
    return "<User: id=$id, firstName=$firstName, lastName=$lastName, email=$email>";
  }
}

class ChatMessage {
  String? id;
  final bool ai;
  final String messageContent;
  final DateTime timeSent;

  ChatMessage({
    required this.ai,
    required this.messageContent,
    required this.timeSent,
    this.id,
  });

  Map<String, dynamic> toMap() {
    return {
      'ai': ai,
      'messageContent': messageContent,
      'timeSent': Timestamp.fromDate(timeSent),
    };
  }

  // Refactored to save into the sub-collection path
  Future<void> save(String conversationId) async {
    final db = FirebaseFirestore.instance;
    DocumentReference docRef = await db
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .add(toMap());

    this.id = docRef.id;
  }

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      ai: data['ai'] ?? false,
      messageContent: data['messageContent'] ?? '',
      timeSent: (data['timeSent'] as Timestamp).toDate(),
    );
  }
}

class Conversation {
  String? id;
  String? title;
  List<String> _messageIds = [];
  final String userId;
  final DateTime dateCreated;
  final String language;

  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String collectionName = "conversations";

  Conversation({
    required this.userId,
    required this.dateCreated,
    required this.language,
    this.id,
    this.title,
    List<String>? messageIds,
  }) : _messageIds = messageIds ?? [];

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'dateCreated': Timestamp.fromDate(dateCreated),
      'messages': _messageIds,
      'title': title ?? "New Chat",
      'language': language,
    };
  }

  // Logic to sync with ChatController's sub-collection save
  Future<void> addMessage(ChatMessage newMessage) async {
    if (id == null) return;

    // 1. Save message to the sub-collection
    await newMessage.save(id!);

    // 2. Update the ID list in the parent conversation
    _messageIds.add(newMessage.id!);

    await _db.collection(collectionName).doc(id).update({
      'messages': FieldValue.arrayUnion([newMessage.id]),
    });
  }

  Future<void> saveNew() async {
    DocumentReference docRef = await _db
        .collection(collectionName)
        .add(toMap());
    this.id = docRef.id;
  }

  factory Conversation.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final List<String> msgIds = List<String>.from(data['messages'] ?? []);

    return Conversation(
      id: doc.id,
      title: data['title'] ?? 'New Chat',
      userId: data['userId'] ?? '',
      dateCreated: (data['dateCreated'] as Timestamp).toDate(),
      language: data['language'] ?? "English",
      messageIds: msgIds,
    );
  }

  int get length => _messageIds.length;
  bool get isEmpty => _messageIds.isEmpty;

  static Future<void> deleteById(String id) async {
    await _db.collection(collectionName).doc(id).delete();
  }

  Future<void> updateTitle(String newTitle) async {
    DocumentReference convRef = Conversation._db
        .collection(Conversation.collectionName)
        .doc(this.id!);

    await convRef.update({'title': newTitle});
  }
}
