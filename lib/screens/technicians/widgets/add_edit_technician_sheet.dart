import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../models/technician_model.dart';
import '../../../providers/technician_provider.dart';
import '../../../providers/branch_provider.dart';
import '../../../utils/constants.dart';
import '../../../utils/validators.dart';

class AddEditTechnicianSheet extends StatefulWidget {
  final TechnicianModel? technician;

  const AddEditTechnicianSheet({super.key, this.technician});

  @override
  State<AddEditTechnicianSheet> createState() => _AddEditTechnicianSheetState();
}

class _AddEditTechnicianSheetState extends State<AddEditTechnicianSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late String _selectedRole;
  late String _selectedBranchId;
  late bool _isActive;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.technician?.name ?? '');
    _phoneController = TextEditingController(text: widget.technician?.phone ?? '');
    _emailController = TextEditingController(text: widget.technician?.email ?? '');
    _selectedRole = widget.technician?.role ?? AppConstants.roleTechnician;
    _selectedBranchId = AppConstants.defaultCenterId;
    _isActive = widget.technician?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final provider = Provider.of<TechnicianProvider>(context, listen: false);
      final technician = TechnicianModel(
        id: widget.technician?.id ?? const Uuid().v4(),
        uid: widget.technician?.uid ?? '',
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        role: _selectedRole,
        isActive: _isActive,
        ordersCompleted: widget.technician?.ordersCompleted ?? 0,
        avgRating: widget.technician?.avgRating ?? 0.0,
      );

      // Note: In a true multi-branch system, we might need to handle moving 
      // the technician if _selectedBranchId changed. For now, we assume 
      // the provider handles it or it's saved to the selected branch.
      
      if (widget.technician == null) {
        await provider.addTechnician(technician);
      } else {
        await provider.updateTechnician(technician);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving technician: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.technician == null ? 'Add Technician' : 'Edit Technician',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: Validators.required,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: Validators.phone,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: Validators.email,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Role',
                  prefixIcon: Icon(Icons.security),
                ),
                items: const [
                  DropdownMenuItem(value: AppConstants.roleAdmin, child: Text('Admin')),
                  DropdownMenuItem(value: AppConstants.roleTechnician, child: Text('Technician')),
                  DropdownMenuItem(value: AppConstants.roleViewer, child: Text('Viewer')),
                ],
                onChanged: (val) => setState(() => _selectedRole = val!),
              ),
              const SizedBox(height: 16),
              Consumer<BranchProvider>(
                builder: (context, branchProvider, child) {
                  if (branchProvider.branches.isEmpty) return const SizedBox.shrink();
                  
                  return DropdownButtonFormField<String>(
                    value: _selectedBranchId,
                    decoration: const InputDecoration(
                      labelText: 'Branch / Center',
                      prefixIcon: Icon(Icons.business),
                    ),
                    items: branchProvider.branches.map((b) => DropdownMenuItem(value: b.id, child: Text(b.name))).toList(),
                    onChanged: (val) => setState(() => _selectedBranchId = val!),
                  );
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Is Active'),
                subtitle: const Text('Inactive technicians cannot be assigned orders.'),
                value: _isActive,
                onChanged: (val) => setState(() => _isActive = val),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(widget.technician == null ? 'Add Technician' : 'Save Changes'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
