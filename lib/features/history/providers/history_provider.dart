import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../risk_engine/models/risk_level.dart';
import '../data/mock_history_repository.dart';
import '../models/transaction_model.dart';

final historyRepositoryProvider = Provider<IHistoryRepository>((ref) {
  return MockHistoryRepository();
});

class HistoryState {
  final List<TransactionModel> transactions;
  final bool isLoading;
  final RiskLevel? selectedRiskFilter;
  final String searchQuery;

  const HistoryState({
    this.transactions = const [],
    this.isLoading = false,
    this.selectedRiskFilter,
    this.searchQuery = '',
  });

  List<TransactionModel> get filteredTransactions {
    return transactions.where((tx) {
      final matchesRisk =
          selectedRiskFilter == null || tx.riskLevel == selectedRiskFilter;
      final q = searchQuery.toLowerCase().trim();
      final matchesSearch = q.isEmpty ||
          tx.recipientName.toLowerCase().contains(q) ||
          tx.recipientUpiId.toLowerCase().contains(q) ||
          (tx.note?.toLowerCase().contains(q) ?? false);
      return matchesRisk && matchesSearch;
    }).toList();
  }

  HistoryState copyWith({
    List<TransactionModel>? transactions,
    bool? isLoading,
    RiskLevel? selectedRiskFilter,
    bool clearFilter = false,
    String? searchQuery,
  }) {
    return HistoryState(
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      selectedRiskFilter:
          clearFilter ? null : (selectedRiskFilter ?? this.selectedRiskFilter),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class HistoryNotifier extends Notifier<HistoryState> {
  @override
  HistoryState build() {
    final repo = ref.read(historyRepositoryProvider);
    return HistoryState(
      transactions: repo.getInitialTransactions(),
      isLoading: false,
    );
  }

  Future<void> loadTransactions() async {
    state = state.copyWith(isLoading: true);
    final repo = ref.read(historyRepositoryProvider);
    final txList = await repo.getTransactions();
    state = state.copyWith(transactions: txList, isLoading: false);
  }

  Future<void> addTransaction(TransactionModel tx) async {
    state = state.copyWith(
      transactions: [tx, ...state.transactions],
    );
    final repo = ref.read(historyRepositoryProvider);
    await repo.addTransaction(tx);
  }

  void setFilter(RiskLevel? level) {
    if (level == null) {
      state = state.copyWith(clearFilter: true);
    } else {
      state = state.copyWith(selectedRiskFilter: level);
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }
}

final historyProvider =
    NotifierProvider<HistoryNotifier, HistoryState>(HistoryNotifier.new);
