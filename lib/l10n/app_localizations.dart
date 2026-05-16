import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
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
    Locale('en'),
    Locale('zh'),
  ];

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'PureDDCCI Control Center'**
  String get appTitle;

  /// No description provided for @unknownMonitor.
  ///
  /// In en, this message translates to:
  /// **'Unknown Monitor'**
  String get unknownMonitor;

  /// No description provided for @displayIdentification.
  ///
  /// In en, this message translates to:
  /// **'Display Identification'**
  String get displayIdentification;

  /// No description provided for @manufacturerName.
  ///
  /// In en, this message translates to:
  /// **'Manufacturer name'**
  String get manufacturerName;

  /// No description provided for @productCode.
  ///
  /// In en, this message translates to:
  /// **'Product code'**
  String get productCode;

  /// No description provided for @serialNumber.
  ///
  /// In en, this message translates to:
  /// **'Serial number'**
  String get serialNumber;

  /// No description provided for @manufactured.
  ///
  /// In en, this message translates to:
  /// **'Manufactured'**
  String get manufactured;

  /// No description provided for @edidVersion.
  ///
  /// In en, this message translates to:
  /// **'EDID version'**
  String get edidVersion;

  /// No description provided for @inputType.
  ///
  /// In en, this message translates to:
  /// **'Input type'**
  String get inputType;

  /// No description provided for @preferredTiming.
  ///
  /// In en, this message translates to:
  /// **'Preferred timing'**
  String get preferredTiming;

  /// No description provided for @extensionBlocks.
  ///
  /// In en, this message translates to:
  /// **'Extension blocks'**
  String get extensionBlocks;

  /// No description provided for @rawData.
  ///
  /// In en, this message translates to:
  /// **'Raw data'**
  String get rawData;

  /// No description provided for @ddcciSupported.
  ///
  /// In en, this message translates to:
  /// **'Supported'**
  String get ddcciSupported;

  /// No description provided for @commandInterface.
  ///
  /// In en, this message translates to:
  /// **'Command Interface'**
  String get commandInterface;

  /// No description provided for @capabilitiesString.
  ///
  /// In en, this message translates to:
  /// **'Capabilities string'**
  String get capabilitiesString;

  /// No description provided for @controlCodesSupported.
  ///
  /// In en, this message translates to:
  /// **'Control codes supported'**
  String get controlCodesSupported;

  /// No description provided for @currentTiming.
  ///
  /// In en, this message translates to:
  /// **'Current timing'**
  String get currentTiming;

  /// No description provided for @mccsCompliance.
  ///
  /// In en, this message translates to:
  /// **'MCCS compliance'**
  String get mccsCompliance;

  /// No description provided for @commandLineEditor.
  ///
  /// In en, this message translates to:
  /// **'Command-line editor'**
  String get commandLineEditor;

  /// No description provided for @displayControl.
  ///
  /// In en, this message translates to:
  /// **'Display control'**
  String get displayControl;

  /// No description provided for @horizontalFrequency.
  ///
  /// In en, this message translates to:
  /// **'Horizontal frequency'**
  String get horizontalFrequency;

  /// No description provided for @verticalFrequency.
  ///
  /// In en, this message translates to:
  /// **'Vertical frequency'**
  String get verticalFrequency;

  /// No description provided for @displayUsageTime.
  ///
  /// In en, this message translates to:
  /// **'Display usage time'**
  String get displayUsageTime;

  /// No description provided for @displayControllerType.
  ///
  /// In en, this message translates to:
  /// **'Display controller type'**
  String get displayControllerType;

  /// No description provided for @displayFirmwareLevel.
  ///
  /// In en, this message translates to:
  /// **'Display firmware level'**
  String get displayFirmwareLevel;

  /// No description provided for @osdButtonControl.
  ///
  /// In en, this message translates to:
  /// **'OSD/Button control'**
  String get osdButtonControl;

  /// No description provided for @osdLanguage.
  ///
  /// In en, this message translates to:
  /// **'OSD language'**
  String get osdLanguage;

  /// No description provided for @powerMode.
  ///
  /// In en, this message translates to:
  /// **'Power mode'**
  String get powerMode;

  /// No description provided for @vcpVersion.
  ///
  /// In en, this message translates to:
  /// **'VCP version'**
  String get vcpVersion;

  /// No description provided for @presetOperations.
  ///
  /// In en, this message translates to:
  /// **'Preset operations'**
  String get presetOperations;

  /// No description provided for @restoreFactoryDefaults.
  ///
  /// In en, this message translates to:
  /// **'Restore factory defaults'**
  String get restoreFactoryDefaults;

  /// No description provided for @restoreFactoryLuminanceContrast.
  ///
  /// In en, this message translates to:
  /// **'Restore factory luminance/contrast defaults'**
  String get restoreFactoryLuminanceContrast;

  /// No description provided for @restoreFactoryGeometry.
  ///
  /// In en, this message translates to:
  /// **'Restore factory geometry defaults'**
  String get restoreFactoryGeometry;

  /// No description provided for @restoreFactoryColor.
  ///
  /// In en, this message translates to:
  /// **'Restore factory color defaults'**
  String get restoreFactoryColor;

  /// No description provided for @restoreFactoryTV.
  ///
  /// In en, this message translates to:
  /// **'Restore factory TV defaults'**
  String get restoreFactoryTV;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @geometry.
  ///
  /// In en, this message translates to:
  /// **'Geometry'**
  String get geometry;

  /// No description provided for @imageAdjustment.
  ///
  /// In en, this message translates to:
  /// **'Image adjustment'**
  String get imageAdjustment;

  /// No description provided for @audioFunctions.
  ///
  /// In en, this message translates to:
  /// **'Audio functions'**
  String get audioFunctions;

  /// No description provided for @dpvlFunctions.
  ///
  /// In en, this message translates to:
  /// **'DPVL functions'**
  String get dpvlFunctions;

  /// No description provided for @miscellaneousFunctions.
  ///
  /// In en, this message translates to:
  /// **'Miscellaneous functions'**
  String get miscellaneousFunctions;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'hours'**
  String get hours;

  /// No description provided for @osdDisabled.
  ///
  /// In en, this message translates to:
  /// **'OSD Disabled'**
  String get osdDisabled;

  /// No description provided for @osdEnabled.
  ///
  /// In en, this message translates to:
  /// **'OSD Enabled'**
  String get osdEnabled;

  /// No description provided for @cannotSupplyInfo.
  ///
  /// In en, this message translates to:
  /// **'Display cannot supply this information'**
  String get cannotSupplyInfo;

  /// No description provided for @storeCurrentSettings.
  ///
  /// In en, this message translates to:
  /// **'Store current settings'**
  String get storeCurrentSettings;

  /// No description provided for @horizontalPosition.
  ///
  /// In en, this message translates to:
  /// **'Horizontal position (phase)'**
  String get horizontalPosition;

  /// No description provided for @horizontalSize.
  ///
  /// In en, this message translates to:
  /// **'Horizontal size'**
  String get horizontalSize;

  /// No description provided for @horizontalPincushion.
  ///
  /// In en, this message translates to:
  /// **'Horizontal pincushion'**
  String get horizontalPincushion;

  /// No description provided for @horizontalPincushionBalance.
  ///
  /// In en, this message translates to:
  /// **'Horizontal pincushion balance'**
  String get horizontalPincushionBalance;

  /// No description provided for @horizontalConvergenceRB.
  ///
  /// In en, this message translates to:
  /// **'Horizontal convergence R/B'**
  String get horizontalConvergenceRB;

  /// No description provided for @horizontalConvergenceMG.
  ///
  /// In en, this message translates to:
  /// **'Horizontal convergence M/G'**
  String get horizontalConvergenceMG;

  /// No description provided for @horizontalLinearity.
  ///
  /// In en, this message translates to:
  /// **'Horizontal linearity'**
  String get horizontalLinearity;

  /// No description provided for @horizontalLinearityBalance.
  ///
  /// In en, this message translates to:
  /// **'Horizontal linearity balance'**
  String get horizontalLinearityBalance;

  /// No description provided for @verticalPosition.
  ///
  /// In en, this message translates to:
  /// **'Vertical position (phase)'**
  String get verticalPosition;

  /// No description provided for @verticalSize.
  ///
  /// In en, this message translates to:
  /// **'Vertical size'**
  String get verticalSize;

  /// No description provided for @verticalPincushion.
  ///
  /// In en, this message translates to:
  /// **'Vertical pincushion'**
  String get verticalPincushion;

  /// No description provided for @verticalPincushionBalance.
  ///
  /// In en, this message translates to:
  /// **'Vertical pincushion balance'**
  String get verticalPincushionBalance;

  /// No description provided for @verticalConvergenceRB.
  ///
  /// In en, this message translates to:
  /// **'Vertical convergence R/B'**
  String get verticalConvergenceRB;

  /// No description provided for @verticalConvergenceMG.
  ///
  /// In en, this message translates to:
  /// **'Vertical convergence M/G'**
  String get verticalConvergenceMG;

  /// No description provided for @verticalLinearity.
  ///
  /// In en, this message translates to:
  /// **'Vertical linearity'**
  String get verticalLinearity;

  /// No description provided for @verticalLinearityBalance.
  ///
  /// In en, this message translates to:
  /// **'Vertical linearity balance'**
  String get verticalLinearityBalance;

  /// No description provided for @horizontalParallelogram.
  ///
  /// In en, this message translates to:
  /// **'Horizontal parallelogram'**
  String get horizontalParallelogram;

  /// No description provided for @verticalParallelogram.
  ///
  /// In en, this message translates to:
  /// **'Vertical parallelogram'**
  String get verticalParallelogram;

  /// No description provided for @horizontalKeystone.
  ///
  /// In en, this message translates to:
  /// **'Horizontal keystone'**
  String get horizontalKeystone;

  /// No description provided for @verticalKeystone.
  ///
  /// In en, this message translates to:
  /// **'Vertical keystone'**
  String get verticalKeystone;

  /// No description provided for @rotation.
  ///
  /// In en, this message translates to:
  /// **'Rotation'**
  String get rotation;

  /// No description provided for @topCornerFlare.
  ///
  /// In en, this message translates to:
  /// **'Top corner flare'**
  String get topCornerFlare;

  /// No description provided for @topCornerHook.
  ///
  /// In en, this message translates to:
  /// **'Top corner hook'**
  String get topCornerHook;

  /// No description provided for @bottomCornerFlare.
  ///
  /// In en, this message translates to:
  /// **'Bottom corner flare'**
  String get bottomCornerFlare;

  /// No description provided for @bottomCornerHook.
  ///
  /// In en, this message translates to:
  /// **'Bottom corner hook'**
  String get bottomCornerHook;

  /// No description provided for @adjustFocalPlane.
  ///
  /// In en, this message translates to:
  /// **'Adjust focal plane'**
  String get adjustFocalPlane;

  /// No description provided for @adjustZoom.
  ///
  /// In en, this message translates to:
  /// **'Adjust zoom'**
  String get adjustZoom;

  /// No description provided for @trapezoid.
  ///
  /// In en, this message translates to:
  /// **'Trapezoid'**
  String get trapezoid;

  /// No description provided for @keystone.
  ///
  /// In en, this message translates to:
  /// **'Keystone'**
  String get keystone;

  /// No description provided for @horizontalMirror.
  ///
  /// In en, this message translates to:
  /// **'Horizontal mirror (flip)'**
  String get horizontalMirror;

  /// No description provided for @verticalMirror.
  ///
  /// In en, this message translates to:
  /// **'Vertical mirror (flip)'**
  String get verticalMirror;

  /// No description provided for @displayScaling.
  ///
  /// In en, this message translates to:
  /// **'Display scaling'**
  String get displayScaling;

  /// No description provided for @windowPositionTLX.
  ///
  /// In en, this message translates to:
  /// **'Window position (TL_X)'**
  String get windowPositionTLX;

  /// No description provided for @windowPositionTLY.
  ///
  /// In en, this message translates to:
  /// **'Window position (TL_Y)'**
  String get windowPositionTLY;

  /// No description provided for @windowPositionBRX.
  ///
  /// In en, this message translates to:
  /// **'Window position (BR_X)'**
  String get windowPositionBRX;

  /// No description provided for @windowPositionBRY.
  ///
  /// In en, this message translates to:
  /// **'Window position (BR_Y)'**
  String get windowPositionBRY;

  /// No description provided for @windowControlOnOff.
  ///
  /// In en, this message translates to:
  /// **'Window control on/off'**
  String get windowControlOnOff;

  /// No description provided for @windowControlValue.
  ///
  /// In en, this message translates to:
  /// **'Window control value'**
  String get windowControlValue;

  /// No description provided for @scanMode.
  ///
  /// In en, this message translates to:
  /// **'Scan mode (TV)'**
  String get scanMode;

  /// No description provided for @normalMode.
  ///
  /// In en, this message translates to:
  /// **'Normal mode'**
  String get normalMode;

  /// No description provided for @mirroredHorizontally.
  ///
  /// In en, this message translates to:
  /// **'Mirrored horizontally mode'**
  String get mirroredHorizontally;

  /// No description provided for @mirroredVertically.
  ///
  /// In en, this message translates to:
  /// **'Mirrored vertically mode'**
  String get mirroredVertically;

  /// No description provided for @noScaling.
  ///
  /// In en, this message translates to:
  /// **'No scaling'**
  String get noScaling;

  /// No description provided for @maxImageNoDistortion.
  ///
  /// In en, this message translates to:
  /// **'Max image, no aspect ratio distortion'**
  String get maxImageNoDistortion;

  /// No description provided for @maxVerticalNoDistortion.
  ///
  /// In en, this message translates to:
  /// **'Max vertical image, no aspect ratio distortion'**
  String get maxVerticalNoDistortion;

  /// No description provided for @maxHorizontalNoDistortion.
  ///
  /// In en, this message translates to:
  /// **'Max horizontal image, no aspect ratio distortion'**
  String get maxHorizontalNoDistortion;

  /// No description provided for @maxVerticalWithDistortion.
  ///
  /// In en, this message translates to:
  /// **'Max vertical image with aspect ratio distortion'**
  String get maxVerticalWithDistortion;

  /// No description provided for @maxHorizontalWithDistortion.
  ///
  /// In en, this message translates to:
  /// **'Max horizontal image with aspect ratio distortion'**
  String get maxHorizontalWithDistortion;

  /// No description provided for @linearExpansionH.
  ///
  /// In en, this message translates to:
  /// **'Linear expansion (compression) on horizontal axis'**
  String get linearExpansionH;

  /// No description provided for @linearExpansionHV.
  ///
  /// In en, this message translates to:
  /// **'Linear expansion (compression) on h and v axes'**
  String get linearExpansionHV;

  /// No description provided for @squeezeMode.
  ///
  /// In en, this message translates to:
  /// **'Squeeze mode'**
  String get squeezeMode;

  /// No description provided for @nonLinearExpansion.
  ///
  /// In en, this message translates to:
  /// **'Non-linear expansion'**
  String get nonLinearExpansion;

  /// No description provided for @noEffect.
  ///
  /// In en, this message translates to:
  /// **'No effect'**
  String get noEffect;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get off;

  /// No description provided for @on.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get on;

  /// No description provided for @normalOperation.
  ///
  /// In en, this message translates to:
  /// **'Normal operation'**
  String get normalOperation;

  /// No description provided for @underscan.
  ///
  /// In en, this message translates to:
  /// **'Underscan'**
  String get underscan;

  /// No description provided for @overscan.
  ///
  /// In en, this message translates to:
  /// **'Overscan'**
  String get overscan;

  /// No description provided for @widescreen.
  ///
  /// In en, this message translates to:
  /// **'Widescreen'**
  String get widescreen;

  /// No description provided for @colorTemperatureIncrement.
  ///
  /// In en, this message translates to:
  /// **'Color temperature increment'**
  String get colorTemperatureIncrement;

  /// No description provided for @colorTemperatureRequest.
  ///
  /// In en, this message translates to:
  /// **'Color temperature request'**
  String get colorTemperatureRequest;

  /// No description provided for @clock.
  ///
  /// In en, this message translates to:
  /// **'Clock'**
  String get clock;

  /// No description provided for @luminance.
  ///
  /// In en, this message translates to:
  /// **'Luminance'**
  String get luminance;

  /// No description provided for @fleshToneEnhancement.
  ///
  /// In en, this message translates to:
  /// **'Flesh tone enhancement'**
  String get fleshToneEnhancement;

  /// No description provided for @contrast.
  ///
  /// In en, this message translates to:
  /// **'Contrast'**
  String get contrast;

  /// No description provided for @backlightControl.
  ///
  /// In en, this message translates to:
  /// **'Backlight control'**
  String get backlightControl;

  /// No description provided for @selectColorPreset.
  ///
  /// In en, this message translates to:
  /// **'Select color preset'**
  String get selectColorPreset;

  /// No description provided for @redVideoGain.
  ///
  /// In en, this message translates to:
  /// **'Red video gain'**
  String get redVideoGain;

  /// No description provided for @userColorCompensation.
  ///
  /// In en, this message translates to:
  /// **'User color compensation'**
  String get userColorCompensation;

  /// No description provided for @greenVideoGain.
  ///
  /// In en, this message translates to:
  /// **'Green video gain'**
  String get greenVideoGain;

  /// No description provided for @blueVideoGain.
  ///
  /// In en, this message translates to:
  /// **'Blue video gain'**
  String get blueVideoGain;

  /// No description provided for @focus.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get focus;

  /// No description provided for @autoSetup.
  ///
  /// In en, this message translates to:
  /// **'Auto setup'**
  String get autoSetup;

  /// No description provided for @autoColorSetup.
  ///
  /// In en, this message translates to:
  /// **'Auto color setup'**
  String get autoColorSetup;

  /// No description provided for @grayScaleExpansion.
  ///
  /// In en, this message translates to:
  /// **'Gray scale expansion'**
  String get grayScaleExpansion;

  /// No description provided for @clockPhase.
  ///
  /// In en, this message translates to:
  /// **'Clock phase'**
  String get clockPhase;

  /// No description provided for @horizontalMoire.
  ///
  /// In en, this message translates to:
  /// **'Horizontal moire'**
  String get horizontalMoire;

  /// No description provided for @verticalMoire.
  ///
  /// In en, this message translates to:
  /// **'Vertical moire'**
  String get verticalMoire;

  /// No description provided for @sixAxisSaturationRed.
  ///
  /// In en, this message translates to:
  /// **'6 axis saturation: Red'**
  String get sixAxisSaturationRed;

  /// No description provided for @sixAxisSaturationYellow.
  ///
  /// In en, this message translates to:
  /// **'6 axis saturation: Yellow'**
  String get sixAxisSaturationYellow;

  /// No description provided for @sixAxisSaturationGreen.
  ///
  /// In en, this message translates to:
  /// **'6 axis saturation: Green'**
  String get sixAxisSaturationGreen;

  /// No description provided for @sixAxisSaturationCyan.
  ///
  /// In en, this message translates to:
  /// **'6 axis saturation: Cyan'**
  String get sixAxisSaturationCyan;

  /// No description provided for @sixAxisSaturationBlue.
  ///
  /// In en, this message translates to:
  /// **'6 axis saturation: Blue'**
  String get sixAxisSaturationBlue;

  /// No description provided for @sixAxisSaturationMagenta.
  ///
  /// In en, this message translates to:
  /// **'6 axis saturation: Magenta'**
  String get sixAxisSaturationMagenta;

  /// No description provided for @backlightLevelWhite.
  ///
  /// In en, this message translates to:
  /// **'Backlight level: White'**
  String get backlightLevelWhite;

  /// No description provided for @videoBlackLevelRed.
  ///
  /// In en, this message translates to:
  /// **'Video black level: Red'**
  String get videoBlackLevelRed;

  /// No description provided for @backlightLevelRed.
  ///
  /// In en, this message translates to:
  /// **'Backlight level: Red'**
  String get backlightLevelRed;

  /// No description provided for @videoBlackLevelGreen.
  ///
  /// In en, this message translates to:
  /// **'Video black level: Green'**
  String get videoBlackLevelGreen;

  /// No description provided for @backlightLevelGreen.
  ///
  /// In en, this message translates to:
  /// **'Backlight level: Green'**
  String get backlightLevelGreen;

  /// No description provided for @videoBlackLevelBlue.
  ///
  /// In en, this message translates to:
  /// **'Video black level: Blue'**
  String get videoBlackLevelBlue;

  /// No description provided for @backlightLevelBlue.
  ///
  /// In en, this message translates to:
  /// **'Backlight level: Blue'**
  String get backlightLevelBlue;

  /// No description provided for @gamma.
  ///
  /// In en, this message translates to:
  /// **'Gamma'**
  String get gamma;

  /// No description provided for @lutSize.
  ///
  /// In en, this message translates to:
  /// **'LUT size'**
  String get lutSize;

  /// No description provided for @singlePointLutOperation.
  ///
  /// In en, this message translates to:
  /// **'Single point LUT operation'**
  String get singlePointLutOperation;

  /// No description provided for @blockLutOperation.
  ///
  /// In en, this message translates to:
  /// **'Block LUT operation'**
  String get blockLutOperation;

  /// No description provided for @whiteLedBacklightControl.
  ///
  /// In en, this message translates to:
  /// **'White LED backlight control'**
  String get whiteLedBacklightControl;

  /// No description provided for @redLedBacklightControl.
  ///
  /// In en, this message translates to:
  /// **'Red LED backlight control'**
  String get redLedBacklightControl;

  /// No description provided for @greenLedBacklightControl.
  ///
  /// In en, this message translates to:
  /// **'Green LED backlight control'**
  String get greenLedBacklightControl;

  /// No description provided for @blueLedBacklightControl.
  ///
  /// In en, this message translates to:
  /// **'Blue LED backlight control'**
  String get blueLedBacklightControl;

  /// No description provided for @sharpness.
  ///
  /// In en, this message translates to:
  /// **'Sharpness'**
  String get sharpness;

  /// No description provided for @velocityScanModulation.
  ///
  /// In en, this message translates to:
  /// **'Velocity scan modulation'**
  String get velocityScanModulation;

  /// No description provided for @tvSaturation.
  ///
  /// In en, this message translates to:
  /// **'TV saturation'**
  String get tvSaturation;

  /// No description provided for @tvContrast.
  ///
  /// In en, this message translates to:
  /// **'TV contrast'**
  String get tvContrast;

  /// No description provided for @hue.
  ///
  /// In en, this message translates to:
  /// **'Hue'**
  String get hue;

  /// No description provided for @tvBlackLevelLuminance.
  ///
  /// In en, this message translates to:
  /// **'TV black level luminance'**
  String get tvBlackLevelLuminance;

  /// No description provided for @windowBackground.
  ///
  /// In en, this message translates to:
  /// **'Window background'**
  String get windowBackground;

  /// No description provided for @sixAxisHueRed.
  ///
  /// In en, this message translates to:
  /// **'6 axis hue control: Red'**
  String get sixAxisHueRed;

  /// No description provided for @sixAxisHueYellow.
  ///
  /// In en, this message translates to:
  /// **'6 axis hue control: Yellow'**
  String get sixAxisHueYellow;

  /// No description provided for @sixAxisHueGreen.
  ///
  /// In en, this message translates to:
  /// **'6 axis hue control: Green'**
  String get sixAxisHueGreen;

  /// No description provided for @sixAxisHueCyan.
  ///
  /// In en, this message translates to:
  /// **'6 axis hue control: Cyan'**
  String get sixAxisHueCyan;

  /// No description provided for @sixAxisHueBlue.
  ///
  /// In en, this message translates to:
  /// **'6 axis hue control: Blue'**
  String get sixAxisHueBlue;

  /// No description provided for @sixAxisHueMagenta.
  ///
  /// In en, this message translates to:
  /// **'6 axis hue control: Magenta'**
  String get sixAxisHueMagenta;

  /// No description provided for @autoSetupOnOff.
  ///
  /// In en, this message translates to:
  /// **'Auto setup on/off'**
  String get autoSetupOnOff;

  /// No description provided for @changeSelectedWindow.
  ///
  /// In en, this message translates to:
  /// **'Change the selected window'**
  String get changeSelectedWindow;

  /// No description provided for @screenOrientation.
  ///
  /// In en, this message translates to:
  /// **'Screen orientation'**
  String get screenOrientation;

  /// No description provided for @stereoVideoMode.
  ///
  /// In en, this message translates to:
  /// **'Stereo video mode'**
  String get stereoVideoMode;

  /// No description provided for @displayMode.
  ///
  /// In en, this message translates to:
  /// **'Display mode'**
  String get displayMode;

  /// No description provided for @speakerVolume.
  ///
  /// In en, this message translates to:
  /// **'Speaker volume'**
  String get speakerVolume;

  /// No description provided for @speakerSelect.
  ///
  /// In en, this message translates to:
  /// **'Speaker select'**
  String get speakerSelect;

  /// No description provided for @microphoneVolume.
  ///
  /// In en, this message translates to:
  /// **'Microphone volume'**
  String get microphoneVolume;

  /// No description provided for @tvSharpness.
  ///
  /// In en, this message translates to:
  /// **'TV sharpness'**
  String get tvSharpness;

  /// No description provided for @audioMute.
  ///
  /// In en, this message translates to:
  /// **'Audio mute'**
  String get audioMute;

  /// No description provided for @treble.
  ///
  /// In en, this message translates to:
  /// **'Treble'**
  String get treble;

  /// No description provided for @bass.
  ///
  /// In en, this message translates to:
  /// **'Bass'**
  String get bass;

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

  /// No description provided for @audioProcessorMode.
  ///
  /// In en, this message translates to:
  /// **'Audio processor mode'**
  String get audioProcessorMode;

  /// No description provided for @monitorStatus.
  ///
  /// In en, this message translates to:
  /// **'Monitor status'**
  String get monitorStatus;

  /// No description provided for @packetCount.
  ///
  /// In en, this message translates to:
  /// **'Packet count'**
  String get packetCount;

  /// No description provided for @monitorXOrigin.
  ///
  /// In en, this message translates to:
  /// **'Monitor x origin'**
  String get monitorXOrigin;

  /// No description provided for @monitorYOrigin.
  ///
  /// In en, this message translates to:
  /// **'Monitor y origin'**
  String get monitorYOrigin;

  /// No description provided for @headerErrorCount.
  ///
  /// In en, this message translates to:
  /// **'Header error count'**
  String get headerErrorCount;

  /// No description provided for @bodyCrcErrorCount.
  ///
  /// In en, this message translates to:
  /// **'Body CRC error count'**
  String get bodyCrcErrorCount;

  /// No description provided for @clientId.
  ///
  /// In en, this message translates to:
  /// **'Client ID'**
  String get clientId;

  /// No description provided for @linkControl.
  ///
  /// In en, this message translates to:
  /// **'Link control'**
  String get linkControl;

  /// No description provided for @degauss.
  ///
  /// In en, this message translates to:
  /// **'Degauss'**
  String get degauss;

  /// No description provided for @newControlValue.
  ///
  /// In en, this message translates to:
  /// **'New control value'**
  String get newControlValue;

  /// No description provided for @softControls.
  ///
  /// In en, this message translates to:
  /// **'Soft controls'**
  String get softControls;

  /// No description provided for @activeControl.
  ///
  /// In en, this message translates to:
  /// **'Active control'**
  String get activeControl;

  /// No description provided for @performancePreservation.
  ///
  /// In en, this message translates to:
  /// **'Performance preservation'**
  String get performancePreservation;

  /// No description provided for @inputSource.
  ///
  /// In en, this message translates to:
  /// **'Input source'**
  String get inputSource;

  /// No description provided for @ambientLightSensor.
  ///
  /// In en, this message translates to:
  /// **'Ambient light sensor'**
  String get ambientLightSensor;

  /// No description provided for @remoteProcedureCall.
  ///
  /// In en, this message translates to:
  /// **'Remote procedure call'**
  String get remoteProcedureCall;

  /// No description provided for @displayIdentificationOperation.
  ///
  /// In en, this message translates to:
  /// **'Display identification operation'**
  String get displayIdentificationOperation;

  /// No description provided for @tvChannelUpDown.
  ///
  /// In en, this message translates to:
  /// **'TV channel up/down'**
  String get tvChannelUpDown;

  /// No description provided for @flatPanelSubPixelLayout.
  ///
  /// In en, this message translates to:
  /// **'Flat panel sub-pixel layout'**
  String get flatPanelSubPixelLayout;

  /// No description provided for @sourceTimingMode.
  ///
  /// In en, this message translates to:
  /// **'Source timing mode'**
  String get sourceTimingMode;

  /// No description provided for @displayTechnologyType.
  ///
  /// In en, this message translates to:
  /// **'Display technology type'**
  String get displayTechnologyType;

  /// No description provided for @displayDescriptorLength.
  ///
  /// In en, this message translates to:
  /// **'Display descriptor length'**
  String get displayDescriptorLength;

  /// No description provided for @displayDescriptorToTransmit.
  ///
  /// In en, this message translates to:
  /// **'Display descriptor to transmit'**
  String get displayDescriptorToTransmit;

  /// No description provided for @enableDisplayOfDescriptor.
  ///
  /// In en, this message translates to:
  /// **'Enable display of display descriptor'**
  String get enableDisplayOfDescriptor;

  /// No description provided for @applicationEnableKey.
  ///
  /// In en, this message translates to:
  /// **'Application enable key'**
  String get applicationEnableKey;

  /// No description provided for @statusIndicators.
  ///
  /// In en, this message translates to:
  /// **'Status indicators'**
  String get statusIndicators;

  /// No description provided for @auxiliaryDisplaySize.
  ///
  /// In en, this message translates to:
  /// **'Auxiliary display size'**
  String get auxiliaryDisplaySize;

  /// No description provided for @auxiliaryDisplayData.
  ///
  /// In en, this message translates to:
  /// **'Auxiliary display data'**
  String get auxiliaryDisplayData;

  /// No description provided for @outputSelect.
  ///
  /// In en, this message translates to:
  /// **'Output select'**
  String get outputSelect;

  /// No description provided for @assetTag.
  ///
  /// In en, this message translates to:
  /// **'Asset tag'**
  String get assetTag;

  /// No description provided for @auxiliaryPowerOutput.
  ///
  /// In en, this message translates to:
  /// **'Auxiliary power output'**
  String get auxiliaryPowerOutput;

  /// No description provided for @imageMode.
  ///
  /// In en, this message translates to:
  /// **'Image mode'**
  String get imageMode;

  /// No description provided for @scratchPad.
  ///
  /// In en, this message translates to:
  /// **'Scratch pad'**
  String get scratchPad;

  /// No description provided for @disabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabled;

  /// No description provided for @enabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get enabled;

  /// No description provided for @mute.
  ///
  /// In en, this message translates to:
  /// **'Mute'**
  String get mute;

  /// No description provided for @unmute.
  ///
  /// In en, this message translates to:
  /// **'Unmute'**
  String get unmute;

  /// No description provided for @activate.
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get activate;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @increment.
  ///
  /// In en, this message translates to:
  /// **'Increment'**
  String get increment;

  /// No description provided for @decrement.
  ///
  /// In en, this message translates to:
  /// **'Decrement'**
  String get decrement;

  /// No description provided for @readEdidBlock.
  ///
  /// In en, this message translates to:
  /// **'Read EDID block'**
  String get readEdidBlock;

  /// No description provided for @displayNative.
  ///
  /// In en, this message translates to:
  /// **'Display native'**
  String get displayNative;

  /// No description provided for @offNoEnhancement.
  ///
  /// In en, this message translates to:
  /// **'Off - no enhancement'**
  String get offNoEnhancement;

  /// No description provided for @enhancement1.
  ///
  /// In en, this message translates to:
  /// **'Enhancement 1 - not including skin tone'**
  String get enhancement1;

  /// No description provided for @enhancement2.
  ///
  /// In en, this message translates to:
  /// **'Enhancement 2 - including skin tone'**
  String get enhancement2;

  /// No description provided for @demoMode.
  ///
  /// In en, this message translates to:
  /// **'Demo mode'**
  String get demoMode;

  /// No description provided for @userMode.
  ///
  /// In en, this message translates to:
  /// **'User mode'**
  String get userMode;

  /// No description provided for @noWhiteExpansion.
  ///
  /// In en, this message translates to:
  /// **'No white region expansion'**
  String get noWhiteExpansion;

  /// No description provided for @firstLevelExpansion.
  ///
  /// In en, this message translates to:
  /// **'First level of expansion'**
  String get firstLevelExpansion;

  /// No description provided for @secondLevelExpansion.
  ///
  /// In en, this message translates to:
  /// **'Second level of expansion'**
  String get secondLevelExpansion;

  /// No description provided for @thirdLevelExpansion.
  ///
  /// In en, this message translates to:
  /// **'Third level of expansion'**
  String get thirdLevelExpansion;

  /// No description provided for @periodic.
  ///
  /// In en, this message translates to:
  /// **'Periodic'**
  String get periodic;

  /// No description provided for @noDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noDataAvailable;

  /// No description provided for @unavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get unavailable;

  /// No description provided for @fullMode.
  ///
  /// In en, this message translates to:
  /// **'Full mode'**
  String get fullMode;

  /// No description provided for @zoomMode.
  ///
  /// In en, this message translates to:
  /// **'Zoom mode'**
  String get zoomMode;

  /// No description provided for @variable.
  ///
  /// In en, this message translates to:
  /// **'Variable'**
  String get variable;

  /// No description provided for @standardDefaultMode.
  ///
  /// In en, this message translates to:
  /// **'Standard/Default mode'**
  String get standardDefaultMode;

  /// No description provided for @productivity.
  ///
  /// In en, this message translates to:
  /// **'Productivity'**
  String get productivity;

  /// No description provided for @mixed.
  ///
  /// In en, this message translates to:
  /// **'Mixed'**
  String get mixed;

  /// No description provided for @movie.
  ///
  /// In en, this message translates to:
  /// **'Movie'**
  String get movie;

  /// No description provided for @userDefined.
  ///
  /// In en, this message translates to:
  /// **'User defined'**
  String get userDefined;

  /// No description provided for @games.
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get games;

  /// No description provided for @sports.
  ///
  /// In en, this message translates to:
  /// **'Sports'**
  String get sports;

  /// No description provided for @professionalMode.
  ///
  /// In en, this message translates to:
  /// **'Professional (all signal processing disabled)'**
  String get professionalMode;

  /// No description provided for @standardIntermediatePower.
  ///
  /// In en, this message translates to:
  /// **'Standard/Default mode with intermediate power consumption'**
  String get standardIntermediatePower;

  /// No description provided for @standardLowPower.
  ///
  /// In en, this message translates to:
  /// **'Standard/Default mode with low power consumption'**
  String get standardLowPower;

  /// No description provided for @demonstration.
  ///
  /// In en, this message translates to:
  /// **'Demonstration'**
  String get demonstration;

  /// No description provided for @dynamicContrast.
  ///
  /// In en, this message translates to:
  /// **'Dynamic contrast'**
  String get dynamicContrast;

  /// No description provided for @notDefinedManufacturer.
  ///
  /// In en, this message translates to:
  /// **'Not defined - manufacturer designed controller'**
  String get notDefinedManufacturer;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @whiteAbsolute.
  ///
  /// In en, this message translates to:
  /// **'White absolute'**
  String get whiteAbsolute;

  /// No description provided for @redAbsolute.
  ///
  /// In en, this message translates to:
  /// **'Red absolute'**
  String get redAbsolute;

  /// No description provided for @greenAbsolute.
  ///
  /// In en, this message translates to:
  /// **'Green absolute'**
  String get greenAbsolute;

  /// No description provided for @blueAbsolute.
  ///
  /// In en, this message translates to:
  /// **'Blue absolute'**
  String get blueAbsolute;

  /// No description provided for @whiteRelative.
  ///
  /// In en, this message translates to:
  /// **'White relative'**
  String get whiteRelative;

  /// No description provided for @fullDisplayImageArea.
  ///
  /// In en, this message translates to:
  /// **'Full display image area selected except active windows'**
  String get fullDisplayImageArea;

  /// No description provided for @window1Selected.
  ///
  /// In en, this message translates to:
  /// **'Window 1 selected'**
  String get window1Selected;

  /// No description provided for @window2Selected.
  ///
  /// In en, this message translates to:
  /// **'Window 2 selected'**
  String get window2Selected;

  /// No description provided for @window3Selected.
  ///
  /// In en, this message translates to:
  /// **'Window 3 selected'**
  String get window3Selected;

  /// No description provided for @window4Selected.
  ///
  /// In en, this message translates to:
  /// **'Window 4 selected'**
  String get window4Selected;

  /// No description provided for @window5Selected.
  ///
  /// In en, this message translates to:
  /// **'Window 5 selected'**
  String get window5Selected;

  /// No description provided for @window6Selected.
  ///
  /// In en, this message translates to:
  /// **'Window 6 selected'**
  String get window6Selected;

  /// No description provided for @window7Selected.
  ///
  /// In en, this message translates to:
  /// **'Window 7 selected'**
  String get window7Selected;

  /// No description provided for @degrees0.
  ///
  /// In en, this message translates to:
  /// **'0 degrees'**
  String get degrees0;

  /// No description provided for @degrees90.
  ///
  /// In en, this message translates to:
  /// **'90 degrees'**
  String get degrees90;

  /// No description provided for @degrees180.
  ///
  /// In en, this message translates to:
  /// **'180 degrees'**
  String get degrees180;

  /// No description provided for @degrees270.
  ///
  /// In en, this message translates to:
  /// **'270 degrees'**
  String get degrees270;

  /// No description provided for @cannotSupplyOrientation.
  ///
  /// In en, this message translates to:
  /// **'Display cannot supply orientation'**
  String get cannotSupplyOrientation;

  /// No description provided for @speakerOffAudioNotSupported.
  ///
  /// In en, this message translates to:
  /// **'Speaker off/Audio not supported'**
  String get speakerOffAudioNotSupported;

  /// No description provided for @stereoExpanded.
  ///
  /// In en, this message translates to:
  /// **'Stereo expanded'**
  String get stereoExpanded;

  /// No description provided for @disableAuxiliaryPower.
  ///
  /// In en, this message translates to:
  /// **'Disable auxiliary power'**
  String get disableAuxiliaryPower;

  /// No description provided for @enableAuxiliaryPowerContinuous.
  ///
  /// In en, this message translates to:
  /// **'Enable auxiliary power - continuous'**
  String get enableAuxiliaryPowerContinuous;

  /// No description provided for @enableAuxiliaryPowerDisplayActive.
  ///
  /// In en, this message translates to:
  /// **'Enable auxiliary power - display active only'**
  String get enableAuxiliaryPowerDisplayActive;

  /// No description provided for @writeOnlyTurnOffDisplay.
  ///
  /// In en, this message translates to:
  /// **'Write only value to turn off display'**
  String get writeOnlyTurnOffDisplay;

  /// No description provided for @subPixelNotDefined.
  ///
  /// In en, this message translates to:
  /// **'Sub-pixel layout not defined'**
  String get subPixelNotDefined;

  /// No description provided for @rgbVerticalStripe.
  ///
  /// In en, this message translates to:
  /// **'Red/Green/Blue vertical stripe'**
  String get rgbVerticalStripe;

  /// No description provided for @rgbHorizontalStripe.
  ///
  /// In en, this message translates to:
  /// **'Red/Green/Blue horizontal stripe'**
  String get rgbHorizontalStripe;

  /// No description provided for @bgrVerticalStripe.
  ///
  /// In en, this message translates to:
  /// **'Blue/Green/Red vertical stripe'**
  String get bgrVerticalStripe;

  /// No description provided for @bgrHorizontalStripe.
  ///
  /// In en, this message translates to:
  /// **'Blue/Green/Red horizontal stripe'**
  String get bgrHorizontalStripe;

  /// No description provided for @quadPixelRedTopLeft.
  ///
  /// In en, this message translates to:
  /// **'Quad pixel, red at top left'**
  String get quadPixelRedTopLeft;

  /// No description provided for @quadPixelRedBottomLeft.
  ///
  /// In en, this message translates to:
  /// **'Quad pixel, red at bottom left'**
  String get quadPixelRedBottomLeft;

  /// No description provided for @deltaTriad.
  ///
  /// In en, this message translates to:
  /// **'Delta (triad)'**
  String get deltaTriad;

  /// No description provided for @mosaic.
  ///
  /// In en, this message translates to:
  /// **'Mosaic'**
  String get mosaic;

  /// No description provided for @crtShadowMask.
  ///
  /// In en, this message translates to:
  /// **'CRT (shadow mask)'**
  String get crtShadowMask;

  /// No description provided for @crtApertureGrill.
  ///
  /// In en, this message translates to:
  /// **'CRT (aperture grill)'**
  String get crtApertureGrill;

  /// No description provided for @lcdActiveMatrix.
  ///
  /// In en, this message translates to:
  /// **'LCD (active matrix)'**
  String get lcdActiveMatrix;

  /// No description provided for @lcos.
  ///
  /// In en, this message translates to:
  /// **'LCos'**
  String get lcos;

  /// No description provided for @plasma.
  ///
  /// In en, this message translates to:
  /// **'Plasma'**
  String get plasma;

  /// No description provided for @oled.
  ///
  /// In en, this message translates to:
  /// **'OLED'**
  String get oled;

  /// No description provided for @el.
  ///
  /// In en, this message translates to:
  /// **'EL'**
  String get el;

  /// No description provided for @mem.
  ///
  /// In en, this message translates to:
  /// **'MEM'**
  String get mem;

  /// No description provided for @mono.
  ///
  /// In en, this message translates to:
  /// **'Mono'**
  String get mono;

  /// No description provided for @stereo.
  ///
  /// In en, this message translates to:
  /// **'Stereo'**
  String get stereo;

  /// No description provided for @langChineseTraditional.
  ///
  /// In en, this message translates to:
  /// **'Chinese (Traditional/Hantai)'**
  String get langChineseTraditional;

  /// No description provided for @langEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get langEnglish;

  /// No description provided for @langFrench.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get langFrench;

  /// No description provided for @langGerman.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get langGerman;

  /// No description provided for @langItalian.
  ///
  /// In en, this message translates to:
  /// **'Italian'**
  String get langItalian;

  /// No description provided for @langJapanese.
  ///
  /// In en, this message translates to:
  /// **'Japanese'**
  String get langJapanese;

  /// No description provided for @langKorean.
  ///
  /// In en, this message translates to:
  /// **'Korean'**
  String get langKorean;

  /// No description provided for @langPortuguesePortugal.
  ///
  /// In en, this message translates to:
  /// **'Portuguese (Portugal)'**
  String get langPortuguesePortugal;

  /// No description provided for @langRussian.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get langRussian;

  /// No description provided for @langSpanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get langSpanish;

  /// No description provided for @langSwedish.
  ///
  /// In en, this message translates to:
  /// **'Swedish'**
  String get langSwedish;

  /// No description provided for @langTurkish.
  ///
  /// In en, this message translates to:
  /// **'Turkish'**
  String get langTurkish;

  /// No description provided for @langChineseSimplified.
  ///
  /// In en, this message translates to:
  /// **'Chinese (Simplified/Kantai)'**
  String get langChineseSimplified;

  /// No description provided for @langPortugueseBrazil.
  ///
  /// In en, this message translates to:
  /// **'Portuguese (Brazil)'**
  String get langPortugueseBrazil;

  /// No description provided for @langArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get langArabic;

  /// No description provided for @langBulgarian.
  ///
  /// In en, this message translates to:
  /// **'Bulgarian'**
  String get langBulgarian;

  /// No description provided for @langCroatian.
  ///
  /// In en, this message translates to:
  /// **'Croatian'**
  String get langCroatian;

  /// No description provided for @langCzech.
  ///
  /// In en, this message translates to:
  /// **'Czech'**
  String get langCzech;

  /// No description provided for @langDanish.
  ///
  /// In en, this message translates to:
  /// **'Danish'**
  String get langDanish;

  /// No description provided for @langDutch.
  ///
  /// In en, this message translates to:
  /// **'Dutch'**
  String get langDutch;

  /// No description provided for @langEstonian.
  ///
  /// In en, this message translates to:
  /// **'Estonian'**
  String get langEstonian;

  /// No description provided for @langFinnish.
  ///
  /// In en, this message translates to:
  /// **'Finnish'**
  String get langFinnish;

  /// No description provided for @langGreek.
  ///
  /// In en, this message translates to:
  /// **'Greek'**
  String get langGreek;

  /// No description provided for @langHebrew.
  ///
  /// In en, this message translates to:
  /// **'Hebrew'**
  String get langHebrew;

  /// No description provided for @langHindi.
  ///
  /// In en, this message translates to:
  /// **'Hindi'**
  String get langHindi;

  /// No description provided for @langHungarian.
  ///
  /// In en, this message translates to:
  /// **'Hungarian'**
  String get langHungarian;

  /// No description provided for @langLatvian.
  ///
  /// In en, this message translates to:
  /// **'Latvian'**
  String get langLatvian;

  /// No description provided for @langLithuanian.
  ///
  /// In en, this message translates to:
  /// **'Lithuanian'**
  String get langLithuanian;

  /// No description provided for @langNorwegian.
  ///
  /// In en, this message translates to:
  /// **'Norwegian'**
  String get langNorwegian;

  /// No description provided for @langPolish.
  ///
  /// In en, this message translates to:
  /// **'Polish'**
  String get langPolish;

  /// No description provided for @langRomanian.
  ///
  /// In en, this message translates to:
  /// **'Romanian'**
  String get langRomanian;

  /// No description provided for @langSerbian.
  ///
  /// In en, this message translates to:
  /// **'Serbian'**
  String get langSerbian;

  /// No description provided for @langSlovak.
  ///
  /// In en, this message translates to:
  /// **'Slovak'**
  String get langSlovak;

  /// No description provided for @langSlovenian.
  ///
  /// In en, this message translates to:
  /// **'Slovenian'**
  String get langSlovenian;

  /// No description provided for @langThai.
  ///
  /// In en, this message translates to:
  /// **'Thai'**
  String get langThai;

  /// No description provided for @langUkrainian.
  ///
  /// In en, this message translates to:
  /// **'Ukrainian'**
  String get langUkrainian;

  /// No description provided for @langVietnamese.
  ///
  /// In en, this message translates to:
  /// **'Vietnamese'**
  String get langVietnamese;

  /// No description provided for @write.
  ///
  /// In en, this message translates to:
  /// **'Write'**
  String get write;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
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
