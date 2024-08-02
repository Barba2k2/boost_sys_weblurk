import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/ui/widgets/drawer_widget.dart';
import '../../../../core/ui/widgets/edit_user_dialog.dart';
import '../../../../core/ui/widgets/user_form_widget.dart';
import '../../../../core/ui/widgets/user_list_widget.dart';
import '../../../../models/user_model.dart';
import 'register_streamer_controller.dart';

class RegisterStreamerPage extends StatefulWidget {
  const RegisterStreamerPage({super.key});

  @override
  State<RegisterStreamerPage> createState() => _RegisterStreamerPageState();
}

class _RegisterStreamerPageState extends State<RegisterStreamerPage> {
  final _controller = Modular.get<RegisterStreamerController>();

  // - Form Controllers
  final _nicknameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _selectedRole = ValueNotifier<String>('user');
  
  // - Modal Controllers
  final _editNicknameController = TextEditingController();
  final _editPasswordController = TextEditingController();
  final _editSelectedRole = ValueNotifier<String>('user');

  @override
  void initState() {
    super.initState();
    _controller.fetchUsers();
  }

  void _showEditDialog(BuildContext context, UserModel user) {
    _editNicknameController.text = user.nickname;
    _editPasswordController.text = user.password!;
    _editSelectedRole.value = user.role;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditUserDialog(
          nicknameController: _editNicknameController,
          passwordController: _editPasswordController,
          selectedRole: _editSelectedRole.value,
          onRoleChanged: (value) {
            _editSelectedRole.value = value!;
          },
          onSave: () {
            _controller.editUser(
              user.id,
              _editNicknameController.text,
              _editPasswordController.text,
              _editSelectedRole.value,
            ).then(
              (_) {
                _editNicknameController.clear();
                _editPasswordController.clear();
                _editSelectedRole.value = 'user';
                setState(() {});
              },
            );
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        elevation: 0,
        title: Text(
          'Cadastrar Streamer',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      drawer: const DrawerWidget(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple,
        onPressed: () {
          _controller.fetchUsers();
          _nicknameController.clear();
          _passwordController.clear();
        },
        child: const Icon(Icons.restart_alt_rounded),
      ),
      body: Observer(
        builder: (_) {
          if (_controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.purple,
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: 600,
                    height: 340,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey[200],
                    ),
                    child: UserFormWidget(
                      nicknameController: _nicknameController,
                      passwordController: _passwordController,
                      selectedRole: _selectedRole.value,
                      onRoleChanged: (value) {
                        _selectedRole.value = value!;
                      },
                      onSubmit: () {
                        _controller.registerUser(
                          _nicknameController.text,
                          _passwordController.text,
                          _selectedRole.value,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: 600,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey[200],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Streamers Cadastrados',
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Observer(
                          builder: (_) {
                            if (_controller.errorMessage != null) {
                              return Text(
                                _controller.errorMessage!,
                                style: const TextStyle(color: Colors.red),
                              );
                            } else if (_controller.users!.isEmpty) {
                              return const Text('Nenhum streamer cadastrado');
                            } else {
                              return UserListWidget(
                                users: _controller.users ?? [],
                                onEdit: (user) {
                                  _showEditDialog(context, user);
                                },
                                onDelete: (id) {
                                  _controller.deleteUser(id);
                                },
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}
