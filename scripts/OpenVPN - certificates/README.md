# OpenVPN server with client certificates helper scripts

## 1. Install
### Copy to router certs.rsc and import it:
   ```bash
   /import "certs.rsc"
   ```
   
After successful import you will see 4 scripts in _System_->_Scripts_:
   
  - **certs_defaults** - defaults for all scripts
  - **certs_createCA** - generate CA certificate
  - **certs_createServer** - create server's certificate
  - **certs_createClient** - create client's certificate

### 2. Generate server certificate:
Run in WinBox terminal:
   ```bash
   /system script run certs_createCA   
   /system script run certs_createServer
   ```
You will get self-signed CA certificate and server certificate signed by created CA with defaults set in _certs_defaults_.
You should specify server (not CA!) certificate in OVPN Server settings.

### 3. Generate, import and use client's certificates
If you decide to use client's certificates for authorization - set _Require Client Certificate_ checkbox.
For each OpenVPN client who needs own certificate run:
   ```bash
   /system script run certs_createClient
   ```
You will be asked for client identity (for example, you can use client's login name) and private key password.
All certificates automatically exported and can be copied from Mikrotik router to client.
If client also Mikrotik based - just import certificates in order:
* CA certificate
* client's crt file
* client's key file (don't forget specify private key password!)
and specify imported client's certificate in OVPN client connection settings.
