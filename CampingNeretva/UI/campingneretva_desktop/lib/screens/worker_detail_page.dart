import 'package:flutter/material.dart';
import '../models/worker_model.dart';
import '../models/review_model.dart';
import '../models/role_model.dart';
import '../services/review_service.dart';
import '../services/worker_service.dart';
import '../services/role_service.dart';
import '../widgets/navbar.dart';
import '../widgets/app_theme.dart';

class WorkerDetailPage extends StatefulWidget {
  final Worker worker;

  const WorkerDetailPage({super.key, required this.worker});

  @override
  State<WorkerDetailPage> createState() => _WorkerDetailPageState();
}

class _WorkerDetailPageState extends State<WorkerDetailPage> {
  final ReviewService _reviewService = ReviewService();

  bool _loading = true;
  List<Review> _reviews = [];

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    try {
      final reviews = await _reviewService.getByWorkerId(widget.worker.id);
      setState(() {
        _reviews = reviews;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _reviews = [];
        _loading = false;
      });
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Potvrdi brisanje'),
            content: const Text(
              'Jeste li sigurni da želite obrisati ovog radnika?',
            ),
            actions: [
              TextButton(
                style: AppTheme.greenTextButtonStyle,
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Odustani'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Obriši'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        await WorkerService.delete(widget.worker.id);
        if (mounted) Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Greška pri brisanju radnika: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _editRoles() async {
    try {
      final allRoles = await RoleService.fetchAll();
      final currentRoles = widget.worker.roles?.map((r) => r.id).toSet() ?? {};

      final updatedRoles = await showDialog<Set<int>>(
        context: context,
        builder: (context) {
          final selected = Set<int>.from(currentRoles);
          return StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  title: const Text('Uredi uloge'),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: ListView(
                      children:
                          allRoles.map((role) {
                            return CheckboxListTile(
                              title: Text(role.roleName),
                              value: selected.contains(role.id),
                              onChanged: (checked) {
                                setDialogState(() {
                                  if (checked == true) {
                                    selected.add(role.id);
                                  } else {
                                    selected.remove(role.id);
                                  }
                                });
                              },
                            );
                          }).toList(),
                    ),
                  ),
                  actions: [
                    TextButton(
                      style: AppTheme.greenTextButtonStyle,
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Odustani'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, selected),
                      child: const Text('Spremi'),
                    ),
                  ],
                ),
          );
        },
      );

      if (updatedRoles != null) {
        final newRoles =
            allRoles.where((r) => updatedRoles.contains(r.id)).toList();
        final updatedWorker = Worker(
          id: widget.worker.id,
          firstName: widget.worker.firstName,
          lastName: widget.worker.lastName,
          phoneNumber: widget.worker.phoneNumber,
          email: widget.worker.email,
          roles: newRoles,
        );
        await WorkerService.update(updatedWorker);

        setState(() {
          widget.worker.roles = newRoles;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Uloge su ažurirane.')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Greška pri učitavanju uloga: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildReviewTile(Review review) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Row(
          children: List.generate(
            review.rating,
            (index) => const Icon(Icons.star, color: Colors.amber, size: 18),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(review.comment, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 4),
            Text(
              review.user != null
                  ? '${review.user!.firstName} ${review.user!.lastName}'
                  : 'Nepoznat korisnik',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.worker;

    return Scaffold(
      appBar: const CustomNavbar(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${w.firstName} ${w.lastName}',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Uloge: ${w.roles?.map((r) => r.roleName).join(', ') ?? 'Nema uloga'}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              'Prosječna ocjena: ${w.averageRating?.toStringAsFixed(1) ?? 'N/A'}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _editRoles,
                  icon: const Icon(Icons.edit),
                  label: const Text('Uredi uloge'),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _confirmDelete,
                  icon: const Icon(Icons.delete),
                  label: const Text('Obriši'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Recenzije',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child:
                  _loading
                      ? const Center(child: CircularProgressIndicator())
                      : _reviews.isEmpty
                      ? const Text('Nema recenzija za ovog radnika.')
                      : ListView.builder(
                        itemCount: _reviews.length,
                        itemBuilder:
                            (context, index) =>
                                _buildReviewTile(_reviews[index]),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
