module telega.telegram.payments;

import std.typecons : Nullable;
import telega.telegram.basic : User;
import asdf.serialization : serdeOptional;

/*** Payments types ***/
struct LabeledPrice
{
    string label;
    uint   amount;
}

struct Invoice
{
    string title;
    string description;
    string start_parameter;
    string currency;
    uint   total_amount;
}

struct ShippingAddress
{
    string country_code;
    string state;
    string city;
    string street_line1;
    string street_line2;
    string post_code;
}

struct OrderInfo
{
    @serdeOptional
    Nullable!string name;
    @serdeOptional
    Nullable!string phone_number;
    @serdeOptional
    Nullable!string email;
    @serdeOptional
    Nullable!ShippingAddress shipping_address;
}

struct ShippingOption
{
    string id;
    string title;
    LabeledPrice[] prices;
}

struct SuccessfulPayment
{
    string currency;
    uint   total_amount;
    string invoice_payload;
    @serdeOptional
    Nullable!string shipping_option_id;
    @serdeOptional
    Nullable!OrderInfo order_info;
    string telegram_payment_charge_id;
    string provider_payment_charge_id;
}

struct ShippingQuery
{
    string id;
    User   from;
    string invoice_payload;
    ShippingAddress shipping_address;
}

struct PreCheckoutQuery
{
    string             id;
    User               from;
    string             currency;
    uint               total_amount;
    string             invoice_payload;
    @serdeOptional
    Nullable!string    shipping_option_id;
    @serdeOptional
    Nullable!OrderInfo order_info;
}
