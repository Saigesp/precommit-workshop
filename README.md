# pre-commit workshop

Taller de configuración y uso de [git-hooks](https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks) y [pre-commit](https://pre-commit.com/).

## Introducción

La automatización local de revisiones de código evita que la calidad se comprometa debido al olvido, nuevos contribuyentes o la presión de una fecha de entrega estricta.

## Git hooks

Los git hooks son scripts personalizados de shell que se ejecutan automáticamente antes o después de determinadas acciones de git (`commit` o `push`, por ejemplo). Estos scripts se encuentran en el directorio `<repositorio>/.git/hooks/`.

La carpeta `hooks/` contiene archivos de ejemplo con la extensión `.sample`. Para activarlos dichos hooks hay que eliminar dicha extensión.

> PD: Si en vez de cambiar la extensión creas un archivo, deberás empezar el archivo con `#!/bin/sh` y darle permisos de ejecución con `chmod +x <archivo>`.

Un ejemplo sencillo para el hook **pre-commit** es el siguiente:

```sh
# .git/hooks/pre-commit

# Run python test script, abort if fails
python test.py || exit 1

# Run npm linter, abort if fails
npm run lint || exit 1

# Run custom script
ROOT_DIR="$(git rev-parse --show-toplevel)"
"${ROOT_DIR}"/custom_path/custom_script.sh
```

Eligiendo a qué comando Git asociar el Hook

Su ámbito es local, es decir, no se comparte entre las distintos clones del repositorio. Para poder compartirlo existen otras herramientas como pre-commit o husky (este para repositorios npm)

## pre-commit

[pre-commit](https://pre-commit.com/) es una librería python open source para gestionar estas automatizaciones más cómodamente. Inicialmente se desarrolló para python pero actualmente se puede utilizar en cualquie proyecto.

Permite utilizar hooks escritos por otras personas fácilmente y actualemente tiene una [amplia lista de comandos indexados](https://pre-commit.com/hooks.html).

Con pre-commit definimos los scripts a ejecutar en el archivo `.pre-commit-config.yaml`, y para instalarlos en el entorno solo es necesario ejecutar (Recuerda que el propio pre-commit debe estar instalado: `pip install pre-commit`):

```sh
$ pre-commit install
```

> Atención! pre-commit sobreescribe el archivo `.git/hooks/pre-commit` al instalarlo

Un ejemplo de configuración para un proyecto de django puede ser:

```yaml
repos:
  - repo: https://github.com/yunojuno/pre-commit-xenon
    rev: cc59b0431a5d072786b59430e9b342b2881064f6
    hooks:
    - id: xenon
      args: ["--max-average=A", "--max-modules=C", "--max-absolute=C"]

  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v2.3.0
    hooks:
      - id: check-merge-conflict
      - id: end-of-file-fixer
      - id: trailing-whitespace
      - id: fix-encoding-pragma

  - repo: https://github.com/ecugol/pre-commit-hooks-django
    rev: v0.4.0
    hooks:
      - id: check-absent-migrations
      - id: check-untracked-migrations
      - id: check-unapplied-migrations

  - repo: https://github.com/pre-commit/pygrep-hooks
    rev: v1.9.0
    hooks:
      - id: python-no-eval

  - repo: https://github.com/PyCQA/bandit
    rev: 1.7.3
    hooks:
      - id: bandit
        args: ["--exclude", "tests", "-s", "B101"]

  - repo: https://github.com/psf/black
    rev: 21.12b0
    hooks:
      - id: black

  - repo: local
    hooks:
      - id: django-test
        name: django-test
        entry: python backend/manage.py test
        always_run: true
        pass_filenames: false
        language: system
```
> Atención! Para repositorios externos es muy importante incluir el código de versión (P.e.: `rev: 21.12b0`), en caso de no hacerlo seríamos vulnerables en caso de que ese repositorio introdujese código malicioso.

### Scripts personalizados

Con pre-commit también podemos definir nuestros propios scripts y agregarlos a la lista de comandos. Un script sencillo para comprobar que no haya prints en el código a subir puede ser:

```sh
#!/bin/sh

# Custom git pre-commit hook for finding and warning about
# Python print statements.
# Based on https://gist.github.com/stuntgoat/8800170

# Get the current git HEAD
head=`git rev-parse --verify HEAD`

# BSD regex for finding Python print statements
find_print='\+[[:space:]]*print[[:space:](]*'

# Save output to $out var
out=`git diff ${head} | grep -e ${find_print}`

# Count number of prints
count=`echo "${out}" | grep -e '\w' | wc -l`
if [ $count -gt 0 ];
   then
    echo "- Prints found:"
    echo "$out"
    echo "-" $count "print statement(s) founds!"
    echo
    exit 1
fi
```

Para añadirlo a la lista de comandos, puedes definirlo como:

```yaml
  - repo: local
    hooks:
      - id: python-no-print
        name: check for print()
        entry: sh ./pre-commit/python-no-print.sh
        always_run: true
        pass_filenames: false
        language: system
```

### Uso en CI

Para utilizar pre-commit en la integración continua basta con añadir `pre-commit run --all-files` como comando, o `pre-commit run --from-ref origin/HEAD --to-ref HEAD` para comprobar sólo los archivos que han cambiado.

## Hooks útiles

### Black

[Black](https://github.com/psf/black) es un formateador de código bastante ligero. Recomiendo ver la [charla en PyCon2019](https://www.youtube.com/watch?v=esZLCuWs_2Y) para ver cómo funciona internamente.

### Xenon

[Xenon](https://xenon.readthedocs.io/en/latest/) es una herramienta de monitorización basada en [Radon](https://github.com/rubik/radon/) para supervisar la complejidad del código.

### Bandit

[Bandit](https://bandit.readthedocs.io/en/latest/) es una herramienta para encontrar problemas de seguridad comunes en el código de Python.

## Otras herramientas

### Husky

[Husky](https://typicode.github.io/husky/#/) es un módulo javascript, parecido a pre-commit pero con algunas diferencias y similitudes. Las principales IMO son:

Ventajas:
- Antiguo: [Se instala automáticamente al instalar dependencias con `npm install`]. Husky parece que [ya no se autoinstala automáticamente](https://blog.typicode.com/husky-git-hooks-autoinstall/).

Desventajas:
- No se pueden referencias comandos de terceros como con pre-commit.

Husky crea una carpeta `.husky` dentro de nuestro repositorio, y ahi podremos escribir los scripts que queramos.
