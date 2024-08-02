import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:validatorless/validatorless.dart';

import 'boost_text_form_field.dart';

import 'role_dropdown.dart';

class EditUserDialog extends StatelessWidget {
  final TextEditingController nicknameController;
  final TextEditingController passwordController;
  final String selectedRole;
  final Function(String?) onRoleChanged;
  final VoidCallback onSave;

  const EditUserDialog({
    super.key,
    required this.nicknameController,
    required this.passwordController,
    required this.selectedRole,
    required this.onRoleChanged,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Editar Usuário',
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      alignment: Alignment.center,
      titlePadding: const EdgeInsets.only(top: 16, left: 24, bottom: 4),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            BoostTextFormField(
              controller: nicknameController,
              label: 'Nickname',
              validator: Validatorless.required('Nickname obrigatório'),
            ),
            const SizedBox(height: 16),
            BoostTextFormField(
              controller: passwordController,
              label: 'Senha',
              obscureText: true,
              validator: Validatorless.required('Senha obrigatória'),
            ),
            const SizedBox(height: 16),
            RoleDropdown(
              selectedRole: selectedRole,
              onChanged: onRoleChanged,
            ),
          ],
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              'Cancelar',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.red,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: TextButton(
            onPressed: onSave,
            child: Text(
              'Salvar',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.green,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
