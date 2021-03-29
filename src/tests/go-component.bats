setup() {
    source ./src/scripts/go-component.sh
    # Stub out ginkgo
    export GINKGO="echo Running Suite"
    cp -rf ./src/tests/repo ~/test_repo
    (cd ~/test_repo \
      && git init \
      && git config user.name "BATS tester" \
      && git config user.email "BATS@unit.test" \
      && git add . \
      && git commit -m "initial commit") > /dev/null
}

teardown()  {
    rm -rf ~/test_repo
    rm -f test.log
}

@test '1: Component Tests are run when go files change' {
    echo 'const One = 1' >> ~/test_repo/main.go
    (cd ~/test_repo && git add . && git commit -m "changed go") > /dev/null
    (cd ~/test_repo && run_component_tests) | grep 'Running Suite'
}

@test '2: Component Tests are run when sql files change' {
    echo 'const One = 1' >> ~/test_repo/main.sql
    (cd ~/test_repo && git add . && git commit -m "changed sql") > /dev/null
    (cd ~/test_repo && run_component_tests) | grep 'Running Suite'
}

@test '3: Component Tests are run when go.mod changes' {
    echo 'const One = 1' >> ~/test_repo/go.mod
    (cd ~/test_repo && git add . && git commit -m "changed go.mod") > /dev/null
    (cd ~/test_repo && run_component_tests) | grep 'Running Suite'
}

@test '4: Component Tests are not run when only tf has changed' {
    echo 'const One = 1' >> ~/test_repo/example.tf
    (cd ~/test_repo && git add . && git commit -m "only changed tf") >/dev/null
    (cd ~/test_repo && run_component_tests) > test.log

    [ -z "$(grep 'Running Suite' test.log)" ]
}

@test '5: Component Tests are not run when only markdown has changed' {
    echo 'const One = 1' >> ~/test_repo/example.md
    (cd ~/test_repo && git add . && git commit -m "only changed md") >/dev/null
    (cd ~/test_repo && run_component_tests) > test.log

    [ -z "$(grep 'Running Suite' test.log)" ]
}
