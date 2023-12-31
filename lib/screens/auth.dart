import 'package:flutter/foundation.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:memory/models/user.dart';
import 'package:memory/widgets/user_image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();
  var _isLogin = true;
  var _enteredEmail = '';
  var _enteredUsername = '';
  var _enteredPassword = '';
  Uint8List? _selectedImage;
  var _isAuthenticating = false;
  var _validationDone = false;
  var _obscurePassword = true;

  Future<void> _login(String email, String password) async {
    try {
      await _firebase.signInWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Authentification failed.')));
      }
    }
  }

  void _submit() async {
    _validationDone = true;
    final isValid = _form.currentState!.validate();
    if (!isValid) {
      return;
    }

    if (!_isLogin && _selectedImage == null) {
      return;
    }

    _form.currentState!.save();

    setState(() {
      _isAuthenticating = true;
    });
    if (_isLogin) {
      await _login(_enteredEmail, _enteredPassword);
    } else {
      try {
        final userCredentials = await _firebase.createUserWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);

        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child(userCredentials.user!.uid);

        await storageRef.putData(_selectedImage!);
        final imageUrl = await storageRef.getDownloadURL();

        FirebaseFirestore.instance
            .collection('users')
            .doc(userCredentials.user!.uid)
            .set(AppUser(
              uid: userCredentials.user!.uid,
              email: _enteredEmail,
              username: _enteredUsername,
              imageUrl: imageUrl,
            ).toJson());
      } on FirebaseAuthException catch (error) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(error.message ?? 'Authentification failed.')));
        }
      }
    }
    setState(() {
      _isAuthenticating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isLogin)
                Container(
                  margin: const EdgeInsets.only(
                    top: 30,
                    bottom: 20,
                    left: 20,
                    right: 20,
                  ),
                  child: SvgPicture.asset(
                    'assets/images/cards_icon.svg',
                    height: MediaQuery.of(context).size.height / 4,
                    fit: BoxFit.cover,
                    colorFilter:
                        const ColorFilter.mode(Colors.white70, BlendMode.srcIn),
                  ),
                ),
              const SizedBox(height: 30),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Card(
                  margin: const EdgeInsets.all(20),
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Form(
                            key: _form,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (!_isLogin)
                                  UserImagePicker(
                                    onPickImage: (pickedImage) {
                                      setState(() {
                                        _selectedImage = pickedImage;
                                      });
                                    },
                                    initialImage: _selectedImage == null
                                        ? null
                                        : MemoryImage(_selectedImage!),
                                  ),
                                if (!_isLogin &&
                                    _selectedImage == null &&
                                    _validationDone)
                                  Text('Must choose a profile picture',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .error)),
                                TextFormField(
                                    key: const ValueKey('email'),
                                    decoration: const InputDecoration(
                                        labelText: 'Email Address'),
                                    keyboardType: TextInputType.emailAddress,
                                    textCapitalization: TextCapitalization.none,
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty ||
                                          !value.contains('@') ||
                                          !value.contains('.')) {
                                        return 'Please enter a valid email address.';
                                      }
                                      return null;
                                    },
                                    onFieldSubmitted: (value) {
                                      _submit();
                                    },
                                    onSaved: (value) {
                                      _enteredEmail = value!;
                                    }),
                                if (!_isLogin)
                                  TextFormField(
                                      key: const ValueKey('username'),
                                      decoration: const InputDecoration(
                                          labelText: 'Username'),
                                      enableSuggestions: false,
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().length < 4) {
                                          return 'Username must be at least 4 characters long.';
                                        }
                                        return null;
                                      },
                                      onSaved: (value) {
                                        _enteredUsername = value!;
                                      }),
                                Row(children: [
                                  Expanded(
                                    child: TextFormField(
                                      key: const ValueKey('password'),
                                      decoration: const InputDecoration(
                                          labelText: 'Password'),
                                      obscureText: _obscurePassword,
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().length < 6) {
                                          return 'Password must be at least 6 characters long.';
                                        }
                                        return null;
                                      },
                                      onFieldSubmitted: (value) {
                                        _submit();
                                      },
                                      onSaved: (value) {
                                        _enteredPassword = value!;
                                      },
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() =>
                                          _obscurePassword = !_obscurePassword);
                                    },
                                    icon: Icon(
                                      _obscurePassword
                                          ? FontAwesomeIcons.eye
                                          : FontAwesomeIcons.eyeSlash,
                                    ),
                                  ),
                                ]),
                                const SizedBox(height: 12),
                                if (_isAuthenticating)
                                  const CircularProgressIndicator(),
                                if (!_isAuthenticating)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ElevatedButton(
                                        onPressed: _submit,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .primaryContainer,
                                        ),
                                        child: Text(
                                            _isLogin ? 'Login' : 'Signup',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onPrimaryContainer,
                                                )),
                                      ),
                                      if (_isLogin) const SizedBox(width: 10),
                                      if (_isLogin)
                                        ElevatedButton(
                                          onPressed: () {
                                            _login('guest@nosuchprovider.com',
                                                'supersecret');
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .primaryContainer,
                                          ),
                                          child: Text('Enter as Guest',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium!
                                                  .copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onPrimaryContainer,
                                                  )),
                                        ),
                                    ],
                                  ),
                                if (!_isAuthenticating)
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _isLogin = !_isLogin;
                                      });
                                    },
                                    child: Text(_isLogin
                                        ? 'Create an account'
                                        : 'I already have an account'),
                                  ),
                                if (kIsWeb) ...[
                                  const SizedBox(height: 20),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 50),
                                    child: Text(
                                      'To download Android app, inquire testing access from dev.benjen@gmail.com',
                                      softWrap: true,
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimaryContainer),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (kIsWeb)
                        Positioned(
                          bottom: 10,
                          right: 10,
                          child: SizedBox(
                            width: 50,
                            height: 50,
                            child: IconButton(
                              onPressed: () {
                                launchUrl(
                                  Uri.parse(
                                      'https://github.com/lordbenedikt/card_pairs_app_flutter'),
                                );
                              },
                              icon: SvgPicture.asset(
                                'assets/images/github-mark.svg',
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
