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


1. Make a new folder: `test_my_awesome_thing`
2. Write a test program with the functionality you want to test: `my_awesome_thing.rb`
3. Write a bpftrace probe to execute againts it: `my_awesome_thing.bt`
4. Capture the expected output on a successful run to make the fixture, stored in `my_awesome_thing.out`
5. Write a test file that automates this using the `CommandRunner` helper to be the test `my_awesome_thing_test.rb`

Tests that are named appropriately should be automatically picked up by `bundle exec rake integration`.

# Tips

Each of of the methods is `CommandRunner` takes an optional argument for the amount of time to sleep.

This is a bit of a hack to avoid race conditions. If you can, you should ideally try and check in a blocking manner if the condition you would have expected has succeeded.

Often though, you just need to wait for a buffer to flush, or a system call to completed. Typically 1 second is more than enough, and anything more than 5 seconds should be highly discouraged as it will make the suite slower.
