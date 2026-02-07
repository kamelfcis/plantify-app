import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../services/supabase_service.dart';
import '../../../../services/order_notification_service.dart';
import 'admin_users_page.dart';
import 'admin_products_page.dart';
import 'admin_orders_page.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  Map<String, int> _stats = {};
  bool _isLoadingStats = true;
  int _newOrderCount = 0;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final List<Widget> _pages = const [
    _DashboardHome(),
    AdminUsersPage(),
    AdminProductsPage(),
    AdminOrdersPage(),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _fadeController.forward();
    _loadStats();
    _startOrderListener();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    OrderNotificationService.instance.stopAdminListener();
    super.dispose();
  }

  void _startOrderListener() async {
    await OrderNotificationService.instance.initialize();
    OrderNotificationService.instance.onNewOrderForAdmin = () {
      if (mounted) {
        setState(() => _newOrderCount++);
        _loadStats(); // Refresh stats
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.notifications_active,
                    color: AppColors.white, size: 20),
                SizedBox(width: 12),
                Text('🛒 New order received!',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'VIEW',
              textColor: AppColors.white,
              onPressed: () => setState(() => _currentIndex = 3),
            ),
          ),
        );
      }
    };
    OrderNotificationService.instance.startAdminListener();
  }

  Future<void> _loadStats() async {
    try {
      final stats = await SupabaseService.instance.getAdminStats();
      if (mounted) {
        setState(() {
          _stats = stats;
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingStats = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.admin_panel_settings,
                  color: AppColors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Text('Admin Dashboard'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _loadStats();
              setState(() {});
            },
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.logout, color: AppColors.error, size: 20),
            ),
            onPressed: () => _showLogoutDialog(),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: IndexedStack(
          index: _currentIndex,
          children: [
            _buildDashboardHome(),
            const AdminUsersPage(),
            const AdminProductsPage(),
            const AdminOrdersPage(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
              if (index == 3) _newOrderCount = 0; // Clear badge on Orders tab
            });
          },
          backgroundColor: Colors.transparent,
          indicatorColor: AppColors.primary.withOpacity(0.15),
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard, color: AppColors.primary),
              label: 'Overview',
            ),
            NavigationDestination(
              icon: Icon(Icons.people_outlined),
              selectedIcon: Icon(Icons.people, color: AppColors.primary),
              label: 'Users',
            ),
            NavigationDestination(
              icon: Icon(Icons.inventory_2_outlined),
              selectedIcon: Icon(Icons.inventory_2, color: AppColors.primary),
              label: 'Products',
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: _newOrderCount > 0,
                label: Text('$_newOrderCount'),
                backgroundColor: AppColors.error,
                child: const Icon(Icons.receipt_long_outlined),
              ),
              selectedIcon: Badge(
                isLabelVisible: _newOrderCount > 0,
                label: Text('$_newOrderCount'),
                backgroundColor: AppColors.error,
                child: const Icon(Icons.receipt_long, color: AppColors.primary),
              ),
              label: 'Orders',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardHome() {
    return RefreshIndicator(
      onRefresh: _loadStats,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Welcome card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Welcome, Admin! 👋',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Manage your Plantify app from here',
                        style: TextStyle(
                          color: AppColors.white.withOpacity(0.85),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.eco,
                    color: AppColors.white,
                    size: 40,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Stats grid
          Text(
            'Quick Stats',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 16),
          if (_isLoadingStats)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            )
          else
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.15,
              children: [
                _buildStatCard(
                  'Total Users',
                  '${_stats['users'] ?? 0}',
                  Icons.people,
                  AppColors.info,
                  () => setState(() => _currentIndex = 1),
                ),
                _buildStatCard(
                  'Products',
                  '${_stats['products'] ?? 0}',
                  Icons.inventory_2,
                  AppColors.accent,
                  () => setState(() => _currentIndex = 2),
                ),
                _buildStatCard(
                  'Orders',
                  '${_stats['orders'] ?? 0}',
                  Icons.receipt_long,
                  AppColors.warning,
                  () => setState(() => _currentIndex = 3),
                ),
                _buildStatCard(
                  'Gifts',
                  '${_stats['gifts'] ?? 0}',
                  Icons.card_giftcard,
                  AppColors.primary,
                  () => setState(() => _currentIndex = 3),
                ),
              ],
            ),
          const SizedBox(height: 24),
          // Quick actions
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 16),
          _buildActionCard(
            'Add New Product',
            'Add plants and supplies to the marketplace',
            Icons.add_box,
            AppColors.accent,
            () => setState(() => _currentIndex = 2),
          ),
          const SizedBox(height: 12),
          _buildActionCard(
            'Manage Orders',
            'View and update order statuses',
            Icons.local_shipping,
            AppColors.warning,
            () => setState(() => _currentIndex = 3),
          ),
          const SizedBox(height: 12),
          _buildActionCard(
            'User Management',
            'View users and manage access',
            Icons.manage_accounts,
            AppColors.info,
            () => setState(() => _currentIndex = 1),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.12),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(
            color: color.withOpacity(0.1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const Spacer(),
            Text(
              value,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.logout, color: AppColors.error),
            SizedBox(width: 8),
            Text('Logout'),
          ],
        ),
        content: const Text('Are you sure you want to exit the admin panel?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/auth/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

// Placeholder widget used in IndexedStack - actual content is _buildDashboardHome()
class _DashboardHome extends StatelessWidget {
  const _DashboardHome();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(); // The actual dashboard home is built inline
  }
}

