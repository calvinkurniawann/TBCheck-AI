import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/auth_service.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  final _usiaCtrl = TextEditingController();
  final _tinggiCtrl = TextEditingController();
  final _beratCtrl = TextEditingController();
  
  String? _jenisKelamin;
  final _authService = AuthService();
  bool _isLoading = false;

  void _register() async {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    final confirmPassword = _confirmPasswordCtrl.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showError('Semua field wajib diisi');
      return;
    }
    if (password != confirmPassword) {
      _showError('Password tidak cocok');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: confirmPassword,
        jenisKelamin: _jenisKelamin,
        usia: int.tryParse(_usiaCtrl.text),
        tinggiBadan: double.tryParse(_tinggiCtrl.text),
        beratBadan: double.tryParse(_beratCtrl.text),
      );
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (!mounted) return;
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.riskHigh),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLightGray,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Buat Akun',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Daftar untuk menyimpan riwayat skrining Anda',
                style: TextStyle(color: AppColors.textGray),
              ),
              const SizedBox(height: 32),
              CustomTextField(controller: _nameCtrl, label: 'Nama Lengkap', hint: 'Masukkan nama Anda'),
              const SizedBox(height: 16),
              CustomTextField(controller: _emailCtrl, label: 'Email', hint: 'Masukkan email valid', keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 16),
              CustomTextField(controller: _passwordCtrl, label: 'Password', hint: 'Minimal 8 karakter', isPassword: true),
              const SizedBox(height: 16),
              CustomTextField(controller: _confirmPasswordCtrl, label: 'Konfirmasi Password', hint: 'Ulangi password', isPassword: true),
              
              const SizedBox(height: 24),
              const Text('Data Profil (Opsional - untuk autofill skrining)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Jenis Kelamin',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: AppColors.bgInput,
                ),
                value: _jenisKelamin,
                items: const [
                  DropdownMenuItem(value: 'Laki-laki', child: Text('Laki-laki')),
                  DropdownMenuItem(value: 'Perempuan', child: Text('Perempuan')),
                ],
                onChanged: (val) => setState(() => _jenisKelamin = val),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(controller: _usiaCtrl, label: 'Usia (thn)', hint: 'Cth: 25', keyboardType: TextInputType.number),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(controller: _tinggiCtrl, label: 'Tinggi (cm)', hint: 'Cth: 170', keyboardType: TextInputType.number),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(controller: _beratCtrl, label: 'Berat (kg)', hint: 'Cth: 65', keyboardType: TextInputType.number),
                  ),
                ],
              ),

              const SizedBox(height: 40),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : PrimaryButton(label: 'Daftar', onPressed: _register),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
