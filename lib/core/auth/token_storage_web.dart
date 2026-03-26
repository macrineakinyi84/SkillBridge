import 'dart:html' as html;

import 'token_storage.dart';

class _WebTokenStorage implements TokenStorage {
  @override
  Future<String?> read(String key) async {
    return html.window.localStorage[key];
  }

  @override
  Future<void> write(String key, String value) async {
    html.window.localStorage[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    html.window.localStorage.remove(key);
  }
}

TokenStorage createTokenStorageImpl() => _WebTokenStorage();

