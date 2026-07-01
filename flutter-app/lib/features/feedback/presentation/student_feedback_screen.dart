import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../batches/presentation/batch_provider.dart';
import '../../home/presentation/home_provider.dart';
import 'feedback_provider.dart';

class StudentFeedbackScreen extends ConsumerWidget {
  const StudentFeedbackScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedbackAsync = ref.watch(myFeedbackProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Feedback')),
      body: feedbackAsync.when(
        loading: () => const Center(child: ChakraLoader()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('No feedback submitted yet.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  key: ValueKey(item.id),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item.batchName ?? 'General Feedback',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text(
                            DateFormat('MMM d, yyyy').format(item.createdAt),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                      if (item.trainerName != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Trainer: ${item.trainerName}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: List.generate(5, (i) {
                          return Icon(
                            i < item.rating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 20,
                          );
                        }),
                      ),
                      if (item.comments != null &&
                          item.comments!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          item.comments!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFeedbackForm(context, ref),
        tooltip: 'Submit Feedback',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showFeedbackForm(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _FeedbackFormBottomSheet(),
    );
  }
}

class _FeedbackFormBottomSheet extends ConsumerStatefulWidget {
  const _FeedbackFormBottomSheet();

  @override
  ConsumerState<_FeedbackFormBottomSheet> createState() =>
      _FeedbackFormBottomSheetState();
}

class _FeedbackFormBottomSheetState
    extends ConsumerState<_FeedbackFormBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _commentsCtrl = TextEditingController();
  String? _selectedBatchId;
  int _selectedRating = 0;
  bool _submitting = false;

  @override
  void dispose() {
    _commentsCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedBatchId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a batch')));
      return;
    }
    if (_selectedRating < 1) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a rating')));
      return;
    }

    setState(() => _submitting = true);

    try {
      final allBatches = ref.read(batchesProvider).value;
      final trainerId = allBatches != null
          ? (allBatches.any((b) => b.id == _selectedBatchId)
                ? allBatches
                      .firstWhere((b) => b.id == _selectedBatchId)
                      .trainerId
                : null)
          : null;

      await ref
          .read(myFeedbackProvider.notifier)
          .submit(
            batchId: _selectedBatchId,
            rating: _selectedRating,
            comments: _commentsCtrl.text.trim().isNotEmpty
                ? _commentsCtrl.text.trim()
                : null,
            trainerId: trainerId,
          );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Feedback submitted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit feedback: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeDataAsync = ref.watch(homeDataProvider);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Submit Feedback',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                homeDataAsync.when(
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: ChakraLoader(size: 32),
                    ),
                  ),
                  error: (e, _) => Text(
                    'Failed to load batches: $e',
                    style: const TextStyle(color: Colors.red),
                  ),
                  data: (data) {
                    final batches = data.upcomingClasses;
                    final uniqueBatches = <String, String>{};
                    for (final c in batches) {
                      uniqueBatches[c.batchId] = c.batchName;
                    }

                    if (uniqueBatches.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'No enrolled batches found. You can only submit feedback for batches you are enrolled in.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }

                    return DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Select Batch',
                        border: OutlineInputBorder(),
                      ),
                      initialValue: _selectedBatchId,
                      items: uniqueBatches.entries.map((entry) {
                        return DropdownMenuItem<String>(
                          value: entry.key,
                          child: Text(entry.value),
                        );
                      }).toList(),
                      onChanged: _submitting
                          ? null
                          : (val) {
                              setState(() => _selectedBatchId = val);
                            },
                      validator: (val) =>
                          val == null ? 'Please select a batch' : null,
                    );
                  },
                ),
                const SizedBox(height: 20),
                Text(
                  'Rating',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final ratingVal = index + 1;
                    return IconButton(
                      key: ValueKey('star_$ratingVal'),
                      icon: Icon(
                        ratingVal <= _selectedRating
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.amber,
                        size: 36,
                      ),
                      onPressed: _submitting
                          ? null
                          : () {
                              setState(() => _selectedRating = ratingVal);
                            },
                    );
                  }),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _commentsCtrl,
                  maxLines: 4,
                  enabled: !_submitting,
                  decoration: const InputDecoration(
                    labelText: 'Comments (Optional)',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _submitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Submit Feedback'),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
