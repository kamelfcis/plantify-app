import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../services/supabase_service.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage>
    with AutomaticKeepAliveClientMixin {
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await SupabaseService.instance.getAllProfiles();
      if (mounted) {
        setState(() {
          _users = users;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading users: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  bool _isUserOnline(Map<String, dynamic> user) {
    final lastSeen = user['last_seen'];
    if (lastSeen == null) return false;
    try {
      final lastSeenTime = DateTime.parse(lastSeen);
      final diff = DateTime.now().difference(lastSeenTime);
      return diff.inMinutes <= 5; // Online if last seen within 5 minutes
    } catch (e) {
      return false;
    }
  }

  String _getLastSeenText(Map<String, dynamic> user) {
    final lastSeen = user['last_seen'];
    if (lastSeen == null) return 'Never';
    try {
      final lastSeenTime = DateTime.parse(lastSeen);
      final diff = DateTime.now().difference(lastSeenTime);
      if (diff.inMinutes <= 5) return 'Online now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${lastSeenTime.day}/${lastSeenTime.month}/${lastSeenTime.year}';
    } catch (e) {
      return 'Unknown';
    }
  }

  Future<void> _toggleBlock(Map<String, dynamic> user) async {
    final isBlocked = user['is_blocked'] == true;
    final action = isBlocked ? 'unblock' : 'block';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              isBlocked ? Icons.lock_open : Icons.block,
              color: isBlocked ? AppColors.success : AppColors.error,
            ),
            const SizedBox(width: 8),
            Text('${isBlocked ? 'Unblock' : 'Block'} User'),
          ],
        ),
        content: Text(
          'Are you sure you want to $action ${user['full_name'] ?? user['email'] ?? 'this user'}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isBlocked ? AppColors.success : AppColors.error,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(isBlocked ? 'Unblock' : 'Block'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await SupabaseService.instance
            .toggleUserBlock(user['id'], !isBlocked);
        _loadUsers();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'User ${isBlocked ? 'unblocked' : 'blocked'} successfully'),
              backgroundColor:
                  isBlocked ? AppColors.success : AppColors.warning,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final filteredUsers = _searchQuery.isEmpty
        ? _users
        : _users.where((u) {
            final name = (u['full_name'] ?? '').toString().toLowerCase();
            final email = (u['email'] ?? '').toString().toLowerCase();
            return name.contains(_searchQuery.toLowerCase()) ||
                email.contains(_searchQuery.toLowerCase());
          }).toList();

    final onlineCount =
        _users.where((u) => _isUserOnline(u)).length;

    return Column(
      children: [
        // Search bar and stats
        Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Online stats
              Row(
                children: [
                  _buildMiniStat(
                    'Total',
                    '${_users.length}',
                    Icons.people,
                    AppColors.info,
                  ),
                  const SizedBox(width: 12),
                  _buildMiniStat(
                    'Online',
                    '$onlineCount',
                    Icons.circle,
                    AppColors.success,
                  ),
                  const SizedBox(width: 12),
                  _buildMiniStat(
                    'Blocked',
                    '${_users.where((u) => u['is_blocked'] == true).length}',
                    Icons.block,
                    AppColors.error,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Search
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.06),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Search users...',
                    prefixIcon:
                        const Icon(Icons.search, color: AppColors.primary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Users list
        Expanded(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                )
              : filteredUsers.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline,
                              size: 64, color: AppColors.grey),
                          const SizedBox(height: 16),
                          Text(
                            'No users found',
                            style: TextStyle(
                                color: AppColors.textSecondary, fontSize: 16),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadUsers,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: filteredUsers.length,
                        itemBuilder: (context, index) {
                          return _buildUserCard(filteredUsers[index]);
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildMiniStat(
      String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final isOnline = _isUserOnline(user);
    final isBlocked = user['is_blocked'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isBlocked
            ? AppColors.error.withOpacity(0.04)
            : AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: isBlocked
            ? Border.all(color: AppColors.error.withOpacity(0.2))
            : null,
      ),
      child: Row(
        children: [
          // Avatar with online indicator
          Stack(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                backgroundImage: user['avatar_url'] != null
                    ? NetworkImage(user['avatar_url'])
                    : null,
                child: user['avatar_url'] == null
                    ? Text(
                        (user['full_name'] ?? 'U')[0].toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      )
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: isOnline ? AppColors.success : AppColors.grey,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        user['full_name'] ?? 'Unknown User',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          decoration: isBlocked
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ),
                    if (isBlocked)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'BLOCKED',
                          style: TextStyle(
                            color: AppColors.error,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  user['email'] ?? '',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      isOnline ? Icons.wifi : Icons.wifi_off,
                      size: 12,
                      color: isOnline ? AppColors.success : AppColors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getLastSeenText(user),
                      style: TextStyle(
                        fontSize: 12,
                        color: isOnline
                            ? AppColors.success
                            : AppColors.textSecondary,
                        fontWeight:
                            isOnline ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Block/Unblock button
          IconButton(
            onPressed: () => _toggleBlock(user),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isBlocked
                    ? AppColors.success.withOpacity(0.1)
                    : AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isBlocked ? Icons.lock_open : Icons.block,
                color: isBlocked ? AppColors.success : AppColors.error,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

