import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import '../widgets/navbar.dart';
import '../widgets/new_admin_dialog.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({Key? key}) : super(key: key);

  @override
  State<UsersPage> createState() => _UserPageState();
}

class _UserPageState extends State<UsersPage> {
  final UserService _userService = UserService();

  Map<String, List<User>> _groupedUsers = {};
  bool _isLoading = false;

  int _currentPage = 0;
  final int _pageSize = 5;

  final TextEditingController _firstNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  void _showAdminDialog() {
    showDialog(
      context: context,
      builder: (_) => NewAdminDialog(onUserCreated: _fetchUsers),
    );
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await _userService.getAllPaginated(
        page: _currentPage,
        pageSize: _pageSize,
        username: _firstNameController.text,
      );

      // Group users by UserType
      final grouped = <String, List<User>>{};
      for (var user in users) {
        final type = user.userType.typeName;
        grouped.putIfAbsent(type, () => []).add(user);
      }

      setState(() => _groupedUsers = grouped);
    } catch (e) {
      print("Error fetching users: $e");
      setState(() => _groupedUsers = {});
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _nextPage() {
    setState(() => _currentPage++);
    _fetchUsers();
  }

  void _prevPage() {
    if (_currentPage > 0) {
      setState(() => _currentPage--);
      _fetchUsers();
    }
  }

  void _applyFilters() {
    setState(() => _currentPage = 0);
    _fetchUsers();
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _firstNameController,
      decoration: const InputDecoration(
        labelText: 'Pretraga po korisničkom imenu',
      ),
      onChanged: (_) {
        _currentPage = 0;
        _fetchUsers();
      },
    );
  }

  Widget _buildUserTile(User user) {
    return ListTile(
      title: Text('${user.firstName} ${user.lastName}'),
      subtitle: Text(user.email),
      trailing: Text(user.username),
    );
  }

  Widget _buildUserList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_groupedUsers.isEmpty) {
      return const Center(child: Text('No users found.'));
    }

    return Expanded(
      child: ListView(
        children:
            _groupedUsers.entries.map((entry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      entry.key,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...entry.value.map(_buildUserTile),
                ],
              );
            }).toList(),
      ),
    );
  }

  Widget _buildPaginationControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: _currentPage > 0 ? _prevPage : null,
          child: const Text('Previous'),
        ),
        const SizedBox(width: 16),
        Text('Page $_currentPage'),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: _groupedUsers.isNotEmpty ? _nextPage : null,
          child: const Text('Next'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomNavbar(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _showAdminDialog,
              child: const Text("Novi Admin"),
            ),
            _buildSearchBar(),
            const SizedBox(height: 16),
            _buildUserList(),
            const SizedBox(height: 16),
            _buildPaginationControls(),
          ],
        ),
      ),
    );
  }
}
