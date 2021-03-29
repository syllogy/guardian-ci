# Source: https://github.com/CircleCI-Public/Orb-Project-Template/blob/master/src/tests/greet.bats

# Runs prior to every test

setup() {
    source ./src/scripts/ginkgo.sh
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

@test '1: Ginkgo runs tests when go or sql files change' {
    echo 'const One = 1' >> ~/test_repo/main.go
    (cd ~/test_repo && git add . && git commit -m "added const") > /dev/null
    (cd ~/test_repo && run_unit_tests) | grep 'Running Suite'
}

@test '2: Ginkgo is not run when only tf has changed' {
    echo 'const One = 1' >> ~/test_repo/example.tf
    (cd ~/test_repo && git add . && git commit -m "only changed tf") >/dev/null
    (cd ~/test_repo && run_unit_tests) > test.log

    [ -z "$(grep 'Running Suite' test.log)" ]
}
