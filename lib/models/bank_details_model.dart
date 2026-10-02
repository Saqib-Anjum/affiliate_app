class BankDetailsModel {
  BankDetailsModel({
    this.paymentMethod = "bank_transfer",
    this.accountHolderName,
    this.bankName,
    this.accountNumberMasked,
    this.ibanMasked,
    this.swiftBic,
    this.branchName,
    this.mobileWalletProvider,
    this.mobileWalletNumberMasked,
    this.updatedAt,
  });

  final String paymentMethod;
  final String? accountHolderName;
  final String? bankName;
  final String? accountNumberMasked;
  final String? ibanMasked;
  final String? swiftBic;
  final String? branchName;
  final String? mobileWalletProvider;
  final String? mobileWalletNumberMasked;
  final DateTime? updatedAt;

  factory BankDetailsModel.fromJson(Map<String, dynamic> json) {
    return BankDetailsModel(
      paymentMethod: json["paymentMethod"] ?? "bank_transfer",
      accountHolderName: json["accountHolderName"],
      bankName: json["bankName"],
      accountNumberMasked: json["accountNumber"],
      ibanMasked: json["iban"],
      swiftBic: json["swiftBic"],
      branchName: json["branchName"],
      mobileWalletProvider: json["mobileWalletProvider"],
      mobileWalletNumberMasked: json["mobileWalletNumber"],
      updatedAt: json["updatedAt"] != null ? DateTime.tryParse(json["updatedAt"]) : null,
    );
  }
}
