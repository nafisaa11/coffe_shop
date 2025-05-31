import 'package:flutter/material.dart';
import 'package:kopiqu/services/auth_service.dart';
import 'package:kopiqu/widgets/admin/admin_profileheader.dart';
import 'package:kopiqu/widgets/admin/admin_infotile.dart';
import 'package:kopiqu/widgets/admin/admin_historycard.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  String displayName = 'Admin';
  String email = 'Tidak ada email';
  String? avatarUrl;
  String? lastLogin;
  int loginsToday = 0;
  List<Map<String, dynamic>> _dummyLoginHistory = [];

  // Improved color scheme
  final Color primaryColor = const Color(0xFFD3864A);
  final Color secondaryColor = const Color(0xFF804E23);
  final Color backgroundColor = const Color(0xFFF8F6F4);
  final Color cardColor = Colors.white;
  final Color textPrimary = const Color(0xFF2D2D2D);
  final Color textSecondary = const Color(0xFF666666);
  final Color accentColor = const Color(0xFFE8B882);
  final Color dangerColor = const Color(0xFFE74C3C);

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadLoginStats();
  }

  void _loadUserData() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null && mounted) {
      setState(() {
        displayName = user.userMetadata?['display_name'] as String? ?? 'Admin';
        email = user.email ?? 'Tidak ada email';
      });
    }
  }

  void _loadLoginStats() {
    if (mounted) {
      final now = DateTime.now();
      final DateFormat timeFormatter = DateFormat('HH:mm', 'id_ID');
      final DateFormat dateFormatter = DateFormat('dd MMM yy', 'id_ID');
      setState(() {
        lastLogin =
            "${dateFormatter.format(now.subtract(const Duration(minutes: 30)))} ${timeFormatter.format(now.subtract(const Duration(minutes: 30)))}";
        loginsToday = 2;
        _dummyLoginHistory = [
          {
            'timestamp': now.subtract(const Duration(minutes: 30)),
            'device': 'KopiQu Admin Web',
          },
          {
            'timestamp': now.subtract(const Duration(hours: 4)),
            'device': 'Perangkat Tidak Dikenal',
          },
          {
            'timestamp': now.subtract(const Duration(days: 1, hours: 2)),
            'device': 'KopiQu Admin Web',
          },
        ];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          // Header Section with gradient
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [primaryColor, secondaryColor],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      // Profile Avatar
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 55,
                          backgroundColor: accentColor,
                          backgroundImage: (avatarUrl != null && avatarUrl!.isNotEmpty)
                              ? NetworkImage(avatarUrl!)
                              : null,
                          child: (avatarUrl == null || avatarUrl!.isEmpty)
                              ? Icon(
                                  Icons.admin_panel_settings_rounded,
                                  size: 60,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Name and Email
                      Text(
                        displayName,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          email,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Content Section
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -20),
              child: Container(
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Quick Stats Row
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.history_toggle_off_rounded,
                              title: 'Login Terakhir',
                              value: lastLogin ?? '-',
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.today_rounded,
                              title: 'Login Hari Ini',
                              value: '$loginsToday kali',
                              color: secondaryColor,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Login Activity Section
                      _buildSectionHeader('Aktivitas Login'),
                      const SizedBox(height: 16),
                      
                      _buildImprovedLoginHistoryCard(),
                      
                      const SizedBox(height: 40),
                      
                      // Logout Button
                      Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: dangerColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.logout_rounded, color: Colors.white),
                          label: const Text(
                            'Logout',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: dangerColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () async {
                            final currentContext = context;
                            await AuthService().logout(currentContext);
                          },
                        ),
                      ),
                      
                      const SizedBox(height: 20),
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

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: textSecondary,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 16,
        color: textSecondary,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    );
  }

  Widget _buildImprovedLoginHistoryCard() {
    final DateFormat formatter = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');

    return Card(
      elevation: 0,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.history_rounded,
                    color: primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Riwayat Login Terakhir',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            if (_dummyLoginHistory.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: textSecondary),
                    const SizedBox(width: 12),
                    Text(
                      'Tidak ada riwayat login yang tercatat.',
                      style: TextStyle(color: textSecondary),
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _dummyLoginHistory.length > 3 ? 3 : _dummyLoginHistory.length,
                itemBuilder: (context, index) {
                  final entry = _dummyLoginHistory[index];
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: index == 0 ? accentColor.withOpacity(0.1) : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: index == 0 ? Border.all(color: accentColor.withOpacity(0.3)) : null,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: index == 0 ? primaryColor : textSecondary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.login_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                formatter.format(entry['timestamp'] as DateTime),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                entry['device'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (index == 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Terbaru',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
                separatorBuilder: (context, index) => const SizedBox(height: 12),
              ),
              
            if (_dummyLoginHistory.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Center(
                  child: TextButton.icon(
                    icon: Icon(Icons.history_rounded, size: 18, color: primaryColor),
                    label: Text(
                      'Lihat Semua Riwayat',
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: () {
                      // TODO: Navigate to full history page
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showFeatureNotImplemented() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 12),
            const Text('Fitur ini belum diimplementasikan.'),
          ],
        ),
        backgroundColor: primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}