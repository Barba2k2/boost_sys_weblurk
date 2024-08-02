import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RoleDropdown extends StatelessWidget {
  final String selectedRole;
  final Function(String?) onChanged;

  const RoleDropdown({
    super.key,
    required this.selectedRole,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
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
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: 'Role',
        fillColor: Colors.white,
        filled: true,
        labelStyle: GoogleFonts.poppins(fontSize: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
