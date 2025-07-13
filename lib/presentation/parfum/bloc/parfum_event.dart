import 'dart:io';
import 'package:equatable/equatable.dart';
import '../../../data/model/parfum_model.dart';

abstract class ParfumEvent extends Equatable {
  const ParfumEvent();

  @override
  List<Object?> get props => [];
}

class LoadParfums extends ParfumEvent {}

class AddParfum extends ParfumEvent {
  final Parfum parfum;
  final File? imageFile;

  const AddParfum(this.parfum, {this.imageFile});

  @override
  List<Object?> get props => [parfum, imageFile];
}

class UpdateParfum extends ParfumEvent {
  final Parfum parfum;
  final File? imageFile;

  const UpdateParfum(this.parfum, {this.imageFile});

  @override
  List<Object?> get props => [parfum, imageFile];
}

class DeleteParfum extends ParfumEvent {
  final int id;

  const DeleteParfum(this.id);

  @override
  List<Object?> get props => [id];
}