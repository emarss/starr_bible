import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:starr/services/colors.dart';
import 'package:starr/services/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

AwesomeDialog showWaitingDialog(BuildContext context,
    {String message = "Sending. Please, wait."}) {
  return AwesomeDialog(
    context: context,
    dismissOnTouchOutside: false,
    dismissOnBackKeyPress: false,
    animType: AnimType.SCALE,
    customHeader: CircularProgressIndicator(
      color: primaryLightColor,
      strokeWidth: 6,
      backgroundColor: primaryColor,
    ),
    padding: EdgeInsets.all(16),
    btnOkColor: primaryColor,
    buttonsBorderRadius: BorderRadius.circular(8),
    width: MediaQuery.of(context).size.width,
    body: Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(message, style: darkFS15W500, textAlign: TextAlign.center),
    ),
  )..show();
}

Future<AwesomeDialog> showWaitingDialogAsync(BuildContext context,
    {String message = "An unexpected error has occured."}) async {
  return AwesomeDialog(
    context: context,
    dismissOnTouchOutside: false,
    dismissOnBackKeyPress: false,
    animType: AnimType.SCALE,
    customHeader: CircularProgressIndicator(
      color: primaryLightColor,
      strokeWidth: 6,
      backgroundColor: primaryColor,
    ),
    padding: EdgeInsets.all(16),
    btnOkColor: primaryColor,
    buttonsBorderRadius: BorderRadius.circular(8),
    width: MediaQuery.of(context).size.width,
    body: Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(message, style: darkFS15W500, textAlign: TextAlign.center),
    ),
  );
}

Future<AwesomeDialog> showErrorDialogAsync(BuildContext context,
    {String message = "An unexpected error has occured."}) async {
  return AwesomeDialog(
      context: context,
      dismissOnTouchOutside: false,
      dismissOnBackKeyPress: false,
      animType: AnimType.SCALE,
      customHeader: buildErrorDialogHeader(),
      padding: EdgeInsets.all(16),
      btnOkColor: primaryColor,
      buttonsBorderRadius: BorderRadius.circular(8),
      width: MediaQuery.of(context).size.width,
      body: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Text(message, style: darkFS15W500, textAlign: TextAlign.center),
      ),
      btnOkOnPress: () {});
}

CircleAvatar buildErrorDialogHeader() {
  return CircleAvatar(
      backgroundColor: primaryColor,
      radius: 45,
      child: Icon(Icons.error_outline, size: 40, color: whiteColor));
}

AwesomeDialog showWarningDialog(BuildContext context,
    {String message = "An unexpected error has occured."}) {
  return AwesomeDialog(
      context: context,
      dismissOnTouchOutside: false,
      dismissOnBackKeyPress: false,
      animType: AnimType.SCALE,
      customHeader: buildWarningDialogHeader(),
      padding: EdgeInsets.all(16),
      btnOkColor: primaryColor,
      buttonsBorderRadius: BorderRadius.circular(8),
      width: MediaQuery.of(context).size.width,
      body: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Text(message, style: darkFS15W500, textAlign: TextAlign.center),
      ),
      btnOkOnPress: () {})
    ..show();
}

CircleAvatar buildWarningDialogHeader() {
  return CircleAvatar(
      backgroundColor: primaryColor,
      radius: 45,
      child: Icon(CupertinoIcons.exclamationmark_shield,
          size: 40, color: whiteColor));
}

AwesomeDialog showInfoDialog(BuildContext context, {String message = ""}) {
  return AwesomeDialog(
      context: context,
      dismissOnTouchOutside: false,
      dismissOnBackKeyPress: false,
      animType: AnimType.SCALE,
      customHeader: buildInfoDialogHeader(),
      padding: EdgeInsets.all(16),
      btnOkColor: primaryColor,
      buttonsBorderRadius: BorderRadius.circular(8),
      width: MediaQuery.of(context).size.width,
      body: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Text(message, style: darkFS15W500, textAlign: TextAlign.center),
      ),
      btnOkOnPress: () {})
    ..show();
}

CircleAvatar buildInfoDialogHeader() {
  return CircleAvatar(
      backgroundColor: primaryColor,
      radius: 45,
      child: Icon(CupertinoIcons.info, size: 40, color: whiteColor));
}

CircleAvatar buildSuccessDialogHeader() {
  return CircleAvatar(
      backgroundColor: primaryColor,
      radius: 45,
      child: Icon(CupertinoIcons.checkmark_alt_circle,
          size: 40, color: whiteColor));
}

Future<AwesomeDialog> showSuccessDialogAsync(BuildContext context,
    {String message = ""}) async {
  return AwesomeDialog(
      context: context,
      dismissOnTouchOutside: false,
      dismissOnBackKeyPress: false,
      animType: AnimType.SCALE,
      customHeader: buildSuccessDialogHeader(),
      padding: EdgeInsets.all(16),
      btnOkColor: primaryColor,
      buttonsBorderRadius: BorderRadius.circular(8),
      width: MediaQuery.of(context).size.width,
      body: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Text(message, style: darkFS15W500, textAlign: TextAlign.center),
      ),
      btnOkOnPress: () {});
}

CircleAvatar buildQuestionDialogHeader() {
  return CircleAvatar(
      backgroundColor: primaryColor,
      radius: 45,
      child: Icon(CupertinoIcons.question, size: 40, color: whiteColor));
}
