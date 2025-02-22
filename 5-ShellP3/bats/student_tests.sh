#!/usr/bin/env bats

# File: student_tests.sh
# 
# Create your unit tests suit in this file

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
 
    expected_output="0dsh3>Filedoesnotexistdsh3>dsh3>cmdloopreturned0"
 
    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]

    [ "$status" -eq 0 ]
}
@test "Piping into external file that lacks permission" {
    current=$(pwd)
    cd /tmp
    touch test.sh
    chmod -x test.sh

    run "${current}/dsh" <<EOF
ls | ./test.sh 
EOF
rm test.sh
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
echo "1 2 3 4 5" | grep 1 | grep 1 | grep 1 | grep 1 | grep 1 | grep 1 | grep 1 | wc -l | grep 1
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
    cd /tmp

    run "${current}/dsh" <<EOF
echo "1 2 3" > out.txt
cat out.txt
EOF
rm out.txt

    stripped_output=$(echo "$output" | tr -d '[:space:]')
 
    expected_output="dsh3>123dsh3>dsh3>dsh3>dsh3>dsh3>cmdloopreturned0"
 
    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]

    [ "$status" -eq 0 ]
}
@test "Test redirection input works" {
    current=$(pwd)
    cd /tmp
    echo "1 2 3" > out.txt 

    run "${current}/dsh" <<EOF
wc -l <  out.txt
EOF
rm out.txt

    stripped_output=$(echo "$output" | tr -d '[:space:]')
    expected_output="1dsh3>dsh3>dsh3>cmdloopreturned0"
 
    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]

    [ "$status" -eq 0 ]
}
# Piping with spaces
# Piping bad commands
# Max length
# rc checking
# Permissions
# Extra whitespace
# Amount of pipes
# Max pipes works
# Spaces and then pipe (empty command before pipe)
# Piping with built in commands
# Empty commands
# Check for file descriptor leaks (Lots of piping)
#
#
#
# Redirection (maybe)
