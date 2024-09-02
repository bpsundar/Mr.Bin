#!/usr/bin/env tclsh

# Function to simulate a client connecting to the server
proc mock_client {server_ip server_port message} {
    # Connect to the server
    set sock [socket $server_ip $server_port]
    
    # Send the message to the server
    puts $sock "$message\n"
    
    # Flush the socket to ensure the message is sent
    flush $sock
    
    # Wait for the server's response
    set response [gets $sock]
    puts "Received from server: $response"
    
    # Close the connection
    close $sock
}

# Server IP and port
set server_ip "127.0.0.1"
set server_port 9191

# Message to send to the server
set message "Hello from the mock client!"

# Call the mock client function
mock_client $server_ip $server_port $message
