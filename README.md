# CKNE Practice Lab

Material de estudio práctico para la certificación **CKNE (Certified Kubernetes
Network Engineer)** de la CNCF/Linux Foundation. El examen es 100% práctico
(tareas sobre un clúster real, no preguntas de opción múltiple), así que todo este
repo está diseñado para que practiques resolviendo problemas reales, no leyendo
teoría.

> No es contenido oficial de la CNCF/Linux Foundation — es material de estudio
> personal, hecho a partir del temario público del examen.

## ¿Qué hay aquí?

| Carpeta / archivo | Qué es | Cuándo usarlo |
|---|---|---|
| [`ckne-practice.html`](ckne-practice.html) | Simulador de terminal en el navegador, 20 escenarios con pistas y solución | Para repasar comandos y flujo de diagnóstico sin necesitar un clúster (en el bus, sin laptop potente, etc.) |
| [`lab/`](lab/) | 19 escenarios **reales** contra un clúster `kind` + Cilium | Para la práctica real que se parece al examen: romper algo de verdad y arreglarlo |
| [`toolbox/`](toolbox/) | Imagen Docker de depuración de red (`ckne-toolbox`) | Como pod de debug dentro del clúster para diagnosticar cualquier escenario |

Empieza por el simulador si quieres repasar sintaxis rápido, y usa `lab/` para la
práctica seria — el simulador no sustituye ejecutar comandos contra un clúster real.

## Requisitos

Necesitas estos binarios instalados en tu máquina (Linux/macOS):

| Herramienta | Para qué | Instalación |
|---|---|---|
| `docker` | correr los nodos de kind y construir el toolbox | https://docs.docker.com/engine/install/ |
| `kind` | crear el clúster local | `go install sigs.k8s.io/kind@latest` o binario desde https://kind.sigs.k8s.io/docs/user/quick-start/#installation |
| `kubectl` | hablar con el clúster | https://kubernetes.io/docs/tasks/tools/#kubectl |
| `helm` | instalar Cilium | https://helm.sh/docs/intro/install/ |
| `cilium` (CLI) | instalar/verificar Cilium, egress/hubble | https://docs.cilium.io/en/stable/gettingstarted/k8s-install-default/#install-the-cilium-cli |
| `hubble` (CLI) | observabilidad de red (`hubble observe`) | https://docs.cilium.io/en/stable/gettingstarted/hubble_setup/ |
| `jq` | parsear salidas JSON en los scripts de verificación | gestor de paquetes de tu distro |

Verifica que todo esté disponible antes de empezar:

```bash
for bin in docker kind kubectl helm cilium hubble jq; do
  command -v "$bin" >/dev/null 2>&1 && echo "OK  $bin" || echo "FALTA  $bin"
done
```

## Quickstart (de cero a tu primer escenario resuelto)

```bash
git clone https://github.com/Stivenavila/ckne-practice-lab.git
cd ckne-practice-lab

# 1) Crear el clúster kind SIN CNI ni kube-proxy (igual que en el examen: instalas el CNI a mano)
cd lab/00-setup
kind create cluster --name ckne --config kind-config.yaml
kubectl get nodes   # todos en NotReady, es esperado

# 2) Instalar Cilium reemplazando kube-proxy — sigue lab/00-setup/README.md paso a paso
#    (ahí están los valores exactos de --set según tu API server)

# 3) Construir y cargar el toolbox de depuración en el clúster
cd ../../toolbox
./build.sh ckne
kubectl apply -f debug-pod.yaml
kubectl get pods   # toolbox y toolbox-hostnet deben quedar Running

# 4) Resolver tu primer escenario
cd ../lab/02-service-networking-dns/scenario-01-broken-selector
cat README.md        # lee el contexto y el objetivo (sin mirar la solución)
./setup.sh            # rompe algo real en el clúster
#   ... diagnostica con kubectl/cilium/hubble y arréglalo tú mismo ...
./verify.sh           # confirma si quedó resuelto
```

Repite el patrón `README.md` → `setup.sh` → diagnosticar → `verify.sh` con cada
escenario. Solo abre `SOLUTION.md` si te trabas o para comparar tu enfoque al
terminar — abrirlo antes arruina el valor de práctica.

Ver **[`lab/README.md`](lab/README.md)** para el flujo detallado, la tabla completa
de los 19 escenarios y troubleshooting común.

## Dominios cubiertos (peso oficial del examen)

| Dominio | Peso | Escenarios en `lab/` |
|---|---|---|
| Core Infrastructure and CNI | 15% | 3 |
| Service Networking and DNS | 25% | 5 |
| Advanced Traffic Management | 20% | 3 |
| Network Security and Policy | 25% | 5 |
| Observability | 15% | 3 |

## Limpieza

Cada escenario trae su propia limpieza en su `README.md`. Para tirar todo el
laboratorio y empezar de cero:

```bash
kind delete cluster --name ckne
```

## Estructura del repo

```
.
├── ckne-practice.html      # simulador de terminal (standalone, sin dependencias)
├── lab/                     # laboratorio real, un README y tabla completa aquí
│   ├── 00-setup/            # kind-config.yaml + guía de instalación de Cilium
│   ├── 01-core-infra-cni/
│   ├── 02-service-networking-dns/
│   ├── 03-advanced-traffic/
│   ├── 04-network-security-policy/
│   └── 05-observability/
└── toolbox/                 # imagen Docker de depuración de red + pod de debug
```
