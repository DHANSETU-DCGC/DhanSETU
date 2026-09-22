import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/keypad_widget.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/risk_badge.dart';
import '../../risk_engine/models/risk_assessment.dart';
import '../../risk_engine/models/risk_signals.dart';
import '../../risk_engine/providers/risk_provider.dart';
import '../models/recipient.dart';
import '../providers/payment_provider.dart';

class SendMoneyScreen extends ConsumerStatefulWidget {
  const SendMoneyScreen({super.key});

  @override
  ConsumerState<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends ConsumerState<SendMoneyScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  String _amountString = '';
  Recipient? _selectedRecipient;
  bool _showSimulatorSheet = false;

  @override
  void dispose() {
    _searchController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _onKeypadDigit(String key) {
    if (key == '.') {
      if (_amountString.contains('.')) return;
      if (_amountString.isEmpty) {
        setState(() => _amountString = '0.');
        return;
      }
    }

    if (_amountString == '0' && key != '.') {
      setState(() => _amountString = key);
      return;
    }

    if (_amountString.contains('.')) {
      final parts = _amountString.split('.');
      if (parts.length > 1 && parts[1].length >= 2) return;
    }

    if (_amountString.length >= 7) return;

    setState(() {
      _amountString += key;
    });

    final val = double.tryParse(_amountString) ?? 0.0;
    ref.read(paymentProvider.notifier).updateAmount(val);
  }

  void _onKeypadBackspace() {
    if (_amountString.isNotEmpty) {
      setState(() {
        _amountString = _amountString.substring(0, _amountString.length - 1);
      });
      final val = double.tryParse(_amountString) ?? 0.0;
      ref.read(paymentProvider.notifier).updateAmount(val);
    }
  }

  void _onKeypadClear() {
    setState(() => _amountString = '');
    ref.read(paymentProvider.notifier).updateAmount(0.0);
  }

  void _selectRecipient(Recipient recipient) {
    setState(() {
      _selectedRecipient = recipient;
    });
    ref.read(paymentProvider.notifier).initDraft(
          recipient,
          amount: double.tryParse(_amountString) ?? 0.0,
        );
  }

  void _proceedToProfiling() {
    if (_selectedRecipient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a recipient first'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final amount = double.tryParse(_amountString) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    ref.read(paymentProvider.notifier).updateAmount(amount);
    ref.read(paymentProvider.notifier).updateNote(_noteController.text);
    context.push('/recipient-profile');
  }

  @override
  Widget build(BuildContext context) {
    final recipientsAsync =
        ref.watch(recipientListProvider(_searchController.text));
    final riskSignals = ref.watch(riskSignalsProvider);
    final riskAssessment = ref.watch(riskAssessmentProvider);

    final formattedAmount = _amountString.isEmpty
        ? '0'
        : NumberFormat('#,##,###.##').format(double.tryParse(_amountString) ?? 0);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Send Money'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: riskSignals.isOnActiveCall,
              backgroundColor: AppColors.danger,
              child: const Icon(Icons.tune_rounded),
            ),
            tooltip: 'Risk Simulator Sandbox',
            onPressed: () => setState(() => _showSimulatorSheet = !_showSimulatorSheet),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Active Phone Call Warning Pill (if active call simulation is ON)
            if (riskSignals.isOnActiveCall)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.dangerLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.phone_in_talk_rounded,
                        color: AppColors.danger, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Active Call Detected (Simulated Social Engineering Risk)',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.dangerDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => ref
                          .read(riskSignalsProvider.notifier)
                          .toggleActiveCall(),
                      child: const Icon(Icons.close_rounded,
                          size: 16, color: AppColors.dangerDark),
                    ),
                  ],
                ),
              ),

            // Recipient Section or Amount Entry Section
            Expanded(
              child: _selectedRecipient == null
                  ? _buildRecipientSelector(recipientsAsync)
                  : _buildAmountInputView(formattedAmount, riskAssessment),
            ),

            // Collapsible Simulator Bottom Bar
            if (_showSimulatorSheet) _buildSimulatorPanel(riskSignals),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipientSelector(AsyncValue<List<Recipient>> recipientsAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: TextField(
            controller: _searchController,
            onChanged: (val) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search by name, UPI ID, or phone',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                    )
                  : null,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Text(
            'Select Recipient to Demo',
            style: AppTypography.titleMedium.copyWith(color: AppColors.textSecondary),
          ),
        ),
        Expanded(
          child: recipientsAsync.when(
            data: (recipients) {
              if (recipients.isEmpty) {
                return const Center(child: Text('No recipients found'));
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: recipients.length,
                itemBuilder: (context, index) {
                  final rec = recipients[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      onTap: () => _selectRecipient(rec),
                      leading: CircleAvatar(
                        backgroundColor: rec.isNewRecipient
                            ? AppColors.dangerLight
                            : AppColors.primaryContainer,
                        child: Text(
                          rec.initials,
                          style: TextStyle(
                            color: rec.isNewRecipient
                                ? AppColors.dangerDark
                                : AppColors.onPrimaryContainer,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              rec.name,
                              style: AppTypography.titleMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (rec.isNewRecipient)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.dangerLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'FLAGGED',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.danger,
                                  fontSize: 9,
                                ),
                              ),
                            ),
                        ],
                      ),
                      subtitle: Text(
                        '${rec.upiId} • ${rec.category}',
                        style: AppTypography.bodySmall,
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded,
                          color: AppColors.textTertiary),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error: $err')),
          ),
        ),
      ],
    );
  }

  Widget _buildAmountInputView(
      String formattedAmount, RiskAssessment riskAssessment) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Selected Recipient Card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: _selectedRecipient!.isNewRecipient
                      ? AppColors.dangerLight
                      : AppColors.primaryContainer,
                  child: Text(
                    _selectedRecipient!.initials,
                    style: TextStyle(
                      color: _selectedRecipient!.isNewRecipient
                          ? AppColors.dangerDark
                          : AppColors.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedRecipient!.name,
                        style: AppTypography.titleMedium,
                      ),
                      Text(
                        _selectedRecipient!.upiId,
                        style: AppTypography.bodySmall,
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedRecipient = null;
                      _amountString = '';
                    });
                  },
                  child: const Text('Change'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Amount Large Display
          Text('Enter Amount', style: AppTypography.bodySmall),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '₹',
                style: AppTypography.amountDisplay.copyWith(
                  color: AppColors.primary,
                  fontSize: 32,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                formattedAmount,
                style: AppTypography.amountDisplay,
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Live Risk Engine Indicator Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.shield_outlined,
                    size: 14, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  'Projected Risk: ',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                RiskBadge(
                  riskLevel: riskAssessment.level,
                  compact: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Note input field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: TextField(
              controller: _noteController,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: 'Add a note (e.g. Dinner, Rent)',
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                fillColor: AppColors.surfaceVariant,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Numerical Keypad
          KeypadWidget(
            onKeyPressed: _onKeypadDigit,
            onBackspace: _onKeypadBackspace,
            onClear: _onKeypadClear,
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: PrimaryButton(
              text: 'Proceed to Risk Check',
              icon: Icons.shield_rounded,
              onPressed: _proceedToProfiling,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimulatorPanel(RiskSignals riskSignals) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: AppColors.cardShadow,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tune_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Demo Risk Simulator Sandbox',
                style: AppTypography.titleMedium,
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                onPressed: () => setState(() => _showSimulatorSheet = false),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Quick-toggle risk variables to preview Low, Medium, and High risk flow branches:',
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: 12),
          // Presets row
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ref.read(riskSignalsProvider.notifier).applyLowRiskPreset();
                    setState(() => _amountString = '450');
                    ref.read(paymentProvider.notifier).updateAmount(450);
                  },
                  child: const Text('Low Preset'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ref.read(riskSignalsProvider.notifier).applyMediumRiskPreset();
                    setState(() => _amountString = '9500');
                    ref.read(paymentProvider.notifier).updateAmount(9500);
                  },
                  child: const Text('Med Preset'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.danger,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    ref.read(riskSignalsProvider.notifier).applyHighRiskPreset();
                    setState(() => _amountString = '15000');
                    ref.read(paymentProvider.notifier).updateAmount(15000);
                  },
                  child: const Text('High Preset'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('Simulate Active Phone Call'),
            subtitle: const Text('Common in remote screen-sharing / coercion scams'),
            value: riskSignals.isOnActiveCall,
            dense: true,
            activeTrackColor: AppColors.dangerLight,
            onChanged: (_) {
              ref.read(riskSignalsProvider.notifier).toggleActiveCall();
            },
          ),
        ],
      ),
    );
  }
}
