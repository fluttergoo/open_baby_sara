String getFirebaseAuthErrorMessage(String code) {
  switch (code) {
    case 'invalid-email':
      return 'Geçersiz e-posta adresi.';
    case 'user-disabled':
      return 'Bu kullanıcı devre dışı.';
    case 'user-not-found':
      return 'Kullanıcı bulunamadı.';
    case 'wrong-password':
      return 'Şifre yanlış.';
    case 'email-already-in-use':
      return 'Bu e-posta adresi zaten kullanılıyor.';
    case 'weak-password':
      return 'Şifre çok zayıf.';
    default:
      return 'Bilinmeyen bir hata oluştu.';
  }
}