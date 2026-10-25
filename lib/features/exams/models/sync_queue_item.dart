enum SyncStatus {
  pending,
  syncing,
  synced,
  failed,
}

class SyncQueueItem {
  final String id;
  final String itemType; // "EXAM_ATTEMPT"
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  final SyncStatus status;
  final int retryCount;
  final String? lastError;

  const SyncQueueItem({
    required this.id,
    required this.itemType,
    required this.payload,
    required this.createdAt,
    this.status = SyncStatus.pending,
    this.retryCount = 0,
    this.lastError,
  });

  SyncQueueItem copyWith({
    String? id,
    String? itemType,
    Map<String, dynamic>? payload,
    DateTime? createdAt,
    SyncStatus? status,
    int? retryCount,
    String? lastError,
  }) {
    return SyncQueueItem(
      id: id ?? this.id,
      itemType: itemType ?? this.itemType,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      retryCount: retryCount ?? this.retryCount,
      lastError: lastError ?? this.lastError,
    );
  }
}
