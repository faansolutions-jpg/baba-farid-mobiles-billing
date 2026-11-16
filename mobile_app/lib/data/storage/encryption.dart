/// AES-256 encryption helpers (CBC + PKCS7, random IV per value).
///
/// The key is the 32-byte base64 key from [SecureStorage]
/// (`getOrCreateEncryptionKey`); it is passed in as bytes so this file
/// never touches storage itself. String format is
/// `base64(iv || ciphertext)`; file format is the same bytes written
/// raw (first 16 bytes are the IV).
///
/// NOTE: this uses the `encrypt` package. It is not in the PLAN.md
/// dependency list, so the agent owning `pubspec.yaml` must add
/// `encrypt: ^5.0.3` (it pulls in `pointycastle` + `crypto`).
library;

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';

/// AES-256 helper bound to one 32-byte key.
class Aes256 {
  final Key _key;

  /// [keyBase64] must decode to exactly 32 bytes (use
  /// `SecureStorage.getOrCreateEncryptionKey`).
  Aes256.fromBase64Key(String keyBase64)
      : _key = Key(base64Decode(keyBase64)) {
    if (_key.bytes.length != 32) {
      throw ArgumentError('AES-256 needs a 32-byte key');
    }
  }

  Aes256.fromBytes(Uint8List keyBytes) : _key = Key(keyBytes) {
    if (keyBytes.length != 32) {
      throw ArgumentError('AES-256 needs a 32-byte key');
    }
  }

  Encrypter get _encrypter => Encrypter(AES(_key, mode: AESMode.cbc));

  /// Encrypts [plainText] to `base64(iv || ciphertext)`.
  String encryptString(String plainText) {
    final iv = IV.fromSecureRandom(16);
    final encrypted = _encrypter.encrypt(plainText, iv: iv);
    final combined = Uint8List(iv.bytes.length + encrypted.bytes.length)
      ..setAll(0, iv.bytes)
      ..setAll(iv.bytes.length, encrypted.bytes);
    return base64Encode(combined);
  }

  /// Decrypts a value produced by [encryptString].
  String decryptString(String cipherText) {
    final combined = base64Decode(cipherText);
    if (combined.length < 17) {
      throw ArgumentError('Ciphertext too short');
    }
    final iv = IV(combined.sublist(0, 16));
    final cipher = Encrypted(combined.sublist(16));
    return _encrypter.decrypt(cipher, iv: iv);
  }

  /// Encrypts the file at [inputPath] and writes `iv || ciphertext`
  /// bytes to [outputPath].
  Future<void> encryptFile(String inputPath, String outputPath) async {
    final plain = await File(inputPath).readAsBytes();
    final iv = IV.fromSecureRandom(16);
    final encrypted = _encrypter.encryptBytes(plain, iv: iv);
    final combined = Uint8List(iv.bytes.length + encrypted.bytes.length)
      ..setAll(0, iv.bytes)
      ..setAll(iv.bytes.length, encrypted.bytes);
    await File(outputPath).writeAsBytes(combined);
  }

  /// Decrypts a file produced by [encryptFile].
  Future<void> decryptFile(String inputPath, String outputPath) async {
    final combined = await File(inputPath).readAsBytes();
    if (combined.length < 17) {
      throw ArgumentError('Ciphertext file too short');
    }
    final iv = IV(combined.sublist(0, 16));
    final cipher = Encrypted(combined.sublist(16));
    final plain = _encrypter.decryptBytes(cipher, iv: iv);
    await File(outputPath).writeAsBytes(plain);
  }
}

/// Convenience one-shot helpers that build the [Aes256] instance from a
/// base64 key each call. Prefer reusing one [Aes256] for many values.
String encryptString(String plainText, String keyBase64) =>
    Aes256.fromBase64Key(keyBase64).encryptString(plainText);

String decryptString(String cipherText, String keyBase64) =>
    Aes256.fromBase64Key(keyBase64).decryptString(cipherText);

Future<void> encryptFile(
        String inputPath, String outputPath, String keyBase64) =>
    Aes256.fromBase64Key(keyBase64).encryptFile(inputPath, outputPath);

Future<void> decryptFile(
        String inputPath, String outputPath, String keyBase64) =>
    Aes256.fromBase64Key(keyBase64).decryptFile(inputPath, outputPath);
