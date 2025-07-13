import 'package:equatable/equatable.dart';
import '../../../data/model/parfum_model.dart';

abstract class ParfumState extends Equatable {
  const ParfumState();

  @override
  List<Object?> get props => [];
}

class ParfumInitial extends ParfumState {}

class ParfumLoading extends ParfumState {}

class ParfumLoaded extends ParfumState {
  final List<Parfum> parfums;

  const ParfumLoaded(this.parfums);

  @override
  List<Object?> get props => [parfums];
}

class ParfumError extends ParfumState {
  final String message;

  const ParfumError(this.message);

  @override
  List<Object?> get props => [message];
}

class ParfumOperationSuccess extends ParfumState {
  final String message;

  const ParfumOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}