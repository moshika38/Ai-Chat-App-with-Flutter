import 'package:ai_chat_app/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:ai_chat_app/screens/login_screen.dart';
import 'package:ai_chat_app/constants/colors.dart';
import 'package:provider/provider.dart';


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: Stack(
        children: [
          Positioned(
            top: -150,
            right: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.circleBackground,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.iconOverlay,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.person_add_outlined,
                              size: 40,
                              color: AppColors.iconColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Text(
                        'Create\nAccount',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryText.withOpacity(0.9),
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Start your AI journey today',
                        style: TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Container(
                        padding: const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          color: AppColors.containerOverlay,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _nameController,
                              style:
                                  const TextStyle(color: AppColors.primaryText),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Name',
                                hintStyle: TextStyle(color: AppColors.hintText),
                                prefixIcon: Icon(
                                  Icons.person_outline,
                                  color: AppColors.hintText,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your name';
                                }
                                return null;
                              },
                            ),
                            const Divider(
                                height: 5, color: AppColors.dividerColor),
                            TextFormField(
                              controller: _emailController,
                              style:
                                  const TextStyle(color: AppColors.primaryText),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Email',
                                hintStyle: TextStyle(color: AppColors.hintText),
                                prefixIcon: Icon(
                                  Icons.email_outlined,
                                  color: AppColors.hintText,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}')
                                    .hasMatch(value)) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const Divider(
                                height: 25, color: AppColors.dividerColor),
                            TextFormField(
                              controller: _passwordController,
                              style:
                                  const TextStyle(color: AppColors.primaryText),
                              obscureText: true,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Password',
                                hintStyle: TextStyle(color: AppColors.hintText),
                                prefixIcon: Icon(
                                  Icons.lock_outline,
                                  color: AppColors.hintText,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),
                      Consumer(
                        builder: (BuildContext context,
                                UserProvider userProvider, child) =>
                            GestureDetector(
                          onTap: () {
                            if (_formKey.currentState!.validate()) {
                              if (userProvider.isLoading == false) {
                                userProvider.createUser(
                                  _emailController.text,
                                  _passwordController.text,
                                  context,
                                );
                              }
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.gradientStart,
                                  AppColors.gradientEnd
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                userProvider.isLoading
                                    ? 'Creating..'
                                    : 'Register',
                                style: const TextStyle(
                                  color: AppColors.primaryText,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.05),
                      GestureDetector(
                        onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginScreen()),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account?',
                              style: TextStyle(color: AppColors.primaryText),
                            ),
                            SizedBox(width: 5),
                            Text(
                              'Login',
                              style: TextStyle(color: AppColors.secondaryText),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
