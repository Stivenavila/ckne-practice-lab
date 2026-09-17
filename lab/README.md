# Laboratorio práctico CKNE

19 escenarios reales (no simulados) organizados por los 5 dominios del examen,
pensados para ejecutarse contra un clúster `kind` con Cilium. Cada uno rompe algo
real y te obliga a diagnosticarlo y arreglarlo con `kubectl`/`cilium`/`hubble` de
verdad, tal como el formato del examen (tareas, no preguntas de opción múltiple).

## Empieza aquí
1. `00-setup/` — crear el clúster e instalar Cilium.
2. `../toolbox/` — imagen Docker de depuración de red (equivalente a netshoot, con
   `cilium`, `hubble`, `kubectl`, `tcpdump`, `iptables`, etc.).

## Dominios (peso según el temario)
| Dominio | Peso | Carpeta |
|---|---|---|
| Core Infrastructure and CNI | 15% | `01-core-infra-cni/` (3 escenarios) |
| Service Networking and DNS | 25% | `02-service-networking-dns/` (5 escenarios) |
| Advanced Traffic Management | 20% | `03-advanced-traffic/` (3 escenarios) |
| Network Security and Policy | 25% | `04-network-security-policy/` (5 escenarios) |
| Observability | 15% | `05-observability/` (3 escenarios) |

## Flujo de estudio recomendado
```bash
cd lab/<dominio>/<escenario>
cat README.md        # contexto + objetivo, sin spoilers
./setup.sh            # rompe algo real
# ... diagnostica y arregla con comandos reales ...
./verify.sh           # confirma si quedó resuelto
cat SOLUTION.md        # solo si te trabaste o para comparar tu approach
```

Cronómetra cada escenario — el examen es por tiempo. Cuando lo resuelvas sin mirar
`SOLUTION.md`, pasa al siguiente dominio.
