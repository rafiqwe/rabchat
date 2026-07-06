import 'package:flutter/material.dart';
import 'package:rabchats/data/repositories/contacts_repo.dart';
import 'package:rabchats/data/services/service_loactor.dart';
import 'package:rabchats/logic/cubit/auth_cubit.dart';
import 'package:rabchats/presentation/chats/chat_message_screen.dart';
import 'package:rabchats/presentation/screen/login_screen.dart';
import 'package:rabchats/router/app_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ContactsRepo _contactsRepo;

  @override
  void initState() {
    _contactsRepo = getIt<ContactsRepo>();
    super.initState();
  }

  void _showContactList(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      // Allows the sheet to handle expansion beautifully
      builder: (context) {
        // We pass the repository instance down to our isolated sheet widget
        return ContactBottomSheetContent(contactsRepo: _contactsRepo);
      },
    );
  }

  Future<void> handleLogOut() async {
    try {
      await getIt<AuthCubit>().signOut();
      getIt<AppRouter>().pushAndRemoveUntil(LoginScreen());
    } catch (e) {
      print('Failed to sign out : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Chats'),
        actions: [
          IconButton(
            onPressed: handleLogOut,
            icon: const Icon(Icons.logout_outlined),
          ),
        ],
      ),
      body: const Center(child: Text('User is authenticated')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showContactList(context),
        child: const Icon(Icons.chat, color: Colors.white),
      ),
    );
  }
}

/// --- NEW OPTIMIZED BOTTOM SHEET WIDGET ---
class ContactBottomSheetContent extends StatefulWidget {
  final ContactsRepo contactsRepo;

  const ContactBottomSheetContent({super.key, required this.contactsRepo});

  @override
  State<ContactBottomSheetContent> createState() =>
      _ContactBottomSheetContentState();
}

class _ContactBottomSheetContentState extends State<ContactBottomSheetContent> {
  // Store the future reference so it is evaluated EXACTLY once on initialization
  late final Future<List<Map<String, dynamic>>> _contactsFuture;

  @override
  void initState() {
    super.initState();
    _contactsFuture = widget.contactsRepo.getRegisteredContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // Gives the sheet a nice explicit height constraint
      height: MediaQuery.of(context).size.height * 0.6,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'Contacts',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _contactsFuture, // 🚀 Uses cached future reference now!
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error : ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData) {
                  return const Center(child: Text('No data available'));
                }

                final contacts = snapshot.data!;

                if (contacts.isEmpty) {
                  return const Center(child: Text('No contacts found'));
                }

                return ListView.builder(
                  itemCount: contacts.length,
                  itemBuilder: (context, index) {
                    final contact = contacts[index];
                    final String displayName = contact['name'] ?? 'Unknown';

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(
                          context,
                        ).primaryColor.withValues(alpha: 0.7),
                        child: Text(
                          displayName.isNotEmpty
                              ? displayName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(displayName),
                      subtitle: Text(contact['phoneNumber'] ?? ''),
                      onTap: () {
                        getIt<AppRouter>().push(
                          ChatMessageScreen(
                            receiverId: contact['id'],
                            receiverName: contact['name'],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
