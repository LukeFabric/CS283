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
 
    expected_output="dragon.cdsh_cli.cdshlib.crsh_cli.crsh_server.clocalmodedsh4>localmodedsh4>dsh4>cmdloopreturned0"
 
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
 
    expected_output="localmodedsh4>Filedoesnotexistlocalmodedsh4>dsh4>cmdloopreturned01"
 
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
 
    expected_output="localmodedsh4>localmodedsh4>Executepermissionforfileisdeniedlocalmodedsh4>dsh4>cmdloopreturned0"
 
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
 
    expected_output="1localmodedsh4>localmodedsh4>dsh4>cmdloopreturned0"
 
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
 
    expected_output="localmodedsh4>error:pipinglimitedto8commandsdsh4>cmdloopreturned0"
 
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
 
    expected_output="39localmodedsh4>localmodedsh4>dsh4>cmdloopreturned0"
 
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
 
    expected_output="1localmodedsh4>1localmodedsh4>dsh4>1localmodedsh4>dsh4>dsh4>1localmodedsh4>dsh4>dsh4>dsh4>1localmodedsh4>dsh4>dsh4>dsh4>dsh4>1localmodedsh4>dsh4>dsh4>dsh4>dsh4>dsh4>1localmodedsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>1localmodedsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>1localmodedsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>1localmodedsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>1localmodedsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>1localmodedsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>1localmodedsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>1localmodedsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>1localmodedsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>1localmodedsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>1localmodedsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>1localmodedsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>1localmodedsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>1localmodedsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>1localmodedsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>localmodedsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>dsh4>cmdloopreturned0"
 
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
 
    expected_output="localmodedsh4>warning:nocommandsprovideddsh4>cmdloopreturned0"
 
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
 
    expected_output="localmodedsh4>warning:nocommandsprovideddsh4>cmdloopreturned0"
 
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
 
    expected_output="localmodedsh4>warning:nocommandsprovideddsh4>cmdloopreturned0"
 
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
 
    expected_output="localmodedsh4>123localmodedsh4>dsh4>dsh4>cmdloopreturned0"
 
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
    expected_output="1localmodedsh4>localmodedsh4>dsh4>cmdloopreturned0"
 
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

    expected_output="localmodedsh4>0dsh4>cmdloopreturned0"

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

    expected_output="localmodedsh4>error:pipinglimitedto8commandsdsh4>-2dsh4>cmdloopreturned0"

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

    expected_output="localmodedsh4>warning:nocommandsprovideddsh4>-1dsh4>cmdloopreturned0"

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

    expected_output="localmodedsh4>Totalcommandlengthtoolongdsh4>-3dsh4>cmdloopreturned0"

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

    expected_output="localmodedsh4>Totalcommandlengthtoolongdsh4>-3dsh4>cmdloopreturned0"

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

    expected_output="localmodedsh4>localmodedsh4>Filedoesnotexistdsh4>-6dsh4>cmdloopreturned0"

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

    expected_output="localmodedsh4>SyntaxErrorincommanddsh4>-4dsh4>cmdloopreturned0"

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

    expected_output="localmodedsh4>localmodedsh4>Filedoesnotexistlocalmodedsh4>dsh4>cmdloopreturned0"

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

    expected_output="1>outlocalmodedsh4>dsh4>cmdloopreturned0"

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

    expected_output="localmodedsh4>1localmodedsh4>dsh4>localmodedsh4>dsh4>dsh4>cmdloopreturned0"

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

    expected_output="localmodedsh4>SyntaxErrorincommanddsh4>cmdloopreturned0"

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

    expected_output="localmodedsh4>123localmodedsh4>dsh4>dsh4>456localmodedsh4>dsh4>dsh4>dsh4>dsh4>cmdloopreturned0"

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

    expected_output="localmodedsh4>localmodedsh4>dsh4>1localmodedsh4>dsh4>dsh4>dsh4>cmdloopreturned0"

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

    expected_output="localmodedsh4>SyntaxErrorincommanddsh4>cmdloopreturned0"

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

    expected_output="localmodedsh4>localmodedsh4>Executepermissionforfileisdeniedlocalmodedsh4>dsh4>cmdloopreturned0"

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

    expected_output="localmodedsh4>Filedoesnotexistlocalmodedsh4>dsh4>cmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]

    [ "$status" -eq 0 ]
}
@test "Piping works with extra whitespace server" {
    ./dsh -s &
    run ./dsh -c <<EOF
      ls        |         grep ".c"
stop-server
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="socketclientmode:addr:127.0.0.1:1234dsh4>dragon.cdsh_cli.cdshlib.crsh_cli.crsh_server.cdsh4>serverappearedtoterminate-exitingcmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]

    [ "$status" -eq 0 ]
}
@test "Piping bad command gives correct error server" {
    ./dsh -s &
    run ./dsh -c <<EOF
echo 123 | sl
stop-server
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')
 
    expected_output="socketclientmode:addr:127.0.0.1:1234dsh4>socketservermode:addr:0.0.0.0:1234->Single-ThreadedModeFiledoesnotexistdsh4>serverappearedtoterminate-exitingcmdloopreturned0"
 
    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]

    [ "$status" -eq 0 ]
}
@test "Piping into external file that lacks permission server" {
    current=$(pwd)
    cd /tmp/dsh-test
    touch test.sh
    chmod -x test.sh
    "${current}/dsh" -s &
    run "${current}/dsh" <<EOF
ls | ./test.sh 
stop-server
EOF
    stripped_output=$(echo "$output" | tr -d '[:space:]')
 
    expected_output="localmodedsh4>localmodedsh4>Executepermissionforfileisdeniedlocalmodedsh4>dsh4>dsh4>cmdloopreturned0"
 
    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]

    [ "$status" -eq 0 ]
}
@test "Max pipes server" {
    ./dsh -s &
    run ./dsh -c <<EOF
echo "1 2 3 4 5" | grep 1  | grep 1 | grep 1 | grep 1 | grep 1 | grep 1 | wc -l
stop-server
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')
 
    expected_output="socketclientmode:addr:127.0.0.1:1234dsh4>1dsh4>serverappearedtoterminate-exitingcmdloopreturned0"
 
    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]

    [ "$status" -eq 0 ]
}
@test "Too many pipes doesn't work server" {
    ./dsh -s &
    run ./dsh -c <<EOF
echo "1 2 3 4 5" | grep 1 | grep 1 | grep 1 | grep 1 | grep 1 | grep 1 | grep 1 | wc -l | grep 1 | error
stop-server
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')
 
    expected_output="socketclientmode:addr:127.0.0.1:1234dsh4>Error:pipinglimitedto8commandsdsh4>serverappearedtoterminate-exitingcmdloopreturned0"
 
    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]

    [ "$status" -eq 0 ]
}
@test "Piping works with built-in commands server" {
    ./dsh -s &
    run ./dsh -c <<EOF
dragon | wc -l
stop-server
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')
 
    expected_output="socketclientmode:addr:127.0.0.1:1234dsh4>40dsh4>serverappearedtoterminate-exitingcmdloopreturned0"
 
    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]

    [ "$status" -eq 0 ]
}
@test "Empty command after pipe results in error server" {
    ./dsh -s &
    run ./dsh -c <<EOF
ls |    
stop-server
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')
 
    expected_output="socketclientmode:addr:127.0.0.1:1234dsh4>warning:nocommandsprovideddsh4>serverappearedtoterminate-exitingcmdloopreturned0"
 
    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]

    [ "$status" -eq 0 ]
}
@test "Empty command before pipe results in error server" {
    ./dsh -s &
    run ./dsh -c <<EOF
     | ls
stop-server
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')
 
    expected_output="socketclientmode:addr:127.0.0.1:1234dsh4>warning:nocommandsprovideddsh4>serverappearedtoterminate-exitingcmdloopreturned0"
 
    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]

    [ "$status" -eq 0 ]
}
@test "Empty command between pipes results in error server" {
    ./dsh -s &
    run ./dsh -c <<EOF
ls |    | grep .c
stop-server
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')
 
    expected_output="socketclientmode:addr:127.0.0.1:1234dsh4>warning:nocommandsprovideddsh4>serverappearedtoterminate-exitingcmdloopreturned0"
 
    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]

    [ "$status" -eq 0 ]
}
@test "rc initially returns 0 server" {
    ./dsh -s &
    run ./dsh -c <<EOF
rc
stop-server
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="socketclientmode:addr:127.0.0.1:1234dsh4>socketservermode:addr:0.0.0.0:1234->Single-ThreadedMode0dsh4>serverappearedtoterminate-exitingcmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]

    [ "$status" -eq 0 ]
}
@test "rc is -2 if there are too many pipes server" {
    ./dsh -s &
    run ./dsh -c <<EOF
cd | asdf | asdf | asdf | asdf | asdf | sadf | asdf | asqw | asdf
rc
stop-server
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="socketclientmode:addr:127.0.0.1:1234dsh4>Error:pipinglimitedto8commandsdsh4>socketservermode:addr:0.0.0.0:1234->Single-ThreadedMode-2dsh4>serverappearedtoterminate-exitingcmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]

    [ "$status" -eq 0 ]
}
@test "rc is -1 for empty commands server" {
    ./dsh -s &
    run ./dsh -c <<EOF
ls

rc
stop-server
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="socketclientmode:addr:127.0.0.1:1234dsh4>batsdragon.cdshdsh_cli.cdshlib.cdshlib.hmakefileoutput.txtrsh_cli.crshlib.hrsh_server.cdsh4>warning:nocommandsprovideddsh4>socketservermode:addr:0.0.0.0:1234->Single-ThreadedMode-1dsh4>serverappearedtoterminate-exitingcmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]

    [ "$status" -eq 0 ]
}
@test "rc -3 if command is too long server" {
    ./dsh -s &
    run ./dsh -c <<EOF
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
rc
stop-server
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="socketclientmode:addr:127.0.0.1:1234dsh4>Totalcommandlengthtoolongdsh4>socketservermode:addr:0.0.0.0:1234->Single-ThreadedMode-3dsh4>serverappearedtoterminate-exitingcmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]

    [ "$status" -eq 0 ]
}
@test "rc -3 if argument is too long server" {
    ./dsh -s &
    run ./dsh -c <<EOF
echo aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
rc
stop-server
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="socketclientmode:addr:127.0.0.1:1234dsh4>Totalcommandlengthtoolongdsh4>socketservermode:addr:0.0.0.0:1234->Single-ThreadedMode-3dsh4>serverappearedtoterminate-exitingcmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]

    [ "$status" -eq 0 ]
}
@test "rc -6 if executable does not exist server" {
    ./dsh -s &
    run ./dsh -c <<EOF
ehco 1 2 3
rc
stop-server
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="socketclientmode:addr:127.0.0.1:1234dsh4>socketservermode:addr:0.0.0.0:1234->Single-ThreadedModedsh4>Filedoesnotexistdsh4>serverappearedtoterminate-exitingcmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]

    [ "$status" -eq 0 ]
}
