# Smorth

A very minimal stack based (post fix) programming language written in x86 64-bit assembly
for Linux.

The program consists of a REPL which will read a line of user input and then
interpret it. The input is split into "words", each word is then handled accordingly.

The simplest type of word is an integer, which will simply be pushed onto a stack during
interpretation. The operator word `+` will pop two operands (integers) from the stack, add them
together and push the result back onto the stack. The value on top of the stack can be consumed
and printed out using the `.` operator.

Example invocations:
```
>> 13 5 + .
18
>> 1 2 + 3 + .
6
>> 20
>> 15
>> + .
35
```

## Building

**Requirements:** [NASM](https://www.nasm.us/).

The included `build.sh` script can be used to easily compile the project as follows:
```
$ chmod +x ./build.sh
$ ./build.sh
```
The resulting `smorth` binary can then be executed!

You can also use `./build.sh run` to compile and run the program in one go.

## License

Licensed under the [MIT License](./LICENSE).
