import 'package:flutter/material.dart';



class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.grey[200],
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black87),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome card
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1F1D36),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(16.0),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Priyanshu Shrivastava',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '7020764285',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Edit Profile button
              _buildMenuButton(
                title: 'Edit Profile',
                gradient: const LinearGradient(
                  colors: [Color(0xFF3F3B6C), Color(0xFF624F82)],
                ),
                onTap: () {},
              ),
              
              const SizedBox(height: 16),
              
              // How to use the App button
              _buildMenuButton(
                title: 'How to use the App',
                gradient: const LinearGradient(
                  colors: [Color(0xFF301E67), Color(0xFF5B8FB9)],
                ),
                onTap: () {},
              ),
              
              const SizedBox(height: 16),
              
              // Privacy Policy button
              _buildMenuButton(
                title: 'Privacy Policy',
                gradient: const LinearGradient(
                  colors: [Color(0xFF03001C), Color(0xFF5B0060)],
                ),
                onTap: () {},
              ),
              
              const SizedBox(height: 16),
              
              // Request New Features button
              _buildMenuButton(
                title: 'Request New Features',
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A1A40), Color(0xFF270082)],
                ),
                onTap: () {},
              ),
              
              const SizedBox(height: 16),
              
              // Terms and Conditions button
              _buildMenuButton(
                title: 'Terms and Conditions',
                gradient: const LinearGradient(
                  colors: [Color(0xFFB91646), Color(0xFF6E1660)],
                ),
                onTap: () {},
              ),
              
              const SizedBox(height: 24),
              
              // Back to Home button
              Center(
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Back To Home',
                    style: TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildMenuButton({
    required String title,
    required LinearGradient gradient,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Center(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}