import 'package:nowdelivery_user_app/core/data/models/product_model.dart';
import 'package:nowdelivery_user_app/core/data/models/store_model.dart';
import 'package:nowdelivery_user_app/features/tracking_order/data/models/delivery_man_model.dart';












class OrderModel {
  final int? id;
  final String? uuid;
  final String? orderNumber;
  final int? orderGroupId;
  final int? vendorId;
  final int? branchId;





  final StoreModel vendor;



  final OrderUserModel user;




  final DeliveryManModel? driver;



  final String? status;






  final Map<String, dynamic>? orderStatus;


  final bool isTracking;

  final String? paymentStatus;
  final double subtotal;
  final double tax;
  final double deliveryFee;
  final double discount;
  final double driverTip;
  final double total;
  final String? paymentMethod;
  final String? deliveryAddress;


  final OrderRegionModel region;

  final String? cancelReason;
  final String? notes;



  final String? estimatedDeliveryTime;
  final String? deliveredTime;
  final String? respondByAt;
  final String? acceptedAt;
  final String? preparedAt;
  final String? pickupArrivedAt;
  final String? pickedUpAt;
  final String? deliveryArrivedAt;
  final String? cancelledAt;
  final String? createdAt;
  final String? updatedAt;





  final Map<String, dynamic>? deliveredAt;

  final List<ProductModel> items;

  const OrderModel({
    this.id,
    this.uuid,
    this.orderNumber,
    this.orderGroupId,
    this.vendorId,
    this.branchId,
    this.vendor = const StoreModel(),
    this.user = const OrderUserModel(),
    this.driver,
    this.status,
    this.orderStatus,
    this.isTracking = false,
    this.paymentStatus,
    this.subtotal = 0,
    this.tax = 0,
    this.deliveryFee = 0,
    this.discount = 0,
    this.driverTip = 0,
    this.total = 0,
    this.paymentMethod,
    this.deliveryAddress,
    this.region = const OrderRegionModel(),
    this.cancelReason,
    this.notes,
    this.estimatedDeliveryTime,
    this.deliveredTime,
    this.respondByAt,
    this.acceptedAt,
    this.preparedAt,
    this.pickupArrivedAt,
    this.pickedUpAt,
    this.deliveryArrivedAt,
    this.deliveredAt,
    this.cancelledAt,
    this.createdAt,
    this.updatedAt,
    this.items = const <ProductModel>[],
  });

  factory OrderModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const OrderModel();
    }

    final Map<String, dynamic>? vendor =
        json['vendor'] as Map<String, dynamic>?;

    return OrderModel(
      id: (json['id'] as num?)?.toInt(),
      uuid: json['uuid']?.toString(),
      orderNumber: json['order_number']?.toString(),
      orderGroupId: (json['order_group_id'] as num?)?.toInt(),
      vendorId: (json['vendor_id'] as num?)?.toInt(),
      branchId: (json['branch_id'] as num?)?.toInt(),
      vendor: StoreModel.fromJson(<String, dynamic>{
        'id': vendor?['id'],
        'name': vendor?['name'],
        'logo_url': vendor?['logo_url'],
      }),
      user: OrderUserModel.fromJson(json['user'] as Map<String, dynamic>?),
      driver: json['driver'] is Map<String, dynamic>
          ? DeliveryManModel.fromJson(json['driver'] as Map<String, dynamic>)
          : null,
      status: json['status']?.toString(),
      orderStatus: (json['order_status'] is Map)
          ? json['order_status'] as Map<String, dynamic>
          : (json['status'] is String)
          ? {'ar': json['status'] as String, 'en': json['status'] as String}
          : null,
      isTracking: json['is_tracking'] as bool? ?? false,
      paymentStatus: json['payment_status']?.toString(),
      subtotal: double.tryParse(json['subtotal']?.toString() ?? '') ?? 0.0,
      tax:
          double.tryParse(
            (json['tax'] ?? json['tax_amount'])?.toString() ?? '',
          ) ??
          0.0,
      deliveryFee:
          double.tryParse(json['delivery_fee']?.toString() ?? '') ?? 0.0,
      discount:
          double.tryParse(
            (json['discount'] ?? json['discount_amount'])?.toString() ?? '',
          ) ??
          0.0,
      driverTip: double.tryParse(json['driver_tip']?.toString() ?? '') ?? 0.0,
      total:
          double.tryParse(
            (json['total'] ?? json['total_amount'])?.toString() ?? '',
          ) ??
          0.0,
      paymentMethod: json['payment_method']?.toString(),
      deliveryAddress: json['delivery_address']?.toString(),
      region: OrderRegionModel.fromJson(json['region'] as Map<String, dynamic>?),
      cancelReason: json['cancel_reason']?.toString(),
      notes: json['notes']?.toString(),
      estimatedDeliveryTime: json['estimated_delivery_time']?.toString(),
      deliveredTime: json['delivered_time']?.toString(),
      respondByAt: json['respond_by_at']?.toString(),
      acceptedAt: json['accepted_at']?.toString(),
      preparedAt: json['prepared_at']?.toString(),
      pickupArrivedAt: json['pickup_arrived_at']?.toString(),
      pickedUpAt: json['picked_up_at']?.toString(),
      deliveryArrivedAt: json['delivery_arrived_at']?.toString(),
      deliveredAt: (json['delivered_at'] is String)
          ? {
              'ar': json['delivered_at'] as String,
              'en': json['delivered_at'] as String,
            }
          : json['delivered_at'],
      cancelledAt: json['cancelled_at']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      items:
          (json['items'] as List?)?.map((e) {
            final Map<String, dynamic> item =
                (e as Map<String, dynamic>?) ?? <String, dynamic>{};
            final Map<String, dynamic>? product =
                item['product'] as Map<String, dynamic>?;





            if (product != null) {
              return ProductModel.fromJson(<String, dynamic>{
                ...product,
                'quantity': item['quantity'],
              });
            }
            return ProductModel.fromJson(<String, dynamic>{
              ...item,
              'product_id': item['product_id'],
              'name': item['product_name'],
              'sku': item['product_sku'],
              'price': item['unit_price'],
            });
          }).toList() ??
          const <ProductModel>[],
    );
  }
}



class OrderRegionModel {
  final String? city;
  final String? area;

  const OrderRegionModel({this.city, this.area});

  factory OrderRegionModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const OrderRegionModel();
    }

    return OrderRegionModel(
      city: json['city']?.toString(),
      area: json['area']?.toString(),
    );
  }
}






class OrderUserModel {
  final int? id;
  final String? name;
  final String? phone;

  const OrderUserModel({this.id, this.name, this.phone});

  factory OrderUserModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const OrderUserModel();
    }

    return OrderUserModel(
      id: (json['id'] as num?)?.toInt(),
      name: json['name']?.toString(),
      phone: json['phone']?.toString(),
    );
  }
}
