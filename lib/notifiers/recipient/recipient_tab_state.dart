import 'package:anonaddy/models/recipient/recipient.dart';

enum RecipientTabStatus { loading, loaded, failed }

extension Shortcuts on RecipientTabStatus {
  bool isFailed() => this == RecipientTabStatus.failed;
}

class RecipientTabState {
  const RecipientTabState({
    required this.status,
    required this.recipients,
    required this.errorMessage,
  });

  final RecipientTabStatus status;
  final List<Recipient> recipients;
  final String errorMessage;

  static RecipientTabState initialState() {
    return const RecipientTabState(
      status: RecipientTabStatus.loading,
      recipients: <Recipient>[],
      errorMessage: '',
    );
  }

  RecipientTabState copyWith({
    RecipientTabStatus? status,
    List<Recipient>? recipients,
    String? errorMessage,
  }) {
    return RecipientTabState(
      status: status ?? this.status,
      recipients: recipients ?? this.recipients,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  String toString() {
    return 'RecipientTabState{status: $status, recipients: $recipients, errorMessage: $errorMessage}';
  }
}
