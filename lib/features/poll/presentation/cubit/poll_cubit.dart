import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:votera_app/core/di/service_locator.dart';
import '../../domain/entities/poll_entity.dart';
import '../../domain/repositories/poll_repository.dart';

// ── States ─────────────────────────────────────────────────────────────────

abstract class PollState {}

class PollInitial extends PollState {}

class PollLoading extends PollState {}

class PollListLoaded extends PollState {
  PollListLoaded(this.polls);

  final List<PollSummaryEntity> polls;
}

class PollDetailLoaded extends PollState {
  PollDetailLoaded(this.poll);

  final PollDetailEntity poll;
}

class PollResultsLoaded extends PollState {
  PollResultsLoaded(this.results);

  final List<PollResultEntity> results;
}

class PollActionSuccess extends PollState {
  PollActionSuccess(this.message);

  final String message;
}

class PollError extends PollState {
  PollError(this.message);

  final String message;
}

// ── Cubit ───────────────────────────────────────────────────────────────────

class PollCubit extends Cubit<PollState> {
  PollCubit() : super(PollInitial()) {
    _repository = sl<PollRepository>();
  }

  late final PollRepository _repository;

  Future<void> loadPolls(int userId) async {
    emit(PollLoading());
    try {
      final polls = await _repository.getPolls(userId);
      emit(PollListLoaded(polls));
    } catch (e) {
      emit(PollError(e.toString()));
    }
  }

  Future<void> loadPollDetail(int pollId) async {
    emit(PollLoading());
    try {
      final poll = await _repository.getPollDetail(pollId);
      emit(PollDetailLoaded(poll));
    } catch (e) {
      emit(PollError(e.toString()));
    }
  }

  Future<void> createPoll({
    required int workspaceId,
    required int categoryId,
    required String question,
    required List<String> options,
    required String visibility,
    String? expiryDate,
    bool isAnonymous = true,
  }) async {
    emit(PollLoading());
    try {
      await _repository.createPoll(
        workspaceId: workspaceId,
        categoryId: categoryId,
        question: question,
        options: options,
        visibility: visibility,
        expiryDate: expiryDate,
        isAnonymous: isAnonymous,
      );
      emit(PollActionSuccess('Poll created successfully'));
    } catch (e) {
      emit(PollError(e.toString()));
    }
  }

  Future<void> castVote({required int pollId, required int optionId}) async {
    emit(PollLoading());
    try {
      await _repository.castVote(pollId: pollId, optionId: optionId);
      emit(PollActionSuccess('Vote submitted successfully'));
    } catch (e) {
      emit(PollError(e.toString()));
    }
  }

  Future<void> loadResults(int pollId) async {
    emit(PollLoading());
    try {
      final results = await _repository.getResults(pollId);
      emit(PollResultsLoaded(results));
    } catch (e) {
      emit(PollError(e.toString()));
    }
  }
}
