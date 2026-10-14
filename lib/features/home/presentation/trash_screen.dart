import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';

class TrashScreen extends ConsumerWidget {
  const TrashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final database = ref.watch(databaseProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Trash')),
      body: StreamBuilder(
        stream: database.watchTrash(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Could not open trash. ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final documents = snapshot.data!;
          if (documents.isEmpty) {
            return const Center(
              child: Text('Deleted documents will appear here.'),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: documents.length,
            separatorBuilder: (_, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final document = documents[index];
              return Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.description_outlined),
                  ),
                  title: Text(
                    document.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    'Moved to trash ${document.modifiedAt.day}/${document.modifiedAt.month}/${document.modifiedAt.year}',
                  ),
                  trailing: PopupMenuButton<String>(
                    tooltip: 'Document actions',
                    onSelected: (action) async {
                      if (action == 'restore') {
                        await database.restoreFromTrash(document.id);
                      } else if (action == 'delete') {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            title: const Text('Delete permanently?'),
                            content: Text(
                              '“${document.title}” and its source pages will be removed.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(dialogContext, false),
                                child: const Text('Cancel'),
                              ),
                              FilledButton(
                                onPressed: () =>
                                    Navigator.pop(dialogContext, true),
                                child: const Text('Delete permanently'),
                              ),
                            ],
                          ),
                        );
                        if (confirmed == true) {
                          await database.deleteDocument(document.id);
                          await ref
                              .read(scanStorageProvider)
                              .removeDocumentAssets(document.id);
                        }
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'restore', child: Text('Restore')),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete permanently'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
