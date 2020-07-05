module telega.telegram.passport;

import std.typecons;
import telega.botapi;
import telega.serialization;

version (unittest)
{
    import telega.test : assertEquals;
}

/******************************************************************/
/*                              Types                             */
/******************************************************************/

struct PassportData
{
    EncryptedPassportElement[] data;
    EncryptedCredentials credentials;
}

struct PassportFile
{
    string file_id;
    string file_unique_id;
    uint file_size;
    uint file_date;
}

struct EncryptedPassportElement
{
    enum Type
    {
        PersonalDetails = "personal_details",
        Passport = "passport",
        DriverLicence = "driver_license",
        IdentityCard = "identity_card",
        InternalPassport = "internal_passport",
        Address = "address",
        UtilityBill = "utility_bill",
        BankStatement = "bank_statement",
        RentalAgreement = "rental_agreement",
        PassportRegistration = "passport_registration",
        TemporaryRegistration = "temporary_registration",
        PhoneNumber = "phone_number",
        Email = "email"
    }

    string type;
    Nullable!string data;
    Nullable!string phone_number;
    Nullable!string email;
    Nullable!(PassportFile[]) files;
    Nullable!PassportFile front_side;
    Nullable!PassportFile reverse_side;
    Nullable!PassportFile selfie;
    Nullable!(PassportFile[]) translation;
    string hash;
}

struct EncryptedCredentials
{
    string data;
    string hash;
    string secret;
}

import std.meta : AliasSeq;

alias PassportElementErrorStructs = AliasSeq!(
    PassportElementErrorDataField,
    PassportElementErrorFrontSide,
    PassportElementErrorReverseSide,
    PassportElementErrorSelfie,
    PassportElementErrorFile,
    PassportElementErrorFiles,
    PassportElementErrorTranslationFile,
    PassportElementErrorTranslationFiles,
    PassportElementErrorUnspecified,
);

alias PassportElementError = JsonableAlgebraicProxy!PassportElementErrorStructs;


struct PassportElementErrorDataField
{
    string source;
    string type;
    string field_name;
    string data_hash;
    string message;
}

struct PassportElementErrorFrontSide
{
    string source = "front_side";
    string type;
    string file_hash;
    string message;
}

struct PassportElementErrorReverseSide
{
    string source = "reverse_side";
    string type;
    string file_hash;
    string message;
}

struct PassportElementErrorSelfie
{
    string source = "selfie";
    string type;
    string file_hash;
    string message;
}

struct PassportElementErrorFile
{
    string source = "file";
    string type;
    string file_hash;
    string message;
}

struct PassportElementErrorFiles
{
    string source = "files";
    string type;
    string[] file_hashes;
    string message;
}

struct PassportElementErrorTranslationFile
{
    string source = "translation_file";
    string type;
    string file_hash;
    string message;
}

struct PassportElementErrorTranslationFiles
{
    string source = "translation_files";
    string type;
    string[] file_hashes;
    string message;
}

struct PassportElementErrorUnspecified
{
    string source = "unspecified";
    string type;
    string element_hash;
    string message;
}

/******************************************************************/
/*                             Methods                            */
/******************************************************************/

struct SetPassportDataErrorsMethod
{
    mixin TelegramMethod!"/setPassportDataErrors";

    uint user_id;
    PassportElementError[] errors;
}

unittest
{
    SetPassportDataErrorsMethod m = {
        user_id: 42,
        errors: [
            PassportElementErrorUnspecified(
                "unspecified",
                EncryptedPassportElement.Type.Email,
                "#123",
                "Error Message"
            )
        ]
    };

    m.serializeToJsonString()
        .assertEquals(
            `{"user_id":42,"errors":[{"source":"unspecified","type":"email","element_hash":"#123",` ~
            `"message":"Error Message"}]}`
        );
}

bool setPassportDataErrors(BotApi api, uint userId, PassportElementError[] errors)
{
    SetPassportDataErrorsMethod m = {
        user_id : userId,
        errors : errors
    };

    return api.setPassportDataErrors(m);
}

bool setPassportDataErrors(BotApi api, ref SetPassportDataErrorsMethod m)
{
    return api.callMethod!(bool, SetPassportDataErrorsMethod)(m);
}
