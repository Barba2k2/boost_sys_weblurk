// user_form_widget.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UserFormWidget extends StatelessWidget {
  final TextEditingController nicknameController;
  final TextEditingController passwordController;
  final String selectedRole;
  final ValueChanged<String?> onRoleChanged;
  final VoidCallback onSubmit;

  const UserFormWidget({
    required this.nicknameController,
    required this.passwordController,
    required this.selectedRole,
    required this.onRoleChanged,
    required this.onSubmit,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: nicknameController,
          decoration: InputDecoration(
            fillColor: Colors.white,
            filled: true,
            labelText: 'Nickname',
            labelStyle: GoogleFonts.poppins(
              fontSize: 20,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: passwordController,
          obscureText: true,
          decoration: InputDecoration(
            fillColor: Colors.white,
            filled: true,
            labelText: 'Senha',
            labelStyle: GoogleFonts.poppins(
              fontSize: 20,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: selectedRole,
          items: ['user', 'admin']
              .map(
                (role) => DropdownMenuItem(
                  value: role,
                  child: Text(
                    role,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: onRoleChanged,
          decoration: InputDecoration(
            labelText: 'Regra',
            fillColor: Colors.white,
            filled: true,
            labelStyle: GoogleFonts.poppins(
              fontSize: 20,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 60,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple[600],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Registrar',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
