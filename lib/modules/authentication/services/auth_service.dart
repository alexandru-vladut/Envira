import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_base/core/app_config.dart';
import 'package:flutter_app_base/core/utils/app_navigator.dart';
import 'package:flutter_app_base/core/utils/context_utils.dart';
import 'package:flutter_app_base/core/global_instances.dart';
import 'package:flutter_app_base/data/models/user_model.dart';
import 'package:flutter_app_base/modules/bottom_nav_bar.dart';
import 'package:flutter_app_base/session/auth_state_provider.dart';
import 'package:flutter_app_base/data/repositories/user_repository.dart';
import 'package:flutter_app_base/modules/landing/pages/forget_email_sent.dart';
import 'package:flutter_app_base/modules/landing/pages/verification_email_sent.dart';
import 'package:flutter_app_base/modules/authentication/pages/login_page.dart';
import 'package:flutter_app_base/modules/authentication/pages/create_pin_page.dart';
import 'package:flutter_app_base/modules/authentication/pages/enter_pin_page.dart';
import 'package:flutter_app_base/core/utils/dialog_widgets/dialog_widgets.dart';
import 'package:provider/provider.dart';

class AuthService {
  // Inject UserRepository
  final UserRepository _userRepository;
  
  // Regular constructor
  AuthService(this._userRepository);

  // FirebaseAuth instance
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<void> signIn({required String email, required String password}) async {

    loadingDialog(); // safe: uses navigatorKey inside

    try {
      // 1. Check data with FirebaseAuth (validate email and password)
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Check if user exists in 'users' collection
      // (A user may not exist in 'users' collection if the account was disabled - deleted data)
      User user = _firebaseAuth.currentUser!;
      List<UserModel> filteredUsers = await _userRepository.getDocumentsByField("uid", user.uid);
      
      if (filteredUsers.isEmpty) {
        _firebaseAuth.signOut();
        logger.e('[ERROR - signIn()] User not found in Firestore Database.');
        AppNavigator.pop(); // close loadingDialog
        errorDialog(
          title: '[ERROR - signIn()] User not found in Firestore Database.',
        );
        return;
      }

      if (AppConfig.emailVerificationEnabled == false && AppConfig.pinCodeEnabled == false) {
        await sessionManager.startListeningToProviders();
        AppNavigator.navigateAndRemoveAll(page: const BottomNavBar());
        return;
      }

      if (AppConfig.emailVerificationEnabled) {
        if (user.emailVerified == false) {
          await user.sendEmailVerification();
          _firebaseAuth.signOut();
          AppNavigator.navigateAndRemoveAll(page: const VerificationEmailSent());
          return;
        } else if (AppConfig.pinCodeEnabled == false) {
          await sessionManager.startListeningToProviders();
          AppNavigator.navigateAndRemoveAll(page: const BottomNavBar());
          return;
        }
      }
      
      if (AppConfig.pinCodeEnabled) {
        UserModel currentUser = filteredUsers[0];
        String? currentUserPin = currentUser.pin;

        // Sign out in case PIN verification doesn't happen
        _firebaseAuth.signOut();

        // If user has no PIN, redirect to 'Set PIN' page, else redirect to 'Enter PIN' page
        if (currentUserPin == null) {
          AppNavigator.navigateAndRemoveAll(page: CreatePin(email: email, password: password));
        } else {
          AppNavigator.navigateAndRemoveAll(page: EnterPin(email: email, password: password));
        }
      }
      
    } on FirebaseAuthException catch (error) {
      if (error.code == 'user-not-found' || error.code == 'wrong-password') {
        AppNavigator.pop(); // close loadingDialog
        errorDialog(
          title: 'Email/parolă greșite!',
        );
        logger.w("[WARNING - signIn()] Wrong email/password: ${error.toString()}");
      } else {
        AppNavigator.pop(); // close loadingDialog
        errorDialog(
          title: error.toString(),
        );
        logger.e("[ERROR - signIn()] ${error.toString()}");
      }
    }
  }

  Future<void> logOut({bool showLoadingDialog = true}) async {

    // Handle context across async gaps
    final ctx = ContextUtils.getSafeContext();
    if (ctx == null) return;

    if (showLoadingDialog) loadingDialog();

    try {
      logger.i('[INFO - logOut()] Logging out user...');

      ctx.read<AuthStateProvider>().markManualLogout();
      await _firebaseAuth.signOut();
      await sessionManager.stopListeningToProviders();

      logger.i('[INFO - logOut()] User logged out successfully.');
      
      AppNavigator.navigateAndRemoveAll(page: const LoginPage());
    } catch (error) {
      logger.e('[ERROR - logOut()] ${error.toString()}');
      if (showLoadingDialog) {
        AppNavigator.pop();
        await Future.delayed(const Duration(milliseconds: 200));
        errorDialog(title: error.toString());
      }
    }
  }

  Future<void> sendPasswordResetEmail(BuildContext dialogContext, String email) async {

    Navigator.pop(dialogContext);
    loadingDialog();

    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      logger.i('[INFO - sendPasswordResetEmail()] Password reset email sent successfully.');
      AppNavigator.navigateAndRemoveAll(page: const ForgetEmailSent());
      
    } catch (error) {
      logger.e('[ERROR - sendPasswordResetEmail()] ${error.toString()}');
      AppNavigator.pop(); // close loadingDialog
      errorDialog(title: error.toString());
    }
  }

  void signUp(String inputEmail, String inputName, String inputPassword, String inputConfirmPassword) async {

    loadingDialog();

    try {
      // 1. Check if password and confirmPassword fields correspond.
      if (inputPassword != inputConfirmPassword) {
        AppNavigator.pop(); // close loadingDialog
        errorDialog(title: 'Parolele nu corespund!');
        logger.w('[WARNING - signUp()] Passwords do not match!');
        return;
      }
        
      // 2. Check data with FirebaseAuth (validate email and password)
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: inputEmail,
        password: inputPassword
      );

      User user = userCredential.user!;

      UserModel newUser = UserModel(
        uid: user.uid, // uid field from Firestore is the same as FirebaseAuth uid
        name: inputName,
        email: inputEmail,
        pin: null,
        totalPoints: 0,
        credits: 0,
        companyId: "355aInOtLhMaQm6fyMCh",
        role: "user",
        myVouchersIds: [],
      );
  
      _userRepository.addDocument(newUser);

      await user.updateDisplayName(inputName);
      await user.reload();

      if (AppConfig.emailVerificationEnabled == false) {
        await sessionManager.startListeningToProviders();
        AppNavigator.navigateAndRemoveAll(page: const BottomNavBar());
        return;
      }

      await user.sendEmailVerification();
      _firebaseAuth.signOut();

      logger.i('[INFO - signUp()] User created successfully. Email verification sent.');

      // Navigare catre pagina de 'Email Verification Sent' care trebuie sa aiba si redirect catre 'Login Page'
      AppNavigator.navigateAndRemoveAll(page: const VerificationEmailSent());

    } on FirebaseAuthException catch (error) {
      if (error.code == 'weak-password') {
        AppNavigator.pop(); // close loadingDialog
        errorDialog(title: 'Parolă prea slabă!\n (min. 6 caractere)',);
        logger.w("[WARNING - signUp()] Weak password: ${error.toString()}");
      } else if (error.code == 'email-already-in-use') {
        AppNavigator.pop(); // close loadingDialog
        errorDialog(title: 'Adresă de email deja existentă!');
        logger.w("[WARNING - signUp()] Email already in use: ${error.toString()}");
      } else {
        AppNavigator.pop(); // close loadingDialog
        errorDialog(title: error.toString());
        logger.e("[ERROR - signUp()] ${error.toString()}");
      }
    }
  }

  Future<void> createPinCode(BuildContext context, String email, String password, String pin) async {

    loadingDialog();
    
    try {
      UserModel currentUser = (await _userRepository.getDocumentsByField("email", email))[0];
      _userRepository.updateDocumentField(currentUser.docId!, "pin", pin);

      // we know that credentials are correct, no need for try catch block
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await sessionManager.startListeningToProviders();
      AppNavigator.navigateAndRemoveAll(page: const BottomNavBar());

    } catch (error) {
      logger.e('[ERROR - createPinCode()] ${error.toString()}');
      AppNavigator.pop(); // close loadingDialog
      errorDialog(title: error.toString());
    }
  }
}
