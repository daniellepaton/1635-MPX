import 'dart:html' as html; // For detecting Spotify auth code on web
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/spotify_service.dart';

class LoginPage extends StatefulWidget {
  final Function() onLoginSuccess;

  const LoginPage({super.key, required this.onLoginSuccess});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _showManualEntry = false;

  @override
  void initState() {
    super.initState();
    _checkForSpotifyRedirectCode(); // NEW: handle /callback auto-login
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _checkForSpotifyRedirectCode() async {
    final code = html.window.localStorage['spotify_auth_code'];

    if (code != null && code.isNotEmpty) {
      html.window.localStorage.remove('spotify_auth_code');

      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final success = await _authService.spotifyService.exchangeCodeForToken(code);
        if (success && mounted) {
          widget.onLoginSuccess();
        } else if (mounted) {
          setState(() {
            _errorMessage = "Failed to complete Spotify login. Try again.";
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _errorMessage = "Error exchanging Spotify code: $e";
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _handleSpotifyLogin() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Open Spotify authentication
      await _authService.spotifyService.authenticate();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        final errorMsg = e.toString().replaceAll('Exception: ', '');

        setState(() {
          _errorMessage = errorMsg;
          _isLoading = false;
        });

        if (errorMsg.contains('credentials not configured') ||
            errorMsg.contains('INVALID_CLIENT')) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Spotify Setup Required'),
              content: SingleChildScrollView(
                child: Text(
                  '$errorMsg\n\n'
                  'Quick Fix:\n'
                  '1. Open lib/services/spotify_service.dart\n'
                  '2. Fix Client ID and Secret\n'
                  '3. Ensure Redirect URI matches:\n'
                  '   https://mpx.web.app/callback',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    }
  }

  Future<void> _handleManualCodeEntry() async {
    if (!mounted) return;

    final code = _codeController.text.trim();
    if (code.isEmpty) {
      setState(() => _errorMessage = 'Please enter an authorization code');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final success = await _authService.spotifyService.exchangeCodeForToken(code);
      if (success && mounted) {
        widget.onLoginSuccess();
      } else if (mounted) {
        setState(() {
          _errorMessage = 'Failed to exchange code. Try again.';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        final errorMsg = e.toString().replaceAll('Exception: ', '');
        setState(() {
          _errorMessage =
              'Error: $errorMsg\n\nCommon issues:\n- Redirect URI mismatch\n- Code expired\n- Invalid code';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _checkAuthStatus() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final isAuthenticated = await _authService.isAuthenticated();

      if (isAuthenticated && mounted) {
        widget.onLoginSuccess();
      } else if (mounted) {
        setState(() {
          _errorMessage = 'Not authenticated yet.';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error checking status: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title Box
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'MP-X',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'MOOD TRACKER',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 48),

                Text(
                  'Connect with Spotify to create personalized mood-balancing playlists based on your emotional state.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
                ),

                const SizedBox(height: 48),

                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      border: Border.all(color: Colors.red[300]!, width: 1),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red[900]),
                      textAlign: TextAlign.center,
                    ),
                  ),

                // Login Button
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSpotifyLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF1DB954), // Spotify Green
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.music_note,
                                    size: 16, color: Colors.white),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'CONTINUE WITH SPOTIFY',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 24),

                // Manual code entry toggle
                TextButton(
                  onPressed: () =>
                      setState(() => _showManualEntry = !_showManualEntry),
                  child: Text(
                    _showManualEntry
                        ? 'Hide Manual Entry'
                        : 'Enter Authorization Code Manually',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black87,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),

                if (_showManualEntry) ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: _codeController,
                    decoration: const InputDecoration(
                      labelText: 'Authorization Code',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleManualCodeEntry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('SUBMIT CODE'),
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Check status
                SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : _checkAuthStatus,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.black, width: 2),
                    ),
                    child: const Text(
                      'CHECK STATUS',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  'Current Redirect URI:\n${SpotifyService.redirectUri}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
