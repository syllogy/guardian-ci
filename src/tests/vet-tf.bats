setup() {
    source ./src/scripts/vet-tf.sh
    cp -rf ./src/tests/tf_repo /tmp/tf_repo
    mkdir /tmp/tf_modules
    echo '12' > /tmp/tf_modules/VERSION
    export TERRAFORM="echo terraform"
    export TF_MODULE_DIR=/tmp/tf_modules
}

teardown()  {
    rm -rf /tmp/tf_repo
    rm -rf /tmp/tf_modules
    rm -f /tmp/testlog
}

@test 'vet-tf passes when no modules are present' {
  rm /tmp/tf_repo/uses_module.tf
  (cd /tmp/tf_repo && vet_terraform)
}

@test 'vet-tf passes when modules are up to date' {
  echo '0.1.0' > /tmp/tf_modules/VERSION
  (cd /tmp/tf_repo && vet_terraform)
}

@test 'vet-tf fails when modules are not up to date' {
  ! (cd /tmp/tf_repo && vet_terraform > /tmp/testlog)
   grep 'terraform modules can be upgraded' /tmp/testlog
}

@test 'vet-tf fails when terraform is not formatted' {
  export TERRAFORM="false"

  ! (cd /tmp/tf_repo && vet_terraform > /tmp/testlog)
   grep 'not formatted correctly' /tmp/testlog
}
