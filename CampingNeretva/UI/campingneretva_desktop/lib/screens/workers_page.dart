import 'package:flutter/material.dart';
import '../models/worker_model.dart';
import '../services/worker_service.dart';
import '../services/review_service.dart';
import '../services/role_service.dart';
import 'worker_detail_page.dart';
import '../widgets/navbar.dart';
import '../models/role_model.dart';
import '../widgets/app_theme.dart';

class WorkersPage extends StatefulWidget {
  const WorkersPage({super.key});

  @override
  State<WorkersPage> createState() => _WorkersPageState();
}

class _WorkersPageState extends State<WorkersPage> {
  final WorkerService _workerService = WorkerService();
  final ReviewService _reviewService = ReviewService();
  final TextEditingController _searchController = TextEditingController();

  List<Worker> _workers = [];
  List<Worker> _filteredWorkers = [];
  List<Role> _roles = [];
  String _selectedSort = 'Bez sortiranja';
  Role? _selectedRole;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final workers = await _workerService.getAllPaginated(includeRoles: true);
    final roles = await RoleService.fetchAll();

    for (var worker in workers) {
      final reviews = await _reviewService.getByWorkerId(worker.id);
      worker.averageRating =
          reviews.isNotEmpty
              ? reviews.map((r) => r.rating).reduce((a, b) => a + b) /
                  reviews.length
              : 0.0;
    }

    setState(() {
      _workers = workers;
      _roles = roles;
      _filteredWorkers = List.from(workers);
      _isLoading = false;
    });

    _applyFilters();
  }

  void _applyFilters() {
    List<Worker> list = List.from(_workers);

    if (_searchController.text.isNotEmpty) {
      list =
          list
              .where(
                (w) => ('${w.firstName} ${w.lastName}').toLowerCase().contains(
                  _searchController.text.toLowerCase(),
                ),
              )
              .toList();
    }

    if (_selectedRole != null) {
      list =
          list
              .where(
                (w) => w.roles?.any((r) => r.id == _selectedRole!.id) ?? false,
              )
              .toList();
    }

    switch (_selectedSort) {
      case 'Najviša ocjena':
        list.sort((a, b) => b.averageRating!.compareTo(a.averageRating!));
        break;
      case 'Najniža ocjena':
        list.sort((a, b) => a.averageRating!.compareTo(b.averageRating!));
        break;
    }

    setState(() {
      _filteredWorkers = list;
    });
  }

  void _showAddWorkerDialog() {
    final firstNameCtrl = TextEditingController();
    final lastNameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    List<Role> selectedRoles = [];

    showDialog(
      context: context,
      builder:
          (_) => StatefulBuilder(
            builder:
                (context, setStateDialog) => AlertDialog(
                  title: const Text('Novi radnik'),
                  content: SingleChildScrollView(
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            controller: firstNameCtrl,
                            decoration: const InputDecoration(labelText: 'Ime'),
                            validator:
                                (val) =>
                                    val == null || val.isEmpty
                                        ? 'Unesite ime'
                                        : null,
                          ),
                          TextFormField(
                            controller: lastNameCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Prezime',
                            ),
                            validator:
                                (val) =>
                                    val == null || val.isEmpty
                                        ? 'Unesite prezime'
                                        : null,
                          ),
                          TextFormField(
                            controller: phoneCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Telefon',
                            ),
                            validator:
                                (val) =>
                                    val == null || val.isEmpty
                                        ? 'Unesite broj telefona'
                                        : null,
                          ),
                          TextFormField(
                            controller: emailCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                            ),
                            validator:
                                (val) =>
                                    val == null || !val.contains('@')
                                        ? 'Unesite ispravan email'
                                        : null,
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            children:
                                _roles
                                    .map(
                                      (role) => FilterChip(
                                        label: Text(role.roleName),
                                        selected: selectedRoles.contains(role),
                                        onSelected: (selected) {
                                          setStateDialog(() {
                                            if (selected) {
                                              selectedRoles.add(role);
                                            } else {
                                              selectedRoles.remove(role);
                                            }
                                          });
                                        },
                                      ),
                                    )
                                    .toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Odustani'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;
                        await WorkerService.create({
                          'firstName': firstNameCtrl.text,
                          'lastName': lastNameCtrl.text,
                          'phoneNumber': phoneCtrl.text,
                          'email': emailCtrl.text,
                          'roles': selectedRoles.map((r) => r.id).toList(),
                        });
                        Navigator.pop(context);
                        _loadData();
                      },
                      child: const Text('Spremi'),
                    ),
                  ],
                ),
          ),
    );
  }

  void _showRolesDialog() {
    final newRoleCtrl = TextEditingController();

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Pregled uloga'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ..._roles.map(
                  (role) => ListTile(
                    title: Text(role.roleName),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        await RoleService.delete(role.id);
                        Navigator.pop(context);
                        _loadData();
                      },
                    ),
                  ),
                ),
                TextField(
                  controller: newRoleCtrl,
                  decoration: const InputDecoration(labelText: 'Nova uloga'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Zatvori'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await RoleService.create(
                    Role(id: 0, roleName: newRoleCtrl.text),
                  );
                  Navigator.pop(context);
                  _loadData();
                },
                child: const Text('Dodaj'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.greenTheme,
      child: Scaffold(
        appBar: const CustomNavbar(),
        body:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          '👨‍🌾 Upravljanje radnicima',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Pretraži po imenu',
                                prefixIcon: const Icon(Icons.search),
                                border:
                                    Theme.of(
                                      context,
                                    ).inputDecorationTheme.border,
                                enabledBorder:
                                    Theme.of(
                                      context,
                                    ).inputDecorationTheme.enabledBorder,
                                focusedBorder:
                                    Theme.of(
                                      context,
                                    ).inputDecorationTheme.focusedBorder,
                              ),
                              onChanged: (_) => _applyFilters(),
                            ),
                          ),
                          const SizedBox(width: 16),
                          DropdownButton<String>(
                            value: _selectedSort,
                            items:
                                [
                                      'Bez sortiranja',
                                      'Najviša ocjena',
                                      'Najniža ocjena',
                                    ]
                                    .map(
                                      (e) => DropdownMenuItem(
                                        value: e,
                                        child: Text(e),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (val) {
                              setState(() {
                                _selectedSort = val!;
                              });
                              _applyFilters();
                            },
                          ),
                          const SizedBox(width: 16),
                          DropdownButton<Role?>(
                            value: _selectedRole,
                            hint: const Text('Filtriraj po ulozi'),
                            items: [
                              const DropdownMenuItem<Role?>(
                                value: null,
                                child: Text('Sve'),
                              ),
                              ..._roles.map(
                                (r) => DropdownMenuItem(
                                  value: r,
                                  child: Text(r.roleName),
                                ),
                              ),
                            ],
                            onChanged: (val) {
                              setState(() {
                                _selectedRole = val;
                              });
                              _applyFilters();
                            },
                          ),
                          const Spacer(),
                          ElevatedButton(
                            onPressed: _showAddWorkerDialog,
                            child: const Text('Novi radnik'),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: _showRolesDialog,
                            child: const Text('Pregled uloga'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _filteredWorkers.length,
                          itemBuilder: (context, index) {
                            final worker = _filteredWorkers[index];
                            return ListTile(
                              title: Text(worker.fullName),
                              subtitle: Text(
                                worker.roles!.map((e) => e.roleName).join(', '),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.star, color: Colors.amber),
                                  Text(
                                    worker.averageRating!.toStringAsFixed(1),
                                  ),
                                ],
                              ),
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => WorkerDetailPage(worker: worker),
                                  ),
                                );
                                _loadData();
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}
