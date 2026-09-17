# Laboratorio práctico CKNE

19 escenarios **reales** (no simulados), organizados por los 5 dominios del examen,
pensados para ejecutarse contra un clúster `kind` con Cilium. Cada uno rompe algo de
verdad — una policy mal configurada, una ruta faltante, un selector roto — y te
obliga a diagnosticarlo y repararlo con `kubectl`/`cilium`/`hubble` reales, igual
que el formato del examen.

## 0. Antes de empezar

1. Revisa los requisitos y el quickstart en el [README raíz](../README.md).
2. Levanta el clúster e instala Cilium siguiendo **[`00-setup/README.md`](00-setup/README.md)**.
3. Construye y carga el toolbox de depuración: **[`../toolbox/`](../toolbox/)**.

Varios escenarios necesitan una característica de Cilium habilitada aparte del
setup base (Gateway API, egress gateway, métricas de Hubble). Cada `README.md` de
escenario lo indica en una sección "Requisito previo" con el comando `helm upgrade`
exacto — solo hay que ejecutarlo una vez por clúster, no por escenario.

## 1. Flujo de cada escenario

```bash
cd lab/<dominio>/<escenario>
cat README.md         # contexto + objetivo, sin spoilers
./setup.sh             # rompe algo real en el clúster
# ... diagnostica y arregla con comandos reales (kubectl, cilium, hubble, tcpdump...) ...
./verify.sh            # confirma automáticamente si quedó resuelto
cat SOLUTION.md         # solo si te trabaste, o para comparar tu enfoque al final
```

Recomendaciones:
- **Cronómetra cada escenario** — el examen es por tiempo (~2h para todo el examen,
  ~90-120 min repartidos entre varias tareas).
- No abras `SOLUTION.md` antes de intentarlo — reduce el valor de la práctica a cero.
- Si `verify.sh` falla, vuelve a leer el `README.md`: casi siempre la pista clave
  ya está en el contexto.
- Al terminar un escenario, límpialo (comando al final de cada `README.md`) antes
  de pasar al siguiente, para no arrastrar recursos de un escenario a otro.

## 2. Tabla completa de escenarios

| # | Dominio | Escenario | Objetivo en una frase | Requisito extra |
|---|---|---|---|---|
| 1 | Core Infra/CNI (15%) | [`scenario-01-missing-route`](01-core-infra-cni/scenario-01-missing-route/) | Restaurar una ruta borrada entre nodos que rompe conectividad pod-to-pod cross-node | — |
| 2 | Core Infra/CNI | [`scenario-02-cidr-exhaustion`](01-core-infra-cni/scenario-02-cidr-exhaustion/) | Diagnosticar pods `Pending` por capacidad del nodo y mitigar sin borrar el Deployment | — |
| 3 | Core Infra/CNI | [`scenario-03-multus-secondary-iface`](01-core-infra-cni/scenario-03-multus-secondary-iface/) | Instalar Multus y darle a un pod una segunda interfaz de red | — |
| 4 | Service Networking/DNS (25%) | [`scenario-01-broken-selector`](02-service-networking-dns/scenario-01-broken-selector/) | Corregir un Service sin endpoints por selector mal escrito | — |
| 5 | Service Networking/DNS | [`scenario-02-coredns-stub-domain`](02-service-networking-dns/scenario-02-coredns-stub-domain/) | Agregar un stub domain en CoreDNS para forwardear un dominio interno | — |
| 6 | Service Networking/DNS | [`scenario-03-headless-service`](02-service-networking-dns/scenario-03-headless-service/) | Convertir un Service en headless para direccionar pods de un StatefulSet por DNS | — |
| 7 | Service Networking/DNS | [`scenario-04-endpoint-not-ready`](02-service-networking-dns/scenario-04-endpoint-not-ready/) | Arreglar un readiness probe que deja todos los pods fuera del balanceo | — |
| 8 | Service Networking/DNS | [`scenario-05-gateway-httproute`](02-service-networking-dns/scenario-05-gateway-httproute/) | Exponer un Service creando un HTTPRoute sobre un Gateway existente | Gateway API habilitada en Cilium |
| 9 | Advanced Traffic (20%) | [`scenario-01-egress-gateway`](03-advanced-traffic/scenario-01-egress-gateway/) | Forzar el egress de un namespace por un nodo/IP fija con CiliumEgressGatewayPolicy | Egress Gateway habilitado |
| 10 | Advanced Traffic | [`scenario-02-session-affinity-streaming`](03-advanced-traffic/scenario-02-session-affinity-streaming/) | Fijar conexiones de streaming al mismo pod backend con sessionAffinity | — |
| 11 | Advanced Traffic | [`scenario-03-path-based-routing`](03-advanced-traffic/scenario-03-path-based-routing/) | Enrutar `/orders` e `/inventory` a backends distintos con un mismo HTTPRoute | Gateway API habilitada |
| 12 | Network Security/Policy (25%) | [`scenario-01-default-deny`](04-network-security-policy/scenario-01-default-deny/) | Aislar un namespace con default-deny + allow explícito por namespace origen | — |
| 13 | Network Security/Policy | [`scenario-02-cert-manager-tls`](04-network-security-policy/scenario-02-cert-manager-tls/) | Emitir un certificado con cert-manager y terminarlo en un listener HTTPS del Gateway | cert-manager instalado, Gateway API habilitada |
| 14 | Network Security/Policy | [`scenario-03-wireguard-encryption`](04-network-security-policy/scenario-03-wireguard-encryption/) | Activar cifrado transparente (WireGuard) entre nodos y confirmarlo con tcpdump | — |
| 15 | Network Security/Policy | [`scenario-04-l7-http-policy`](04-network-security-policy/scenario-04-l7-http-policy/) | Permitir solo `GET /public` con una CiliumNetworkPolicy L7 | — |
| 16 | Network Security/Policy | [`scenario-05-dns-egress-policy`](04-network-security-policy/scenario-05-dns-egress-policy/) | Restringir egress a un único FQDN externo con `toFQDNs` | — |
| 17 | Observability (15%) | [`scenario-01-hubble-drop-audit`](05-observability/scenario-01-hubble-drop-audit/) | Encontrar con `hubble observe` qué policy está bloqueando tráfico | — |
| 18 | Observability | [`scenario-02-prometheus-topk-drops`](05-observability/scenario-02-prometheus-topk-drops/) | Identificar el servicio con más drops leyendo métricas de Hubble | Métricas de Hubble habilitadas |
| 19 | Observability | [`scenario-03-tracing-otel`](05-observability/scenario-03-tracing-otel/) | Encontrar el salto de red con mayor latencia en un trace distribuido (demo Jaeger HotROD) | — |

## 3. Requisitos previos por dominio (helm upgrades de una sola vez)

Algunos escenarios necesitan una feature de Cilium encendida aparte del setup
base. Ejecuta estos comandos **antes** de llegar a esos escenarios (cada uno se
puede aplicar en cualquier momento, no rompen lo ya instalado):

```bash
# Gateway API (escenarios 8, 11, 13)
helm upgrade cilium cilium/cilium --namespace kube-system --reuse-values \
  --set gatewayAPI.enabled=true
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.1.0/standard-install.yaml
kubectl -n kube-system rollout restart deployment/cilium-operator

# Egress Gateway (escenario 9)
helm upgrade cilium cilium/cilium --namespace kube-system --reuse-values \
  --set egressGateway.enabled=true
kubectl -n kube-system rollout restart daemonset/cilium

# cert-manager (escenario 13)
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.yaml
kubectl -n cert-manager rollout status deployment/cert-manager --timeout=120s
kubectl -n cert-manager rollout status deployment/cert-manager-webhook --timeout=120s

# Métricas de Hubble (escenario 18)
helm upgrade cilium cilium/cilium --namespace kube-system --reuse-values \
  --set hubble.metrics.enabled="{drop,tcp,flow}" \
  --set hubble.metrics.enableOpenMetrics=true
kubectl -n kube-system rollout restart daemonset/cilium
```

## 4. Troubleshooting común

**`cilium status` se queda colgado o reporta `unreachable`**
Verifica que `k8sServiceHost`/`k8sServicePort` en la instalación de Cilium apunten
al endpoint real del API server: `kubectl cluster-info | head -1`.

**Un escenario no encuentra la imagen (`ErrImagePull`/`ImagePullBackOff`)**
Las imágenes públicas (`nicolaka/netshoot`, `hashicorp/http-echo`, etc.) se bajan de
Docker Hub al primer uso — si no tienes salida a internet desde los nodos de kind,
no van a poder resolver el pull. El toolbox (`ckne-toolbox`) sí debe cargarse
manualmente con `kind load docker-image` (ver `toolbox/README.md`).

**`kubectl exec` a un Deployment falla con "no pods found"**
El pod puede tardar unos segundos en llegar a `Running`. Cada `setup.sh` ya espera
con `kubectl wait`, pero si lo interrumpiste, corre `kubectl get pods -n <ns> -w`
para confirmar el estado antes de reintentar.

**Un Gateway se queda sin IP en `status.addresses`**
Confirma que el `GatewayClass` `cilium` existe (`kubectl get gatewayclass`) y que el
`cilium-operator` está `Running` — usualmente basta con
`kubectl -n kube-system rollout restart deployment/cilium-operator`.

**`hubble observe` no muestra nada**
Necesitas el relay corriendo y accesible: `cilium hubble port-forward &` en otra
terminal antes de usar el CLI.

**Quiero reiniciar un escenario desde cero**
Borra su namespace (comando al final de cada `README.md`) y vuelve a correr
`setup.sh` — cada script es idempotente (usa `kubectl apply`, no falla si el
namespace ya existe).

## 5. Limpieza total del laboratorio

```bash
kind delete cluster --name ckne
```
