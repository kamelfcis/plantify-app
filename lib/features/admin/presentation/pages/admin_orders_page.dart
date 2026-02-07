import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../services/supabase_service.dart';

class AdminOrdersPage extends StatefulWidget {
  const AdminOrdersPage({super.key});

  @override
  State<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage>
    with AutomaticKeepAliveClientMixin {
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;
  String _filterStatus = 'All';
  RealtimeChannel? _ordersChannel;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
    _startRealtimeListener();
  }

  @override
  void dispose() {
    _stopRealtimeListener();
    super.dispose();
  }

  void _startRealtimeListener() {
    final client = SupabaseService.instance.client;
    _ordersChannel = client.channel('admin-orders-page');
    _ordersChannel!
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'orders',
          callback: (payload) {
            debugPrint('🔄 Orders table changed — auto-refreshing');
            _loadOrders();
          },
        )
        .subscribe();
  }

  void _stopRealtimeListener() {
    if (_ordersChannel != null) {
      SupabaseService.instance.client.removeChannel(_ordersChannel!);
      _ordersChannel = null;
    }
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    try {
      final orders = await SupabaseService.instance.getAllOrders();
      if (mounted) {
        setState(() {
          _orders = orders;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading orders: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppColors.warning;
      case 'processing':
        return AppColors.info;
      case 'shipped':
        return const Color(0xFF9B59B6);
      case 'delivered':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.schedule;
      case 'processing':
        return Icons.autorenew;
      case 'shipped':
        return Icons.local_shipping;
      case 'delivered':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  Future<void> _changeOrderStatus(Map<String, dynamic> order) async {
    final currentStatus = order['status'] ?? 'pending';
    String? newStatus;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child:
                  const Icon(Icons.swap_horiz, color: AppColors.info, size: 22),
            ),
            const SizedBox(width: 10),
            const Text('Update Status'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Order: ${order['order_number'] ?? order['id'].toString().substring(0, 8)}',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            ...['pending', 'processing', 'shipped', 'delivered', 'cancelled']
                .map((status) {
              final isSelected = currentStatus == status;
              final color = _getStatusColor(status);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () {
                    newStatus = status;
                    Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color.withOpacity(0.12)
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(14),
                      border: isSelected
                          ? Border.all(color: color.withOpacity(0.4))
                          : null,
                    ),
                    child: Row(
                      children: [
                        Icon(_getStatusIcon(status), color: color, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            status[0].toUpperCase() + status.substring(1),
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: color,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Icon(Icons.check_circle, color: color, size: 20),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );

    if (newStatus != null && newStatus != currentStatus) {
      try {
        await SupabaseService.instance
            .updateOrderStatus(order['id'], newStatus!);
        _loadOrders();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Order status updated to ${newStatus![0].toUpperCase()}${newStatus!.substring(1)}'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating status: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  void _showOrderDetails(Map<String, dynamic> order) {
    final items = order['order_items'] as List? ?? [];
    final gifts = order['gifts'] as List? ?? [];
    final isGift = order['is_gift'] == true || gifts.isNotEmpty;
    final shipping = order['shipping_address'] as Map<String, dynamic>? ?? {};

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Header
              Row(
                children: [
                  Icon(
                    isGift ? Icons.card_giftcard : Icons.receipt_long,
                    color: AppColors.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order #${order['order_number'] ?? order['id'].toString().substring(0, 8)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (isGift)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              '🎁 Gift Order',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  _buildStatusChip(order['status'] ?? 'pending'),
                ],
              ),
              const SizedBox(height: 24),
              // Order info
              _buildDetailSection('Order Info', [
                _buildDetailRow(
                    'Total', '\$${order['total_amount']?.toStringAsFixed(2)}'),
                _buildDetailRow(
                    'Date',
                    _formatDate(order['created_at'])),
                _buildDetailRow(
                    'Status',
                    (order['status'] ?? 'pending').toString().toUpperCase()),
              ]),
              const SizedBox(height: 16),
              // Shipping
              _buildDetailSection('Shipping Address', [
                _buildDetailRow(
                    'Name', shipping['fullName'] ?? 'N/A'),
                _buildDetailRow(
                    'Phone', shipping['phone'] ?? 'N/A'),
                _buildDetailRow(
                    'Address', shipping['address'] ?? 'N/A'),
                _buildDetailRow(
                    'City',
                    '${shipping['city'] ?? ''} ${shipping['zipCode'] ?? ''}'),
              ]),
              const SizedBox(height: 16),
              // Items
              _buildDetailSection(
                'Items (${items.length})',
                items
                    .map((item) => _buildDetailRow(
                          '${item['product_name']} x${item['quantity']}',
                          '\$${item['subtotal']?.toStringAsFixed(2)}',
                        ))
                    .toList(),
              ),
              // Gift info
              if (isGift && gifts.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildDetailSection('Gift Details', [
                  _buildDetailRow(
                      'To', gifts[0]['receiver_name'] ?? 'N/A'),
                  _buildDetailRow(
                      'Email', gifts[0]['receiver_email'] ?? 'N/A'),
                  if (gifts[0]['gift_message'] != null)
                    _buildDetailRow(
                        'Message', gifts[0]['gift_message']),
                ]),
              ],
              const SizedBox(height: 24),
              // Change status button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _changeOrderStatus(order);
                  },
                  icon: const Icon(Icons.swap_horiz),
                  label: const Text('Change Status'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }

  Widget _buildStatusChip(String status) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getStatusIcon(status), color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            status[0].toUpperCase() + status.substring(1),
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final filteredOrders = _filterStatus == 'All'
        ? _orders
        : _orders
            .where((o) =>
                (o['status'] ?? 'pending').toString().toLowerCase() ==
                _filterStatus.toLowerCase())
            .toList();

    final giftOrders = _orders.where((o) {
      final gifts = o['gifts'] as List? ?? [];
      return o['is_gift'] == true || gifts.isNotEmpty;
    }).length;

    return Column(
      children: [
        // Stats row
        Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(
            children: [
              _buildOrderStat(
                  'Total', '${_orders.length}', AppColors.info),
              const SizedBox(width: 10),
              _buildOrderStat(
                'Pending',
                '${_orders.where((o) => o['status'] == 'pending').length}',
                AppColors.warning,
              ),
              const SizedBox(width: 10),
              _buildOrderStat('Gifts', '$giftOrders', AppColors.primary),
            ],
          ),
        ),
        // Filter chips
        Container(
          height: 55,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              'All',
              'Pending',
              'Processing',
              'Shipped',
              'Delivered',
              'Cancelled'
            ].map((status) {
              final isSelected = _filterStatus == status;
              final color = status == 'All'
                  ? AppColors.primary
                  : _getStatusColor(status.toLowerCase());
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(
                    status,
                    style: TextStyle(
                      color: isSelected ? AppColors.white : color,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (_) =>
                      setState(() => _filterStatus = status),
                  selectedColor: color,
                  backgroundColor: color.withOpacity(0.08),
                  checkmarkColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected
                          ? Colors.transparent
                          : color.withOpacity(0.3),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        // Orders list
        Expanded(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                )
              : filteredOrders.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt_long_outlined,
                              size: 64, color: AppColors.grey),
                          const SizedBox(height: 16),
                          Text(
                            'No orders found',
                            style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 16),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadOrders,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: filteredOrders.length,
                        itemBuilder: (context, index) {
                          return _buildOrderCard(filteredOrders[index]);
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildOrderStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final status = order['status'] ?? 'pending';
    final color = _getStatusColor(status);
    final gifts = order['gifts'] as List? ?? [];
    final isGift = order['is_gift'] == true || gifts.isNotEmpty;
    final items = order['order_items'] as List? ?? [];

    return GestureDetector(
      onTap: () => _showOrderDetails(order),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
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
          border: Border(
            left: BorderSide(color: color, width: 4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Icon(_getStatusIcon(status), color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '#${order['order_number'] ?? order['id'].toString().substring(0, 8)}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                if (isGift)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('🎁 ', style: TextStyle(fontSize: 12)),
                        Text(
                          'Gift',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                _buildStatusChip(status),
              ],
            ),
            const SizedBox(height: 12),
            // Info rows
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.attach_money,
                          size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        '\$${order['total_amount']?.toStringAsFixed(2) ?? '0.00'}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.shopping_bag,
                        size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      '${items.length} item${items.length != 1 ? 's' : ''}',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time,
                    size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  _formatDate(order['created_at']),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                // Change status button
                InkWell(
                  onTap: () => _changeOrderStatus(order),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.swap_horiz,
                            color: AppColors.info, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'Change',
                          style: TextStyle(
                            color: AppColors.info,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

