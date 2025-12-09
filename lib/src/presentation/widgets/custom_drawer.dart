import 'package:agri_vision/src/presentation/screens/Drawer_Pages/History_Screen/history_screen.dart';
import 'package:agri_vision/src/presentation/screens/Drawer_Pages/support_screen.dart';
import 'package:agri_vision/src/presentation/screens/Drawer_Pages/about_screen.dart';
import 'package:agri_vision/src/presentation/AppConstant/user_session.dart';
import 'package:agri_vision/src/presentation/screens/flow/user_information.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  Future<void> _logoutUser(BuildContext context) async {
    Get.dialog(
      Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(
            "لاگ آؤٹ",
            style: GoogleFonts.vazirmatn(fontWeight: FontWeight.bold),
          ),
          content: Text(
            "کیا آپ لاگ آؤٹ کرنا چاہتے ہیں؟\nآپ کو دوبارہ ای میل اور OTP درج کرنا پڑے گا۔",
            style: GoogleFonts.vazirmatn(),
            textAlign: TextAlign.right,
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text(
                "نہیں",
                style: GoogleFonts.vazirmatn(color: const Color(0xFF02A96C)),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Get.back(result: true),
              child: Text(
                "ہاں، لاگ آؤٹ کریں",
                style: GoogleFonts.vazirmatn(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    ).then((confirm) async {
      if (confirm == true) {
        Get.back(); // Close drawer
        
        // ✅ FIXED: Use UserSession.logout()
        await UserSession.logout();
        
        Get.showSnackbar(
          GetSnackBar(
            messageText: Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                "کامیابی سے لاگ آؤٹ ہو گئے",
                style: GoogleFonts.vazirmatn(
                  color: Colors.white,
                  fontSize: 16,
                ),
                textAlign: TextAlign.right,
              ),
            ),
            backgroundColor: const Color(0xFF02A96C),
            duration: const Duration(seconds: 2),
            snackPosition: SnackPosition.TOP,
          ),
        );
        
        await Future.delayed(const Duration(milliseconds: 500));
        Get.offAll(() => const UserInformation());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Drawer(
        backgroundColor: const Color(0xFFFDF8E3),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
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
                  const Icon(Icons.agriculture, size: 50, color: Colors.white),
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

            _DrawerItem(
              icon: Icons.history,
              title: "سکین ہسٹری",
              onTap: () {
                Get.back();
                Get.to(() =>  HistoryScreen());
              },
            ),

            _DrawerItem(
              icon: Icons.help_outline,
              title: "مدد اور سپورٹ",
              onTap: () {
                Get.back();
                Get.to(() => const SupportScreen());
              },
            ),

            _DrawerItem(
              icon: Icons.info_outline,
              title: "ایپ کے بارے میں",
              onTap: () {
                Get.back();
                Get.to(() => const AboutScreen());
              },
            ),

            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red, size: 24),
              title: Text(
                "لاگ آؤٹ کریں",
                style: GoogleFonts.vazirmatn(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.red,
                ),
              ),
              onTap: () => _logoutUser(context),
              contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
            ),

            const SizedBox(height: 20),
            const Divider(color: Color(0xFF02A96C), height: 1, indent: 20, endIndent: 20),
            const SizedBox(height: 20),

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
      leading: Icon(icon, color: const Color(0xFF02A96C), size: 24),
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