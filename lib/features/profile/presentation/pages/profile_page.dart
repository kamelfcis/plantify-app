import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../services/supabase_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final user = SupabaseService.instance.currentUser;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.white,
                        child: Icon(
                          Icons.person,
                          size: 50,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user?.userMetadata?['full_name'] ?? 'User',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: AppColors.white,
                            ),
                      ),
                      Text(
                        user?.email ?? '',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.white.withOpacity(0.9),
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSectionTitle('Account'),
                GlassCard(
                  child: Column(
                    children: [
                      _buildMenuItem(
                        icon: Icons.person_outline,
                        title: 'Personal Information',
                        onTap: () {
                          // Navigate to edit profile
                        },
                      ),
                      const Divider(),
                      _buildMenuItem(
                        icon: Icons.email_outlined,
                        title: 'Email Settings',
                        onTap: () {
                          // Navigate to email settings
                        },
                      ),
                      const Divider(),
                      _buildMenuItem(
                        icon: Icons.lock_outlined,
                        title: 'Change Password',
                        onTap: () {
                          // Navigate to change password
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('Orders & Gifts'),
                GlassCard(
                  child: Column(
                    children: [
                      _buildMenuItem(
                        icon: Icons.shopping_bag_outlined,
                        title: 'Order History',
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            '3',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        onTap: () {
                          _showOrderHistory();
                        },
                      ),
                      const Divider(),
                      _buildMenuItem(
                        icon: Icons.card_giftcard_outlined,
                        title: 'Gift History',
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            '1',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        onTap: () {
                          _showGiftHistory();
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('Help & Support'),
                GlassCard(
                  child: Column(
                    children: [
                      _buildMenuItem(
                        icon: Icons.lightbulb_outline,
                        title: 'Tips & Ideas',
                        onTap: () {
                          _showTips();
                        },
                      ),
                      const Divider(),
                      _buildMenuItem(
                        icon: Icons.help_outline,
                        title: 'FAQ',
                        onTap: () {
                          _showFAQ();
                        },
                      ),
                      const Divider(),
                      _buildMenuItem(
                        icon: Icons.support_agent_outlined,
                        title: 'Contact Support',
                        onTap: () {
                          // Navigate to support
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                GradientButton(
                  text: 'Sign Out',
                  onPressed: () async {
                    await SupabaseService.instance.signOut();
                    if (mounted) {
                      context.go('/auth/login');
                    }
                  },
                  width: double.infinity,
                  gradient: LinearGradient(
                    colors: [AppColors.error, AppColors.error.withOpacity(0.7)],
                  ),
                ),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      trailing: trailing ?? Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }

  void _showOrderHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Order History'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _OrderItem(orderId: '#12345', date: '2024-01-15', total: '\$29.99', status: 'Delivered'),
              _OrderItem(orderId: '#12344', date: '2024-01-10', total: '\$45.98', status: 'Shipped'),
              _OrderItem(orderId: '#12343', date: '2024-01-05', total: '\$19.99', status: 'Processing'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showGiftHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Gift History'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _GiftItem(
                receiver: 'John Doe',
                date: '2024-01-12',
                total: '\$29.99',
                status: 'Delivered',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTips() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Tips & Ideas'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('💧 Watering Tips', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Water plants in the morning for best absorption.'),
              SizedBox(height: 16),
              Text('☀️ Light Tips', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Most indoor plants prefer bright, indirect light.'),
              SizedBox(height: 16),
              Text('🌡️ Temperature', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Keep plants away from drafts and heating vents.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showFAQ() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Frequently Asked Questions'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Q: How often should I water my plants?', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('A: It depends on the plant type. Use our water calculator for personalized recommendations.'),
              SizedBox(height: 16),
              Text('Q: Can I return a plant?', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('A: Yes, we offer a 30-day return policy for healthy plants.'),
              SizedBox(height: 16),
              Text('Q: How accurate is the AI identification?', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('A: Our AI has a 95%+ accuracy rate for common plant species.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _OrderItem extends StatelessWidget {
  final String orderId;
  final String date;
  final String total;
  final String status;

  const _OrderItem({
    required this.orderId,
    required this.date,
    required this.total,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(orderId, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(total, style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(date, style: Theme.of(context).textTheme.bodySmall),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: _getStatusColor(status),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return AppColors.success;
      case 'shipped':
        return AppColors.info;
      case 'processing':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }
}

class _GiftItem extends StatelessWidget {
  final String receiver;
  final String date;
  final String total;
  final String status;

  const _GiftItem({
    required this.receiver,
    required this.date,
    required this.total,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('To: $receiver', style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(total, style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(date, style: Theme.of(context).textTheme.bodySmall),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: AppColors.success,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

