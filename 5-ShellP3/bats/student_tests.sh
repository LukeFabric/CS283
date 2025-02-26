#!/usr/bin/env bats

# File: student_tests.sh
# 
# Create your unit tests suit in this file
setup() {
    mkdir -p /tmp/dsh-test
}

teardown() {
    rm -rf /tmp/dsh-test
}

@test "Example: check ls runs without errors" {
    run ./dsh <<EOF                
ls
EOF

    # Assertions
    [ "$status" -eq 0 ]
}
@test "Piping works with extra whitespace" {
    run ./dsh <<EOF
      ls        |         grep ".c"        
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')
 
    expected_output="dragon.cdsh_cli.cdshlib.cdsh3>dsh3>dsh3>cmdloopreturned0"
 
    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]

    [ "$status" -eq 0 ]
}

@test "Piping bad command gives correct error" {
    run ./dsh <<EOF
sl | wc -l
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')
 
    expected_output="dsh3>Filedoesnotexistdsh3>dsh3>cmdloopreturned00"
 
    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]

    [ "$status" -eq 0 ]
}
@test "Piping into external file that lacks permission" {
    current=$(pwd)
    cd /tmp/dsh-test
    touch test.sh
    chmod -x test.sh

    run "${current}/dsh" <<EOF
ls | ./test.sh 
EOF
    stripped_output=$(echo "$output" | tr -d '[:space:]')
 
    expected_output="dsh3>dsh3>Executepermissionforfileisdenieddsh3>dsh3>cmdloopreturned0"
 
    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]

    [ "$status" -eq 0 ]
}
@test "Max pipes" {
    run ./dsh <<EOF
echo "1 2 3 4 5" | grep 1  | grep 1 | grep 1 | grep 1 | grep 1 | grep 1 | wc -l
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')
 
    expected_output="1dsh3>dsh3>dsh3>cmdloopreturned0"
 
    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]

    [ "$status" -eq 0 ]
}
@test "Too many pipes doesn't work" {
    run ./dsh <<EOF
echo "1 2 3 4 5" | grep 1 | grep 1 | grep 1 | grep 1 | grep 1 | grep 1 | grep 1 | wc -l | grep 1 | error
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')
 
    expected_output="dsh3>error:pipinglimitedto8commandsdsh3>cmdloopreturned0"
 
    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]

    [ "$status" -eq 0 ]
}
@test "Piping works with built-in commands" {
    run ./dsh <<EOF
dragon | wc -l
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')
 
    expected_output="38dsh3>dsh3>dsh3>cmdloopreturned0"
 
    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]

    [ "$status" -eq 0 ]
}
@test "Verify lack of file descriptor leaks" {
    run ./dsh <<EOF
echo "1 2 3 4 5" | grep 1 | grep 1 | grep 1 | grep 1 | grep 1 | grep 1 | wc -l
echo "1 2 3 4 5" | grep 1 | grep 1 | grep 1 | grep 1 | grep 1 | grep 1 | wc -l
echo "1 2 3 4 5" | grep 1 | grep 1 | grep 1 | grep 1 | grep 1 | grep 1 | wc -l
echo "1 2 3 4 5" | grep 1 | grep 1 | grep 1 | grep 1 | grep 1 | grep 1 | wc -l
echo "1 2 3 4 5" | grep 1 | grep 1 | grep 1 | grep 1 | grep 1 | grep 1 | wc -l
echo "1 2 3 4 5" | grep 1 | grep 1 | grep 1 | grep 1 | grep 1 | grep 1 | wc -l
echo "1 2 3 4 5" | grep 1 | grep 1 | grep 1 | grep 1 | grep 1 | grep 1 | wc -l
echo "1 2 3 4 5" | grep 1 | grep 1 | grep 1 | grep 1 | grep 1 | grep 1 | wc -l
echo "1 2 3 4 5" | grep 1 | grep 1 | grep 1 | grep 1 | grep 1 | grep 1 | wc -l
echo "1 2 3 4 5" | grep 1 | grep 1 | grep 1 | grep 1 | grep 1 | grep 1 | wc -l
echo "1 2 3 4 5" | grep 1 | grep 1 | grep 1 | grep 1 | grep 1 | grep 1 | wc -l
echo "1 2 3 4 5" | grep 1 | grep 1 | grep 1 | grep 1 | grep 1 | grep 1 | wc -l
echo "1 2 3 4 5" | grep 1 | grep 1 | grep 1 | grep 1 | grep 1 | grep 1 | wc -l
echo "1 2 3 4 5" | grep 1 | grep 1 | grep 1 | grep 1 | grep 1 | grep 1 | wc -l
echo "1 2 3 4 5" | grep 1 | grep 1 | grep 1 | grep 1 | grep 1 | grep 1 | wc -l
echo "1 2 3 4 5" | grep 1 | grep 1 | grep 1 | grep 1 | grep 1 | grep 1 | wc -l
echo "1 2 3 4 5" | grep 1 | grep 1 | grep 1 | grep 1 | grep 1 | grep 1 | wc -l
echo "1 2 3 4 5" | grep 1 | grep 1 | grep 1 | grep 1 | grep 1 | grep 1 | wc -l
echo "1 2 3 4 5" | grep 1 | grep 1 | grep 1 | grep 1 | grep 1 | grep 1 | wc -l
echo "1 2 3 4 5" | grep 1 | grep 1 | grep 1 | grep 1 | grep 1 | grep 1 | wc -l
echo "1 2 3 4 5" | grep 1 | grep 1 | grep 1 | grep 1 | grep 1 | grep 1 | wc -l
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')
 
    expected_output="1dsh3>1dsh3>dsh3>1dsh3>dsh3>dsh3>1dsh3>dsh3>dsh3>dsh3>1dsh3>dsh3>dsh3>dsh3>dsh3>1dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>1dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>1dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>1dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>1dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>1dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>1dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>1dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>1dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>1dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>1dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>1dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>1dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>1dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>1dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>1dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>dsh3>cmdloopreturned0"
 
    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]

    [ "$status" -eq 0 ]
}
@test "Empty command after pipe results in error" {
    run ./dsh <<EOF
ls |     
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')
 
    expected_output="dsh3>warning:nocommandsprovideddsh3>cmdloopreturned0"
 
    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]

    [ "$status" -eq 0 ]
}
@test "Empty command before pipe results in error" {
    run ./dsh <<EOF
     | ls
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')
 
    expected_output="dsh3>warning:nocommandsprovideddsh3>cmdloopreturned0"
 
    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]

    [ "$status" -eq 0 ]
}
@test "Empty command between pipes results in error" {
    run ./dsh <<EOF
ls |    | grep .c
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')
 
    expected_output="dsh3>warning:nocommandsprovideddsh3>cmdloopreturned0"
 
    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]

    [ "$status" -eq 0 ]
}
@test "Test redirection output works" {
    current=$(pwd)
    cd /tmp/dsh-test

    run "${current}/dsh" <<EOF
echo "1 2 3" > out1.txt
cat out1.txt
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')
 
    expected_output="dsh3>123dsh3>dsh3>dsh3>cmdloopreturned0"
 
    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]

    [ "$status" -eq 0 ]
}
@test "Test redirection input works" {
    current=$(pwd)
    cd /tmp/dsh-test
    echo "1 2 3" > out2.txt

    run "${current}/dsh" <<EOF
wc -l < out2.txt
EOF
    stripped_output=$(echo "$output" | tr -d '[:space:]')
    expected_output="1dsh3>dsh3>dsh3>cmdloopreturned0"
 
    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]

    [ "$status" -eq 0 ]
}
@test "rc initially returns 0" {
    run "./dsh" <<EOF
rc
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="dsh3>0dsh3>cmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]

    [ "$status" -eq 0 ]
}
@test "rc is -2 if there are too many pipes" {
    run "./dsh" <<EOF
cd | asdf | asdf | asdf | asdf | asdf | sadf | asdf | asqw | asdf
rc
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="dsh3>error:pipinglimitedto8commandsdsh3>-2dsh3>cmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]

    [ "$status" -eq 0 ]
}
@test "rc is -1 for empty commands" {
    run "./dsh" <<EOF

rc
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="dsh3>warning:nocommandsprovideddsh3>-1dsh3>cmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]

    [ "$status" -eq 0 ]
}
@test "rc -3 if command is too long" {
    run "./dsh" <<EOF
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
rc
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="dsh3>Totalcommandlengthtoolongdsh3>-3dsh3>cmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]

    [ "$status" -eq 0 ]
}
@test "rc -3 if argument is too long" {
    run "./dsh" <<EOF
echo aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
rc
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="dsh3>Totalcommandlengthtoolongdsh3>-3dsh3>cmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]

    [ "$status" -eq 0 ]
}
@test "rc -6 if executable does not exist" {
    run "./dsh" <<EOF
ehco 1 2 3
rc
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="dsh3>dsh3>Filedoesnotexistdsh3>-6dsh3>cmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]

    [ "$status" -eq 0 ]
}

@test "rc -4 if not filename given to redirect into" {
    run "./dsh" <<EOF
echo 1 2 3 >
rc
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="dsh3>SyntaxErrorincommanddsh3>-4dsh3>cmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]

    [ "$status" -eq 0 ]
}
@test "Correct message from trying to read in non existant file" {
    run "./dsh" <<EOF
wc -l < awehghgafahksdhvmfbawrirryabwebrbsfebrfigasioipohbj.txt
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="dsh3>dsh3>Filedoesnotexistdsh3>dsh3>cmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]

    [ "$status" -eq 0 ]
}
@test "Handle redirection character inside of quotes" {
    run "./dsh" <<EOF
echo "1 > out"
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="1>outdsh3>dsh3>cmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]

    [ "$status" -eq 0 ]
}
@test "Arguments after filename for redirection are processed" {
    current=$(pwd)
    cd /tmp/dsh-test

    run "${current}/dsh" <<EOF
echo "123" > out.txt
wc < out.txt -l
EOF
    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="dsh3>1dsh3>dsh3>dsh3>dsh3>dsh3>cmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]

    [ "$status" -eq 0 ]
}
@test "Multiple redirection attempts results in error" {
    run "./dsh" <<EOF
echo 123 > out.txt > test.txt
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="dsh3>SyntaxErrorincommanddsh3>cmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]

    [ "$status" -eq 0 ]
}
@test "Redirect out properly truncates existing file" {

    current=$(pwd)
    cd /tmp/dsh-test

    run "${current}/dsh" <<EOF
echo "123" > out.txt
cat out.txt
echo "456" > out.txt
cat out.txt
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="dsh3>123dsh3>dsh3>dsh3>456dsh3>dsh3>dsh3>dsh3>dsh3>cmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]

    [ "$status" -eq 0 ]
}
@test "Handle input and output redirection in one command" {
    current=$(pwd)
    cd /tmp/dsh-test

    run "${current}/dsh" <<EOF
echo "123" > out.txt
wc -l < out.txt > a.txt
cat a.txt
EOF
    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="dsh3>dsh3>dsh3>1dsh3>dsh3>dsh3>dsh3>cmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]

    [ "$status" -eq 0 ]
}
@test "Not putting a file for reading in and attempting to redirect out: " {
    run "./dsh" <<EOF
wc -l < > out.txt
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="dsh3>SyntaxErrorincommanddsh3>cmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]

    [ "$status" -eq 0 ]
}
@test "Output file lacks write permission" {

    current=$(pwd)
    cd /tmp/dsh-test
    echo "123" > out4.txt
    chmod 444 out4.txt
    run "${current}/dsh" <<EOF
echo "456" >> out4.txt
EOF
    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="dsh3>dsh3>Executepermissionforfileisdenieddsh3>dsh3>cmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]

    [ "$status" -eq 0 ]
}
@test "File redirection without command gives correct error" {
    run "./dsh" <<EOF
> output.txt
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="dsh3>Filedoesnotexistdsh3>dsh3>cmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]

    [ "$status" -eq 0 ]
}

