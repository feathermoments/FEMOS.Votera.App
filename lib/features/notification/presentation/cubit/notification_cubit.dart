import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:votera_app/core/di/service_locator.dart';
import 'package:votera_app/features/notification/domain/entities/notification_entity.dart';
import 'package:votera_app/features/notification/domain/repositories/inotification_repository.dart';
import 'package:votera_app/features/notification/presentation/cubit/notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit() : super(const NotificationInitial()) {
    _repo = sl<INotificationRepository>();
  }

  late final INotificationRepository _repo;

  Future<void> load() async {
    emit(const NotificationLoading());
    try {
      final items = await _repo.getNotifications();
      emit(NotificationLoaded(items));
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> markAsRead(int notificationId) async {
    final current = state;
    if (current is! NotificationLoaded) return;

    // Optimistically update UI
    final updated = current.notifications.map((n) {
      return n.id == notificationId ? _ReadNotification(n) : n;
    }).toList();
    emit(NotificationLoaded(updated));

    try {
      await _repo.markAsRead(notificationId);
    } catch (_) {
      // Revert on failure
      emit(NotificationLoaded(current.notifications));
    }
  }

  Future<void> markAllAsRead() async {
    final current = state;
    if (current is! NotificationLoaded) return;

    final updated = current.notifications.map(_ReadNotification.new).toList();
    emit(NotificationLoaded(updated));

    try {
      await _repo.markAllAsRead();
    } catch (_) {
      emit(NotificationLoaded(current.notifications));
    }
  }
}

/// Thin wrapper that overrides [isRead] to true without modifying the entity.
class _ReadNotification extends NotificationEntity {
  _ReadNotification(NotificationEntity n)
    : super(
        id: n.id,
        title: n.title,
        message: n.message,
        isRead: true,
        createdAt: n.createdAt,
        navigationLink: n.navigationLink,
      );
}
