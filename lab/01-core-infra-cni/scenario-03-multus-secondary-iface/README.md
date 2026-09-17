# Escenario: pod con segunda interfaz de red (Multus)

**Namespace:** `net-lab3`

## Contexto
Una carga de captura de datos necesita una interfaz secundaria además de `eth0`
(la que gestiona Cilium).

## Objetivo
1. Instala Multus CNI como meta-plugin.
2. Crea una `NetworkAttachmentDefinition` de tipo `bridge` (más estable en Docker/kind
   que `macvlan`, que suele fallar por restricciones del bridge de Docker).
3. Crea un pod que use esa NAD vía la anotación `k8s.v1.cni.cncf.io/networks` y
   confirma con `ip addr` que tiene dos interfaces.

## Cómo empezar

```bash
./setup.sh
```

El script instala Multus (manifiesto oficial) y deja el namespace listo. El resto
(crear la NAD y el pod) lo haces tú — son los dos recursos que se evalúan en el
examen real.

## Pistas
```bash
kubectl get network-attachment-definitions -n net-lab3
kubectl -n net-lab3 exec <pod> -- ip addr
```

## Verificar
```bash
./verify.sh
```

## Limpieza
```bash
kubectl delete ns net-lab3
kubectl delete -f https://raw.githubusercontent.com/k8snetworkplumbingwg/multus-cni/master/deployments/multus-daemonset.yml --ignore-not-found
```
