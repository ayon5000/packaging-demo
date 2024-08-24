#!/bin/bash

set -e

THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

function try-load-dotenv {
    if [ ! -f "$THIS_DIR/.env" ]; then
        echo "no .env file found"
        return 1
    fi

    while read -r line; do
        export "$line"
    done < <(grep -v '^#' "$THIS_DIR/.env" | grep -v '^$')
}

function clean {
    rm -rf dist build coverage.xml test-reports
    find . \
      -type d \
      \( \
        -name "*cache*" \
        -o -name "*.dist-info" \
        -o -name "*.egg-info" \
        -o -name "*htmlcov" \
      \) \
      -not -path "*env/*" \
      -exec rm -r {} + || true

    find . \
      -type f \
      -name "*.pyc" \
      -not -path "*env/*" \
      -exec rm {} +
}

function install {
    python -m pip install --upgrade pip
    python -m pip install --editable "$THIS_DIR/[dev]"
}

function install_pre_commit {
    python -m pip install pre-commit
}

function build {
    python -m build --sdist --wheel "$THIS_DIR/"
}

function publish:test {
    try-load-dotenv || true
    twine upload dist/* \
        --repository testpypi \
        --username=__token__ \
        --password="$TEST_PYPI_TOKEN"
}

function publish:prod {
    try-load-dotenv || true
    twine upload dist/* \
        --repository pypi \
        --username=__token__ \
        --password="$PROD_PYPI_TOKEN"
}

# run linting, formatting, and other static code quality tools
function lint {
    pre-commit run --all-files
}

# run linting, formatting, and other static code quality tools
function lint:ci {
    SKIP=no-commit-to-branch pre-commit run --all-files
}

function release:test {
    lint
    clean
    build
    publish:test
}

function release:prod {
    release:test
    publish:prod
}

function test:source-quick-with-coverage {
    python -m pytest -m 'not slow' "$THIS_DIR/tests/" \
    --cov "$THIS_DIR/mypackage/" \
    --cov-report html \
    --cov-report term \
    --cov-fail-under 10
}

function test:source-all {
    python -m pytest "$THIS_DIR/tests/"
}

#example /bin/bash run.sh test tests/test_slow.py::test__slow_add__successful
function test:source-with-coverage {
    python -m pytest "${@:-$THIS_DIR/tests/}" \
    --cov "$THIS_DIR/mypackage/" \
    --cov-report term \
    --cov-fail-under 20
}

function test:quick-source-with-reports {
    PYTEST_EXIT_STATUS=0
    rm -rf test-reports
    mkdir test-reports
    python -m pytest -m 'not slow' "$THIS_DIR/tests/" \
        --cov "$THIS_DIR/mypackage/" \
        --cov-report html \
        --cov-report term \
        --cov-report xml \
        --junit-xml "$THIS_DIR/test-reports/report.xml" \
        --cov-fail-under 20 || ((PYTEST_EXIT_STATUS+=$?))
    mv coverage.xml "$THIS_DIR/test-reports/"
    mv htmlcov "$THIS_DIR/test-reports/"
    return $PYTEST_EXIT_STATUS
}


function test:wheel-locally {
    source deactivate || true
    rm -rf test-env || true
    python -m venv test-env
    source ./test-env/bin/activate
    clean
    pip install build
    build
    PYTEST_EXIT_STATUS=0
    pip install ./dist/*.whl pytest pytest-cov
    rm -rf test-reports
    mkdir test-reports
    INSTALLED_PKG_DIR="$(python -c 'import mypackage; print(mypackage.__path__[0])')"
    python -m pytest -m 'not slow' "$THIS_DIR/tests/" \
        --cov "$INSTALLED_PKG_DIR" \
        --cov-report html \
        --cov-report term \
        --cov-report xml \
        --junit-xml "$THIS_DIR/test-reports/report.xml" \
        --cov-fail-under 20 || ((PYTEST_EXIT_STATUS+=$?))
    mv coverage.xml "$THIS_DIR/test-reports/"
    mv htmlcov "$THIS_DIR/test-reports/"
    deactivate
    return $PYTEST_EXIT_STATUS
}

function start {
    build # Call task dependency
    python -m SimpleHTTPServer 9000
}

function serve-coverage-report {
    python -m http.server -d "$THIS_DIR/htmlcov/"
}


function default {
    # Default task to execute
    start
}

function help {
    echo "$0 <task> <args>"
    echo "Tasks:"
    compgen -A function | cat -n
}

TIMEFORMAT="Task completed in %3lR"
time ${@:-help}
