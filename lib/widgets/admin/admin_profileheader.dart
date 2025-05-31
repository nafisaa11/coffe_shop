import 'package:flutter/material.dart';

class ProfileHeaderCard extends StatelessWidget {
  final String displayName;
  final String email;
  final String? avatarUrl;
  final IconData fallbackIcon;
  final Color backgroundColor;
  final Color iconColor;
  final Color textColor;

  const ProfileHeaderCard({
    super.key,
    required this.displayName,
    required this.email,
    this.avatarUrl,
    this.fallbackIcon = Icons.admin_panel_settings_rounded,
    this.backgroundColor = const Color(0xFFD3864A),
    this.iconColor = Colors.white,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            backgroundColor,
            backgroundColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Avatar with status indicator
                Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        backgroundImage: (avatarUrl != null && avatarUrl!.isNotEmpty)
                            ? NetworkImage(avatarUrl!)
                            : null,
                        child: (avatarUrl == null || avatarUrl!.isEmpty)
                            ? Icon(
                                fallbackIcon,
                                size: 50,
                                color: iconColor,
                              )
                            : null,
                      ),
                    ),
                    
                    // Online status indicator
                    Positioned(
                      bottom: 5,
                      right: 5,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Name with badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        displayName,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified_rounded,
                            size: 14,
                            color: textColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Admin',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Email with icon
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.email_rounded,
                        size: 16,
                        color: textColor.withOpacity(0.9),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          email,
                          style: TextStyle(
                            fontSize: 15,
                            color: textColor.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}