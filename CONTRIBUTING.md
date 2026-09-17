# Convención de ramas y contribución

Este repo sigue **GitHub Flow**: un modelo simple pensado para iterar rápido sin
ceremonia de releases.

## Reglas

1. `main` siempre debe quedar en estado desplegable/funcional. No se pushea
   directo ahí salvo fixes triviales de documentación.
2. Todo cambio nuevo va en una rama corta, nombrada según el tipo de cambio:
   - `feature/<nombre-corto>` — funcionalidad nueva
   - `fix/<nombre-corto>` — corrección de bug
   - `chore/<nombre-corto>` — mantenimiento, dependencias, configuración
   - `docs/<nombre-corto>` — solo documentación
3. Abre un Pull Request hacia `main` cuando la rama esté lista. Describe qué
   cambia y por qué (el diff ya muestra el qué).
4. Mergea con **squash merge** para mantener el historial de `main` limpio
   (un commit por PR, sin commits intermedios de "wip" o "fix typo").
5. Borra la rama después de mergear (`gh pr merge --delete-branch`).

## Ejemplo de flujo

```bash
git checkout main
git pull
git checkout -b feature/nombre-de-la-tarea

# ... trabaja y commitea ...

git push -u origin feature/nombre-de-la-tarea
gh pr create --fill

# tras revisar y mergear:
git checkout main
git pull
git branch -d feature/nombre-de-la-tarea
```

## Mensajes de commit

Formato libre pero descriptivo, en español, enfocado en el **por qué** del cambio
más que en el qué — eso ya lo muestra el diff.

## Ramas largas o compartidas

Si una rama va a vivir más de unos días o la va a tocar más de una persona, avisa
en el PR temprano (draft PR) en vez de acumular commits en silencio — evita
conflictos grandes al final.
