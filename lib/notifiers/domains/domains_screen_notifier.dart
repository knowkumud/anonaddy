import 'package:anonaddy/models/domain/domain_model.dart';
import 'package:anonaddy/notifiers/domains/domains_screen_state.dart';
import 'package:anonaddy/services/domain/domains_service.dart';
import 'package:anonaddy/shared_components/constants/constants_exports.dart';
import 'package:anonaddy/utilities/utilities.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final domainsScreenStateNotifier = StateNotifierProvider.autoDispose<
    DomainsScreenNotifier, DomainsScreenState>((ref) {
  return DomainsScreenNotifier(
    domainService: ref.read(domainService),
  );
});

class DomainsScreenNotifier extends StateNotifier<DomainsScreenState> {
  DomainsScreenNotifier({required this.domainService})
      : super(DomainsScreenState.initialState());

  final DomainsService domainService;

  /// Updates DomainScreen state
  void _updateState(DomainsScreenState newState) {
    if (mounted) state = newState;
  }

  Future<void> fetchDomain(Domain domain) async {
    try {
      _updateState(state.copyWith(status: DomainsScreenStatus.loading));
      final updatedDomain = await domainService.fetchSpecificDomain(domain.id);

      _updateState(state.copyWith(
        status: DomainsScreenStatus.loaded,
        domain: updatedDomain,
      ));
    } catch (error) {
      _updateState(state.copyWith(
        status: DomainsScreenStatus.failed,
        errorMessage: error.toString(),
      ));
    }
  }

  Future editDescription(String domainId, newDescription) async {
    try {
      final updatedDomain =
          await domainService.updateDomainDescription(domainId, newDescription);
      Utilities.showToast(ToastMessage.editDescriptionSuccess);
      _updateState(state.copyWith(domain: updatedDomain));
    } catch (error) {
      Utilities.showToast(error.toString());
    }
  }

  Future<void> activateDomain(String domainId) async {
    try {
      _updateState(state.copyWith(activeSwitchLoading: true));
      final newDomain = await domainService.activateDomain(domainId);
      final updatedDomain = state.domain.copyWith(active: newDomain.active);

      _updateState(state.copyWith(
        activeSwitchLoading: false,
        domain: updatedDomain,
      ));
    } catch (error) {
      Utilities.showToast(error.toString());
      _updateState(state.copyWith(activeSwitchLoading: false));
    }
  }

  Future<void> deactivateDomain(String domainId) async {
    _updateState(state.copyWith(activeSwitchLoading: true));
    try {
      await domainService.deactivateDomain(domainId);

      final updatedDomain = state.domain.copyWith(active: false);

      _updateState(state.copyWith(
        activeSwitchLoading: false,
        domain: updatedDomain,
      ));
    } catch (error) {
      Utilities.showToast(error.toString());
      _updateState(state.copyWith(activeSwitchLoading: false));
    }
  }

  Future<void> activateCatchAll(String domainId) async {
    _updateState(state.copyWith(catchAllSwitchLoading: true));
    try {
      final newDomain = await domainService.activateCatchAll(domainId);

      final updatedDomain = state.domain.copyWith(catchAll: newDomain.catchAll);

      _updateState(state.copyWith(
        catchAllSwitchLoading: false,
        domain: updatedDomain,
      ));
    } catch (error) {
      Utilities.showToast(error.toString());
      _updateState(state.copyWith(catchAllSwitchLoading: false));
    }
  }

  Future<void> deactivateCatchAll(String domainId) async {
    _updateState(state.copyWith(catchAllSwitchLoading: true));
    try {
      await domainService.deactivateCatchAll(domainId);

      final updatedDomain = state.domain.copyWith(catchAll: false);

      _updateState(state.copyWith(
        catchAllSwitchLoading: false,
        domain: updatedDomain,
      ));
    } catch (error) {
      Utilities.showToast(error.toString());
      _updateState(state.copyWith(catchAllSwitchLoading: false));
    }
  }

  Future<void> updateDomainDefaultRecipients(
      String domainId, String recipientId) async {
    try {
      _updateState(state.copyWith(updateRecipientLoading: true));
      final newDomain = await domainService.updateDomainDefaultRecipient(
          domainId, recipientId);

      Utilities.showToast('Default recipient updated successfully!');

      final updatedDomain =
          state.domain.copyWith(defaultRecipient: newDomain.defaultRecipient);

      _updateState(state.copyWith(
        updateRecipientLoading: false,
        domain: updatedDomain,
      ));
    } catch (error) {
      Utilities.showToast(error.toString());
      _updateState(state.copyWith(updateRecipientLoading: false));
    }
  }

  Future<void> deleteDomain(String domainId) async {
    try {
      await domainService.deleteDomain(domainId);
      Utilities.showToast('Domain deleted successfully!');
    } catch (error) {
      Utilities.showToast(error.toString());
    }
  }
}
