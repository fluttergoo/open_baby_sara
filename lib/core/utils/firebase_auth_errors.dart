String getFirebaseAuthErrorMessage(String code) {
  switch (code) {
    case 'invalid-email':
      return 'Invalid email address.';
    case 'user-disabled':
      return 'This user has been disabled.';
    case 'user-not-found':
      return 'User not found.';
    case 'wrong-password':
      return 'Incorrect password.';
    case 'email-already-in-use':
      return 'This email address is already in use.';
    case 'weak-password':
      return 'Password is too weak.';
    default:
      return 'An unknown error has occurred.';
  }

}