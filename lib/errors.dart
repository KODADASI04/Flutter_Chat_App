class Errors {
  static String show(String hataKodu) {
    switch (hataKodu) {
      case "email-already-in-use":
        return "Bu mail adresi zaten kullanımda lütfen farklı bir mail kullanınız";
      case "wrong-password":
        return "Hatalı Şifre Girdiniz";
      case "user-not-found":
        return "Girdiğiniz kullanıcı bulunamadı.Lütfen öncelikle bir kullanıcı oluşturunuz.";
      case "account-exist-with-different-credential":
        return "Mail adresiniz ile daha önceden farklı bir giriş yöntemiyle kayıt olunmuştur.Lütfen bu yöntemi deneyiniz.";
      default:
        return "Bir hata oluştu";
    }
  }
}
