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

@test "Max args works" {
    run "./dsh" <<EOF
echo 1 2 3 4 5 6 7 8
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="12345678dsh2>dsh2>cmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]

    [ "$status" -eq 0 ]
}
@test "cd too many args" {
    run "./dsh" <<EOF
cd / -f
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="dsh2>cd():Toomanyargumentsdsh2>cmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]

    [ "$status" -eq 0 ]
}
@test "leading whitespace before command" {
    run "./dsh" <<EOF
        echo 1 2 3 4 5 6 7
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="1234567dsh2>dsh2>cmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]

    [ "$status" -eq 0 ]
}
@test "Max length command" {
    echo '#!/bin/bash' > reallyreallyreallyreallyreallyreallyreallyrealllongfilename.sh
    echo 'echo "$1"' >> reallyreallyreallyreallyreallyreallyreallyrealllongfilename.sh
    chmod +x reallyreallyreallyreallyreallyreallyreallyrealllongfilename.sh
    run "./dsh" <<EOF
./reallyreallyreallyreallyreallyreallyreallyrealllongfilename.sh aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
EOF
rm reallyreallyreallyreallyreallyreallyreallyrealllongfilename.sh
    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaadsh2>dsh2>cmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]

    [ "$status" -eq 0 ]
}
@test "Max length arg with extra whitespace works" {
    run "./dsh" <<EOF
    echo aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa              
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaadsh2>dsh2>cmdloopreturned0"
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

    expected_output="dsh2>0dsh2>cmdloopreturned0"

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

    expected_output="dsh2>error:pipinglimitedto8commandsdsh2>-2dsh2>cmdloopreturned0"

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

    expected_output="dsh2>warning:nocommandsprovideddsh2>-1dsh2>cmdloopreturned0"

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

    expected_output="dsh2>Totalcommandlengthtoolongdsh2>-3dsh2>cmdloopreturned0"

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

    expected_output="dsh2>Totalcommandlengthtoolongdsh2>-3dsh2>cmdloopreturned0"

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

    expected_output="dsh2>dsh2>Filedoesnotexistdsh2>-6dsh2>cmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]

    [ "$status" -eq 0 ]
}
@test "Correct message for external file that lacks permission" {
    touch test.sh
    chmod -x test.sh
    run "./dsh" <<EOF
./test.sh
rc
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="dsh2>dsh2>Executepermissionforfileisdenieddsh2>-6dsh2>cmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]

    [ "$status" -eq 0 ]
}
@test "Valid external commands set rc to 0" {
    run "./dsh" <<EOF
echo 1 2 3 4 5 6 7
rc
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="1234567dsh2>dsh2>0dsh2>cmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]

    [ "$status" -eq 0 ]
}
@test "Extra whitespace in command valid" {
    run "./dsh" <<EOF
echo    1    2    3    4    5    6    7
EOF

    stripped_output=$(echo "$output" | tr -d '[:space:]')

    expected_output="1234567dsh2>dsh2>cmdloopreturned0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "Exit status: $status"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]

    [ "$status" -eq 0 ]
}

