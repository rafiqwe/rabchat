import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:rabchats/core/widgets/chat_list_tile.dart';
import 'package:rabchats/data/repositories/auth_repo.dart';
import 'package:rabchats/data/repositories/chat_repo.dart';
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
  late final ChatRepo _chatRepo;
  late final String _currentUserId;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    _contactsRepo = getIt<ContactsRepo>();
    _chatRepo = getIt<ChatRepo>();
    _currentUserId = getIt<AuthRepo>().currentUser?.uid ?? '';
    _searchController.addListener(() {
      setState(
        () => _searchQuery = _searchController.text.trim().toLowerCase(),
      );
    });
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showContactList(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
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
    final primary = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primary,
        title: const Text(
          'Chats',
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
        ),
        actions: [
          IconButton(
            tooltip: 'Log out',
            onPressed: handleLogOut,
            icon: const Icon(Icons.logout_outlined, color: Colors.white),
          ),
          const SizedBox(width: 4),
        ],
        // bottom: PreferredSize(
        //   preferredSize: const Size.fromHeight(64),
        //   child: Padding(
        //     padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        //     child: Container(
        //       height: 44,
        //       decoration: BoxDecoration(
        //         color: Colors.white,
        //         borderRadius: BorderRadius.circular(24),
        //         boxShadow: [
        //           BoxShadow(
        //             color: Colors.black.withOpacity(0.06),
        //             blurRadius: 6,
        //             offset: const Offset(0, 2),
        //           ),
        //         ],
        //       ),
        //       child: TextField(
        //         controller: _searchController,
        //         style: const TextStyle(fontSize: 14.5),
        //         decoration: const InputDecoration(
        //           hintText: 'Search chats',
        //           hintStyle: TextStyle(color: Colors.grey),
        //           prefixIcon: Icon(Icons.search, color: Colors.grey, size: 22),
        //           border: InputBorder.none,
        //           contentPadding: EdgeInsets.symmetric(vertical: 10),
        //         ),
        //       ),
        //     ),
        //   ),
        // ),
      ),
      body: StreamBuilder(
        stream: _chatRepo.getChatRoom(_currentUserId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            log(snapshot.error.toString());
            return _buildErrorState();
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final chats = snapshot.data!;
          if (chats.isEmpty) {
            return _buildEmptyState();
          }

          final filteredChats = _searchQuery.isEmpty
              ? chats
              : chats.where((chat) {
                  final otherUserId = chat.perticipants.firstWhere(
                    (id) => id != _currentUserId,
                    orElse: () => '',
                  );
                  final name = (chat.perticipantsName?[otherUserId] ?? '')
                      .toLowerCase();
                  return name.contains(_searchQuery);
                }).toList();

          if (filteredChats.isEmpty) {
            return _buildNoResultsState();
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 4),
            itemCount: filteredChats.length,
            separatorBuilder: (context, index) =>
                const Divider(height: 1, indent: 78, color: Color(0xFFEDEDED)),
            itemBuilder: (context, index) {
              final chat = filteredChats[index];
              return ChatListTile(
                chat: chat,
                currentUserId: _currentUserId,
                onTap: () {
                  final otherUserId = chat.perticipants.firstWhere(
                    (id) => id != _currentUserId,
                  );
                  final otherUserName =
                      chat.perticipantsName![otherUserId] ?? 'Unknow';
                  getIt<AppRouter>().push(
                    ChatMessageScreen(
                      receiverId: otherUserId,
                      receiverName: otherUserName,
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primary,
        elevation: 2,
        onPressed: () => _showContactList(context),
        child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
          SizedBox(height: 12),
          Text(
            'Failed to fetch recent chats',
            style: TextStyle(color: Colors.black54, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          const Text(
            'No conversations yet',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tap the button below to start chatting',
            style: TextStyle(fontSize: 13, color: Colors.black45),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off, size: 56, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            'No chats match "$_searchQuery"',
            style: const TextStyle(fontSize: 14, color: Colors.black45),
          ),
        ],
      ),
    );
  }
}

class ContactBottomSheetContent extends StatefulWidget {
  final ContactsRepo contactsRepo;

  const ContactBottomSheetContent({super.key, required this.contactsRepo});

  @override
  State<ContactBottomSheetContent> createState() =>
      _ContactBottomSheetContentState();
}

class _ContactBottomSheetContentState extends State<ContactBottomSheetContent> {
  late final Future<List<Map<String, dynamic>>> _contactsFuture;
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _contactsFuture = widget.contactsRepo.getRegisteredContacts();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              // Drag handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'New Chat',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F2),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'Search contacts',
                      hintStyle: TextStyle(color: Colors.grey),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey,
                        size: 20,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Divider(height: 1),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _contactsFuture,
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

                    var contacts = snapshot.data!;

                    if (_query.isNotEmpty) {
                      contacts = contacts.where((c) {
                        final name = (c['name'] ?? '').toString().toLowerCase();
                        return name.contains(_query);
                      }).toList();
                    }

                    if (contacts.isEmpty) {
                      return Center(
                        child: Text(
                          _query.isEmpty
                              ? 'No contacts found'
                              : 'No contacts match "$_query"',
                          style: const TextStyle(color: Colors.black45),
                        ),
                      );
                    }

                    return ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: contacts.length,
                      separatorBuilder: (context, index) => const Divider(
                        height: 1,
                        indent: 74,
                        color: Color(0xFFF0F0F0),
                      ),
                      itemBuilder: (context, index) {
                        final contact = contacts[index];
                        final String displayName = contact['name'] ?? 'Unknown';

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          leading: CircleAvatar(
                            radius: 22,
                            backgroundColor: primary.withOpacity(0.85),
                            child: Text(
                              displayName.isNotEmpty
                                  ? displayName[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          title: Text(
                            displayName,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
                            contact['phoneNumber'] ?? '',
                            style: const TextStyle(fontSize: 12.5),
                          ),
                          onTap: () {
                            Navigator.pop(context);
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
      },
    );
  }
}
