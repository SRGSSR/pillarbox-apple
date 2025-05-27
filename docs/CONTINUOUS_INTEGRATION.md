# Continuous integration

Continuous integration is performed using GitHub Actions. Worflows require a few action secrets and variables to be set in the GitHub repository settings.

## Secrets

Some information is kept confidential and stored in secrets.

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

## Environment variables

Non-confidential information is provided in environment variables:

- `TESTFLIGHT_GROUPS`: A comma-delimited list of TestFlight groups to which published demo applications must be distributed.
