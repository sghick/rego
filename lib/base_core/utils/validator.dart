import 'package:wellcomeback/base_core/utils/string_utils.dart';

final RegExp emailReg =
    RegExp(r'^[a-zA-Z0-9_-]+@[a-zA-Z0-9_-]+(\.[a-zA-Z0-9_-]+)+$');

String? emailValidator(String str) {
  if (isEmptyString(str)) return '请输入您的注册邮箱';
  str = str.trim();
  if (!emailReg.hasMatch(str)) return '请输入有效的邮箱地址';
  return null;
}

String? passwordValidator(String str) {
  if (isEmptyString(str)) return "请输入您的密码";
  str = str.trim();
  if (str.length < 6) return "密码长度至少6位";
  return null;
}

String? passwordEnterValidator(String str) {
  if (isEmptyString(str)) return "请输入您的密码";
  str = str.trim();
  if (str.length < 6) return "请输入有效的密码";
  return null;
}

String? referrerCodeValidator(String str) {
  if (isEmptyString(str)) return null;
  str = str.trim();
  if (str.length < 5 || str.length > 8) return "请输入合法的邀请码";
  return null;
}

String? emailCaptchaValidator(String str) {
  if (isEmptyString(str)) return '请输入您的注册验证码';
  str = str.trim();
  if (str.length != 6) return '请输入有效的注册验证码';
  return null;
}

String? newPasswordValidator(String str) {
  if (isEmptyString(str)) return "请输入您的新密码";
  str = str.trim();
  if (str.length < 6) return "密码长度至少6位";
  return null;
}
