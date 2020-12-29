# Setup Ingress With Security Control

Documentation available during exam:
* https://v1-19.docs.kubernetes.io/docs/concepts/services-networking/ingress/
* https://v1-19.docs.kubernetes.io/docs/concepts/services-networking/ingress/#tls
* https://v1-19.docs.kubernetes.io/docs/concepts/services-networking/ingress-controllers/
* https://v1-19.docs.kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#-em-secret-tls-em-

# TL;DR

You can secure an Ingress by specifying a Secret that contains a TLS private key and certificate. The Ingress resource only supports a single TLS port, 443, and assumes TLS termination at the ingress point (traffic to the Service and its Pods is in plaintext). If the TLS configuration section in an Ingress specifies different hosts, they are multiplexed on the same port according to the hostname specified through the SNI TLS extension (provided the Ingress controller supports SNI). The TLS secret must contain keys named tls.crt and tls.key that contain the certificate and private key to use for TLS.

Referencing this secret in an Ingress tells the Ingress controller to secure the channel from the client to the load balancer using TLS. You need to make sure the TLS secret you created came from a certificate that contains a Common Name (CN), also known as a Fully Qualified Domain Name (FQDN) for https-example.foo.com.

## Hands On

`kubectl apply -f manifest.yaml`

Givien you have:
* namespace 01-03
* two applications (foo-app, bar-app)
* two services (foo-service, bar-service) using port 5678/tcp
* nginx ingress controller

**Create:**
* secret with a name `ckss-local-tls` and selfsigned certificate data for `ckss.local` domain
* ingress object so:
  * foo-app is accessible from root of ckss.local domain over https
  * bar-app is accessible from root of any domain over http(s)

**Verify with:**

```
curl http://localhost
curl -k https://localhost
curl -k https://ckss.localhost
```

**Expected output:**
```
bar
bar
foo
```

**Solution:**

Create certificate and secret with:
```
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout cert.key -out cert -subj "/CN=ckss.local/O=ckss.local"
kubectl -n 01-03 create secret tls ckss-local-tls --key cert.key --cert cert
```

Create ingress:
`kubectl apply -f ingress.yaml`

**Cleanup:**

`kubectl delete -f manifest.yaml -f ingress.yaml --wait=false`
