import 'package:fe/services/ApiUserService.dart';
import 'package:flutter/material.dart';


class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<StatefulWidget> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final ApiUserService apiService = ApiUserService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();  // Added form key

  int currentStep = 0;
  bool isLoading = false; // To track loading state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Forgot Password"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (currentStep == 0) ...[
                const Text(
                  "Enter your email:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Form(
                  key: _formKey,  // Wrap email field in a form
                  child: TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      hintText: "Enter Email",
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter an email address.";
                      }
                      // if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      //   return "Please enter a valid email address.";
                      // }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      setState(() {
                        isLoading = true;
                      });

                      bool success = await apiService.forgotPassword(emailController.text);
                      setState(() {
                        isLoading = false;
                      });

                      if (success) {
                        setState(() => currentStep = 1);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Success! Please check your email for the OTP.")),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Failed to send OTP")),
                        );
                      }
                    }
                  },
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : const Text("Send OTP"),
                ),
              ] else if (currentStep == 1) ...[
                const Text(
                  "Enter OTP code:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: otpController,
                  decoration: const InputDecoration(
                    hintText: "Type OTP",
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                    setState(() {
                      isLoading = true;
                    });

                    bool success = await apiService.verifyOTP(emailController.text, otpController.text);
                    setState(() {
                      isLoading = false;
                    });

                    if (success) {
                      setState(() => currentStep = 2);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Invalid OTP")),
                      );
                    }
                  },
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : const Text("Verify OTP"),
                ),
              ] else if (currentStep == 2) ...[
                const Text(
                  "Enter new password:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: "Type password",
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: "Confirm password",
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                    if (passwordController.text == confirmPasswordController.text) {
                      setState(() {
                        isLoading = true;
                      });

                      bool success = await apiService.resetPassword(
                        emailController.text,
                        otpController.text,
                        passwordController.text,
                      );
                      setState(() {
                        isLoading = false;
                      });

                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Password reset successful")),
                        );
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Password reset failed")),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Passwords do not match")),
                      );
                    }
                  },
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : const Text("Reset Password"),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

