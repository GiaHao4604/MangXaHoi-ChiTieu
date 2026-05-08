import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/auth_api_service.dart';
import 'package:flutter_application_1/services/auth_session_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthApiService _authApiService = AuthApiService();
  final AuthSessionService _sessionService = AuthSessionService();

  bool _isLoading = true;
  String _title = 'Xin chao';
  String _subtitle = 'Dang tai du lieu nguoi dung...';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final token = await _sessionService.getToken();

    if (token == null || token.trim().isEmpty) {
      if (!mounted) {
        return;
      }
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    final result = await _authApiService.getMe(token: token);

    if (!mounted) {
      return;
    }

    if (!result.success) {
      await _sessionService.clearToken();
      if (!mounted) {
        return;
      }
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    final name = (result.data?['name'] as String?)?.trim() ?? 'Nguoi dung';
    final email = (result.data?['email'] as String?)?.trim() ?? '';

    setState(() {
      _isLoading = false;
      _title = 'Xin chao, $name';
      _subtitle = email;
    });
  }

  Future<void> _logout() async {
    await _sessionService.clearToken();
    if (!mounted) {
      return;
    }
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 360,
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 16,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: _isLoading
            ? const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text('Dang tai thong tin...'),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.verified_user,
                    size: 42,
                    color: Color(0xFF4A46DE),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF212121),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6C6C77),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 42,
                    child: FilledButton(
                      onPressed: _logout,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFD13B33),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Dang xuat'),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
