import 'package:ai_chat_app/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:ai_chat_app/screens/register_screen.dart';
import 'package:ai_chat_app/constants/colors.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
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
            left: -100,
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
                              Icons.chat_bubble_outline,
                              size: 40,
                              color: AppColors.iconColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Text(
                        'Welcome\nBack',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryText.withOpacity(0.9),
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Chat with the smartest AI',
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
                              if (userProvider.isLoading == false ) {
                                userProvider.loginUser(
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
                                userProvider.isLogin ? 'Logging...' : 'Login',
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
                          height: MediaQuery.of(context).size.height * 0.1),
                      GestureDetector(
                        onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Don\'t have an account?',
                              style: TextStyle(
                                color: AppColors.primaryText,
                              ),
                            ),
                            SizedBox(width: 5),
                            Text(
                              'Create  ',
                              style: TextStyle(
                                color: AppColors.secondaryText,
                              ),
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
