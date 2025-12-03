// lib/src/presentation/widgets/custom_drawer.dart
import 'package:agri_vision/src/presentation/screens/Drawer_Pages/History_Screen/history_screen.dart';
import 'package:agri_vision/src/presentation/screens/Drawer_Pages/support_screen.dart';
import 'package:agri_vision/src/presentation/screens/Drawer_Pages/about_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';


class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Drawer(
        backgroundColor: const Color(0xFFFDF8E3),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Header Section
            Container(
              height: 200,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF02A96C), Color(0xFF00C853)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.agriculture,
                    size: 50,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 10),
                  Text(
                   "ایگری ویژن",
                    style: GoogleFonts.vazirmatn(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Agri Vision',
                    style: GoogleFonts.vazirmatn(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            // Menu Items
            _DrawerItem(
              icon: Icons.history,
              title: "سکین ہسٹری",
              onTap: () {
                Navigator.pop(context);
                Get.to(() => HistoryScreen());
              },
            ),

            _DrawerItem(
              icon: Icons.help_outline,
              title: "مدد اور سپورٹ",
              onTap: () {
                Navigator.pop(context);
                Get.to(() => SupportScreen());
              },
            ),

            _DrawerItem(
              icon: Icons.info_outline,
              title: "ایپ کے بارے میں",
              onTap: () {
                Navigator.pop(context);
                Get.to(() => AboutScreen());
              },
            ),

            const SizedBox(height: 20),
            const Divider(
              color: Color(0xFF02A96C),
              height: 1,
              indent: 20,
              endIndent: 20,
            ),
            const SizedBox(height: 20),

            // App Version
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "ورژن 1.0.0",
                textAlign: TextAlign.center,
                style: GoogleFonts.vazirmatn(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: const Color(0xFF02A96C),
        size: 24,
      ),
      title: Text(
        title,
        style: GoogleFonts.vazirmatn(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF02A96C),
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
    );
  }
}