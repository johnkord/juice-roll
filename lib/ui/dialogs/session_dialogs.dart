import 'package:flutter/material.dart';
import '../../models/session.dart';
import '../shared/dialog_components.dart';

/// A bottom sheet for selecting or managing sessions.
class SessionSelectorSheet extends StatelessWidget {
  final List<Session> sessions;
  final Session? currentSession;
  final void Function(Session) onSelectSession;
  final void Function(Session) onShowDetails;
  final void Function(Session) onDeleteSession;
  final VoidCallback onNewSession;
  final VoidCallback onImportSession;

  const SessionSelectorSheet({
    super.key,
    required this.sessions,
    required this.currentSession,
    required this.onSelectSession,
    required this.onShowDetails,
    required this.onDeleteSession,
    required this.onNewSession,
    required this.onImportSession,
  });

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inDays < 1) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Text(
                  'Sessions',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: onImportSession,
                  icon: const Icon(Icons.download, size: 18),
                  label: const Text('Import'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // New Session button
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.green,
              child: Icon(Icons.add, color: Colors.white),
            ),
            title: const Text('New Session'),
            subtitle: const Text('Start a fresh adventure'),
            onTap: () {
              Navigator.pop(context);
              onNewSession();
            },
          ),
          const Divider(height: 1),
          // Session list
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                final session = sessions[index];
                final isSelected = session.id == currentSession?.id;
                
                return Dismissible(
                  key: Key(session.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    return await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Session?'),
                        content: Text(
                          isSelected
                              ? 'This is your current session. Deleting it will create a new empty session. '
                                'Are you sure you want to delete "${session.name}" with ${session.history.length} rolls?'
                              : 'Are you sure you want to delete "${session.name}"? '
                                'This will permanently remove all ${session.history.length} rolls.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: TextButton.styleFrom(foregroundColor: Colors.red),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    ) ?? false;
                  },
                  onDismissed: (direction) {
                    onDeleteSession(session);
                  },
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isSelected ? Colors.blue : Colors.grey[700],
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white)
                          : Text(
                              session.name.isNotEmpty
                                  ? session.name[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(color: Colors.white),
                            ),
                    ),
                    title: Text(
                      session.name,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      '${session.history.length} rolls • ${_formatDate(session.lastAccessedAt)}',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.info_outline),
                      onPressed: () {
                        Navigator.pop(context);
                        onShowDetails(session);
                      },
                    ),
                    selected: isSelected,
                    onTap: () {
                      Navigator.pop(context);
                      if (!isSelected) {
                        onSelectSession(session);
                      }
                    },
                  ),
                );
              },
            ),
          ),
          // Footer with session count
          Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              '${sessions.length} session${sessions.length == 1 ? '' : 's'}',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dialog for viewing and managing session details.
class SessionDetailsDialog extends StatefulWidget {
  final Session session;
  final bool isCurrentSession;
  final Future<void> Function(Session) onUpdate;
  final Future<void> Function() onDelete;
  final VoidCallback onExport;

  const SessionDetailsDialog({
    super.key,
    required this.session,
    required this.isCurrentSession,
    required this.onUpdate,
    required this.onDelete,
    required this.onExport,
  });

  @override
  State<SessionDetailsDialog> createState() => _SessionDetailsDialogState();
}

class _SessionDetailsDialogState extends State<SessionDetailsDialog> {
  late TextEditingController _nameController;
  late TextEditingController _notesController;
  bool _isEditing = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.session.name);
    _notesController = TextEditingController(text: widget.session.notes ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _formatFullDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final amPm = date.hour >= 12 ? 'PM' : 'AM';
    return '${months[date.month - 1]} ${date.day}, ${date.year} at $hour:${date.minute.toString().padLeft(2, '0')} $amPm';
  }

  Future<void> _saveChanges() async {
    final updatedSession = widget.session.copyWith(
      name: _nameController.text.trim().isEmpty 
          ? widget.session.name 
          : _nameController.text.trim(),
      notes: _notesController.text.trim(),
    );
    await widget.onUpdate(updatedSession);
    if (mounted) {
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session updated')),
      );
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Session?'),
        content: Text(
          widget.isCurrentSession
              ? 'This is your current session. Deleting it will create a new empty session. '
                'Are you sure you want to delete "${widget.session.name}" with ${widget.session.history.length} rolls?'
              : 'Are you sure you want to delete "${widget.session.name}"? '
                'This will permanently remove all ${widget.session.history.length} rolls.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isDeleting = true);
      await widget.onDelete();
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Expanded(
            child: _isEditing
                ? TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Session Name',
                      border: OutlineInputBorder(),
                    ),
                    autofocus: true,
                  )
                : Text(widget.session.name),
          ),
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
        ],
      ),
      contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
          maxWidth: 350,
        ),
        child: ScrollableDialogContent(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats
              const SectionHeader(icon: Icons.analytics, title: 'Session Stats'),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    DetailRow(
                      icon: Icons.casino,
                      label: 'Rolls',
                      value: '${widget.session.history.length}',
                    ),
                    const SizedBox(height: 8),
                    DetailRow(
                      icon: Icons.calendar_today,
                      label: 'Created',
                      value: _formatFullDate(widget.session.createdAt),
                    ),
                    const SizedBox(height: 8),
                    DetailRow(
                      icon: Icons.access_time,
                      label: 'Last Played',
                      value: _formatFullDate(widget.session.lastAccessedAt),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Notes
              const SectionHeader(icon: Icons.notes, title: 'Notes'),
              const SizedBox(height: 8),
              if (_isEditing)
                TextField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    hintText: 'Add notes about this session...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[700]!),
                  ),
                  child: Text(
                    (widget.session.notes ?? '').isEmpty
                        ? 'No notes yet'
                        : widget.session.notes!,
                    style: TextStyle(
                      color: (widget.session.notes ?? '').isEmpty
                          ? Colors.grey[500]
                          : Colors.white,
                      fontStyle: (widget.session.notes ?? '').isEmpty
                          ? FontStyle.italic
                          : FontStyle.normal,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              // Export button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: widget.onExport,
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy to Clipboard'),
                ),
              ),
              if (widget.isCurrentSession)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'This is your current session',
                    style: TextStyle(
                      color: Colors.blue[300],
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        if (!_isDeleting)
          TextButton.icon(
            onPressed: _confirmDelete,
            icon: const Icon(Icons.delete, size: 18),
            label: const Text('Delete'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        if (_isDeleting)
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        const Spacer(),
        if (_isEditing) ...[
          TextButton(
            onPressed: () {
              _nameController.text = widget.session.name;
              _notesController.text = widget.session.notes ?? '';
              setState(() => _isEditing = false);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _saveChanges,
            child: const Text('Save'),
          ),
        ] else
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
      ],
    );
  }
}
