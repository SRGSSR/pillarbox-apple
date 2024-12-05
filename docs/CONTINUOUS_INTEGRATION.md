# Continuous integration

Continuous integration is performed using GitHub Actions. Worflows require a few action secrets and variables to be set in the GitHub repository settings.

## Secrets

Some information is kept confidential and stored in secrets.

### Apple developer certificate

An Apple developer certificate exported from Xcode, and protected by a password, is required. More information is available from the [GitHub documentation](https://docs.github.com/en/actions/use-cases-and-examples/deploying/installing-an-apple-certificate-on-macos-runners-for-xcode-development):

- `APPLE_DEV_CERTIFICATE`: The certificate `p12` file converted to Base64 can be copied to the clipboard with:

    ```shell
    base64 -i developer_certificate.p12 | pbcopy
    ```

- `APPLE_DEV_CERTIFICATE_PASSWORD`: The password used to protect the developer certificate.

### App Store Connect API key

An [App Store Connect API key](https://appstoreconnect.apple.com/access/integrations/api) is required for automatic provisioning:

- `APP_STORE_CONNECT_API_KEY`: The key `p8` file converted to Base64 can be copied to the clipboard with:

    ```shell
    base64 -i api_key.p8 | pbcopy
    ```

- `APP_STORE_CONNECT_KEY_ID`: The key ID.
- `APP_STORE_CONNECT_KEY_ISSUER_ID`: The key issuer ID.

### Other secrets

- `TEAM_ID`: The team ID.
- `KEYCHAIN_PASSWORD`: An arbitrary password used to create a local keychain to store certificates on GitHub runners. This password is only used to prevent secrets from being easily read from this keychain, should it somehow leak from a GitHub-hosted agent.

## Environment variables

Non-confidential information is provided in environment variables:

- `TESTFLIGHT_GROUPS`: A comma-delimited list of TestFlight groups to which published demo applications must be distributed.
