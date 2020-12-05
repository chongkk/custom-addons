# Home Assistant Add-on: Custom Letsencrypt

## Installation

Follow these steps to get the add-on installed on your system:

1. Navigate in your Home Assistant frontend to **Supervisor** -> **Add-on Store**.
2. Find the "letsencrypt" add-on and click it.
3. Click on the "INSTALL" button.

## How to use

To use this add-on, you have two options on how to get your certificate:

### 1. http challenge

- Requires Port 80 to be available from the internet and your domain assigned to the externally assigned IP address
- Doesn’t allow wildcard certificates (*.yourdomain.com).

### 2. dns challenge

- Requires you to use one of the supported DNS providers (See "Supported DNS providers" below)
- Allows to request wildcard certificates (*.yourdomain.com)
- Doesn’t need you to open a port to your Home Assistant host on your router.

### You always need to provide the following entries within the configuration

```yaml
email: your@email.com
domains:
  # use "*.yourdomain.com" for wildcard certificates.
  - yourdomain.com
challenge: http OR dns
```

IF you choose "dns" as "challenge", you will also need to fill:

```yaml
# Add the dnsprovider of your choice from the list of "Supported DNS providers" below
dns:
  provider: ""
```

In addition add the fields according to the credentials required by your dns provider:


```yaml
propagation_seconds: 60
cloudflare_email: ''
cloudflare_api_key: ''
cloudflare_api_token: ''
```

## Advanced

### Changing the ACME Server
By default, The addon uses Let’s Encrypt’s default server at https://acme-v02.api.letsencrypt.org/. You can instruct the addon to use a different ACME server by providing the field `acme_server` with the URL of the server’s ACME directory:

```yaml
acme_server: 'https://my.custom-acme-server.com'
```

If your custom ACME server uses a certificate signed by an untrusted certificate authority (CA), you can add the root certificate to the trust store by setting its content as an option:
```yaml
acme_server: 'https://my.custom-acme-server.com'
acme_root_ca_cert: |
  -----BEGIN CERTIFICATE-----
  MccBfTCCASugAwIBAgIRAPPIPTKNBXkBozsoE46UPZcwCGYIKoZIzj0EAwIwHTEb...kg==
  -----END CERTIFICATE-----
```

## Example Configurations

### dns challenge

```yaml
email: your.email@example.com
domains:
  - home-assistant.io
certfile: fullchain.pem
keyfile: privkey.pem
challenge: dns
dns:
  provider: dns-cloudflare
  cloudflare_email: your.email@example.com
  cloudflare_api_key: 31242lk3j4ljlfdwsjf0
```

### CloudFlare

Previously, Cloudflare’s “Global API Key” was used for authentication, however this key can access the entire Cloudflare API for all domains in your account, meaning it could cause a lot of damage if leaked.

Cloudflare’s newer API Tokens can be restricted to specific domains and operations, and are therefore now the recommended authentication option.

However, due to some shortcomings in Cloudflare’s implementation of Tokens, Tokens created for Certbot currently require `Zone:Zone:Read` and `Zone:DNS:Edit` permissions for all zones in your account.

Example credentials file using restricted API Token (recommended):
```yaml
dns:
  provider: dns-cloudflare
  cloudflare_api_token: 0123456789abcdef0123456789abcdef01234
```

Example credentials file using Global API Key (not recommended):
```yaml
dns:
  provider: dns-cloudflare
  cloudflare_email: cloudflare@example.com
  cloudflare_api_key: 0123456789abcdef0123456789abcdef01234
```

## Supported DNS providers

```txt
dns-cloudflare
```

## Support
