import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart'; // Correct import
import 'package:boost_sys_weblurk/core/logger/app_logger.dart';
import 'package:boost_sys_weblurk/core/services/url_launcher_service.dart';

// Mock the logger
class MockAppLogger extends Mock implements AppLogger {}

// Mock the UrlLauncherPlatform
class MockUrlLauncherPlatform extends Mock implements UrlLauncherPlatform {}

void main() {
  group(
    'UrlLauncherService',
    () {
      late MockAppLogger mockLogger;
      late UrlLauncherService urlLauncherService;
      late MockUrlLauncherPlatform mockUrlLauncherPlatform;

      setUp(
        () {
          mockLogger = MockAppLogger();
          mockUrlLauncherPlatform = MockUrlLauncherPlatform();
          // Override the default UrlLauncherPlatform instance for testing
          UrlLauncherPlatform.instance = mockUrlLauncherPlatform;

          urlLauncherService = UrlLauncherService(
            logger: mockLogger,
          );
        },
      );

      test(
        'launchURL logs error if URL is invalid',
        () async {
          // Arrange
          const invalidUrl = 'invalid-url';
          when(mockUrlLauncherPlatform.canLaunch(
                  any, // Use any for the URL to match any string
                  useSafariVC: anyNamed('useSafariVC'),
                  useWebView: anyNamed('useWebView'),
                  enableJavaScript: anyNamed('enableJavaScript'),
                  enableDomStorage: anyNamed('enableDomStorage'),
                  universalLinksOnly: anyNamed('universalLinksOnly'),
                  headers: anyNamed('headers'),
                  webOnlyWindowName: anyNamed('webOnlyWindowName'),
                  forceWebView: anyNamed('forceWebView'),
                  forceSafariVC: anyNamed('forceSafariVC'),
                  enableSwipingBack: anyNamed('enableSwipingBack'),
                  showTitle: anyNamed('showTitle'),
                  statusBarBrightness: anyNamed('statusBarBrightness'),
                  mode: anyNamed('mode'),
                  browserConfiguration: anyNamed('browserConfiguration'),
                  webLaunchMode: anyNamed('webLaunchMode'),
                  ) // Match any parameters
              ).thenAnswer((_) async => false);

          // Act
          await urlLauncherService.launchURL(invalidUrl);

          // Assert
          verify(mockLogger.error(
            'Não foi possível abrir a URL: $invalidUrl',
            any,
            any,
          )).called(1);
        },
      );

      test(
        'launchURL opens URL if valid',
        () async {
          // Arrange
          const validUrl = 'https://google.com';
          when(mockUrlLauncherPlatform.canLaunch(
                  any, // Use any for the URL to match any string
                  useSafariVC: anyNamed('useSafariVC'),
                  useWebView: anyNamed('useWebView'),
                  enableJavaScript: anyNamed('enableJavaScript'),
                  enableDomStorage: anyNamed('enableDomStorage'),
                  universalLinksOnly: anyNamed('universalLinksOnly'),
                  headers: anyNamed('headers'),
                  webOnlyWindowName: anyNamed('webOnlyWindowName'),
                  forceWebView: anyNamed('forceWebView'),
                  forceSafariVC: anyNamed('forceSafariVC'),
                  enableSwipingBack: anyNamed('enableSwipingBack'),
                  showTitle: anyNamed('showTitle'),
                  statusBarBrightness: anyNamed('statusBarBrightness'),
                  mode: anyNamed('mode'),
                  browserConfiguration: anyNamed('browserConfiguration'),
                  webLaunchMode: anyNamed('webLaunchMode'),
                  ) // Match any parameters
              ).thenAnswer((_) async => true);
          when(mockUrlLauncherPlatform.launch(
                  any, // Use any for the URL to match any string
                  useSafariVC: anyNamed('useSafariVC'),
                  useWebView: anyNamed('useWebView'),
                  enableJavaScript: anyNamed('enableJavaScript'),
                  enableDomStorage: anyNamed('enableDomStorage'),
                  universalLinksOnly: anyNamed('universalLinksOnly'),
                  headers: anyNamed('headers'),
                  webOnlyWindowName: anyNamed('webOnlyWindowName'),
                  forceWebView: anyNamed('forceWebView'),
                  forceSafariVC: anyNamed('forceSafariVC'),
                  enableSwipingBack: anyNamed('enableSwipingBack'),
                  showTitle: anyNamed('showTitle'),
                  statusBarBrightness: anyNamed('statusBarBrightness'),
                  mode: anyNamed('mode'),
                  browserConfiguration: anyNamed('browserConfiguration'),
                  webLaunchMode: anyNamed('webLaunchMode'),
                  ) // Match any parameters
              ).thenAnswer((_) async => true);

          // Act
          await urlLauncherService.launchURL(validUrl);

          // Assert
          verify(mockUrlLauncherPlatform.launch(
            argThat(equals(validUrl)),
            useSafariVC: anyNamed('useSafariVC'),
            useWebView: anyNamed('useWebView'),
            enableJavaScript: anyNamed('enableJavaScript'),
            enableDomStorage: anyNamed('enableDomStorage'),
            universalLinksOnly: anyNamed('universalLinksOnly'),
            headers: anyNamed('headers'),
            webOnlyWindowName: anyNamed('webOnlyWindowName'),
            forceWebView: anyNamed('forceWebView'),
            forceSafariVC: anyNamed('forceSafariVC'),
            enableSwipingBack: anyNamed('enableSwipingBack'),
            showTitle: anyNamed('showTitle'),
            statusBarBrightness: anyNamed('statusBarBrightness'),
            mode: anyNamed('mode'),
            browserConfiguration: anyNamed('browserConfiguration'),
            webLaunchMode: anyNamed('webLaunchMode'),
          )).called(1);
          verifyNever(mockLogger.error(any, any, any));
        },
      );
    },
  );
}
