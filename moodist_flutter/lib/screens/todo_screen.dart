import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/todo_state.dart';

class TodoScreen extends StatelessWidget {
  const TodoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('待办'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Consumer<TodoState>(
          builder: (context, state, _) {
            if (state.todos.isEmpty) {
              return _EmptyTodo(theme: theme, onAdd: state.addTodo);
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _AddTodoBar(onAdd: (text) => state.addTodo(text), theme: theme),
                _ProgressChip(
                  done: state.doneCount,
                  total: state.todos.length,
                  theme: theme,
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: state.todos.length,
                    itemBuilder: (context, i) {
                      final t = state.todos[i];
                      final isLast = i == state.todos.length - 1;
                      return Padding(
                        padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
                        child: _TodoCard(
                          todo: t,
                          onToggle: () => state.toggleTodo(t.id),
                          onDelete: () => state.deleteTodo(t.id),
                          theme: theme,
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _EmptyTodo extends StatelessWidget {
  const _EmptyTodo({required this.theme, required this.onAdd});

  final ThemeData theme;
  final void Function(String) onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_outline_rounded,
                size: 56,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '暂无待办',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '在下方输入内容并添加，开始管理你的任务',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _AddTodoBar(onAdd: onAdd, theme: theme),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddTodoBar extends StatefulWidget {
  const _AddTodoBar({required this.onAdd, required this.theme});

  final void Function(String) onAdd;
  final ThemeData theme;

  @override
  State<_AddTodoBar> createState() => _AddTodoBarState();
}

class _AddTodoBarState extends State<_AddTodoBar> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onAdd(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Material(
        color: widget.theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _focusNode.requestFocus(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      hintText: '添加新待办…',
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onSubmitted: (_) => _submit(),
                  ),
                ),
                IconButton.filled(
                  onPressed: _submit,
                  icon: const Icon(Icons.add_rounded),
                  style: IconButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressChip extends StatelessWidget {
  const _ProgressChip({required this.done, required this.total, required this.theme});

  final int done;
  final int total;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          Icon(Icons.trending_up_rounded, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            '已完成 $done / $total',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _TodoCard extends StatelessWidget {
  const _TodoCard({
    required this.todo,
    required this.onToggle,
    required this.onDelete,
    required this.theme,
  });

  final TodoItem todo;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: theme.cardTheme.color,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Checkbox(
                value: todo.done,
                onChanged: (_) => onToggle(),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  todo.todo,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    decoration: todo.done ? TextDecoration.lineThrough : null,
                    color: todo.done
                        ? theme.colorScheme.onSurfaceVariant
                        : theme.colorScheme.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline_rounded, size: 22, color: theme.colorScheme.outline),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
