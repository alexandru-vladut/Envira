import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_base/app/app_config.dart';
import 'package:flutter_app_base/app/app_navigator.dart';
import 'package:flutter_app_base/app/global_instances.dart';
import 'package:flutter_app_base/data/models/user_model.dart';
import 'package:flutter_app_base/session/auth_state_provider.dart';
import 'package:flutter_app_base/data/repositories/user_repository.dart';
import 'package:flutter_app_base/presentation/screens/authentication/landing_pages/forget_email_sent.dart';
import 'package:flutter_app_base/presentation/screens/authentication/landing_pages/verification_email_sent.dart';
import 'package:flutter_app_base/presentation/screens/authentication/login/login.dart';
import 'package:flutter_app_base/presentation/screens/authentication/pin/create_pin.dart';
import 'package:flutter_app_base/presentation/screens/authentication/pin/enter_pin.dart';
import 'package:flutter_app_base/presentation/screens/home.dart';
import 'package:flutter_app_base/presentation/widgets/dialog_widgets.dart';
import 'package:provider/provider.dart';

class AuthService {
  // Inject UserRepository
  final UserRepository _userRepository;
  
  // Regular constructor
  AuthService(this._userRepository);

  // FirebaseAuth instance
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void signIn(BuildContext context, String email, String password) async {

    loadingDialog(context);

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
        errorDialog(context, '[ERROR - signIn()] User not found in Firestore Database.');
        return;
      }

      if (AppConfig.secureLogin == false) {
        await sessionManager.startListeningToProviders(context, user.uid);
        AppNavigator.navigateAndRemoveAll(context, const HomePage());
        return;
      }

      if (user.emailVerified == false) {
        await user.sendEmailVerification();
        _firebaseAuth.signOut();
        AppNavigator.navigateAndRemoveAll(context, const VerificationEmailSent());
        return;
      }
        
      UserModel currentUser = filteredUsers[0];
      String? currentUserPin = currentUser.pin;

      // Sign out in case PIN verification doesn't happen
      _firebaseAuth.signOut();

      // If user has no PIN, redirect to 'Set PIN' page, else redirect to 'Enter PIN' page
      if (currentUserPin == null) {
        AppNavigator.navigateAndRemoveAll(context, CreatePin(email: email, password: password));
      } else {
        AppNavigator.navigateAndRemoveAll(context, EnterPin(email: email, password: password));
      }
      
    } on FirebaseAuthException catch (error) {
      if (error.code == 'user-not-found' || error.code == 'wrong-password') {
        errorDialog(context, 'Email/parolă greșite!');
        logger.w("[WARNING - signIn()] Wrong email/password: ${error.toString()}");
      } else {
        errorDialog(context, error.toString());
        logger.e("[ERROR - signIn()] ${error.toString()}");
      }
    }
  }

  Future<void> logOut(BuildContext context, {bool showLoadingDialog = true}) async {
    if (showLoadingDialog) {
      loadingDialog(context);
    }

    try {
      logger.i('[INFO - logOut()] Logging out user...');
      context.read<AuthStateProvider>().markManualLogout(); // 👈 mark it before logging out

      await _firebaseAuth.signOut();
      sessionManager.stopListeningToProviders(context);

      logger.i('[INFO - logOut()] User logged out successfully.');
      
      if (showLoadingDialog) {
        Navigator.pop(context);
        await Future.delayed(const Duration(milliseconds: 200));
      }
      AppNavigator.navigateAndRemoveAll(context, const LoginPage());
    } catch (error) {
      logger.e('[ERROR - logOut()] ${error.toString()}');
      if (showLoadingDialog) {
        Navigator.pop(context);
        await Future.delayed(const Duration(milliseconds: 200));
        errorDialog(context, error.toString());
      }
    }
  }

  Future<void> sendPasswordResetEmail(BuildContext context, BuildContext dialogContext, String email) async {

    Navigator.pop(dialogContext);
    loadingDialog(context);

    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      logger.i('[INFO - sendPasswordResetEmail()] Password reset email sent successfully.');
      AppNavigator.navigateAndRemoveAll(context, const ForgetEmailSent());
      
    } catch (error) {
      logger.e('[ERROR - sendPasswordResetEmail()] ${error.toString()}');
      errorDialog(context, error.toString());
    }
  }

  void signUp(BuildContext context, String inputEmail, String inputName, String inputPassword, String inputConfirmPassword) async {

    loadingDialog(context);

    try {
      // 1. Check if password and confirmPassword fields correspond.
      if (inputPassword != inputConfirmPassword) {
        errorDialog(context, 'Parolele nu corespund!');
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
        // friends: [],
        // tickets: [],
        // preferences: {},
        // feelings: {},
        // creditCards: [],
        // ecoCard: null 
      );
  
      _userRepository.addDocument(newUser);

      await user.updateDisplayName(inputName);
      await user.reload();

      if (AppConfig.secureLogin == false) {
        await sessionManager.startListeningToProviders(context, user.uid);
        AppNavigator.navigateAndRemoveAll(context, const HomePage());
        return;
      }

      await user.sendEmailVerification();
      _firebaseAuth.signOut();

      logger.i('[INFO - signUp()] User created successfully. Email verification sent.');

      // Navigare catre pagina de 'Email Verification Sent' care trebuie sa aiba si redirect catre 'Login Page'
      AppNavigator.navigateAndRemoveAll(context, VerificationEmailSent());

    } on FirebaseAuthException catch (error) {
      if (error.code == 'weak-password') {
        errorDialog(context, 'Parolă prea slabă!\n (min. 6 caractere)');
        logger.w("[WARNING - signUp()] Weak password: ${error.toString()}");
      } else if (error.code == 'email-already-in-use') {
        errorDialog(context, 'Adresă de email deja existentă!');
        logger.w("[WARNING - signUp()] Email already in use: ${error.toString()}");
      } else {
        errorDialog(context, error.toString());
        logger.e("[ERROR - signUp()] ${error.toString()}");
      }
    }
  }

  Future<void> createPinCode(BuildContext context, String email, String password, String pin) async {

    loadingDialog(context);
    
    try {
      UserModel currentUser = (await _userRepository.getDocumentsByField("email", email))[0];
      _userRepository.updateDocumentField(currentUser.docId!, "pin", pin);

      // we know that credentials are correct, no need for try catch block
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await sessionManager.startListeningToProviders(context, currentUser.uid);
      AppNavigator.navigateAndRemoveAll(context, const HomePage());

    } catch (error) {
      logger.e('[ERROR - createPinCode()] ${error.toString()}');
      errorDialog(context, error.toString());
    }
  }

}
