import 'package:flutter/material.dart';

/// INI YANG DIPAKE
void showErrorPopup(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      Future.delayed(const Duration(seconds: 2), () {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      });

      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Terjadi Kesalahan",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
        ),
        content: Text(message),
      );
    },
  );
}

// kagak kepake
void showSuccessPopup(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      Future.delayed(const Duration(seconds: 2), () {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      });

      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Berhasil",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
        ),
        content: Text(message),
      );
    },
  );
}
