import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:rabchats/data/model/user_model.dart';
import 'package:rabchats/data/services/auth_repository.dart';

class ContactsRepo extends BaseRepository {
  String get currentUserId => FirebaseAuth.instance.currentUser!.uid;

  Future<List<Map<String, dynamic>>> getRegisteredContacts() async {
    try {
      final bool hasPermission = await FlutterContacts.requestPermission();

      if (!hasPermission) {
        print('Contacts permission denied by user.');
        return [];
      }

      final List<Contact> contactList = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: true,
      );

      if (contactList.isEmpty) return [];

      // 3. Map contacts safely (checking if phone list isn't empty)
      final phoneNumbers = contactList.where((c) => c.phones.isNotEmpty).map((
        c,
      ) {
        final rawPhone = c.phones.first.number;
        return {
          'name': c.displayName,
          'phoneNumber': rawPhone.replaceAll(RegExp(r'[\s\-()]'), ''),
          'photo': c.photo,
        };
      }).toList();

      // 4. Fetch your users from Firestore
      final usersSnapshot = await firebaseStore.collection('Users').get();
      final registeredUsers = usersSnapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();

      // 5. Match contacts with registered users
      final matchContacts = phoneNumbers
          .where((contact) {
            final phoneNumber = contact['phoneNumber'];
            return registeredUsers.any((user) {
              // Clean up firestore phone number for a flawless match
              final cleanUserPhone = user.phoneNumber.replaceAll(
                RegExp(r'[\s\-()]'),
                '',
              );
              return cleanUserPhone.contains(phoneNumber.toString()) &&
                  user.uid != currentUserId;
            });
          })
          .map((contact) {
            final registeredUser = registeredUsers.firstWhere((user) {
              final cleanUserPhone = user.phoneNumber.replaceAll(
                RegExp(r'[\s\-()]'),
                '',
              );
              return cleanUserPhone.contains(contact['phoneNumber'].toString());
            });
            return {
              'id': registeredUser.uid,
              'name': contact['name'],
              'phoneNumber': contact['phoneNumber'],
            };
          })
          .toList();

      return matchContacts;
    } catch (e) {
      print('Error loading registered contacts: $e');
      return [];
    }
  }
}
