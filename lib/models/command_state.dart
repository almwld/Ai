enum CommandState {
  idle,
  processing,
  success,
  failed;

  bool get isProcessing => this == CommandState.processing;
  bool get isSuccess => this == CommandState.success;
  bool get isFailed => this == CommandState.failed;
}
