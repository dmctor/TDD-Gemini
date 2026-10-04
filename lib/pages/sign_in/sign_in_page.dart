import 'package:flutter/material.dart';

import 'sign_in_controller.dart';

class SignInPage extends StatefulWidget {
  final SignInController controller;

  const SignInPage({super.key, required this.controller});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _validationError;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSignInPressed() async {
    final rawUsername = _usernameController.text;
    final rawPassword = _passwordController.text;

    // Criterio 3: Validación de campos vacíos tras trim
    if (rawUsername.trim().isEmpty || rawPassword.trim().isEmpty) {
      setState(() {
        _validationError = 'Los campos son obligatorios';
      });
      return;
    }

    setState(() {
      _validationError = null;
    });

    // RN-01: Se envían las credenciales sanitizadas al controlador
    await widget.controller.authenticate(
      rawUsername.trim(),
      rawPassword.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Iniciar Sesion')),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  key: const Key('sign_in_username_field'),
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: 'Usuario'),
                ),
                TextField(
                  key: const Key('sign_in_password_field'),
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Contrasena'),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                if (_validationError != null)
                  Text(
                    _validationError!,
                    style: const TextStyle(color: Colors.red),
                  ),
                if (widget.controller.errorMessage != null)
                  Text(
                    widget.controller.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                const SizedBox(height: 20),
                if (widget.controller.isLoading)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    key: const Key('sign_in_submit_button'),
                    onPressed: _onSignInPressed,
                    child: const Text('Ingresar'),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
