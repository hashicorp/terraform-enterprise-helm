# This is where the generated certificates will be stored

## certificate_p12.pfx
The certificate, any intermediates, and the private key archived as a PFX file (PKCS12 format, generally used by Microsoft products). 

## certificate_pem.pem
 The certificate in PEM format. This does not include the issuer_pem
## issuer.pem
 The intermediate certificates of the issuer. Multiple certificates are concatenated in this field when there is more than one intermediate certificate in the chain.

## full_chain.pem
 The certificate in PEM format. This does include the issuer_pem

## private_key.pem
The certificate's private key, in PEM format, if the certificate was generated from scratch. No password