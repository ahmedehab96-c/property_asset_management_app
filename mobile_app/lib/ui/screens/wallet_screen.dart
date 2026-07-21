import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:property_asset_management_app/l10n/app_localizations.dart';
import 'package:property_asset_management_app/core/models/view_status.dart';
import 'package:property_asset_management_app/viewmodels/wallet_notifier.dart';
import 'package:property_asset_management_app/utils/owner_api_mappers.dart';
import 'package:property_asset_management_app/core/providers/locale_notifier.dart';
import 'package:property_asset_management_app/theme/app_theme.dart';
import 'package:property_asset_management_app/widgets/app_scaffold.dart';
import 'package:property_asset_management_app/ui/animations/staggered_animation.dart';
import 'package:property_asset_management_app/ui/animations/page_transitions.dart';
import 'package:property_asset_management_app/ui/screens/profile_screen.dart';
import 'package:property_asset_management_app/ui/screens/notifications_screen.dart';
import 'package:property_asset_management_app/ui/screens/bank_transfer_account_selection_screen.dart';
import 'package:property_asset_management_app/ui/home_shell.dart';
import 'package:property_asset_management_app/widgets/demo_data_banner.dart';
import 'package:property_asset_management_app/utils/responsive_helper.dart';

enum _WalletTransactionFilter { all, revenues, expenses, thisMonth, thisYear }

class _WalletTransaction {
  final String title;
  final String amount;
  final String dateLabel;
  final DateTime date;
  final bool isIncome;

  const _WalletTransaction({
    required this.title,
    required this.amount,
    required this.dateLabel,
    required this.date,
    required this.isIncome,
  });
}

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _balanceAnimation;
  _WalletTransactionFilter _selectedFilter = _WalletTransactionFilter.all;
  double _targetBalance = 125000;

  _WalletTransaction _mapTransaction(WalletTransactionData data) {
    return _WalletTransaction(
      title: data.title,
      amount: data.amount,
      dateLabel: data.dateLabel,
      date: data.date,
      isIncome: data.isIncome,
    );
  }

  List<_WalletTransaction> _filteredTransactions(
    List<_WalletTransaction> transactions,
  ) {
    final now = DateTime.now();
    return transactions.where((transaction) {
      switch (_selectedFilter) {
        case _WalletTransactionFilter.all:
          return true;
        case _WalletTransactionFilter.revenues:
          return transaction.isIncome;
        case _WalletTransactionFilter.expenses:
          return !transaction.isIncome;
        case _WalletTransactionFilter.thisMonth:
          return transaction.date.year == now.year &&
              transaction.date.month == now.month;
        case _WalletTransactionFilter.thisYear:
          return transaction.date.year == now.year;
      }
    }).toList();
  }

  void _applyFilter(_WalletTransactionFilter filter) {
    setState(() => _selectedFilter = filter);
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _balanceAnimation = Tween<double>(begin: 0.0, end: _targetBalance).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _animationController.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    ref.read(walletProvider.notifier).load(
          l10n: AppLocalizations.of(context),
          isArabic: ref.read(isArabicProvider),
        );
  }

  void _syncBalanceAnimation(double balance) {
    if (_targetBalance == balance) return;
    _targetBalance = balance;
    _restartBalanceAnimation();
  }

  void _restartBalanceAnimation() {
    _balanceAnimation = Tween<double>(begin: 0.0, end: _targetBalance).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _animationController
      ..reset()
      ..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showFilterBottomSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: context.estate.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.filterTransactions,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.estate.textPrimary,
                  ),
            ),
            SizedBox(height: 20),
            _FilterOption(
              title: l10n.all,
              isSelected: _selectedFilter == _WalletTransactionFilter.all,
              onTap: () => _applyFilter(_WalletTransactionFilter.all),
            ),
            _FilterOption(
              title: l10n.revenues,
              isSelected: _selectedFilter == _WalletTransactionFilter.revenues,
              onTap: () => _applyFilter(_WalletTransactionFilter.revenues),
            ),
            _FilterOption(
              title: l10n.expenses,
              isSelected: _selectedFilter == _WalletTransactionFilter.expenses,
              onTap: () => _applyFilter(_WalletTransactionFilter.expenses),
            ),
            _FilterOption(
              title: l10n.thisMonth,
              isSelected: _selectedFilter == _WalletTransactionFilter.thisMonth,
              onTap: () => _applyFilter(_WalletTransactionFilter.thisMonth),
            ),
            _FilterOption(
              title: l10n.thisYear,
              isSelected: _selectedFilter == _WalletTransactionFilter.thisYear,
              onTap: () => _applyFilter(_WalletTransactionFilter.thisYear),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final ws = ref.watch(walletProvider);
    _syncBalanceAnimation(ws.balance);
    final transactions =
        ws.transactions.map(_mapTransaction).toList();
    final filteredTransactions = _filteredTransactions(transactions);
    final loading = ws.status == ViewStatus.loading && ws.transactions.isEmpty;
    return AppScaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    context.estate.surfaceGlass,
                    context.estate.surfaceGlassLight,
                  ],
                ),
              ),
              child: AppBar(
                backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_forward_ios, color: context.estate.textPrimary),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              // If part of bottom navigation, navigate to dashboard
              final homeShellState = context.findAncestorStateOfType<HomeShellState>();
              if (homeShellState != null) {
                homeShellState.changeIndex(0);
              }
            }
          },
        ),
        title: Text(
          AppLocalizations.of(context).financialWallet,
          style: TextStyle(color: context.estate.textPrimary),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: context.estate.textPrimary),
            tooltip: AppLocalizations.of(context).notifications,
            onPressed: () {
              Navigator.push(
                context,
                SlidePageRoute(
                  page: const NotificationsScreen(),
                  direction: AxisDirection.left,
                ),
              );
            },
          ),
          SizedBox(width: 8),
          IconButton(
            icon: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.estate.textPrimary.withValues(alpha: 0.2),
              ),
              child: Icon(Icons.person, color: context.estate.textPrimary, size: 18),
            ),
            tooltip: AppLocalizations.of(context).profile,
            onPressed: () {
              Navigator.push(
                context,
                SlidePageRoute(
                  page: const ProfileScreen(),
                  direction: AxisDirection.left,
                ),
              );
            },
          ),
          SizedBox(width: 8),
        ],
      ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: loading
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: AppColors.accentGold),
                    const SizedBox(height: 16),
                    Text(
                      l10n.loadingWallet,
                      style: TextStyle(color: context.estate.textSecondary),
                    ),
                  ],
                ),
              )
            : FadeTransition(
        opacity: _fadeAnimation,
        child: RefreshIndicator(
          color: AppColors.accentGold,
          onRefresh: () async => _load(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(ResponsiveHelper.adaptivePadding(context)),
            child: ResponsiveHelper.constrainContent(
              context: context,
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (ws.fromDemo)
            const DemoDataBanner(margin: EdgeInsets.only(bottom: 16)),
                // Main Balance Card with animation
                StaggeredAnimation(
                  index: 0,
                  child: _GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: Icon(Icons.visibility_outlined, color: context.estate.textPrimary),
                              onPressed: () {},
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            Text(
                              AppLocalizations.of(context).totalBalance,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: context.estate.textPrimary,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        AnimatedBuilder(
                          animation: _balanceAnimation,
                          builder: (context, child) {
                            final formattedBalance =
                                (_balanceAnimation.value).toStringAsFixed(0);
                            final displayBalance = formattedBalance
                                .replaceAllMapped(
                                  RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                  (Match m) => '${m[1]},',
                                );
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      displayBalance,
                                      style: theme.textTheme.displayLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                        color: context.estate.textPrimary,
                                letterSpacing: 1,
                                        fontSize: 42,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        l10n.aed,
                                        style: theme.textTheme.titleLarge?.copyWith(
                                          color: context.estate.textPrimary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4),
                                Text(
                                  l10n.aedCurrency,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: context.estate.textSecondary,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                        ),
                        SizedBox(height: 20),
                // Quick Stats Cards
                StaggeredAnimation(
                  index: 1,
                  child: Row(
                          children: [
                            Expanded(
                        child: _QuickStatCard(
                          label: AppLocalizations.of(context).totalExpenses,
                          value: ws.totalExpensesDisplay,
                          color: Colors.redAccent,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                        child: _QuickStatCard(
                          label: AppLocalizations.of(context).monthlyIncome,
                          value: ws.monthlyIncomeDisplay,
                          color: Colors.greenAccent,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                // Bank Transfer Button
                StaggeredAnimation(
                  index: 2,
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const BankTransferAccountSelectionScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentGold,
                        foregroundColor: AppColors.primaryBlue,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                              ),
                        elevation: 0,
                            ),
                      child: Text(
                        AppLocalizations.of(context).bankTransferRequest,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 32),
                // Transaction Log Section
                StaggeredAnimation(
                  index: 3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          _showFilterBottomSheet(context);
                        },
                        child: Row(
                          children: [
                            Icon(
                              Icons.filter_list,
                              color: context.estate.textPrimary,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              AppLocalizations.of(context).filterTransactions,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: context.estate.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        AppLocalizations.of(context).transactionLog,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          color: context.estate.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                ...filteredTransactions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final transaction = entry.value;
                  return Padding(
                    padding: EdgeInsets.only(bottom: index == filteredTransactions.length - 1 ? 20 : 14),
                    child: StaggeredAnimation(
                      index: 4 + index,
                      child: _TransactionCard(
                        title: transaction.title,
                        amount: transaction.amount,
                        date: transaction.dateLabel,
                        isIncome: transaction.isIncome,
                      ),
                    ),
                  );
                }),
                if (filteredTransactions.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Text(
                      Localizations.localeOf(context).languageCode == 'ar'
                          ? 'لا توجد معاملات مطابقة للفلتر'
                          : 'No transactions match this filter',
                      style: theme.textTheme.bodyLarge?.copyWith(color: context.estate.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
            ),
          ),
        ),
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;

  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryBlue.withValues(alpha: 0.8),
                AppColors.navy.withValues(alpha: 0.6),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 25,
                offset: const Offset(0, 12),
                spreadRadius: 2,
              ),
              BoxShadow(
                color: AppColors.accentGold.withValues(alpha: 0.1),
                blurRadius: 20,
                spreadRadius: 1,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _QuickStatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _QuickStatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.cardDark.withValues(alpha: 0.8),
                AppColors.navy.withValues(alpha: 0.6),
              ],
            ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: context.estate.textSecondary,
                  fontSize: 12,
                ),
          ),
          SizedBox(height: 8),
          Text(
            value,
                style: theme.textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
          ),
        ),
      ),
    );
  }
}

class _TransactionCard extends StatefulWidget {
  final String title;
  final String amount;
  final String date;
  final bool isIncome;

  const _TransactionCard({
    required this.title,
    required this.amount,
    required this.date,
    required this.isIncome,
  });

  @override
  State<_TransactionCard> createState() => _TransactionCardState();
}

class _TransactionCardState extends State<_TransactionCard>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ScaleTransition(
      scale: _scaleAnimation,
      child: InkWell(
        onTapDown: (_) {
          setState(() => _isPressed = true);
          _controller.forward();
        },
        onTapUp: (_) {
          setState(() => _isPressed = false);
          _controller.reverse();
        },
        onTapCancel: () {
          setState(() => _isPressed = false);
          _controller.reverse();
        },
        borderRadius: BorderRadius.circular(18),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _isPressed
                      ? [
                          AppColors.cardDark.withValues(alpha: 0.9),
                          AppColors.navy.withValues(alpha: 0.7),
                        ]
                      : [
                          AppColors.cardDark.withValues(alpha: 0.8),
                          AppColors.navy.withValues(alpha: 0.6),
                        ],
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: _isPressed
                      ? (widget.isIncome
                          ? Colors.greenAccent
                          : Colors.redAccent)
                          .withValues(alpha: 0.3)
                      : Colors.white.withValues(alpha: 0.1),
                  width: _isPressed ? 1.5 : 1,
                ),
                boxShadow: _isPressed
                    ? [
                        BoxShadow(
                          color: (widget.isIncome
                                  ? Colors.greenAccent
                                  : Colors.redAccent)
                              .withValues(alpha: 0.2),
                          blurRadius: 15,
                          spreadRadius: 1,
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: (widget.isIncome
                              ? Colors.greenAccent
                              : Colors.redAccent)
                          .withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: (widget.isIncome
                                ? Colors.greenAccent
                                : Colors.redAccent)
                            .withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      widget.isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                      color: widget.isIncome
                          ? Colors.greenAccent
                          : Colors.redAccent,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: context.estate.textSecondary.withValues(alpha: 0.7),
                            ),
                            SizedBox(width: 6),
                            Text(
                              widget.date,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: context.estate.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: (widget.isIncome
                              ? Colors.greenAccent
                              : Colors.redAccent)
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: (widget.isIncome
                                ? Colors.greenAccent
                                : Colors.redAccent)
                            .withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      widget.amount,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: widget.isIncome
                            ? Colors.greenAccent
                            : Colors.redAccent,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterOption extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterOption({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
              color: isSelected ? AppColors.accentGold : AppColors.white,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
      ),
      trailing: Icon(
        isSelected ? Icons.check_circle : Icons.arrow_forward_ios,
        size: isSelected ? 20 : 16,
        color: isSelected ? AppColors.accentGold : AppColors.grey,
      ),
      onTap: onTap,
    );
  }
}
