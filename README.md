# pre-commit workshop

[En desarrollo]

Taller de configuración y uso de pre-commit y git hooks

## Introducción

TODO: Intro

## Git hooks

Los git hooks son scripts personalizados de shell que se ejecutan automáticamente antes o después de determinadas acciones de git (`commit` o `push`, por ejemplo). Estos scripts se encuentran en el directorio `<repositorio>/.git/hooks/`

La carpeta `hooks/` contiene archivos de ejemplo con la extensión `.sample`. Para activarlos dichos hooks hay que eliminar dicha extensión.

TODO: Ejemplos

```
# .git/hooks/pre-commit

# Run python test, abort if fails
python test.py || exit 1

# Run npm linter, abort if fails
npm run lint || exit 1
```

Su ámbito es local, es decir, no se comparte entre las distintos clones del repositorio. Para poder compartirlo existen otras herramientas como pre-commit o husky (este para repositorios npm)

## Pre-commit

TODO: Pre commit intro

## Husky

TODO: Pre commit intro