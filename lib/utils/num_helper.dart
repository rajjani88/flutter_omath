removeTraillingZero(double num) {
  RegExp regex = RegExp(r'([.]*0)(?!.*\d)');
  return num.toString().replaceAll(regex, '');
}
