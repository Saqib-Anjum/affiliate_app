import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "../../core/utils/formatters.dart";
import "../../core/validators/validators.dart";
import "../../core/widgets/custom_button.dart";
import "../../core/widgets/search_field.dart";
import "../../core/widgets/state_widgets.dart";
import "../../providers/student_provider.dart";

class StudentListScreen extends ConsumerWidget {
  const StudentListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(studentsProvider);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        heroTag: "student_fab",
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (_) => const _CreateStudentSheet(),
        ),
        icon: const Icon(Icons.person_add_outlined),
        label: const Text("Add Student"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SearchField(
              hintText: "Search students by name, email...",
              onChanged: (v) => ref.read(studentSearchProvider.notifier).state = v,
            ),
          ),
          Expanded(
            child: studentsAsync.when(
              loading: () => const LoadingWidget(),
              error: (e, _) => ErrorStateWidget(message: e.toString()),
              data: (result) {
                if (result.data.isEmpty) {
                  return const EmptyState(title: "No students found", icon: Icons.school_outlined);
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                  itemCount: result.data.length,
                  itemBuilder: (context, index) {
                    final student = result.data[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        title: Text(student.fullName, style: textTheme.titleMedium),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            "${student.email}\nLast login: ${student.lastLoginAt != null ? Formatters.dateTime(student.lastLoginAt) : "Never"}",
                            style: textTheme.bodySmall?.copyWith(height: 1.4),
                          ),
                        ),
                        isThreeLine: true,
                        trailing: Switch(
                          activeThumbColor: const Color(0xFF2563EB),
                          value: student.isActive,
                          onChanged: (v) => ref.read(studentActionsProvider).setActive(student.id, v),
                        ),
                      ),
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

class _CreateStudentSheet extends ConsumerStatefulWidget {
  const _CreateStudentSheet();

  @override
  ConsumerState<_CreateStudentSheet> createState() => _CreateStudentSheetState();
}

class _CreateStudentSheetState extends ConsumerState<_CreateStudentSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final phone = _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim();
      await ref.read(studentActionsProvider).create(
            fullName: _nameController.text.trim(),
            email: _emailController.text.trim(),
            phone: phone,
            password: _passwordController.text,
          );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Row(
              children: const [
                Icon(Icons.person_add_rounded, color: Color(0xFF2563EB)),
                SizedBox(width: 8),
                Text(
                  "Create Student Account",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, letterSpacing: -0.2),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFCA5A5)),
                ),
                child: Text(_error!, style: TextStyle(color: Colors.red.shade800, fontSize: 13)),
              ),
            ],
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Student Full Name *",
                prefixIcon: Icon(Icons.badge_outlined),
              ),
              validator: (v) => Validators.required(v, field: "Full name"),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: "Email Address *",
                prefixIcon: Icon(Icons.email_outlined),
              ),
              validator: Validators.requiredEmail,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Phone Number",
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Temporary Password *",
                prefixIcon: Icon(Icons.lock_outlined),
              ),
              validator: Validators.password,
            ),
            const SizedBox(height: 20),
            CustomButton(
              label: "Create Student Account",
              icon: Icons.check_circle_rounded,
              loading: _saving,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
