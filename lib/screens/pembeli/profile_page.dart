// screens/profile_page.dart
import 'package:flutter/material.dart';
import 'package:kopiqu/screens/pembeli/daftar_riwayat_page.dart';
import 'package:kopiqu/screens/pembeli/editprofiledialog.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:kopiqu/widgets/Layout/headerProfile_widget.dart';
import 'package:kopiqu/widgets/admin/admin_logoutbutton.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  void _refreshProfileHeader() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          // Profile Header with enhanced styling
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFFD07C3D),
                  const Color(0xFFD07C3D).withOpacity(0.8),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD07C3D).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const ProfileHeader(),
          ),

          // Main content with proper spacing
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // Menu Section
                  Container(
                    margin: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section Title
                        const SizedBox(width: 12),

                        // Menu Items Container
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _buildModernMenuItem(
                                context: context,
                                icon: PhosphorIcons.user(PhosphorIconsStyle.regular),
                                text: 'Profil Saya',
                                subtitle: 'Kelola informasi pribadi Anda',
                                gradientColors: [
                                  const Color(0xFFD07C3D).withOpacity(0.1),
                                  const Color(0xFFD07C3D).withOpacity(0.05),
                                ],
                                onTap: () async {
                                  final result = await showDialog<bool>(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return const EditProfileDialog();
                                    },
                                  );
                                  if (result == true && mounted) {
                                    print('Profil berhasil diupdate, me-refresh ProfileHeader...');
                                    _refreshProfileHeader();
                                  }
                                },
                              ),
                              
                              // Divider
                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: 20),
                                height: 1,
                                color: Colors.grey.shade100,
                              ),

                              _buildModernMenuItem(
                                context: context,
                                icon: PhosphorIcons.clockCounterClockwise(PhosphorIconsStyle.regular),
                                text: 'Riwayat Pembelian',
                                subtitle: 'Lihat semua transaksi Anda',
                                gradientColors: [
                                  Colors.blue.withOpacity(0.1),
                                  Colors.blue.withOpacity(0.05),
                                ],
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const DaftarRiwayatPage(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Additional spacing before logout button
                  const SizedBox(height: 20),

                  // Logout Button Section - with proper spacing from navbar
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 100, 20, 50), // Extra bottom padding for navbar
                    child: Column(
                      children: [
                        // Logout Button
                        const LogoutButton(),
                        
                        const SizedBox(height: 16),
                        
                        // Footer text
                        Text(
                          'Terima kasih telah menggunakan KopiQu v1.0',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernMenuItem({
    required BuildContext context,
    required IconData icon,
    required String text,
    required String subtitle,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Icon with gradient background
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: gradientColors[0].withOpacity(0.8),
                  size: 24,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      text,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C2C2C),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Arrow icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  PhosphorIcons.caretRight(PhosphorIconsStyle.bold),
                  size: 16,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}