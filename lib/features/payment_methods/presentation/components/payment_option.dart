/// Identifies a selectable payment option on the Payment Methods screen.
///
/// Shared by the sections so selection state stays type-safe instead of
/// relying on matching magic-string ids.
enum PaymentOption { visa, masterCard, applePay, stcPay }
