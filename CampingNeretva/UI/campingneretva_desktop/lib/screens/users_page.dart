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
  bool _hasNextPage = true;

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
        page: _currentPage + 1,
        pageSize: _pageSize,
        username: _firstNameController.text,
      );

      _hasNextPage = users.length == _pageSize;

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
    if (_hasNextPage) {
      setState(() => _currentPage++);
      _fetchUsers();
    }
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

  void _confirmDelete(User user) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Confirm Delete'),
            content: Text('Delete user "${user.firstName} ${user.lastName}"?'),
            actions: [
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
              ElevatedButton(
                child: const Text('Delete'),
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  await _deleteUser(user.id);
                },
              ),
            ],
          ),
    );
  }

  Future<void> _deleteUser(int userId) async {
    setState(() => _isLoading = true);
    try {
      await _userService.deleteUser(userId);
      await _fetchUsers();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete user: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _firstNameController,
      decoration: const InputDecoration(
        labelText: 'Pretraga po korisničkom imenu',
      ),
      onChanged: (_) {
        _applyFilters();
      },
    );
  }

  Widget _buildUserTile(User user) {
    return ListTile(
      title: Text('${user.firstName} ${user.lastName}'),
      subtitle: Text(user.email),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(user.username),
          const SizedBox(width: 10),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _confirmDelete(user),
          ),
        ],
      ),
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
        Text('Page ${_currentPage + 1}'),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: _hasNextPage ? _nextPage : null,
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
