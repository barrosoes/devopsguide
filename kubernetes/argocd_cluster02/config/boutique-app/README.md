🚀 Boutique microservices app (plain HTTP mode)

![Boutique microservices architecture](./microservices5.png)

This folder deploys the Boutique demo app behind an NGINX Ingress (HTTP).

## Notes

- This environment is currently **not using Istio service mesh**.
- We intentionally avoid `istio-injection=enabled`, `PeerAuthentication`, and `DestinationRule` resources, because removing the Istio control-plane (`istiod`) while keeping sidecars/mTLS causes TLS/certificate errors and the frontend returns HTTP 500.