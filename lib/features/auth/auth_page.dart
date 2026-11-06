
import 'package:flutter/material.dart';

import '../../app/app_theme.dart';
import '../../core/backend/backend_config.dart';
import 'data/auth_repository.dart';
import '../home/home_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();

  bool _isRegistering = false;
  bool _hidePassword = true;
  bool _hideConfirmation = true;
  bool _acceptedTerms = false;
  bool _submitting = false;

  final _auth = AuthRepository();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  void _switchMode(bool register) {
    if (_isRegistering == register) return;

    setState(() {
      _isRegistering = register;
      _formKey.currentState?.reset();
      _acceptedTerms = false;
    });
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    if (_isRegistering && !_acceptedTerms) {
      _showMessage('Acepta los términos para crear tu cuenta.');
      return;
    }

    setState(() => _submitting = true);

    try {
      // No continuar ni abrir HomePage si Supabase no está configurado.
      if (!BackendConfig.isConfigured) {
        throw StateError(
          'Supabase no está configurado. Revisa SUPABASE_URL y '
          'SUPABASE_PUBLISHABLE_KEY en backend_config.dart.',
        );
      }

      if (_isRegistering) {
        debugPrint('========== REGISTRO DE USUARIO ==========');
        debugPrint('Conectando con Supabase Auth...');

        final result = await _auth.register(
          email: _email.text.trim(),
          password: _password.text,
          displayName: _name.text.trim(),
        );

        debugPrint('Registro enviado correctamente.');
        debugPrint('Usuario creado: ${result.user != null}');
        debugPrint('Sesión creada: ${result.session != null}');
        debugPrint('=========================================');

        if (!mounted) return;

        if (result.session == null) {
          _showMessage(
            'Cuenta creada. Revisa tu correo para confirmar el registro.',
          );
          return;
        }
      } else {
        debugPrint('========== INICIO DE SESIÓN ==========');

        await _auth.signIn(
          _email.text.trim(),
          _password.text,
        );

        debugPrint('Inicio de sesión exitoso.');
        debugPrint('======================================');
      }

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => const HomePage(),
        ),
      );
    } catch (error, stackTrace) {
      debugPrint('');
      debugPrint('========== ERROR DE AUTENTICACIÓN ==========');
      debugPrint('ERROR: $error');
      debugPrint('TIPO: ${error.runtimeType}');
      debugPrint('STACKTRACE:');
      debugPrint(stackTrace.toString());
      debugPrint('=============================================');
      debugPrint('');

      if (mounted) {
        _showMessage(error.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF1C344B),
        ),
      );
  }

  String? _required(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa $label.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final registering = _isRegistering;

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A1D32),
              AppColors.navy,
              Color(0xFF081120),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _BrandHeader(),
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.panel.withValues(alpha: 0.94),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.07),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.22),
                            blurRadius: 32,
                            offset: const Offset(0, 16),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _ModeSelector(
                            registering: registering,
                            onChanged: _switchMode,
                          ),
                          const SizedBox(height: 26),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            child: Column(
                              key: ValueKey(registering),
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  registering
                                      ? 'Únete a la comunidad'
                                      : 'Qué gusto verte',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    height: 1.2,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.4,
                                  ),
                                ),
                                const SizedBox(height: 7),
                                Text(
                                  registering
                                      ? 'Crea tu cuenta y comparte lo que construyes.'
                                      : 'Inicia sesión y sigue creando con tu comunidad.',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.65),
                                    fontSize: 14,
                                    height: 1.45,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (registering) ...[
                                  _AuthField(
                                    label: 'Nombre',
                                    hint: '¿Cómo te llamas?',
                                    icon: Icons.person_outline_rounded,
                                    controller: _name,
                                    validator: (v) => _required(v, 'tu nombre'),
                                    textCapitalization:
                                        TextCapitalization.words,
                                  ),
                                  const SizedBox(height: 16),
                                ],
                                _AuthField(
                                  label: 'Correo electrónico',
                                  hint: 'tu@correo.com',
                                  icon: Icons.alternate_email_rounded,
                                  controller: _email,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    final required = _required(
                                      value,
                                      'tu correo',
                                    );

                                    if (required != null) return required;

                                    if (!RegExp(
                                      r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                                    ).hasMatch(value!.trim())) {
                                      return 'Revisa el formato de tu correo.';
                                    }

                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                _AuthField(
                                  label: 'Contraseña',
                                  hint: registering
                                      ? 'Mínimo 8 caracteres'
                                      : 'Tu contraseña',
                                  icon: Icons.lock_outline_rounded,
                                  controller: _password,
                                  obscureText: _hidePassword,
                                  validator: (value) {
                                    final required = _required(
                                      value,
                                      'tu contraseña',
                                    );

                                    if (required != null) return required;

                                    if (value!.length < 8) {
                                      return 'Usa al menos 8 caracteres.';
                                    }

                                    return null;
                                  },
                                  suffix: IconButton(
                                    tooltip: _hidePassword
                                        ? 'Mostrar contraseña'
                                        : 'Ocultar contraseña',
                                    onPressed: () => setState(
                                      () => _hidePassword = !_hidePassword,
                                    ),
                                    icon: Icon(
                                      _hidePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                    ),
                                  ),
                                ),
                                if (registering) ...[
                                  const SizedBox(height: 16),
                                  _AuthField(
                                    label: 'Confirmar contraseña',
                                    hint: 'Escríbela de nuevo',
                                    icon: Icons.verified_user_outlined,
                                    controller: _confirmation,
                                    obscureText: _hideConfirmation,
                                    validator: (value) {
                                      final required = _required(
                                        value,
                                        'la confirmación',
                                      );

                                      if (required != null) return required;

                                      if (value != _password.text) {
                                        return 'Las contraseñas no coinciden.';
                                      }

                                      return null;
                                    },
                                    suffix: IconButton(
                                      tooltip: _hideConfirmation
                                          ? 'Mostrar contraseña'
                                          : 'Ocultar contraseña',
                                      onPressed: () => setState(
                                        () => _hideConfirmation =
                                            !_hideConfirmation,
                                      ),
                                      icon: Icon(
                                        _hideConfirmation
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Material(
                                    color: Colors.transparent,
                                    child: CheckboxListTile(
                                      value: _acceptedTerms,
                                      onChanged: (value) => setState(
                                        () => _acceptedTerms = value ?? false,
                                      ),
                                      contentPadding: EdgeInsets.zero,
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                      dense: true,
                                      activeColor: AppColors.violet,
                                      title: Text(
                                        'Acepto los términos de uso y la política de privacidad.',
                                        style: TextStyle(
                                          color: Colors.white.withValues(
                                            alpha: 0.72,
                                          ),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ] else ...[
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () => _showMessage(
                                        'La recuperación de contraseña estará disponible próximamente.',
                                      ),
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppColors.cyan,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 10,
                                        ),
                                      ),
                                      child: const Text(
                                        '¿Olvidaste tu contraseña?',
                                      ),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 12),
                                _PrimaryButton(
                                  label: registering
                                      ? 'Crear cuenta'
                                      : 'Iniciar sesión',
                                  icon: registering
                                      ? Icons.person_add_alt_1_rounded
                                      : Icons.arrow_forward_rounded,
                                  onPressed: _submitting ? null : _submit,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 22),
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: Colors.white.withValues(alpha: 0.12),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: Text(
                                  'ACCESO SIMULADO',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.4),
                                    fontSize: 10,
                                    letterSpacing: 1.4,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: Colors.white.withValues(alpha: 0.12),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Text.rich(
                        TextSpan(
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.58),
                            fontSize: 14,
                          ),
                          children: [
                            TextSpan(
                              text: registering
                                  ? '¿Ya tienes cuenta? '
                                  : '¿Aún no tienes cuenta? ',
                            ),
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: GestureDetector(
                                onTap: () => _switchMode(!registering),
                                child: Text(
                                  registering ? 'Inicia sesión' : 'Regístrate',
                                  style: const TextStyle(
                                    color: AppColors.cyan,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Center(
                      child: Text(
                        'Al continuar, proteges tu espacio y el de la comunidad.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.36),
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Container(
        width: 124,
        height: 124,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: AppColors.blue.withValues(alpha: 0.38),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.blue.withValues(alpha: 0.17),
              blurRadius: 28,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: Image.asset('DevShare.png', fit: BoxFit.contain),
        ),
      ),
      const SizedBox(height: 14),
      const Text(
        'Tu espacio para crear y compartir.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color(0xFF9FB4CA),
          fontSize: 14,
          letterSpacing: 0.2,
        ),
      ),
    ],
  );
}

class _ModeSelector extends StatelessWidget {
  const _ModeSelector({
    required this.registering,
    required this.onChanged,
  });

  final bool registering;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: AppColors.field,
      borderRadius: BorderRadius.circular(15),
    ),
    child: Row(
      children: [
        _ModeTab(
          label: 'Iniciar sesión',
          selected: !registering,
          onTap: () => onChanged(false),
        ),
        _ModeTab(
          label: 'Registrarme',
          selected: registering,
          onTap: () => onChanged(true),
        ),
      ],
    ),
  );
}

class _ModeTab extends StatelessWidget {
  const _ModeTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Expanded(
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        gradient: selected
            ? const LinearGradient(
                colors: [AppColors.violet, AppColors.blue],
              )
            : null,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          foregroundColor: selected ? Colors.white : Colors.white60,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        child: Text(label, maxLines: 1),
      ),
    ),
  );
}

class _AuthField extends StatelessWidget {
  const _AuthField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
    this.suffix,
    this.textCapitalization = TextCapitalization.none,
  });

  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final Widget? suffix;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 2),
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFFDDE9F5),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        textCapitalization: textCapitalization,
        style: const TextStyle(fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: Color(0xFF70869D),
            fontSize: 14,
          ),
          prefixIcon: Icon(
            icon,
            color: AppColors.cyan,
            size: 20,
          ),
          suffixIcon: suffix,
          filled: true,
          fillColor: AppColors.field,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 17,
            horizontal: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              color: Colors.white.withValues(alpha: 0.07),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              color: Colors.white.withValues(alpha: 0.07),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(
              color: AppColors.cyan,
              width: 1.4,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(
              color: Color(0xFFFF788D),
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(
              color: Color(0xFFFF788D),
              width: 1.4,
            ),
          ),
        ),
      ),
    ],
  );
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 54,
    child: DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.violet, AppColors.blue],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.violet.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: FilledButton.icon(
        onPressed: onPressed,
        iconAlignment: IconAlignment.end,
        icon: Icon(icon, size: 19),
        label: Text(label),
        style: FilledButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ),
  );
}
