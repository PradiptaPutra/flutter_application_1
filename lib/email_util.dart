// email_util.dart

import 'dart:io';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:fluttertoast/fluttertoast.dart';

Future<void> sendEmail(String pdfPath, String recipient) async {
  final smtpServer = gmail('mtsalikhlasberbahh@gmail.com', 'oxtm hpkh ciiq ppan');

  final message = Message()
    ..from = Address('anapanca@gmail.com', 'ANAPANCA admin')
    ..recipients.add(recipient)
    ..subject = 'Lampiran PDF'
    ..text = 'Silakan temukan lampiran PDF.'
    ..attachments.add(FileAttachment(File(pdfPath)));

  try {
    final sendReport = await send(message, smtpServer);
    print('Email sent: ${sendReport.toString()}');
    Fluttertoast.showToast(msg: 'Email successfully sent');
  } catch (e) {
    print('Error while sending email: $e');
    Fluttertoast.showToast(msg: 'Failed to send email. Error: $e');
  }
}
