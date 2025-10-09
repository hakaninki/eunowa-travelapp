import 'dart:io';

class AddPostState {
  final File? image;
  final String description;
  final String location;
  final double? lat;
  final double? lng;

  final bool isLoading;
  final String? error;

  const AddPostState({
    this.image,
    this.description = '',
    this.location = '',
    this.lat,
    this.lng,
    this.isLoading = false,
    this.error,
  });

  AddPostState copyWith({
    File? image,
    String? description,
    String? location,
    double? lat,
    double? lng,
    bool? isLoading,
    String? error,       // null => aynı kalsın, '' gönderirsen temizlersin
  }) {
    return AddPostState(
      image: image ?? this.image,
      description: description ?? this.description,
      location: location ?? this.location,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  const AddPostState.initial() : this();
}
