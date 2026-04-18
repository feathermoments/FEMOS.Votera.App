import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:votera_app/core/storage/local_storage.dart';

class LocaleCubit extends Cubit<Locale> {
  LocaleCubit(this._storage) : super(_parse(_storage.locale));

  final LocalStorageService _storage;

  void setLocale(Locale locale) {
    _storage.locale = locale.languageCode;
    emit(locale);
  }

  static Locale _parse(String code) => switch (code) {
    'hi' => const Locale('hi'),
    _ => const Locale('en'),
  };
}
