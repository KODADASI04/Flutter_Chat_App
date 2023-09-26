import 'package:flutter/material.dart';

class SocialLoginButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback onPressed;
  final Color? buttonColor;
  final Widget buttonIcon;
  final Color? textColor;
  final double radius;
  final double? height;

  const SocialLoginButton(
      {super.key,
      required this.onPressed,
      required this.buttonText,
      this.buttonColor,
      this.buttonIcon = const SizedBox(width: 20),
      this.textColor,
      this.radius = 16,
      this.height = 50});
  //: assert(buttonText != null) şeklinde constructora ekleme yaparsak bu şart sağlanmadığı her şekilde hata vermesi sağlanmaktadır.

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: const EdgeInsets.only(bottom: 8),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          backgroundColor: buttonColor,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            buttonIcon,
            Text(
              buttonText,
              style: TextStyle(
                color: textColor,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
          ],
        ),
      ),
    );
  }
}

/* if(kosul)...[

] seklindeki bir kullanım ile kosula bağlı olarak istediğimiz widget listesini döndürebilmekteyiz.Bu yapıya da spreads yapısı denmektedir.*/
