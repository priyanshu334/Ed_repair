import 'package:ed_repair/pages/OwnerLoginPage.dart';
import 'package:ed_repair/pages/StaffLoginPage.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              
              // Logo
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Hero(
                  tag: 'app_logo',
                  child: Image.asset(
                    'assets/images/img1.png', 
                    height: 180,
                  ),
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Tagline
              const Text(
                'Your Gadget\'s Best Friend',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Login Options Card
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF1E1E2F),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Choose Login Type',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    
                    const SizedBox(height: 36),
                    
                    // Owner Login
                    _buildLoginOption(
                      context: context,
                      image: 'assets/images/img2.png',
                      title: 'Owner Login',
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const OwnerLoginPage()));
                        // Navigate to Owner Login
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        children: [
                          Expanded(child: Divider(color: Colors.white38, thickness: 1)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'OR',
                              style: TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.white38, thickness: 1)),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Staff Login
                    _buildLoginOption(
                      context: context,
                      image: 'assets/images/img3.png',
                      title: 'Staff Login',
                      onTap: () {
                        // Navigate to Staff Login
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const Staffloginpage()));
                      },
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Help text
                    const Text(
                      'Need assistance? Contact support',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 14,
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildLoginOption({
    required BuildContext context,
    required String image,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              children: [
                Image.asset(
                  image,
                  height: 180,
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title == 'Owner Login' ? 'Access store management' : 'Access staff portal',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}