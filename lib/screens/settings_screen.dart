import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _db = DatabaseHelper.instance;
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _shopNameController = TextEditingController();

  String _printerWidth = '58';
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final shopName = await _db.getSetting(AppConstants.keyShopName) ?? AppConstants.appName;
    final width = await _db.getSetting(AppConstants.keyPrinterWidth) ?? '58';
    setState(() {
      _shopNameController.text = shopName;
      _printerWidth = width;
      _loading = false;
    });
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final username = await _db.getSetting(AppConstants.keyAdminUsername) ?? AppConstants.defaultUsername;
    final currentOk = await _db.verifyAdminCredentials(username, _currentPasswordController.text);

    if (!currentOk) {
      setState(() => _saving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Current password is incorrect.')));
      }
      return;
    }

    await _db.changeAdminPassword(_newPasswordController.text);
    await _db.setSetting(AppConstants.keyShopName, _shopNameController.text.trim());
    await _db.setSetting(AppConstants.keyPrinterWidth, _printerWidth);

    setState(() => _saving = false);
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settings saved successfully.')));
    }
  }

  Future<void> _saveShopSettingsOnly() async {
    await _db.setSetting(AppConstants.keyShopName, _shopNameController.text.trim());
    await _db.setSetting(AppConstants.keyPrinterWidth, _printerWidth);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Shop settings saved.')));
    }
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _shopNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Shop Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _shopNameController,
                    decoration: const InputDecoration(labelText: 'Shop name (shown on bill)'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _printerWidth,
                    decoration: const InputDecoration(labelText: 'Receipt paper width'),
                    items: const [
                      DropdownMenuItem(value: '58', child: Text('58mm thermal')),
                      DropdownMenuItem(value: '80', child: Text('80mm thermal')),
                    ],
                    onChanged: (v) => setState(() => _printerWidth = v ?? '58'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(onPressed: _saveShopSettingsOnly, child: const Text('Save Shop Settings')),
                  const SizedBox(height: 32),
                  const Text('Change Admin Password', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _currentPasswordController,
                          obscureText: true,
                          decoration: const InputDecoration(labelText: 'Current password'),
                          validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _newPasswordController,
                          obscureText: true,
                          decoration: const InputDecoration(labelText: 'New password'),
                          validator: (v) => (v == null || v.length < 4) ? 'At least 4 characters' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: true,
                          decoration: const InputDecoration(labelText: 'Confirm new password'),
                          validator: (v) => v != _newPasswordController.text ? 'Passwords do not match' : null,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _saving ? null : _changePassword,
                          child: _saving
                              ? const SizedBox(
                                  height: 22, width: 22,
                                  child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
                              : const Text('Save Changes'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
