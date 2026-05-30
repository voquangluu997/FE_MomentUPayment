import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moment_u_payment/core/network/api_client.dart';

class NotificationSettingsState {
  final bool budgetAlerts;
  final bool securitySystem;
  final bool sharedWalletUpdates;
  final bool isLoading;

  NotificationSettingsState({
    this.budgetAlerts = true,
    this.securitySystem = true,
    this.sharedWalletUpdates = true,
    this.isLoading = false,
  });

  NotificationSettingsState copyWith({
    bool? budgetAlerts,
    bool? securitySystem,
    bool? sharedWalletUpdates,
    bool? isLoading,
  }) {
    return NotificationSettingsState(
      budgetAlerts: budgetAlerts ?? this.budgetAlerts,
      securitySystem: securitySystem ?? this.securitySystem,
      sharedWalletUpdates: sharedWalletUpdates ?? this.sharedWalletUpdates,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class NotificationSettingsNotifier
    extends StateNotifier<NotificationSettingsState> {
  NotificationSettingsNotifier() : super(NotificationSettingsState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await dioClient.get('/users/notification-settings');
      if (response.statusCode == 200) {
        final data = response.data;
        state = NotificationSettingsState(
          budgetAlerts: data['budgetAlerts'] ?? true,
          securitySystem: data['securitySystem'] ?? true,
          sharedWalletUpdates: data['sharedWalletUpdates'] ?? true,
          isLoading: false,
        );
      }
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> toggleSetting({
    bool? budgetAlerts,
    bool? securitySystem,
    bool? sharedWalletUpdates,
  }) async {
    final previousState = state;
    state = state.copyWith(
      budgetAlerts: budgetAlerts,
      securitySystem: securitySystem,
      sharedWalletUpdates: sharedWalletUpdates,
    );

    try {
      final response = await dioClient.patch(
        '/users/notification-settings',
        data: {
          'budgetAlerts': state.budgetAlerts,
          'securitySystem': state.securitySystem,
          'sharedWalletUpdates': state.sharedWalletUpdates,
        },
      );

      if (response.statusCode != 200) {
        state = previousState; // Khôi phục trạng thái cũ nếu server lỗi
      }
    } catch (_) {
      state = previousState;
    }
  }
}

final notificationSettingsProvider =
    StateNotifierProvider<
      NotificationSettingsNotifier,
      NotificationSettingsState
    >((ref) => NotificationSettingsNotifier());
