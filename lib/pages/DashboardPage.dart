import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: const [
          Icon(Icons.notifications_none, color: Colors.black),
          SizedBox(width: 10),
          Icon(Icons.menu, color: Colors.black),
          SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Welcome Banner
            Stack(
              alignment: Alignment.centerLeft,
              children: [
                Image.asset(
                  'assets/dashboard_banner.png',
                  width: double.infinity,
                  height: 120,
                  fit: BoxFit.cover,
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 16.0),
                  child: Text(
                    'Welcome Home\nPriyanshu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Text(
              'Your Stats',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            // Stat Cards
            for (int i = 0; i < 4; i++)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: const DecorationImage(
                      image: AssetImage('assets/stat_card.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Total Orders - 20',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // Action Cards
            _buildActionCard('Add Order', 'assets/add_order.png'),
            _buildActionCard('View Order', 'assets/view_order.png'),
            _buildActionCard('Service Options', 'assets/service_options.png'),
            _buildActionCard('Staff Management', 'assets/staff_management.png'),
            _buildActionCard('Customer Management', 'assets/customer_management.png'),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(String label, String assetPath) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Image.asset(assetPath, fit: BoxFit.contain),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
