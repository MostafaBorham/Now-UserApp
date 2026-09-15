








class AppliedDiscountModel {

  final int vendorId;


  final String code;



  final double discount;


  final bool isVoucher;

  const AppliedDiscountModel({
    required this.vendorId,
    required this.code,
    this.discount = 0,
    this.isVoucher = false,
  });
}
