import 'package:agri_vision/src/presentation/screens/Drone_Module/DroneBookingScreen.dart';
import 'package:agri_vision/src/presentation/screens/Drone_Module/DroneBookingHistoryScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DroneServiceScreen extends StatelessWidget {
  const DroneServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double safeAreaTop = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF8E3),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🌾 --- Top Image Section ---
            Container(
              margin: EdgeInsets.fromLTRB(16, safeAreaTop + 16, 16, 0),
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(60),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
                image: const DecorationImage(
                  image: AssetImage('assets/images/droneDash.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withAlpha(77),
                      Colors.black.withAlpha(179),
                    ],
                  ),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'ڈرون سپرے سروس',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 6),
                      Text(
                        'صحت مند فصل کے لیے جدید سپرے ٹیکنالوجی',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // 🌿 --- Feature Cards Section ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.95,
                children: const [
                  FeatureCard(
                    icon: Icons.precision_manufacturing,
                    title: 'درست سپرے',
                    subtitle: 'ہدف شدہ فصل کے لیے مؤثر سپرے',
                  ),
                  FeatureCard(
                    icon: Icons.savings,
                    title: 'لاگت مؤثر',
                    subtitle: 'کم لاگت میں زیادہ نتیجہ',
                  ),
                  FeatureCard(
                    icon: Icons.eco,
                    title: 'ماحول دوست',
                    subtitle: 'کیمیائی اثرات میں کمی',
                  ),
                  FeatureCard(
                    icon: Icons.speed,
                    title: 'تیز اور محفوظ',
                    subtitle: 'وقت کی بچت اور بہتر کارکردگی',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 🕒 --- Order History Button (NEW) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Get.to(() => const OrderHistoryPage());
                  },
                  icon: const Icon(Icons.history, color: Color(0xFF02A96C)),
                  label: const Text(
                    'آرڈر ہسٹری',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF02A96C),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF02A96C), width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // 🚁 --- Booking Button ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    Get.to(() => const DroneBookingScreen());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF02A96C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 6,
                  ),
                  child: const Text(
                    'سروس بک کریں',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),
            const Text(
"یہ سروس فی الحال پنجاب کے علاقوں کے لیے میسر ہے۔",
              style: TextStyle(
                color: Color(0xFF02A96C),
                fontSize: 14,
                decoration: TextDecoration.underline,
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// 🌾 --- Feature Card Widget ---
class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(51),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF02A96C).withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF02A96C), size: 32),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Color(0xFF02A96C),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 12,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
