# Assinatura Android (Upload Key)

## 1) Gerar keystore de upload

```bash
keytool -genkeypair -v -storetype PKCS12 -keystore upload-keystore.jks -alias upload -keyalg RSA -keysize 2048 -validity 10000
```

## 2) Configurar arquivo local

Copie `android/key.properties.example` para `android/key.properties` e preencha:

```properties
storePassword=SEU_STORE_PASSWORD
keyPassword=SEU_KEY_PASSWORD
keyAlias=upload
storeFile=../upload-keystore.jks
```

## 3) Observações de segurança

- Nunca commitar `key.properties` nem `upload-keystore.jks`.
- Fazer backup seguro do keystore e senhas.
- Se perder a chave, o processo de recuperação com Play é burocrático.
