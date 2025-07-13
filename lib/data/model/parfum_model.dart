// lib/data/model/parfum_model.dart

import 'dart:convert';
import 'package:equatable/equatable.dart';

class Parfum extends Equatable {
  final int? id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String category;
  final String imageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Parfum({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.category,
    required this.imageUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory Parfum.fromJson(Map<String, dynamic> json) {
    final baseUrl = 'http//10.0.2.2:3000/uploads/';
    return Parfum(
      // PERBAIKAN DI SINI UNTUK 'id'
      id: (json['id'] is String) ? int.tryParse(json['id']) : (json['id'] as int?),
      name: json['name'],
      description: json['description'],
      // Perbaikan parsing price:
      price: (json['price'] is String) ? double.parse(json['price']) : (json['price'] as num).toDouble(),
      // PERBAIKAN DI SINI UNTUK 'stock'
      stock: (json['stock'] is String) ? int.parse(json['stock']) : (json['stock'] as int),
      category: json['category'],
      // Perbaikan imageUrl: Langsung gunakan URL dari JSON, berikan string kosong jika null
      imageUrl: json['image_url'] != null
          ? json['image_url'] as String
          : '',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'category': category,
      'image_url': imageUrl,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Parfum copyWith({
    int? id,
    String? name,
    String? description,
    double? price,
    int? stock,
    String? category,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Parfum(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        price,
        stock,
        category,
        imageUrl,
        createdAt,
        updatedAt,
      ];
}