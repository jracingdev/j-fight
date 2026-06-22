import 'api_client.dart' show mensagemErroApi;

export 'api_client.dart' show ApiException, comTimeout, kApiQueryTimeout, mensagemErroApi;

String mensagemErroSupabase(Object erro, {String recurso = 'dados'}) =>
    mensagemErroApi(erro, recurso: recurso);
