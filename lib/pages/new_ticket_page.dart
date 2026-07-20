import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/ticket.dart';
import '../models/ticket_category.dart';
import '../providers/category_provider.dart';
import '../providers/ticket_provider.dart';
import '../utils/validators.dart';
import '../widgets/attachment_picker.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_dropdown_field.dart';
import '../widgets/custom_text_field.dart';

/// Form for opening a new support ticket.
class NewTicketPage extends ConsumerStatefulWidget {
  const NewTicketPage({super.key});

  @override
  ConsumerState<NewTicketPage> createState() => _NewTicketPageState();
}

class _NewTicketPageState extends ConsumerState<NewTicketPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  TicketCategory? _category;
  TicketPriority _priority = TicketPriority.medium;
  Uint8List? _attachmentBytes;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_category == null) return;
    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);

    await ref.read(ticketsControllerProvider.notifier).createTicket(
          title: _titleController.text,
          description: _descriptionController.text,
          category: _category!,
          priority: _priority,
          attachmentBytes: _attachmentBytes,
        );

    if (!mounted) return;
    setState(() => _isSubmitting = false);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Chamado aberto com sucesso.')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Abrir chamado')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomTextField(
                  label: 'Título',
                  hint: 'Resuma o problema em poucas palavras',
                  controller: _titleController,
                  textInputAction: TextInputAction.next,
                  validator: (v) => Validators.required(v, field: 'Título'),
                ),
                const SizedBox(height: 20),
                categoriesAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (_, _) => const Text('Não foi possível carregar as categorias.'),
                  data: (categories) {
                    if (categories.isEmpty) {
                      return const Text('Nenhuma categoria disponível.');
                    }
                    final selected = categories.firstWhere(
                      (c) => c.id == _category?.id,
                      orElse: () => categories.first,
                    );
                    _category = selected;
                    return CustomDropdownField<TicketCategory>(
                      label: 'Categoria',
                      value: selected,
                      items: categories
                          .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                          .toList(),
                      onChanged: (value) => setState(() => _category = value),
                    );
                  },
                ),
                const SizedBox(height: 20),
                CustomDropdownField<TicketPriority>(
                  label: 'Prioridade',
                  value: _priority,
                  items: TicketPriority.values
                      .map((p) => DropdownMenuItem(value: p, child: Text(p.label)))
                      .toList(),
                  onChanged: (value) => setState(() => _priority = value!),
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  label: 'Descrição',
                  hint: 'Descreva o problema com detalhes',
                  controller: _descriptionController,
                  maxLines: 5,
                  textInputAction: TextInputAction.newline,
                  validator: (v) => Validators.required(v, field: 'Descrição'),
                ),
                const SizedBox(height: 20),
                AttachmentPicker(
                  onChanged: (bytes) => _attachmentBytes = bytes,
                ),
                const SizedBox(height: 32),
                CustomButton(
                  label: 'Abrir chamado',
                  isLoading: _isSubmitting,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
