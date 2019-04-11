# Running integration tests

Just use rake:

`bundle exec rake integration`

# Integration test anatomy

This is the structure of the integration test suite:

```
integration
├── integration_helper.rb
└── test_hello
    ├── hello.bt
    ├── hello.out
    ├── hello.rb
    └── hello_test.rb
```

Such that there is one test per subdirectory of the `integration` folder.

Each correspond to:

- `hello_test.rb`: A `_test.rb` file, the control logic for this test that will be executed by minitest.
- `hello.rb`     : A `.rb` file, which is a script that will be the target of our probe.
- `hello.bt`     : A `.bt` file, which is a bpf trace script containing our test probe.
- `hello.out`    : A text file, containing the expected output of running the probe script against the target file.

# Adding tests

We have a rake test that will create all the files needed for a new integration test.

`bundle exec rake 'new:integration[new_of_test]'`

# Tips

Each of of the methods is `CommandRunner` takes an optional argument for the amount of time to sleep.

This is a bit of a hack to avoid race conditions. If you can, you should ideally try and check in a blocking manner if the condition you would have expected has succeeded.

Often though, you just need to wait for a buffer to flush, or a system call to completed. Typically 1 second is more than enough, and anything more than 5 seconds should be highly discouraged as it will make the suite slower.

You may also want to force some synchrony between the tracer and the tracee using a signal, which is why i added the `usr2` helper. This can be used to induce the tracee to fire a probe at a predictable time.
