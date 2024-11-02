import 'package:boost_sys_weblurk/app/core/ui/webview/custom_webview.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('Custom WebView loads Twitch URL correctly',
      (WidgetTester tester) async {
    const twitchUrl = 'https://www.twitch.tv';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomWebView(initialUrl: twitchUrl),
        ),
      ),
    );

    // Verifica se a WebView foi carregada
    expect(find.byType(CustomWebView), findsOneWidget);

    // Aguarda o estado da WebView indicar que a URL foi carregada
    // Isso depende do que foi implementado no `CustomWebView`
    // Exemplo: espera-se que `CustomWebView` exiba um indicador de progresso enquanto carrega
    // e depois confirma a URL carregada.

    // Verificar o indicador de progresso
    expect(find.byKey(Key('loading_indicator')), findsOneWidget);

    // Simule o fim do carregamento e veja se o progresso desaparece
    // Você pode precisar de um `setState` no widget para controlar o progresso
    await tester.pumpAndSettle();
    expect(find.byKey(Key('loading_indicator')), findsNothing);
  });
}
