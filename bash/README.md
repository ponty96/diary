# Bash Scripts
Hi there, so this is a repository of funky bash script I use to either automate
stuff or make my life easier.

## Bash Cheat Sheet

## Bash: DiD yOu KnOw?
A list of neat things I'm uncovering as I transition from hacking bash to
properly learning shell scripting.

### Piping
Piping in Bash is basically passing the standard output(stdout) of one process
as the standard input(stdin) of another process. A few things to know:

* Commands in Bash receive their stdin from the processes that start them:
```sh
$ date | cat > file_one.txt
```
The `cat` command gets it stdin, its first argument, from the bash shell, and in
this case we pipe "date" into `cat`.

More on [Piping here.](https://www.baeldung.com/linux/pipe-output-to-function#:~:text=A%20pipe%20in%20Bash%20takes,in%20at%20the%20command%20line.&text=Guiding%20principle%20%231%3A%20Commands%20executed,the%20process%20that%20starts%20them.)

### SubShells

Parallelism and variable scope control is achieved in Bash using subshells. A
subshell is a separate instance of a the command processor with its own variable
scope. Each shell script running is, in effect, a subprocess (child process) of
its parent shell.

Subshells generally capture variables from its originating process(parent), but
cannot update their state outside the subshell.

```sh
#!/bin/bash
# subshell.sh

# declared variable
global_variable=1
(
# Inside parentheses, and therefore a subshell . . .
while [ 1 ]   # Endless loop.
do
  inner_variable=5
  another_variable=$global_variable+$inner_variable

  # $another_variable == 6
  global_variable = $global_variable+3

  # $global_variable == 4
done
)
# End of subshell

# Outside here $global_variable remains 1
```

#### Piping
Piping is bash's concept for passing data across processes - "subshells". Bash
accomplishes this by passing the standard out(stdout) of a (completed) process
to the standard-in(stdin) of the "piped into" process.

```sh
$ date | cat > file_one.txt
```

`date` command runs in the "main" shell process, its functions result(stdout),
is piped `|` into (stdin) `cat` as its first argument. Finally, a file
descriptor redirection of the content `>` into `file_one.txt`.


### Arithmetic Ops
While working on the `./release_memory.sh` script, I encountered a nit problem
which is explained in depth in [sub-shell](#subshells):

```s
current_index=0

loop once
  pid_i=$current_index+1
  # pid_i == 1, but current_index ==1

  cpu_i=$current_index+2
  # cpu_i == 3, but current_index == 3

  current_index=$current_index+4
  # current_index becomes 7

end loop
# current_index remains 7
```

At a glance, at the first run, we expect the value of `pid_i` and `cpu_i` during
the loop to be `1` and `2` respectively, and the value of `current_index` would
be `4` at the end of the run, updating the global value of `current_index` to
`4`.

However, the arithmetic operations mutates the global value of `current_index`
to `7`.

```s
current_index=0

loop once
  pid_i=$((current_index+1))
  # pid_i == 1, but current_index == 0

  cpu_i=$((current_index+2))
  # cpu_i == 2, but current_index == 0

  ((current_index=current_index+4))
  # current_index becomes 4

end loop
# current_index remains 4
```
#### Why?
`result = $((arithmetic operation))` is called a assignment "shell arithmetic
expansion" or "arithmetic expression". My understanding is that this tells Bash
to evaluate the content of command ``(())`, but `$` assigns the result of the
expression to `result` without mutating the variables within the expression.

Kinda, like a closure that captures value from the global scope without mutating
it.

However, `((arithmetic operation))`, known as a command or arithmetic statement,
captures and mutates the value. Therefore, `((current_index=current_index+4))`
mutates the "global" `current_index` value.


