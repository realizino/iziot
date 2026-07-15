import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fa.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fa'),
    Locale('fr'),
    Locale('it'),
    Locale('ru'),
    Locale('tr'),
    Locale('zh'),
  ];

  /// No description provided for @izino.
  ///
  /// In en, this message translates to:
  /// **'IzIno'**
  String get izino;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get language;

  /// No description provided for @enter_the.
  ///
  /// In en, this message translates to:
  /// **'Enter the required fields'**
  String get enter_the;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @signup.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signup;

  /// No description provided for @forgetpassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get forgetpassword;

  /// No description provided for @here.
  ///
  /// In en, this message translates to:
  /// **'here'**
  String get here;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @configpassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get configpassword;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @family.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get family;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phone;

  /// No description provided for @bio.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get bio;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @please_enter_link.
  ///
  /// In en, this message translates to:
  /// **'Please enter a link or phone number'**
  String get please_enter_link;

  /// No description provided for @qrcode.
  ///
  /// In en, this message translates to:
  /// **'QR Code'**
  String get qrcode;

  /// No description provided for @linkshare.
  ///
  /// In en, this message translates to:
  /// **'Share link'**
  String get linkshare;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @nnew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get nnew;

  /// No description provided for @camera_access.
  ///
  /// In en, this message translates to:
  /// **'Camera access is not allowed. Please enable the permission from device settings.'**
  String get camera_access;

  /// No description provided for @camera_not_supported.
  ///
  /// In en, this message translates to:
  /// **'Camera is not supported on this device.'**
  String get camera_not_supported;

  /// No description provided for @camera_not_access.
  ///
  /// In en, this message translates to:
  /// **'Camera is not available or an error occurred.'**
  String get camera_not_access;

  /// No description provided for @aboutus.
  ///
  /// In en, this message translates to:
  /// **'About us'**
  String get aboutus;

  /// No description provided for @darkmod.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get darkmod;

  /// No description provided for @exit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exit;

  /// No description provided for @devloped_by.
  ///
  /// In en, this message translates to:
  /// **'Developed by '**
  String get devloped_by;

  /// No description provided for @addlocation.
  ///
  /// In en, this message translates to:
  /// **'Add location'**
  String get addlocation;

  /// No description provided for @language_label.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language_label;

  /// No description provided for @messages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// No description provided for @law.
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get law;

  /// No description provided for @opration_is_done.
  ///
  /// In en, this message translates to:
  /// **'Operation completed successfully'**
  String get opration_is_done;

  /// No description provided for @loginisinvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid credentials'**
  String get loginisinvalid;

  /// No description provided for @pleasefillallfeilds.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all required fields'**
  String get pleasefillallfeilds;

  /// No description provided for @pleaseentervalidpassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid password'**
  String get pleaseentervalidpassword;

  /// No description provided for @verifycodeisfalse.
  ///
  /// In en, this message translates to:
  /// **'The verification code is incorrect'**
  String get verifycodeisfalse;

  /// No description provided for @youraccessisdenied.
  ///
  /// In en, this message translates to:
  /// **'Your access is denied'**
  String get youraccessisdenied;

  /// No description provided for @signupisdonelaws.
  ///
  /// In en, this message translates to:
  /// **'By signing up you agree to the '**
  String get signupisdonelaws;

  /// No description provided for @laws.
  ///
  /// In en, this message translates to:
  /// **'terms and conditions'**
  String get laws;

  /// No description provided for @laws_done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get laws_done;

  /// No description provided for @updateapp.
  ///
  /// In en, this message translates to:
  /// **'Update available'**
  String get updateapp;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @pleaseupdateapp.
  ///
  /// In en, this message translates to:
  /// **'Please update your app to continue'**
  String get pleaseupdateapp;

  /// No description provided for @linkrepoisempty.
  ///
  /// In en, this message translates to:
  /// **'No links added yet'**
  String get linkrepoisempty;

  /// No description provided for @youcannotsignupwiththisdata.
  ///
  /// In en, this message translates to:
  /// **'Unable to sign up with this information'**
  String get youcannotsignupwiththisdata;

  /// No description provided for @backpressagin.
  ///
  /// In en, this message translates to:
  /// **'Press back again to exit'**
  String get backpressagin;

  /// No description provided for @inputisinvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid input'**
  String get inputisinvalid;

  /// No description provided for @launch.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get launch;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @copylinkinclipboard.
  ///
  /// In en, this message translates to:
  /// **'Link copied to clipboard'**
  String get copylinkinclipboard;

  /// No description provided for @thepassisnot.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get thepassisnot;

  /// No description provided for @nothavemessageyet.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get nothavemessageyet;

  /// No description provided for @commingsoon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get commingsoon;

  /// No description provided for @usernotfound.
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get usernotfound;

  /// No description provided for @report.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get report;

  /// No description provided for @please_select_your_report_topic.
  ///
  /// In en, this message translates to:
  /// **'Please select a report topic'**
  String get please_select_your_report_topic;

  /// No description provided for @weresivedyourreport.
  ///
  /// In en, this message translates to:
  /// **'Your report has been received'**
  String get weresivedyourreport;

  /// No description provided for @ifyoudontsignup.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get ifyoudontsignup;

  /// No description provided for @pelasecheckinputs.
  ///
  /// In en, this message translates to:
  /// **'Please check your inputs'**
  String get pelasecheckinputs;

  /// No description provided for @openqrcodescanner.
  ///
  /// In en, this message translates to:
  /// **'Open QR scanner'**
  String get openqrcodescanner;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @unsave.
  ///
  /// In en, this message translates to:
  /// **'Unsave'**
  String get unsave;

  /// No description provided for @call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// No description provided for @listisempty.
  ///
  /// In en, this message translates to:
  /// **'List is empty'**
  String get listisempty;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @onboarding1_title.
  ///
  /// In en, this message translates to:
  /// **'Smart IoT Solutions'**
  String get onboarding1_title;

  /// No description provided for @onboarding1_text.
  ///
  /// In en, this message translates to:
  /// **'Connect your devices and monitor them easily with IZIOT smart IoT solutions.'**
  String get onboarding1_text;

  /// No description provided for @onboarding2_title.
  ///
  /// In en, this message translates to:
  /// **'Track & Monitor Devices'**
  String get onboarding2_title;

  /// No description provided for @onboarding2_text.
  ///
  /// In en, this message translates to:
  /// **'View your device status, location, and data anytime from anywhere.'**
  String get onboarding2_text;

  /// No description provided for @currentlocation.
  ///
  /// In en, this message translates to:
  /// **'Current Location'**
  String get currentlocation;

  /// No description provided for @onboarding3_title.
  ///
  /// In en, this message translates to:
  /// **'Control Your Smart World'**
  String get onboarding3_title;

  /// No description provided for @onboarding3_text.
  ///
  /// In en, this message translates to:
  /// **'Manage your IoT devices and access real-time information with IZIOT.'**
  String get onboarding3_text;

  /// No description provided for @onboarding4_title.
  ///
  /// In en, this message translates to:
  /// **'Are you ready?'**
  String get onboarding4_title;

  /// No description provided for @onboarding4_text.
  ///
  /// In en, this message translates to:
  /// **'Let\'s start IZIOT and experience a smarter connected world.'**
  String get onboarding4_text;

  /// No description provided for @alreadyhaveaccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyhaveaccount;

  /// No description provided for @donthaveaccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get donthaveaccount;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @collapse_menu.
  ///
  /// In en, this message translates to:
  /// **'Collapse menu'**
  String get collapse_menu;

  /// No description provided for @comingsoon_title.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingsoon_title;

  /// No description provided for @comingsoon_desc.
  ///
  /// In en, this message translates to:
  /// **'Google login will be available very soon'**
  String get comingsoon_desc;

  /// No description provided for @nfc_share.
  ///
  /// In en, this message translates to:
  /// **'Share via NFC'**
  String get nfc_share;

  /// No description provided for @nfc_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get nfc_cancel;

  /// No description provided for @nfc_waiting_title.
  ///
  /// In en, this message translates to:
  /// **'Bring phones together'**
  String get nfc_waiting_title;

  /// No description provided for @nfc_waiting_desc.
  ///
  /// In en, this message translates to:
  /// **'Hold the two phones close together to share your profile link'**
  String get nfc_waiting_desc;

  /// No description provided for @nfc_success.
  ///
  /// In en, this message translates to:
  /// **'Link sent successfully!'**
  String get nfc_success;

  /// No description provided for @nfc_error.
  ///
  /// In en, this message translates to:
  /// **'Failed to send. Please try again.'**
  String get nfc_error;

  /// No description provided for @nfc_received_title.
  ///
  /// In en, this message translates to:
  /// **'Link received'**
  String get nfc_received_title;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @noCategoriesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No categories available'**
  String get noCategoriesAvailable;

  /// No description provided for @yourSelectedKeywords.
  ///
  /// In en, this message translates to:
  /// **'Your selections'**
  String get yourSelectedKeywords;

  /// No description provided for @error_in_save.
  ///
  /// In en, this message translates to:
  /// **'Error saving data'**
  String get error_in_save;

  /// No description provided for @error_in_upload.
  ///
  /// In en, this message translates to:
  /// **'Error uploading image'**
  String get error_in_upload;

  /// No description provided for @link_added.
  ///
  /// In en, this message translates to:
  /// **'Link successfully added'**
  String get link_added;

  /// No description provided for @error_in_link_add.
  ///
  /// In en, this message translates to:
  /// **'Error adding link'**
  String get error_in_link_add;

  /// No description provided for @message_copied.
  ///
  /// In en, this message translates to:
  /// **'Message copied'**
  String get message_copied;

  /// No description provided for @not_message_yet.
  ///
  /// In en, this message translates to:
  /// **'No messages have been recorded yet'**
  String get not_message_yet;

  /// No description provided for @error_in_mesages.
  ///
  /// In en, this message translates to:
  /// **'Error loading messages'**
  String get error_in_mesages;

  /// No description provided for @maps.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get maps;

  /// No description provided for @again_auth.
  ///
  /// In en, this message translates to:
  /// **'Need to log in again'**
  String get again_auth;

  /// No description provided for @have_an_error.
  ///
  /// In en, this message translates to:
  /// **'An error has occurred'**
  String get have_an_error;

  /// No description provided for @error_at.
  ///
  /// In en, this message translates to:
  /// **'Error: status code '**
  String get error_at;

  /// No description provided for @error_at_connection.
  ///
  /// In en, this message translates to:
  /// **'Error in communicating with the server'**
  String get error_at_connection;

  /// No description provided for @add_filter.
  ///
  /// In en, this message translates to:
  /// **'Apply filter'**
  String get add_filter;

  /// No description provided for @remove_filter.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get remove_filter;

  /// No description provided for @standard_map.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get standard_map;

  /// No description provided for @hu_map.
  ///
  /// In en, this message translates to:
  /// **'Human'**
  String get hu_map;

  /// No description provided for @topo_map.
  ///
  /// In en, this message translates to:
  /// **'Topographic'**
  String get topo_map;

  /// No description provided for @sattlite_map.
  ///
  /// In en, this message translates to:
  /// **'Satellite'**
  String get sattlite_map;

  /// No description provided for @have_new_version.
  ///
  /// In en, this message translates to:
  /// **'New version available.\n'**
  String get have_new_version;

  /// No description provided for @have_new_version_continune.
  ///
  /// In en, this message translates to:
  /// **'To use new features and fix issues, please update the app.'**
  String get have_new_version_continune;

  /// No description provided for @afew_moment.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get afew_moment;

  /// No description provided for @error_in_data.
  ///
  /// In en, this message translates to:
  /// **'Error in receiving data'**
  String get error_in_data;

  /// No description provided for @chat_is_empty.
  ///
  /// In en, this message translates to:
  /// **'No chat exists'**
  String get chat_is_empty;

  /// No description provided for @new_chat.
  ///
  /// In en, this message translates to:
  /// **'New Chat'**
  String get new_chat;

  /// No description provided for @uUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get uUnknown;

  /// No description provided for @token_is_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to receive token from Google'**
  String get token_is_failed;

  /// No description provided for @error_at_firebase.
  ///
  /// In en, this message translates to:
  /// **'Firebase error: user is null'**
  String get error_at_firebase;

  /// No description provided for @error_at_login.
  ///
  /// In en, this message translates to:
  /// **'Error logging in with Google'**
  String get error_at_login;

  /// No description provided for @email_is_signed_before.
  ///
  /// In en, this message translates to:
  /// **'This email has already been registered with another method'**
  String get email_is_signed_before;

  /// No description provided for @auth_is_wrong.
  ///
  /// In en, this message translates to:
  /// **'Authentication information is invalid'**
  String get auth_is_wrong;

  /// No description provided for @login_is_not_active_with_google.
  ///
  /// In en, this message translates to:
  /// **'Login with Google is not active in Firebase'**
  String get login_is_not_active_with_google;

  /// No description provided for @account_is_not_active.
  ///
  /// In en, this message translates to:
  /// **'User account has been deactivated'**
  String get account_is_not_active;

  /// No description provided for @connection_error.
  ///
  /// In en, this message translates to:
  /// **'Network error — check your internet connection'**
  String get connection_error;

  /// No description provided for @unknowe_error.
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get unknowe_error;

  /// No description provided for @business.
  ///
  /// In en, this message translates to:
  /// **'Businesses'**
  String get business;

  /// No description provided for @error_when_read_data.
  ///
  /// In en, this message translates to:
  /// **'Error receiving data'**
  String get error_when_read_data;

  /// No description provided for @not_have_any_business.
  ///
  /// In en, this message translates to:
  /// **'No business has been registered'**
  String get not_have_any_business;

  /// No description provided for @create_new_business.
  ///
  /// In en, this message translates to:
  /// **'Create new business'**
  String get create_new_business;

  /// No description provided for @not_have_address.
  ///
  /// In en, this message translates to:
  /// **'Address not registered'**
  String get not_have_address;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @deactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get deactive;

  /// No description provided for @until.
  ///
  /// In en, this message translates to:
  /// **'Until'**
  String get until;

  /// No description provided for @bu_tab_title_1.
  ///
  /// In en, this message translates to:
  /// **'Business image'**
  String get bu_tab_title_1;

  /// No description provided for @bu_tab_descr_1.
  ///
  /// In en, this message translates to:
  /// **'Choose a suitable image for your business.'**
  String get bu_tab_descr_1;

  /// No description provided for @bu_tab_title_2.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get bu_tab_title_2;

  /// No description provided for @bu_tab_descr_2.
  ///
  /// In en, this message translates to:
  /// **'Select the categories related to your business.'**
  String get bu_tab_descr_2;

  /// No description provided for @bu_tab_title_3.
  ///
  /// In en, this message translates to:
  /// **'Business information'**
  String get bu_tab_title_3;

  /// No description provided for @bu_tab_descr_3.
  ///
  /// In en, this message translates to:
  /// **'Enter your business name, description and phone number.'**
  String get bu_tab_descr_3;

  /// No description provided for @bu_tab_title_4.
  ///
  /// In en, this message translates to:
  /// **'Address & location'**
  String get bu_tab_title_4;

  /// No description provided for @bu_tab_descr_4.
  ///
  /// In en, this message translates to:
  /// **'Enter the address and select the location on the map.'**
  String get bu_tab_descr_4;

  /// No description provided for @bu_tab_title_5.
  ///
  /// In en, this message translates to:
  /// **'Working hours'**
  String get bu_tab_title_5;

  /// No description provided for @bu_tab_descr_5.
  ///
  /// In en, this message translates to:
  /// **'Select your business start and end hours.'**
  String get bu_tab_descr_5;

  /// No description provided for @bu_tab_title_6.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get bu_tab_title_6;

  /// No description provided for @bu_tab_descr_6.
  ///
  /// In en, this message translates to:
  /// **'Select your business main language.'**
  String get bu_tab_descr_6;

  /// No description provided for @continuee.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continuee;

  /// No description provided for @submit_bus.
  ///
  /// In en, this message translates to:
  /// **'Register business'**
  String get submit_bus;

  /// No description provided for @category_not_found.
  ///
  /// In en, this message translates to:
  /// **'No categories found'**
  String get category_not_found;

  /// No description provided for @selected_category.
  ///
  /// In en, this message translates to:
  /// **'Selected categories'**
  String get selected_category;

  /// No description provided for @select_image.
  ///
  /// In en, this message translates to:
  /// **'Select image'**
  String get select_image;

  /// No description provided for @bu_name.
  ///
  /// In en, this message translates to:
  /// **'Business name'**
  String get bu_name;

  /// No description provided for @dit.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get dit;

  /// No description provided for @sample_phone.
  ///
  /// In en, this message translates to:
  /// **'Phone number (e.g. 123-456-7890)'**
  String get sample_phone;

  /// No description provided for @address_fully.
  ///
  /// In en, this message translates to:
  /// **'Full address'**
  String get address_fully;

  /// No description provided for @swipe_map.
  ///
  /// In en, this message translates to:
  /// **'Move the map until the desired location is centered'**
  String get swipe_map;

  /// No description provided for @start_job.
  ///
  /// In en, this message translates to:
  /// **'Work start time'**
  String get start_job;

  /// No description provided for @end_job.
  ///
  /// In en, this message translates to:
  /// **'Work end time'**
  String get end_job;

  /// No description provided for @please_fill_all_fieilds.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all required information'**
  String get please_fill_all_fieilds;

  /// No description provided for @buz_updated.
  ///
  /// In en, this message translates to:
  /// **'Changes saved successfully'**
  String get buz_updated;

  /// No description provided for @error_in_storage_data.
  ///
  /// In en, this message translates to:
  /// **'Error saving data'**
  String get error_in_storage_data;

  /// No description provided for @lie_info.
  ///
  /// In en, this message translates to:
  /// **'information'**
  String get lie_info;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @links.
  ///
  /// In en, this message translates to:
  /// **'Links'**
  String get links;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @save_chages.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get save_chages;

  /// No description provided for @for_change_click_on_image.
  ///
  /// In en, this message translates to:
  /// **'Tap to change image'**
  String get for_change_click_on_image;

  /// No description provided for @remove_buz.
  ///
  /// In en, this message translates to:
  /// **'Delete this business'**
  String get remove_buz;

  /// No description provided for @links_is_empty.
  ///
  /// In en, this message translates to:
  /// **'No links have been registered'**
  String get links_is_empty;

  /// No description provided for @add_new_link.
  ///
  /// In en, this message translates to:
  /// **'Add link'**
  String get add_new_link;

  /// No description provided for @calls.
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get calls;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @copy_link.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get copy_link;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Link copied'**
  String get copied;

  /// No description provided for @link_removed.
  ///
  /// In en, this message translates to:
  /// **'Link removed'**
  String get link_removed;

  /// No description provided for @error_when_removed.
  ///
  /// In en, this message translates to:
  /// **'Error removing link'**
  String get error_when_removed;

  /// No description provided for @add_NN_link.
  ///
  /// In en, this message translates to:
  /// **'Add new link'**
  String get add_NN_link;

  /// No description provided for @link_not_valid.
  ///
  /// In en, this message translates to:
  /// **'Invalid link'**
  String get link_not_valid;

  /// No description provided for @error_when_add_image.
  ///
  /// In en, this message translates to:
  /// **'Error adding link'**
  String get error_when_add_image;

  /// No description provided for @error_when_add_link.
  ///
  /// In en, this message translates to:
  /// **'Error adding link'**
  String get error_when_add_link;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @remove_bz_alert_title.
  ///
  /// In en, this message translates to:
  /// **'Delete business'**
  String get remove_bz_alert_title;

  /// No description provided for @remove_bz_alert_dec.
  ///
  /// In en, this message translates to:
  /// **'Are you sure? This action cannot be undone.'**
  String get remove_bz_alert_dec;

  /// No description provided for @cencel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cencel;

  /// No description provided for @bz_removed.
  ///
  /// In en, this message translates to:
  /// **'Business deleted'**
  String get bz_removed;

  /// No description provided for @error_when_bz_removing.
  ///
  /// In en, this message translates to:
  /// **'Error deleting business'**
  String get error_when_bz_removing;

  /// No description provided for @show_on_map.
  ///
  /// In en, this message translates to:
  /// **'Show on map'**
  String get show_on_map;

  /// No description provided for @fail_edit_message.
  ///
  /// In en, this message translates to:
  /// **'Message edit failed'**
  String get fail_edit_message;

  /// No description provided for @reply.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get reply;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @this_message_removed.
  ///
  /// In en, this message translates to:
  /// **'This message has been removed'**
  String get this_message_removed;

  /// No description provided for @edited.
  ///
  /// In en, this message translates to:
  /// **'Edited'**
  String get edited;

  /// No description provided for @delete_chat.
  ///
  /// In en, this message translates to:
  /// **'Delete Chat'**
  String get delete_chat;

  /// No description provided for @delete_chat_confirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this chat? This action cannot be undone.'**
  String get delete_chat_confirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @request_added.
  ///
  /// In en, this message translates to:
  /// **'Request submitted'**
  String get request_added;

  /// No description provided for @edit_rquest.
  ///
  /// In en, this message translates to:
  /// **'Edit request'**
  String get edit_rquest;

  /// No description provided for @new_request.
  ///
  /// In en, this message translates to:
  /// **'New request'**
  String get new_request;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get amount;

  /// No description provided for @expire.
  ///
  /// In en, this message translates to:
  /// **'Expiry date (YYYY-MM-DD) optional'**
  String get expire;

  /// No description provided for @city_name.
  ///
  /// In en, this message translates to:
  /// **'City (optional)'**
  String get city_name;

  /// No description provided for @request_accept.
  ///
  /// In en, this message translates to:
  /// **'Request accepted'**
  String get request_accept;

  /// No description provided for @cancel_assignment.
  ///
  /// In en, this message translates to:
  /// **'Cancel Assignment'**
  String get cancel_assignment;

  /// No description provided for @request_close.
  ///
  /// In en, this message translates to:
  /// **'Request closed'**
  String get request_close;

  /// No description provided for @delete_request.
  ///
  /// In en, this message translates to:
  /// **'Delete request'**
  String get delete_request;

  /// No description provided for @are_you_sure.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this request?'**
  String get are_you_sure;

  /// No description provided for @rate_host.
  ///
  /// In en, this message translates to:
  /// **'Rate host'**
  String get rate_host;

  /// No description provided for @rate_client.
  ///
  /// In en, this message translates to:
  /// **'Rate client'**
  String get rate_client;

  /// No description provided for @optienal_comment.
  ///
  /// In en, this message translates to:
  /// **'Optional comment'**
  String get optienal_comment;

  /// No description provided for @feed_back_submit.
  ///
  /// In en, this message translates to:
  /// **'Feedback submitted'**
  String get feed_back_submit;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @not_specified.
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get not_specified;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @keywords.
  ///
  /// In en, this message translates to:
  /// **'Keywords'**
  String get keywords;

  /// No description provided for @community.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get community;

  /// No description provided for @expires.
  ///
  /// In en, this message translates to:
  /// **'Expiry date'**
  String get expires;

  /// No description provided for @no_expiry.
  ///
  /// In en, this message translates to:
  /// **'No expiry'**
  String get no_expiry;

  /// No description provided for @people.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get people;

  /// No description provided for @host.
  ///
  /// In en, this message translates to:
  /// **'Host'**
  String get host;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @client.
  ///
  /// In en, this message translates to:
  /// **'Client'**
  String get client;

  /// No description provided for @client_rate.
  ///
  /// In en, this message translates to:
  /// **'Client rating'**
  String get client_rate;

  /// No description provided for @host_rate.
  ///
  /// In en, this message translates to:
  /// **'Host rating'**
  String get host_rate;

  /// No description provided for @accept_request.
  ///
  /// In en, this message translates to:
  /// **'Accept request'**
  String get accept_request;

  /// No description provided for @close_request.
  ///
  /// In en, this message translates to:
  /// **'Close request'**
  String get close_request;

  /// No description provided for @my_requests.
  ///
  /// In en, this message translates to:
  /// **'My requests'**
  String get my_requests;

  /// No description provided for @accepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get accepted;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status:'**
  String get status;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @assigned.
  ///
  /// In en, this message translates to:
  /// **'Assigned'**
  String get assigned;

  /// No description provided for @closed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closed;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @no_requests_found.
  ///
  /// In en, this message translates to:
  /// **'No requests found'**
  String get no_requests_found;

  /// No description provided for @no_accepted_requests_yet.
  ///
  /// In en, this message translates to:
  /// **'No accepted requests yet'**
  String get no_accepted_requests_yet;

  /// No description provided for @tap_to_create_your_first_request.
  ///
  /// In en, this message translates to:
  /// **'Tap + to create your first request'**
  String get tap_to_create_your_first_request;

  /// No description provided for @no_requests_yet.
  ///
  /// In en, this message translates to:
  /// **'No requests yet'**
  String get no_requests_yet;

  /// No description provided for @notification_permission_alert_title.
  ///
  /// In en, this message translates to:
  /// **'Notification Permission'**
  String get notification_permission_alert_title;

  /// No description provided for @notification_permission_alert_text.
  ///
  /// In en, this message translates to:
  /// **'We need notification permission to send you updates.'**
  String get notification_permission_alert_text;

  /// No description provided for @lang.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get lang;

  /// No description provided for @you.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// No description provided for @message_deleted.
  ///
  /// In en, this message translates to:
  /// **'Message deleted'**
  String get message_deleted;

  /// No description provided for @replying_to.
  ///
  /// In en, this message translates to:
  /// **'Replying to'**
  String get replying_to;

  /// No description provided for @editing_message.
  ///
  /// In en, this message translates to:
  /// **'Editing message'**
  String get editing_message;

  /// No description provided for @type_a_message.
  ///
  /// In en, this message translates to:
  /// **'Type a message'**
  String get type_a_message;

  /// No description provided for @uploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading'**
  String get uploading;

  /// No description provided for @please_wait.
  ///
  /// In en, this message translates to:
  /// **'Please wait'**
  String get please_wait;

  /// No description provided for @open_in_map.
  ///
  /// In en, this message translates to:
  /// **'Open in maps'**
  String get open_in_map;

  /// No description provided for @open_location_in.
  ///
  /// In en, this message translates to:
  /// **'Open location in'**
  String get open_location_in;

  /// No description provided for @google_maps.
  ///
  /// In en, this message translates to:
  /// **'Google Maps'**
  String get google_maps;

  /// No description provided for @cloud_not_open_map.
  ///
  /// In en, this message translates to:
  /// **'Could not open the map application.'**
  String get cloud_not_open_map;

  /// No description provided for @loca.
  ///
  /// In en, this message translates to:
  /// **'📍 Location'**
  String get loca;

  /// No description provided for @photo.
  ///
  /// In en, this message translates to:
  /// **'📷 Photo'**
  String get photo;

  /// No description provided for @apple_maps.
  ///
  /// In en, this message translates to:
  /// **'Apple Maps'**
  String get apple_maps;

  /// No description provided for @waze.
  ///
  /// In en, this message translates to:
  /// **'Waze'**
  String get waze;

  /// No description provided for @neshan.
  ///
  /// In en, this message translates to:
  /// **'Neshan'**
  String get neshan;

  /// No description provided for @balad.
  ///
  /// In en, this message translates to:
  /// **'Balad'**
  String get balad;

  /// No description provided for @nfc_sent_success.
  ///
  /// In en, this message translates to:
  /// **'Sent! Keep phones close...'**
  String get nfc_sent_success;

  /// No description provided for @nfc_sending_title.
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get nfc_sending_title;

  /// No description provided for @nfc_sending_desc.
  ///
  /// In en, this message translates to:
  /// **'Keep your phone close to send your info'**
  String get nfc_sending_desc;

  /// No description provided for @nfc_receiving_title.
  ///
  /// In en, this message translates to:
  /// **'Receiving...'**
  String get nfc_receiving_title;

  /// No description provided for @nfc_receiving_desc.
  ///
  /// In en, this message translates to:
  /// **'Keep your phone close to receive their info'**
  String get nfc_receiving_desc;

  /// No description provided for @send_location.
  ///
  /// In en, this message translates to:
  /// **'Send Location'**
  String get send_location;

  /// No description provided for @nfc_tap_together_title.
  ///
  /// In en, this message translates to:
  /// **'Tap to connect'**
  String get nfc_tap_together_title;

  /// No description provided for @nfc_tap_together_desc.
  ///
  /// In en, this message translates to:
  /// **'Hold close to share.'**
  String get nfc_tap_together_desc;

  /// No description provided for @please_enable_gps.
  ///
  /// In en, this message translates to:
  /// **'Please enable GPS'**
  String get please_enable_gps;

  /// No description provided for @location_permission_denied.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied'**
  String get location_permission_denied;

  /// No description provided for @location_permission_permanently_denied.
  ///
  /// In en, this message translates to:
  /// **'Location permission permanently denied'**
  String get location_permission_permanently_denied;

  /// No description provided for @error_getting_location.
  ///
  /// In en, this message translates to:
  /// **'Error getting location'**
  String get error_getting_location;

  /// No description provided for @my_location.
  ///
  /// In en, this message translates to:
  /// **'My Location'**
  String get my_location;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'de',
    'en',
    'es',
    'fa',
    'fr',
    'it',
    'ru',
    'tr',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fa':
      return AppLocalizationsFa();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'ru':
      return AppLocalizationsRu();
    case 'tr':
      return AppLocalizationsTr();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
