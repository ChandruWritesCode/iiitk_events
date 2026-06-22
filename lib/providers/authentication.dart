// ignore_for_file: await_only_futures, unnecessary_nullable_for_final_variable_declarations

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:iiitk_events/constants.dart';

class Authentication extends ChangeNotifier {
  Authentication() {
    _listenToAuthChanges();
  }

  Future<void> updateDisplayName(String newName) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null && newName.trim().isNotEmpty) {
        await user.updateDisplayName(newName.trim());

        _displayName = newName.trim();

        notifyListeners();
      }
    } catch (e) {
      // debugPrint('Error updating display name: $e');
      rethrow;
    }
  }

  String _displayName = 'Student', _profilePhotoUrl = '';

  String get displayName => _displayName;
  String get profilePhotoUrl => _profilePhotoUrl;

  bool _loggedIn = false;
  bool get loggedIn => _loggedIn;

  Future<void> _listenToAuthChanges() async {
    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null && user.email!.endsWith('@iiitkottayam.ac.in')) {
        _loggedIn = true;
        _displayName = user.displayName!;
        _profilePhotoUrl = user.photoURL!;
      } else {
        _loggedIn = false;
        _displayName = '';
        _profilePhotoUrl = '';
        if (user != null) {
          FirebaseAuth.instance.signOut();
        }
      }
      notifyListeners();
    });
  }

  //login
  Future<void> googleLoginFunc() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;

      await googleSignIn.initialize(
        serverClientId:
            serverClientId,
        hostedDomain: 'iiitkottayam.ac.in',
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.authenticate();

      if (googleUser == null) {
        // debugPrint('user cancelled login');
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final clientAuth = await googleUser.authorizationClient.authorizeScopes([
        'email',
        'profile',
      ]);

      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: clientAuth.accessToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      // debugPrint('error caught while signing in:  $e');
      rethrow;
    }
  }

  //logout func
  Future<void> googleLogoutFunc() async {
    try {
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn.instance.signOut();
    } catch (e) {
      // print('error while logout $e');
      rethrow;
    }
  }
}
