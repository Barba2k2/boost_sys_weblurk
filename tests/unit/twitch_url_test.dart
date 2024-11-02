import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Twitch URL Tests', () {
    test('Should return the correct URL for Twitch', () {
      final twitchURL = 'https://www.twitch.tv/';
      expect(twitchURL, 'https://www.twitch.tv/');
    });
  });
}
