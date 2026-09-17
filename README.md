# CKNE Practice Lab

Material de estudio práctico para la certificación **CKNE (Certified Kubernetes
Network Engineer)**, enfocado en tareas hands-on (no preguntas de opción múltiple),
organizado según los 5 dominios del temario oficial.

## Contenido

- **[`ckne-practice.html`](ckne-practice.html)** — consola de práctica simulada en el
  navegador (20 escenarios con terminal interactiva, pistas y solución). Ábrelo
  directamente en tu navegador, no requiere servidor ni clúster real.

- **[`lab/`](lab/)** — 19 escenarios prácticos **reales**, para ejecutar contra un
  clúster `kind` con Cilium. Cada uno rompe algo de verdad (una policy mal
  configurada, una ruta faltante, un selector roto, etc.) y tú lo diagnosticas y
  reparas con `kubectl`/`cilium`/`hubble` reales. Incluye setup del clúster,
  contexto de cada escenario, script de verificación y solución de referencia.

- **[`toolbox/`](toolbox/)** — imagen Docker de depuración de red (`ckne-toolbox`)
  con `kubectl`, `cilium` CLI, `hubble` CLI, `tcpdump`, `iptables`, `iproute2`,
  `dig`, `iperf3`, `mtr` y más, lista para desplegar como pod de debug.

## Dominios cubiertos (peso del examen)

| Dominio | Peso |
|---|---|
| Core Infrastructure and CNI | 15% |
| Service Networking and DNS | 25% |
| Advanced Traffic Management | 20% |
| Network Security and Policy | 25% |
| Observability | 15% |

## Quickstart

```bash
# 1. Simulador en el navegador (sin clúster)
xdg-open ckne-practice.html

# 2. Laboratorio real
cd lab/00-setup
kind create cluster --name ckne --config kind-config.yaml
# sigue el README.md de 00-setup para instalar Cilium

# 3. Toolbox de depuración
cd ../../toolbox
./build.sh ckne
kubectl apply -f debug-pod.yaml
```

Ver `lab/README.md` para el flujo detallado de cada escenario.

---

Generado como material de estudio personal; no es contenido oficial de la CNCF/Linux
Foundation.
