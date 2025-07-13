import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repository/parfum_repository.dart';
import 'parfum_event.dart';
import 'parfum_state.dart';

class ParfumBloc extends Bloc<ParfumEvent, ParfumState> {
  final ParfumRepository parfumRepository;

  ParfumBloc({required this.parfumRepository}) : super(ParfumInitial()) {
    on<LoadParfums>(_onLoadParfums);
    on<AddParfum>(_onAddParfum);
    on<UpdateParfum>(_onUpdateParfum);
    on<DeleteParfum>(_onDeleteParfum);
  }

  Future<void> _onLoadParfums(LoadParfums event, Emitter<ParfumState> emit) async {
    emit(ParfumLoading());
    try {
      final parfums = await parfumRepository.getAllParfums();
      emit(ParfumLoaded(parfums));
    } catch (e) {
      emit(ParfumError('Failed to load parfums: ${e.toString()}'));
    }
  }

  Future<void> _onAddParfum(AddParfum event, Emitter<ParfumState> emit) async {
    emit(ParfumLoading());
    try {
      await parfumRepository.createParfum(event.parfum, event.imageFile);
      emit(const ParfumOperationSuccess('Parfum added successfully!'));
      add(LoadParfums()); // Refresh the list
    } catch (e) {
      emit(ParfumError('Failed to add parfum: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateParfum(UpdateParfum event, Emitter<ParfumState> emit) async {
    emit(ParfumLoading());
    try {
      await parfumRepository.updateParfum(event.parfum.id!, event.parfum, event.imageFile);
      emit(const ParfumOperationSuccess('Parfum updated successfully!'));
      add(LoadParfums()); // Refresh the list
    } catch (e) {
      emit(ParfumError('Failed to update parfum: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteParfum(DeleteParfum event, Emitter<ParfumState> emit) async {
    emit(ParfumLoading());
    try {
      await parfumRepository.deleteParfum(event.id);
      emit(const ParfumOperationSuccess('Parfum deleted successfully!'));
      add(LoadParfums()); // Refresh the list
    } catch (e) {
      emit(ParfumError('Failed to delete parfum: ${e.toString()}'));
    }
  }
}