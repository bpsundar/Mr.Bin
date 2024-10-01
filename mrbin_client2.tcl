#!/usr/bin/env tclsh

# Function to simulate a client connecting to the server and staying connected
proc mock_client {server_ip server_port message} {
    # Connect to the server
    set sock [socket $server_ip $server_port]
    
    # Send the initial message to the server
    puts $sock "$message"
    
    # Flush the socket to ensure the message is sent
    flush $sock
    
    # Set the socket to non-blocking mode and line buffering
    fconfigure $sock -blocking 0 -buffering line
    
    # Set up a file event to read incoming messages from the server
    fileevent $sock readable [list receive_message $sock]
    
    puts "Connected to server at $server_ip:$server_port"
    puts "Waiting for messages from the server..."

    # Keep the application running
    vwait forever
}

# Function to receive messages from the server
proc receive_message {sock} {
    if {[eof $sock]} {
        puts "Server closed the connection"
        close $sock
        set ::forever 0  ;# Exit the vwait loop
        exit
    } else {
        # Read incoming data
        set response [gets $sock]
        if {[string length $response] > 0} {
            puts "Received from server: $response"
        }
    }
}

# Server IP and port
set server_ip "127.0.0.1"
set server_port 9191

# Message to send to the server
set message "Hello from the mock client!"

# Call the mock client function
mock_client $server_ip $server_port $message
